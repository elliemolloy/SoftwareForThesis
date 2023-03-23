unit BRDFmodel;

interface

uses
	SysUtils, Classes, Math, Dialogs, LinearAlgebra;

const
	MaxNGauLeg=200;
	NGauLeg:array[1..4] of Integer=(30,30,30,20);

type
  T5DArray=array[1..5] of Extended;

procedure GauLeg(X1,X2:Extended;Range,N:Integer);
function Fresnel(N,K,Theta:Extended;Pol:string):Extended;
function SimpleBRDF(Ti,Td,Pd,W,N,K:Extended;Pol:string):Extended;
function QGaus2G(Y1,Y2:Extended;N:Integer;Theta,Dp,W,N2,K2:Extended;Pol:string):Extended;
function QGaus2F(X1,X2,Y1,Y2:Extended;N:Integer;Theta,W,N2,K2:Extended;Pol:string):Extended;
function Integrate(Theta,W,N,K:Extended;Pol:string):Extended;
function CalculateBRDF(Ti,Td,Pd,W,N,K,Rho:Extended;Pol:string):Extended;

var
	GauLegX,GauLegW:array[1..4,1..MaxNGauLeg] of Extended;
	gly:Extended;
	i:Integer;

implementation

{.......................................................}

procedure GauLeg(X1,X2:Extended;Range,N:Integer);
(* Programs using routine GAULEG must define the type
TYPE
	 darray=ARRAY [1..n] OF double;
in the calling program *)
const
	 eps=3.0e-16; (* adjust to your floating precision *)
var
	m,j,i:Integer;
	z1,z,xm,xl,pp,p3,p2,p1:Extended;
begin
	m:=(N+1) div 2;
	xm:=0.5*(X2+X1);
	xl:=0.5*(X2-X1);
	for i:=1 to m do
	begin
		z:=Cos(Pi*(i-0.25)/(N+0.5));
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
		GauLegX[Range,i]:=xm-xl*z;
		GauLegX[Range,n+1-i]:=xm+xl*z;
		GauLegW[Range,i]:=2.0*xl/((1.0-z*z)*pp*pp);
		GauLegW[Range,n+1-i]:=GauLegW[Range,i];
	end;
end;

{.......................................................}

function Fresnel(N,K,Theta:Extended;Pol:string):Extended;
// Calculate Fresnel reflectance for refractive indices n,k, angle theta and polarisation p
var
  sinTheta,cosTheta,e1,e2,e3,e4,a2,b2,a,a2b2,rho:Extended;
begin
  sinTheta:=Sin(Theta);
  cosTheta:=Cos(Theta);
  e1:=Sqr(N)-Sqr(K)-Sqr(sinTheta);
  e2:=Sqrt(Sqr(e1)+(4*Sqr(N)*Sqr(K)));
  a2:=(e2+e1)/2;
  b2:=(e2-e1)/2;
  a:=Sqrt(a2);
  a2b2:=a2+b2;
  e1:=2*a*cosTheta;
  e3:=a2b2-e1+Sqr(cosTheta);
  e4:=a2b2+e1+Sqr(cosTheta);
  rho:=e3/e4;
  if pol<>'s' then
  begin
    e1:=2*a*sinTheta*sinTheta/cosTheta;
    e2:=Sqr(sinTheta)*Sqr(sinTheta/cosTheta);
    e3:=a2b2-e1+e2;
    e4:=a2b2+e1+e2;
    rho:=rho*e3/e4;
  end;
  Fresnel:=rho;
end;

{.......................................................}

function SimpleBRDF(Ti,Td,Pd,W,N,K:Extended;Pol:string):Extended;
// Calculates BRDF using a Gaussian distribution function and Fresnel reflection
var
  sinTi,cosTi,sinTd,cosTd,sinPd,cosPd:Extended;
  alpha,A,P,num,den,c1,c2,Rs,Rp,R,y:Extended;
  j:Integer;
  I,Dd,S,Normal,V,H,results:TVector;
begin
  sinTi:=Sin(Ti);
  cosTi:=Cos(Ti);
  sinTd:=Sin(Td);
  cosTd:=Cos(Td);
  sinPd:=Sin(Pd);
  cosPd:=Cos(Pd);

  // Calculate probability distribution function using a Gaussian with width w
  //Incidence beam vector, spherical coordinates
  I[1]:=sinTi;
  I[2]:=0;
  I[3]:=cosTi;

  // Detection beam
  Dd[1]:=sinTd*cosPd;
  Dd[2]:=sinTd*sinPd;
  Dd[3]:=cosTd;

  // Surface normal
  S[1]:=0;
  S[2]:=0;
  S[3]:=1;

  // Facet normal
  Normal:=VectorAddition(I,Dd);
  den:=Sqrt(DotProduct(Normal,Normal));
  for j:=1 to 3 do
  begin
    Normal[j]:=Normal[j]/den;
  end;

  // Calculate angle of facet
  alpha:=AngleBetweenVectors(Normal,S);

  // Calculate incident angle wrt alpha
  if (Ti=Td) and (Pd=0) then
    A:=0
  else
    A:=AngleBetweenVectors(I,Normal);

  // Beckmann distribution
  num:=Exp(-Sqr(Tan(alpha)/W));
  den:=Pi*Sqr(W)*Sqr(Sqr(Cos(alpha)));
  P:=num/den;

  // Vectors horizontal and vertical wrt labspace
  {V[1]:=-cosTi;
  V[2]:=0;
  V[3]:=sinTi;
  H[1]:=0;
  H[2]:=1;
  H[3]:=0;

  // Fraction of beam vertical and horizontal
  c1:=Abs(DotProduct(Normal,V));
  c2:=Abs(DotProduct(Normal,H));
  if Sqr(c1)+Sqr(c2)=0 then // facet normal to beam
  begin
    c1:=0.5;
    c2:=0.5;
  end
  else
  begin
    c1:=c1/(c1+c2);
    c2:=c2/(c1+c2);
  end;

  // Calculate Fresnel reflectance of facet
  if A>Pi/2 then
  begin
    Rs:=0;
    Rp:=0;
  end
  else
    if Pol='s' then
    begin
      Rs:=c1*Fresnel(N,K,A,'s');
      Rp:=c2*Fresnel(N,K,A,'p');
    end
    else
    begin
      Rs:=c2*Fresnel(N,K,A,'s');
      Rp:=c1*Fresnel(N,K,A,'p');
    end;
  R:=Rp+Rs;}

  R:=Fresnel(N,K,A,Pol);
  y:=P*R/(4*cosTd*cosTi);
  results[1]:=y;
  results[2]:=P;
  results[3]:=R;
  SimpleBRDF:=y;
end;

{.......................................................}

function QGaus2G(Y1,Y2:Extended;N:Integer;Theta,Dp,W,N2,K2:Extended;Pol:string):Extended;
// Calculate numerical integral in theta from Y1 to Y2
var
  tm,tr,dt,ss:Extended;
  i:Integer;
begin
  tm:=(Y1+Y2)/2;
  tr:=(Y2-Y1)/2;
  ss:=0;
  for i:=1 to N do
  begin
    dt:=tr*GauLegX[1,i];
    ss:=ss+GauLegW[1,i]*Sin(tm+dt)*Cos(tm+dt)*SimpleBRDF(Theta,tm+dt,Dp,W,N2,K2,Pol);
  end;
  QGaus2G:=tr*ss;
end;

{.......................................................}

function QGaus2F(X1,X2,Y1,Y2:Extended;N:Integer;Theta,W,N2,K2:Extended;Pol:string):Extended;
// Calculate numerical integral over P*R from X1 to X2 in phi and from Y1 to Y2 in theta using Gaussian quadratures.
var
  pm,pr,ss,dp:Extended;
  i:Integer;
begin
  GauLeg(-1,1,1,N);
  pm:=(X1+X2)/2;
  pr:=(X2-X1)/2;
  ss:=0;
  for i:=1 to N do
  begin
    dp:=pr*GauLegX[1,i];
    ss:=ss+GauLegW[1,i]*QGaus2G(Y1,Y2,N,Theta,pm+dp,W,N2,K2,Pol);
  end;
  QGaus2F:=pr*ss;
end;

{.......................................................}

function Integrate(Theta,W,N,K:Extended;Pol:string):Extended;
// Do numerical integration in separate parts to get more points in the middle
var
  thetaRad:Extended;
  limt1,limt2,limp1,limp2,limp3,limp4,integral1,integral2,integral3,integral4:Extended;
begin
  thetaRad:=Theta*Pi/180;
  limt1:=thetaRad-Arctan(3*W);
  if limt1<0 then
      limt1:=0;
  limt2:=thetaRad+Arctan(3*W);
  if limt2>Pi/2 then
      limt2:=Pi/2;
  limp1:=Pi-Arctan(3*W);
  limp2:=Pi+Arctan(3*W);
  limp3:=Arctan(3*W)-Pi;
  limp4:=Pi-Arctan(3*W);
  integral1:=QGaus2F(0,2*Pi,0,limt1,30,thetaRad,W,N,K,Pol);
  integral2:=QGaus2F(limp1,limp2,limt1,limt2,30,thetaRad,W,N,K,Pol);
  integral3:=QGaus2F(limp3,limp4,limt1,limt2,30,thetaRad,W,N,K,Pol);
  integral4:=QGaus2F(0,2*Pi,limt2,Pi/2,20,thetaRad,W,N,K,Pol);
  Integrate:=integral1+integral2+integral3+integral4;
  {Integrate:=QGaus2F(0,2*Pi,0,Pi/2,30,thetaRad,W,N,K,Pol);}
end;

{.......................................................}

function CalculateBRDF(Ti,Td,Pd,W,N,K,Rho:Extended;Pol:string):Extended;
// Puts all the parts of the BRDF together in one function.
var
  tiRad,tdRad,pdRad:Extended;
  PR,surfaceBRDF,backSurfaceBRDFs,backSurfaceBRDFp,backSurfaceBRDFav,wholeBRDF:Extended;
begin
  tiRad:=Ti*Pi/180;
  tdRad:=Td*Pi/180;
  pdRad:=Pd*Pi/180;
  PR:=SimpleBRDF(tiRad,tdRad,pdRad,W,N,K,Pol);
  surfaceBRDF:=Integrate(Ti,W,N,K,Pol);
  backSurfaceBRDFs:=Integrate(Td,W,N,K,'s');
  backSurfaceBRDFp:=Integrate(Td,W,N,K,'p');
  backSurfaceBRDFav:=(backSurfaceBRDFs+backSurfaceBRDFp)/2;
  wholeBRDF:=Rho*(1-surfaceBRDF)*(1-backSurfaceBRDFav)+Pi*PR;
  CalculateBRDF:=wholeBRDF;
end;

end.
