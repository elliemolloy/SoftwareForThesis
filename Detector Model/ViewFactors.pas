unit ViewFactors;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Dialogs,
	StdCtrls, Math, ComCtrls, LinearAlgebra, DetGlobal, Forms, Reflectance3D;

const
	N=15;
	MaxNGauLeg=1000;

type
	TBeamDataArray=array[1..MaxNGauLeg,1..MaxNGauLeg] of Extended;

function CalculateViewFactor(DetAngle,DetectorRadius,SourceRadius,LengthL:Extended;Pol:string):Extended;
function CalculateDistance(X1,X2,Y1,Y2:Extended):Extended;
function InterpolateBeamData(X,Y:Extended):Extended;
procedure GauLeg(X1,X2:Extended;N:Integer);
function GauLegY1(X:Extended):Extended;
function GauLegY2(X:Extended):Extended;
function GauLegZ1(X,Y:Extended):Extended;
function GauLegZ2(X,Y:Extended):Extended;
function GauLegW1(X,Y,Z:Extended):Extended;
function GauLegW2(X,Y,Z:Extended):Extended;
function Func(X,Y,Z,W:Extended):Extended;
procedure Quad4D(X1,X2:Extended; var SS:Extended);
procedure CalculateArea;
procedure CalculateSignal;


implementation

var
	GauLegX,GauLegW:array[1..MaxNGauLeg] of Extended;
	glx,gly,glz:Extended;
	R,A,B,L:Extended;
	SourceD,DetectorD,Delta,SinDelta,CosDelta:Extended;
	ii,jj:Integer;
	Beam:TBeamArray;
	Area,Signal:TBeamDataArray;

{.......................................................}

function CalculateDistance(X1,X2,Y1,Y2:Extended):Extended;
var
	dx,dy,dSqr,d:Extended;
begin
	dx:=X2-X1;
	dy:=Y2-Y1;
	dSqr:=Sqr(dx)+Sqr(dy);
	d:=Sqrt(dSqr);
	CalculateDistance:=d;
end;

{.......................................................}

function InterpolateBeamData(X,Y:Extended):Extended;
var
	dx1,dx2,dy1,dy2,d1,d2,d3,d4:Extended;
	p1,p2,p3,p4,num,den:Extended;
	x1,x2,y1,y2:Integer;
begin
	x1:=Trunc(X);
	if X<0 then
		x2:=x1-1
	else
		x2:=x1+1;
	y1:=Trunc(Y);
	if Y<0 then
		y2:=y1-1
	else
		y2:=y1+1;
	dx1:=Sqr(x1-X);
	dx2:=Sqr(x2-X);
	dy1:=Sqr(y1-Y);
	dy2:=Sqr(y2-Y);
	d1:=Sqrt(dx1+dy1);
	d2:=Sqrt(dx2+dy1);
	d3:=Sqrt(dx1+dy2);
	d4:=Sqrt(dx2+dy2);
	p1:=Beam[x1,y1];
	p2:=Beam[x2,y1];
	p3:=Beam[x1,y2];
	p4:=Beam[x2,y2];
	num:=p1/d1+p2/d2+p3/d3+p4/d4;
	den:=1/d1+1/d2+1/d3+1/d4;
	InterpolateBeamData:=num/den;
end;

{.......................................................}

procedure GauLeg(X1,X2:Extended;N:Integer);
(* Programs using routine GAULEG must define the type
TYPE
   darray=ARRAY [1..n] OF double;
in the calling program *)
const
	 eps=3.0e-17; (* adjust to your floating precision *)
var
	m,j,i:Integer;
	z1,z,xm,xl,pp,p3,p2,p1:Extended;
begin
	m:=(N+1) div 2;
	xm:=0.5*(X2+X1);
	xl:=0.5*(X2-X1);
	for i:=1 to m do
	begin
		z:=Cos(3.141592654*(i-0.25)/(N+0.5));
		repeat
			p1:=1.0;
			p2:=0.0;
			for j:=1 to N do
			begin
				p3:=p2;
				p2:=p1;
				p1:=((2.0*j-1.0)*z*p2-(j-1.0)*p3)/j;
			end;
			pp:=N*(z*p1-p2)/(z*z-1.0);
			z1:=z;
			z:=z1-p1/pp;
		until Abs(z-z1)<=eps;
		GauLegX[i]:=xm-xl*z;
		GauLegX[N+1-i]:=xm+xl*z;
		GauLegW[i]:=2.0*xl/((1.0-z*z)*pp*pp);
		GauLegW[N+1-i]:=GauLegW[i];
	end;
end;

{.......................................................}

function GauLegY1(X:Extended):Extended;
begin
	if Polar then
		GauLegY1:=0
	else
		GauLegY1:=-Sqrt(Sqr(R)-Sqr(X))
end;

{.......................................................}

function GauLegY2(X:Extended):Extended;
begin
	if Polar then
		GauLegY2:=2*Pi
	else
		GauLegY2:=Sqrt(Sqr(R)-Sqr(X))
end;

{.......................................................}

function GauLegZ1(X,Y:Extended):Extended;
begin
	if Polar then
		GauLegZ1:=0
	else
		if BeamData then
			GauLegZ1:=-N
		else
			GauLegZ1:=-A;
end;

{.......................................................}

function GauLegZ2(X,Y:Extended):Extended;
begin
	if BeamData then
		GauLegZ2:=N
	else
		GauLegZ2:=A;
end;

{.......................................................}

function GauLegW1(X,Y,Z:Extended):Extended;
begin
	if Polar then
		GauLegW1:=0
	else
		if BeamData then
			GauLegW1:=-N
		else
			GauLegW1:=-Sqrt(Sqr(A)-Sqr(Z));
end;

{.......................................................}

function GauLegW2(X,Y,Z:Extended):Extended;
begin
	if Polar then
		GauLegW2:=2*Pi
	else
		if BeamData then
			GauLegW2:=N
		else
			GauLegW2:=Sqrt(Sqr(A)-Sqr(Z));
end;
{.......................................................}

function Func(X,Y,Z,W:Extended):Extended;
var
	r1,phi1,r2,phi2,cosPhi2,x1,y1,x2,y2,z2:Extended;
	dSqr,d,cosTheta1,cosTheta2:Extended;
begin
// x1, y1 are the detector, x2, y2, z2 are the source
	if Polar then
	begin
		r1:=X;
		phi1:=Y;
		r2:=Z;
		phi2:=W;
		x1:=r1*Cos(phi1);
		y1:=r1*Sin(phi1);
		cosPhi2:=Cos(phi2);
		x2:=r2*cosPhi2*CosDelta;
		y2:=r2*Sin(phi2);
		z2:=-r2*cosPhi2*SinDelta;
		dSqr:=Sqr(x1-x2)+Sqr(y1-y2)+Sqr(L-z2);
		d:=Sqrt(dSqr);
		cosTheta1:=Abs((x1-x2)*SinDelta+(L-z2)*CosDelta)/d;
		cosTheta2:=Abs(L-z2)/d;
		if BeamData then
		begin
			Func:=Signal[ii,jj]*r1*r2*cosTheta1*cosTheta2/(Pi*dSqr);
		end
		else
			Func:=r1*r2*cosTheta1*cosTheta2/(Pi*dSqr);
	end
	else
	begin
		x1:=X;
		y1:=Y;
		x2:=Z*CosDelta;
		y2:=W;
		z2:=-Z*SinDelta;
		dSqr:=Sqr(x1-x2)+Sqr(y1-y2)+Sqr(L-z2);
		d:=Sqrt(dSqr);
		cosTheta1:=Abs((x1-x2)*SinDelta+(L-z2)*CosDelta)/d;
		cosTheta2:=Abs(L-z2)/d;
		if BeamData then
		begin
			Func:=Signal[ii,jj]*cosTheta1*cosTheta2/(Pi*dSqr);
		end
		else
			Func:=cosTheta1*cosTheta2/(Pi*dSqr);
	end;
	Application.ProcessMessages;
end;

{.......................................................}

procedure Quad4D(X1,X2:Extended; var SS:Extended);
(* Evaluates 4-dimensional integral with w integration innermost, then
z integration, y integration, and finally x integration. Unlike FORTRAN version,
calls QGAUS (here called QGAUS4) recursively. Programs using routine QUAD4D must
define the integrand by
FUNCTION func(x,y,z,w: real): real;
and functions for the limits of integration by
FUNCTION y1(x: real): real;
FUNCTION y2(x: real): real;
FUNCTION z1(x,y: real): real;
FUNCTION z2(x,y: real): real;
FUNCTION w1(x,y,z: real): real;
FUNCTION w2(x,y,z: real): real;
Also global variables
VAR
	 glx,gly,glz: real;
are required. *)

	procedure QGaus4(A,B:Extended; var SS:Extended; N:Integer);
	var
		j:Integer;
		xr,xm,dx:Extended;

		function F(X:Extended; N:Integer):Extended;
		var
			ss:Extended;
		begin
			if N=1 then
			begin
				ii:=0;
				jj:=0;
				glx:=X;
				QGaus4(GauLegY1(glx),GauLegY2(glx),ss,2);
				F:=ss;
			end
			else
				if N=2 then
				begin
					Inc(jj);
					ii:=0;
					gly:=X;
					QGaus4(GauLegZ1(glx,gly),GauLegZ2(glx,gly),ss,3);
					F:=ss;
				end
				else
					if N=3 then
					begin
						Inc(ii);
						glz:=X;
						QGaus4(GauLegW1(glx,gly,glz),GauLegW2(glx,gly,glz),ss,4);
						F:=ss;
					end
					else
						F:=Func(glx,gly,glz,X);
		end;

	begin
		xm:=0.5*(B+A);
		xr:=0.5*(B-A);
		SS:=0;
		for j:=1 to NGauLeg do
		begin
			dx:=xr*GauLegX[j];
			SS:=SS+GauLegW[j]*F(xm+dx,N);
		end;
		SS:=xr*ss;
	end;

begin
	ii:=0;
	jj:=0;
	QGaus4(X1,X2,SS,1);
end;

{.......................................................}

function CalculateViewFactor(DetAngle,DetectorRadius,SourceRadius,LengthL:Extended;Pol:string):Extended;
var
	value,vf:Extended;
	valid:Boolean;
begin
	valid:=True;
	if BeamData then
	begin
		if Pol='s' then
			Beam:=sBeam
		else
			if Pol='p' then
				Beam:=pBeam;
		CalculateSignal;
	end;
	if valid then
	begin
		SourceD:=2*SourceRadius;
		DetectorD:=2*DetectorRadius;
		R:=DetectorRadius;
		Delta:=DetAngle;
		L:=LengthL;
		CosDelta:=Cos(Delta*Pi/180);
		SinDelta:=Sin(Delta*Pi/180);
		A:=SourceRadius;
		B:=SourceRadius;
		if Polar then
		begin
			Quad4D(0,R,value);
			if BeamData then
				vf:=value
			else
				vf:=value/(Pi*Sqr(SourceRadius));
		end
		else
		begin
			Quad4D(-R,R,value);
			if BeamData then
				vf:=value
			else
				vf:=value/(Pi*A*B);
		end;
		Application.ProcessMessages;
	end;
	CalculateViewFactor:=vf;
end;

{.......................................................}

procedure CalculateArea;
var
	i,j:Integer;
	dx,dy,r1,r2,dTheta:Extended;
	edge,edgeR,edgeTheta:array[0..MaxNGauLeg] of Extended;
	f:TextFile;
begin
	if Polar then
	begin
		edgeR[0]:=0;
		edgeR[NGauLeg]:=N;
		edgeTheta[0]:=0;
		edgeTheta[NGauLeg]:=2*Pi;
		for i:=1 to NGauLeg-1 do
		begin
			edgeR[i]:=0.25*N*(GauLegX[i]+GauLegX[i+1]+2);
			edgeTheta[i]:=0.5*Pi*(GauLegX[i]+GauLegX[i+1]+2);
		end;
		for i:=1 to NGauLeg do
			for j:=1 to NGauLeg do
			begin
				r1:=edgeR[i];
				r2:=edgeR[i-1];
				dTheta:=edgeTheta[j]-edgeTheta[j-1];
				Area[i,j]:=dTheta/2*(Sqr(r1)-Sqr(r2));
			end;
	end
	else
	begin
		edge[0]:=-N;
		edge[NGauLeg]:=N;
		for i:=1 to NGauLeg-1 do
			edge[i]:=0.5*N*(GauLegX[i]+GauLegX[i+1]);
		for i:=1 to NGauLeg do
			for j:=1 to NGauLeg do
			begin
				dx:=edge[i]-edge[i-1];
				dy:=edge[j]-edge[j-1];
				Area[i,j]:=dx*dy;
			end;
	end;
	{AssignFile(f,'Area.txt');
	Rewrite(f);
	for i:=1 to NGauLeg do
	begin
		for j:=1 to NGauLeg do
			Write(f,Area[i,j],#9);
		Writeln(f);
	end;
	CloseFile(f);}
end;

{.......................................................}

procedure CalculateSignal;
var
	i,j:Integer;
	x,y,r,theta,sum,value:Extended;
	f:TextFile;
	ch:Char;
begin
	for i:=1 to MaxNGauLeg do
		for j:=1 to MaxNGauLeg do
		begin
			Signal[i,j]:=0;
			Area[i,j]:=0;
		end;
	CalculateArea;
	sum:=0;
	if Polar then
	begin
		for i:=1 to NGauLeg do
			for j:=1 to NGauLeg do
			begin
				r:=0.5*N*(GauLegX[i]+1);
				theta:=Pi*(GauLegX[j]+1);
				x:=r*Cos(theta);
				y:=r*Sin(theta);
				Signal[i,j]:=Beam[Round(x),Round(y)];
				sum:=sum+Signal[i,j]*Area[i,j];
			end;
	end
	else
	begin
		for i:=1 to NGauLeg do
			for j:=1 to NGauLeg do
			begin
				x:=N*GauLegX[i];
				y:=N*GauLegX[j];
				Signal[i,j]:=InterpolateBeamData(x,y);
				sum:=sum+Signal[i,j]*Area[i,j];
			end;
	end;
	for i:=1 to NGauLeg do
		for j:=1 to NGauLeg do
			Signal[i,j]:=Signal[i,j]/sum;
	{AssignFile(f,'Output.txt');
	Rewrite(f);
	for i:=1 to NGauLeg do
	begin
		for j:=1 to NGauLeg do
			Write(f,Signal[i,j],#9);
		Writeln(f);
	end;
	CloseFile(f);}
	{AssignFile(f,'Input.txt');
	Reset(f);
	for i:=1 to NGauLeg do
	begin
		for j:=1 to NGauLeg do
		begin
			Read(f,value);
			Signal[i,j]:=value;
		end;
		Readln(f);
	end;
	CloseFile(f);}
	{AssignFile(f,'Output.txt');
	Rewrite(f);
	for i:=1 to NGauLeg do
	begin
		for j:=1 to NGauLeg do
			Write(f,Signal[i,j],#9);
		Writeln(f);
	end;
	CloseFile(f);}
end;

{.......................................................}

end.
