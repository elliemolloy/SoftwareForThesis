unit Reflectance3D;

interface

uses
	SysUtils, Classes, Math, ComplexNumbers, Dialogs, LinearAlgebra, Forms;

type
	T2Array=array[1..2] of Extended;
	T4Array=array[1..4] of Extended;
	TBeamArray=array[-15..15,-15..15] of Extended;
  TReflectanceArray=array[1..3,1..35] of Extended;
  TMeasuredDataArray=array[1..19,1..275] of Extended;
  TMirrorReflArray=array[1..25,1..56] of Extended;

function SnellsLaw(N1,N2,Theta1:Extended):Extended;
function SnellsLawComplex(N1,N2,Theta1:ComplexNumber):ComplexNumber;
function CalculateQzRefractiveIndex(Lambda:Extended):Extended;
function CalculateQzReflectance(Theta1,Lambda:Extended;Pol:string):Extended;
function CalculateSiOTransmittance(Theta1,Lambda:Extended;Pol:string):Extended;
function FindSiRefractiveIndex(Lambda:Extended):ComplexNumber;
function FindAlRefractiveIndex(Lambda:Extended):ComplexNumber;
function FindMirrorReflectance(IncidentAngle:Extended;Pol:string):Extended;
{function CalculateCompoundReflectance(Lambda,Thickness,Theta1:Extended;Pol:string):Extended;}
function CalculateCompoundReflectance(Lambda,N1,Thickness,Theta1:Extended;N2,N3:ComplexNumber;Pol:string):Extended;
function CalculatePolarisationRatio(PolVector,SurfaceNormal,BeamVector:TVector):T2Array;
function PolarisationVector(C:T2Array;SurfaceNormal,BeamVector:TVector):TVector;
function NormaliseVector(V:TVector):TVector;
function CalculateSiAngle(DetectorAngle,C1,C2:Extended;var MirrorNormal,DiodeNormal,BeamVector1,BeamVector2,BeamVector3:TVector):TVector;
function CalculateSiAngleDiffuse(DetectorAngle,Cxi,Cyi,Cxm,Cym:Extended;var MirrorNormal,DiodeNormal,BeamVector1,BeamVector2,BeamVector3,MirrorPosition:TVector;var ThetaD,L:Extended):TVector;
function CalculateAbsorbance(Lambda,Thickness,Theta,MirrorTheta:Extended;SiNormal,MirrorNormal,BeamVector1,BeamVector2,BeamVector3:TVector;Pol:string):Extended;
function CalculateRDiffuse(Lambda,Thickness,DetAngle:Extended;var rDiffuseS,rDiffuseP:Extended):Extended;
function CalculateRDiffuseBeamData(Lambda,Thickness,DetAngle:Extended;var RDiffuseS,RDiffuseP:Extended):Boolean;
function CalculateRCollimated(Lambda,Thickness,DetAngle,XOffset,YOffset:Extended;Pol:string;UseBeamData:Boolean):Extended;
procedure CreateRotationMatrix(Angle:Extended;Axis:string;var R:TMatrix);
procedure CreateRotationMatrix2(Angle:Extended;Axis:TVector;var R:TMatrix);
procedure CreateSiRefractiveIndexTable;
procedure CreateAlRefractiveIndexTable;
procedure ReadBeamFile(FileS,FileP:string;var Valid:Boolean);
procedure ReadMirrorReflectanceFile(var Valid:Boolean);
procedure ReadMeasuredData(var Valid:Boolean);

const
	R1=650;
	R2=118;
	Rc=200;
	MirrorAngle=5*Pi/180;
	DiodeAngle=16*Pi/180;

var
	SiReal,SiImaginary,lambdaTable:array[1..50] of Extended;
  AlReal,AlImaginary,AlLambdaTable:array[1..43] of Extended;
	Error:Boolean;
	ErrorString:string;
	SBeam,PBeam:TBeamArray;
  MirrorReflectanceData:TReflectanceArray;
  MeasuredData:TMeasuredDataArray;
  MirrorRefl:TMirrorReflArray;
	PrintC:Boolean;
  {f:Textfile;}

implementation

uses
	DetMainForm, ViewFactors, DetGlobal;

{.......................................................}

function SnellsLaw(N1,N2,Theta1:Extended):Extended;
// angles in radians
begin
	SnellsLaw:=ArcSin(N1*Sin(Theta1)/N2);
end;

{.......................................................}

function SnellsLawComplex(N1,N2,Theta1:ComplexNumber):ComplexNumber;
// angles in radians
var
	nSinTheta,x,SinTheta1,theta2:ComplexNumber;
begin
	sinTheta1:=ComplexSin(Theta1);
	nSinTheta:=ComplexMultiplication(N1,sinTheta1);
	x:=ComplexDivision(nSinTheta,N2);
	theta2:=ComplexArcSin(x);
	SnellsLawComplex:=theta2;
end;

{.......................................................}

function CalculateQzRefractiveIndex(Lambda:Extended):Extended;
// lambda in nm
var
	a,b,c,d,e,f,g,h,j,n:Extended;
begin
	Lambda:=Lambda/1000;
	a:=0.6961663;
	b:=0.4079426;
	c:=0.8974794;
	d:=0.0684043;
	e:=0.1162414;
	f:=9.896161;
	g:=a*Sqr(Lambda)/(Sqr(Lambda)-Sqr(d));
	h:=b*Sqr(Lambda)/(Sqr(Lambda)-Sqr(e));
	j:=c*Sqr(Lambda)/(Sqr(Lambda)-Sqr(f));
	n:=Sqrt(g+h+j+1);
	CalculateQzRefractiveIndex:=n;
end;

{.......................................................}

function CalculateQzReflectance(Theta1,Lambda:Extended;Pol:String):Extended;
// theta1 in radians
// lambda in nm
var
	n1,n2,theta2,cosTheta1,cosTheta2,numerator,denominator,r:Extended;
begin
	n1:=1.0003;
	n2:=CalculateQzRefractiveIndex(Lambda);
	theta2:=SnellsLaw(n1,n2,Theta1);
	cosTheta1:=Cos(Theta1);
	cosTheta2:=Cos(theta2);
	if Pol='p' then
	begin
		numerator:=n2*cosTheta1-n1*cosTheta2;
		denominator:=n2*cosTheta1+n1*cosTheta2;
	end
	else
	begin
		numerator:=n1*cosTheta1-n2*cosTheta2;
		denominator:=n1*cosTheta1+n2*cosTheta2;
	end;
	r:=numerator/denominator;
	r:=Sqr(r);
	CalculateQzReflectance:=r;
end;

{.......................................................}

function CalculateSiOTransmittance(Theta1,Lambda:Extended;Pol:string):Extended;
// theta in radians
// lambda in nm
var
	t,t12,t21:Extended;
	n1,n2,theta2,cosTheta1,cosTheta2,denominator:Extended;
begin
	n1:=1.0003;
	n2:=CalculateQzRefractiveIndex(Lambda);
	theta2:=SnellsLaw(n1,n2,Theta1);
	cosTheta1:=Cos(Theta1);
	cosTheta2:=Cos(theta2);
	if Pol='p' then
	begin
		denominator:=n2*cosTheta1+n1*cosTheta2;
	end
	else
	begin
		denominator:=n1*cosTheta1+n2*cosTheta2;
	end;
	t12:=2*n1*cosTheta1/denominator;
	t12:=Sqr(t12);
	t21:=2*n2*cosTheta2/denominator;
	t21:=Sqr(t21);
	t:=t12*t21;
	CalculateSiOTransmittance:=t;
end;

{.......................................................}

function FindSiRefractiveIndex(Lambda:Extended):ComplexNumber;
var
	i,lower,upper:Integer;
	realDiff,imaginaryDiff,ratio,siRealLambda,siImLambda:Extended;
	finished:Boolean;
	n:ComplexNumber;
begin
	finished:=False;
	// Find two closest values to lambda
	for i:=1 to 50 do
	begin
		if (Lambda<350) or (Lambda>840) then
    begin
      if Lambda=900 then // from https://refractiveindex.info/?shelf=main&book=Si&page=Schinke
        FindSiRefractiveIndex:=MakeComplex(3.61,0.0021092)
      else
        if Lambda=1000 then
          FindSiRefractiveIndex:=MakeComplex(3.575,0.00049020);
			Exit;
    end;
		if not finished then
		begin
			if lambdaTable[i]>Lambda then
			begin
				lower:=i-1;
				upper:=i;
				finished:=True;
			end;
		end;
	end;
	ratio:=(Lambda-LambdaTable[lower])/10;
	realDiff:=SiReal[lower]-SiReal[upper];
	imaginaryDiff:=SiImaginary[lower]-SiImaginary[upper];
	siRealLambda:=SiReal[lower]-(realDiff*ratio);
	siImLambda:=SiImaginary[lower]-(imaginaryDiff*ratio);
	n:=MakeComplex(siRealLambda,siImLambda);
	FindSiRefractiveIndex:=n;
end;

{.......................................................}

function FindAlRefractiveIndex(Lambda:Extended):ComplexNumber;
var
	i,lower,upper:Integer;
	realDiff,imaginaryDiff,ratio,alRealLambda,alImLambda:Extended;
	finished:Boolean;
	n:ComplexNumber;
begin
	finished:=False;
	// Find two closest values to lambda
	for i:=1 to 50 do
	begin
		if (Lambda<350) or (Lambda>840) then
			Exit;
		if not finished then
		begin
			if AlLambdaTable[i]>Lambda then
			begin
				lower:=i-1;
				upper:=i;
				finished:=True;
			end;
		end;
	end;
	ratio:=(Lambda-AlLambdaTable[lower])/10;
	realDiff:=AlReal[lower]-AlReal[upper];
	imaginaryDiff:=AlImaginary[lower]-AlImaginary[upper];
	alRealLambda:=AlReal[lower]-(realDiff*ratio);
	alImLambda:=AlImaginary[lower]-(imaginaryDiff*ratio);
	n:=MakeComplex(alRealLambda,alImLambda);
	FindAlRefractiveIndex:=n;
end;

{.......................................................}

function FindMirrorReflectance(IncidentAngle:Extended;Pol:string):Extended;
var
	i,j,lower,upper:Integer;
	gradient,reflectance:Extended;
	finished:Boolean;
begin
	finished:=False;
  if Pol='s' then
    j:=2
  else
    j:=3;
  if IncidentAngle>20 then
    Exit   // Can't deal with angles greater than 20
  else
    if IncidentAngle<3 then
    begin
      // Extrapolate curve for smaller angle using gradient between first two points
      lower:=1;
      upper:=2;
    end
    else
    begin
	    // Find two angles either side of the incident angle
      for i:=1 to 35 do
      begin

        if not finished then
        begin
          if MirrorReflectanceData[1,i]>IncidentAngle then
          begin
            lower:=i-1;
            upper:=i;
            finished:=True;
          end;
        end;
      end;
    end;
    // Interpolate between the closest two points to calculate reflectance for given angle
    gradient:=(MirrorReflectanceData[j,upper]-MirrorReflectanceData[j,lower])/(MirrorReflectanceData[1,upper]-MirrorReflectanceData[1,lower]);
    reflectance:=MirrorReflectanceData[j,lower]+gradient*(IncidentAngle-MirrorReflectanceData[1,lower]);
    FindMirrorReflectance:=reflectance;
end;

{.......................................................}

{function CalculateCompoundReflectance(Lambda,Thickness,Theta1:Extended;Pol:string):Extended;
var
	n1,n2,theta2,cosTheta1,cosTheta2,num,den,r12,t12,t21,beta:Extended;
	n2C,n3,cosTheta2C,theta3,cosTheta3,numC,denC,r23,t23,e,e1,e2,e3,e4,e5,r:ComplexNumber;
begin
	n1:=1.0003;
	n2:=CalculateQzRefractiveIndex(Lambda);
	n2C:=MakeComplex(n2,0);
	n3:=FindSiRefractiveIndex(Lambda);
	cosTheta1:=Cos(theta1);
	theta2:=SnellsLaw(n1,n2,Theta1);
	cosTheta2:=Cos(theta2);
	cosTheta2C:=MakeComplex(cosTheta2,0);
	theta3:=SnellsLawComplex(n2C,n3,MakeComplex(theta2,0));
	cosTheta3:=ComplexCos(theta3);
	if Pol='p' then
	begin
		num:=n2*cosTheta1-n1*cosTheta2;
		den:=n2*cosTheta1+n1*cosTheta2;
		r12:=num/den;
		t12:=2*n1*cosTheta1/den;
		t21:=2*n2*cosTheta2/den;
		numC:=ComplexSubtraction(ComplexMultiplication(n3,cosTheta2C),ComplexMultiplication(n2C,cosTheta3));
		denC:=ComplexAddition(ComplexMultiplication(n3,cosTheta2C),ComplexMultiplication(n2C,cosTheta3));
		r23:=ComplexDivision(numC,denC);
		t23:=ComplexDivision(MakeComplex(2*n2*cosTheta2,0),denC);
 	end
	else
	begin
		num:=n1*cosTheta1-n2*cosTheta2;
		den:=n1*cosTheta1+n2*cosTheta2;
		r12:=num/den;
		t12:=2*n1*cosTheta1/den;
		t21:=2*n2*cosTheta2/den;
		numC:=ComplexSubtraction(ComplexMultiplication(n2C,cosTheta2C),ComplexMultiplication(n3,cosTheta3));
		denC:=ComplexAddition(ComplexMultiplication(n2C,cosTheta2C),ComplexMultiplication(n3,cosTheta3));
		r23:=ComplexDivision(numC,denC);
		t23:=ComplexDivision(MakeComplex(2*n2*cosTheta2,0),denC);
	end;
	beta:=2*Pi*n2*Thickness*cosTheta2/Lambda;
	e:=MakeComplex(Cos(-2*beta),Sin(-2*beta));
	e1:=ComplexMultiplication(r23,e);
	e2:=ComplexMultiplication(MakeComplex(t12*t21,0),e1);
	e3:=ComplexMultiplication(MakeComplex(r12,0),e1);
	e4:=ComplexAddition(MakeComplex(1,0),e3);
	e5:=ComplexDivision(e2,e4);
	r:=ComplexAddition(MakeComplex(r12,0),e5);
	num:=Sqr(r[1])+Sqr(r[2]);
	CalculateCompoundReflectance:=num;
end;}

{.......................................................}

function CalculateCompoundReflectance(Lambda,N1,Thickness,Theta1:Extended;N2,N3:ComplexNumber;Pol:string):Extended;
var
	theta2,cosTheta1,cosTheta2,num,den,r12,t12,t21,beta:Extended;
	cosTheta2C,theta3,cosTheta3,numC,denC,r23,t23,e,e1,e2,e3,e4,e5,r:ComplexNumber;
begin
	cosTheta1:=Cos(theta1);
	theta2:=SnellsLaw(N1,N2[1],Theta1);
	cosTheta2:=Cos(theta2);
	cosTheta2C:=MakeComplex(cosTheta2,0);
	theta3:=SnellsLawComplex(N2,N3,MakeComplex(theta2,0));
	cosTheta3:=ComplexCos(theta3);
	if Pol='p' then
	begin
		num:=N2[1]*cosTheta1-N1*cosTheta2;
		den:=N2[1]*cosTheta1+N1*cosTheta2;
		r12:=num/den;
		t12:=2*N1*cosTheta1/den;
		t21:=2*N2[1]*cosTheta2/den;
		numC:=ComplexSubtraction(ComplexMultiplication(N3,cosTheta2C),ComplexMultiplication(N2,cosTheta3));
		denC:=ComplexAddition(ComplexMultiplication(N3,cosTheta2C),ComplexMultiplication(N2,cosTheta3));
		r23:=ComplexDivision(numC,denC);
		t23:=ComplexDivision(MakeComplex(2*N2[1]*cosTheta2,0),denC);
 	end
	else
	begin
		num:=N1*cosTheta1-N2[1]*cosTheta2;
		den:=N1*cosTheta1+N2[1]*cosTheta2;
		r12:=num/den;
		t12:=2*N1*cosTheta1/den;
		t21:=2*N2[1]*cosTheta2/den;
		numC:=ComplexSubtraction(ComplexMultiplication(N2,cosTheta2C),ComplexMultiplication(N3,cosTheta3));
		denC:=ComplexAddition(ComplexMultiplication(N2,cosTheta2C),ComplexMultiplication(N3,cosTheta3));
		r23:=ComplexDivision(numC,denC);
		t23:=ComplexDivision(MakeComplex(2*N2[1]*cosTheta2,0),denC);
	end;
	beta:=2*Pi*N2[1]*Thickness*cosTheta2/Lambda;
	e:=MakeComplex(Cos(-2*beta),Sin(-2*beta));
	e1:=ComplexMultiplication(r23,e);
	e2:=ComplexMultiplication(MakeComplex(t12*t21,0),e1);
	e3:=ComplexMultiplication(MakeComplex(r12,0),e1);
	e4:=ComplexAddition(MakeComplex(1,0),e3);
	e5:=ComplexDivision(e2,e4);
	r:=ComplexAddition(MakeComplex(r12,0),e5);
	num:=Sqr(r[1])+Sqr(r[2]);
	CalculateCompoundReflectance:=num;
end;

{.......................................................}

function CalculateCompoundReflectanceDiode(Lambda,Thickness,Theta1:Extended;Pol:string):Extended;
var
	n1,n2,refl:Extended;
	n2C,n3:ComplexNumber;
begin
	n1:=1.0003;
	n2:=CalculateQzRefractiveIndex(Lambda);
	n2C:=MakeComplex(n2,0);
	n3:=FindSiRefractiveIndex(Lambda);
  refl:=CalculateCompoundReflectance(Lambda,n1,Thickness,Theta1,n2C,n3,Pol);
  CalculateCompoundReflectanceDiode:=refl;
end;

{.......................................................}

function CalculateCompoundReflectanceMirror(Lambda,Thickness,Theta1:Extended;Pol:string):Extended;
var
	n1,n2,refl,thetaDeg:Extended;
	n2C,n3:ComplexNumber;
begin
  {if Lambda=560 then // Read reflectance value instead of calculating
  begin
    thetaDeg:=Theta1*180/Pi;
    refl:=FindMirrorReflectance(thetaDeg,Pol);
  end
  else
  begin}
    n1:=1.0003;
    n2:=CalculateQzRefractiveIndex(Lambda);
    n2C:=MakeComplex(n2,0);
    n3:=FindAlRefractiveIndex(Lambda);
    refl:=CalculateCompoundReflectance(Lambda,n1,Thickness,Theta1,n2C,n3,Pol);
  {end;}
  CalculateCompoundReflectanceMirror:=refl;
end;

{.......................................................}

function CalculatePolarisationRatio(PolVector,SurfaceNormal,BeamVector:TVector):T2Array;
var
	sVector,pVector:TVector;
	c:T2Array;
	sumC:Extended;
begin
	sVector:=NormaliseVector(CrossProduct(SurfaceNormal,BeamVector));
	pVector:=NormaliseVector(CrossProduct(sVector,BeamVector));
	c[1]:=DotProduct(PolVector,sVector);
	c[2]:=DotProduct(PolVector,pVector);
	if Sqr(c[1])+Sqr(C[2])=0 then
	begin
		c[1]:=0.5;
		c[2]:=0.5;
	end
	else
	begin
		sumC:=Abs(c[1])+Abs(c[2]);
		c[1]:=c[1]/sumC;
		c[2]:=c[2]/sumC;
	end;
	CalculatePolarisationRatio:=c;
end;

{.......................................................}

function PolarisationVector(C:T2Array;SurfaceNormal,BeamVector:TVector):TVector;
var
	sVector,pVector,polVector:TVector;
	i:Integer;
begin
	sVector:=NormaliseVector(CrossProduct(BeamVector,SurfaceNormal));
	pVector:=NormaliseVector(CrossProduct(sVector,BeamVector));
	for i:=1 to 3 do
		polVector[i]:=C[1]*sVector[i]+C[2]*pVector[i];
	PolarisationVector:=polVector;
end;

{.......................................................}

procedure CreateRotationMatrix(Angle:Extended;Axis:string;var R:TMatrix);
begin
	if (Axis='x') or (Axis='X') then
	begin
		R[1,1]:=1;
		R[1,2]:=0;
		R[1,3]:=0;
		R[2,1]:=0;
		R[2,2]:=Cos(Angle);
		R[2,3]:=-Sin(Angle);
		R[3,1]:=0;
		R[3,2]:=Sin(Angle);
		R[3,3]:=Cos(Angle);
  end
	else
		if (Axis='y') or (Axis='Y') then
		begin
			R[1,1]:=Cos(Angle);
			R[1,2]:=0;
			R[1,3]:=Sin(Angle);
			R[2,1]:=0;
			R[2,2]:=1;
			R[2,3]:=0;
			R[3,1]:=-Sin(Angle);
			R[3,2]:=0;
			R[3,3]:=Cos(Angle);
		end
		else
		begin
			R[1,1]:=Cos(Angle);
			R[1,2]:=-Sin(Angle);
			R[1,3]:=0;
			R[2,1]:=Sin(Angle);
			R[2,2]:=Cos(Angle);
			R[2,3]:=0;
			R[3,1]:=0;
			R[3,2]:=0;
			R[3,3]:=1;
		end;
end;

{.......................................................}

procedure CreateRotationMatrix2(Angle:Extended;Axis:TVector;var R:TMatrix);
var
	axisNorm,cosAngle,sinAngle:Extended;
begin
	// Normalise axis vector
	axisNorm:=Sqrt(DotProduct(Axis,Axis));
	if axisNorm<>1 then
	begin
		Axis[1]:=Axis[1]/axisNorm;
		Axis[2]:=Axis[2]/axisNorm;
		Axis[3]:=Axis[3]/axisNorm;
	end;
	cosAngle:=Cos(Angle);
	sinAngle:=Sin(Angle);
	R[1,1]:=cosAngle+Sqr(Axis[1])*(1-cosAngle);
	R[1,2]:=Axis[1]*Axis[2]*(1-cosAngle)-Axis[3]*sinAngle;
	R[1,3]:=Axis[1]*Axis[3]*(1-cosAngle)+Axis[2]*sinAngle;
	R[2,1]:=Axis[2]*Axis[1]*(1-cosAngle)+Axis[3]*sinAngle;
	R[2,2]:=cosAngle+Sqr(Axis[2])*(1-cosAngle);
	R[2,3]:=Axis[2]*Axis[3]*(1-cosAngle)-Axis[1]*sinAngle;
	R[3,1]:=Axis[3]*Axis[1]*(1-cosAngle)-Axis[2]*sinAngle;
	R[3,2]:=Axis[3]*Axis[2]*(1-cosAngle)+Axis[1]*sinAngle;
	R[3,3]:=cosAngle+Sqr(Axis[3])*(1-cosAngle);
end;

{.......................................................}

function NormaliseVector(V:TVector):TVector;
var
	norm:Extended;
	normalisedV:TVector;
	i:Integer;
begin
	norm:=Sqrt(DotProduct(V,V));
	for i:=1 to 3 do
		normalisedV[i]:=V[i]/norm;
	NormaliseVector:=normalisedV;
end;

{.......................................................}

function CalculateSiAngle(DetectorAngle,C1,C2:Extended;var MirrorNormal,DiodeNormal,BeamVector1,BeamVector2,BeamVector3:TVector):TVector;
var
	o,s,a,e,n,f,oVector,sVector,eVector,nVector,incidentPlaneNormal,toReturn:TVector;
	theta1,norm,t,theta2:Extended;
	rotateBeam,r:TMatrix;
	i:Integer;
begin
	o[1]:=C1+90*Sin(DetectorAngle);
	o[2]:=0;
	o[3]:=C2;
	s[1]:=-Rc*Sin(MirrorAngle);
	s[2]:=R1-Rc*Cos(MirrorAngle);
	s[3]:=Rc*Sin(MirrorAngle);
	a[1]:=C1;
	a[3]:=C2;
	a[2]:=Sqrt(Sqr(Rc)-Sqr(s[1]-a[1])-Sqr(s[3]-a[3]))+s[2];
	theta1:=AngleBetweenThreePoints(o,a,s);
	oVector:=NormaliseVector(VectorSubtraction(o,a));
	sVector:=NormaliseVector(VectorSubtraction(s,a));
	for i:=1 to 3 do
	begin
		eVector[i]:=2*DotProduct(oVector,sVector)*sVector[i]-oVector[i];
		e[i]:=a[i]+R2*eVector[i];
	end;
	nVector[1]:=Sin(DiodeAngle);
	nVector[2]:=Cos(DiodeAngle);
	nVector[3]:=-Sin(DiodeAngle);
	nVector:=NormaliseVector(nVector);
	for i:=1 to 3 do
		n[i]:=e[i]+nVector[i];
	{if DetectorAngle<>0 then
	begin
		CreateRotationMatrix(DetectorAngle,'z',r);
		s:=MatrixMultiplication(r,s);
		n:=MatrixMultiplication(r,n);
		f:=MatrixMultiplication(r,e);
		nVector:=NormaliseVector(VectorSubtraction(n,f));
		a[2]:=Sqrt(Sqr(Rc)-Sqr(s[1]-a[1])-Sqr(s[3]-a[3]))+s[2];
		theta1:=AngleBetweenThreePoints(o,a,s);
		oVector:=NormaliseVector(VectorSubtraction(o,a));
		sVector:=NormaliseVector(VectorSubtraction(s,a));
		for i:=1 to 3 do
			eVector[i]:=2*DotProduct(oVector,sVector)*sVector[i]-oVector[i];
		t:=(DotProduct(nVector,f)-DotProduct(a,nVector))/DotProduct(eVector,nVector);
		for i:=1 to 3 do
			e[i]:=a[i]+t*eVector[i];
		n:=VectorAddition(e,nVector);
	end;}
	theta2:=AngleBetweenThreePoints(a,e,n);
	MirrorNormal:=sVector;
	DiodeNormal:=nVector;
	BeamVector1:=NormaliseVector(VectorSubtraction(o,a));
	BeamVector2:=NormaliseVector(VectorSubtraction(e,a));
	BeamVector3:=NormaliseVector(VectorSubtraction(a,e));
  toReturn[1]:=theta2;
  toReturn[2]:=theta1;
	CalculateSiAngle:=toReturn;
end;

{.......................................................}

function CalculateSiAngleDiffuse(DetectorAngle,Cxi,Cyi,Cxm,Cym:Extended;var MirrorNormal,
							DiodeNormal,BeamVector1,BeamVector2,BeamVector3,MirrorPosition:TVector;var ThetaD,L:Extended):TVector;
// Cxi,Cyi are the x and y positions of the beam at the sample position, Cxm,Cym are the x and y positions
// of the beam when it goes through the aperture. We calculate the position of where these hit the mirror.
var
	o,m,s,a,e,n,f,os,b,oa:TVector;
	oVector,sVector,eVector,nVector,mVector,incidentPlaneNormal,toReturn:TVector;
	discriminant:Extended;
	theta1,norm,t,theta2:Extended;
	rotateBeam,r:TMatrix;
	i:Integer;
begin
	o[1]:=Cxi;
	o[2]:=0;
	o[3]:=Cyi;
	m[1]:=Cxm;
	m[2]:=500;
	m[3]:=Cym;
	s[1]:=-Rc*Sin(MirrorAngle);
	s[2]:=R1-Rc*Cos(MirrorAngle);
	s[3]:=Rc*Sin(MirrorAngle);
	mVector:=NormaliseVector(VectorSubtraction(m,o));
	os:=VectorSubtraction(o,s);
	discriminant:=Sqr(Rc)+Sqr(DotProduct(mVector,os))-DotProduct(os,os);
	t:=-DotProduct(mVector,os)+Sqrt(discriminant);
	for i:=1 to 3 do
		a[i]:=o[i]+t*mVector[i];
	oVector:=NormaliseVector(VectorSubtraction(o,a));
	sVector:=NormaliseVector(VectorSubtraction(s,a));
	theta1:=AngleBetweenThreePoints(o,a,s);
	for i:=1 to 3 do
	begin
		eVector[i]:=2*DotProduct(oVector,sVector)*sVector[i]-oVector[i];
		e[i]:=a[i]+R2*eVector[i];
	end;
	nVector[1]:=Sin(DiodeAngle);
	nVector[2]:=Cos(DiodeAngle);
	nVector[3]:=-Sin(DiodeAngle);
	nVector:=NormaliseVector(nVector);
	for i:=1 to 3 do
		n[i]:=e[i]+nVector[i];
	if DetectorAngle<>0 then
	begin
		CreateRotationMatrix(DetectorAngle,'z',r);
		a:=MatrixMultiplication(r,a);
		s:=MatrixMultiplication(r,s);
		n:=MatrixMultiplication(r,n);
		f:=MatrixMultiplication(r,e);
		nVector:=NormaliseVector(VectorSubtraction(n,f));
		theta1:=AngleBetweenThreePoints(o,a,s);
		oVector:=NormaliseVector(VectorSubtraction(o,a));
		sVector:=NormaliseVector(VectorSubtraction(s,a));
		for i:=1 to 3 do
			eVector[i]:=2*DotProduct(oVector,sVector)*sVector[i]-oVector[i];
		t:=(DotProduct(nVector,f)-DotProduct(a,nVector))/DotProduct(eVector,nVector);
		for i:=1 to 3 do
			e[i]:=a[i]+t*eVector[i];
		n:=VectorAddition(e,nVector);
	end;
	b[1]:=Cxi;
	b[2]:=R1;
	b[3]:=Cyi;
	ThetaD:=AngleBetweenThreePoints(b,o,a);
	oa:=VectorSubtraction(o,a);
	L:=Sqrt(DotProduct(oa,oa));
	theta2:=AngleBetweenThreePoints(a,e,n);
	MirrorNormal:=sVector;
	DiodeNormal:=nVector;
  MirrorPosition:=a;
	BeamVector1:=NormaliseVector(oa);
	BeamVector2:=NormaliseVector(VectorSubtraction(e,a));
	BeamVector3:=NormaliseVector(VectorSubtraction(a,e));
  toReturn[1]:=theta2;
  toReturn[2]:=theta1;
	CalculateSiAngleDiffuse:=toReturn;
end;

{.......................................................}

function CalculateAbsorbance(Lambda,Thickness,Theta,MirrorTheta:Extended;SiNormal,MirrorNormal,BeamVector1,BeamVector2,
							BeamVector3:TVector;Pol:string):Extended;
var
	 polVector1,polVector2:TVector;
	 cMirror,cDiode:T2Array;
	 qzWindowTransmittanceS,qzWindowTransmittanceP,siReflectanceS,siReflectanceP:Extended;
	 mirrorReflectanceP,mirrorReflectanceS,mirrorR,minDistance:Extended;
   absorbanceS,absorbanceP,absorbance,thisDistance,mirrorAngleDeg:Extended;
   i,wavelengthInd,minInd,lower,upper:Integer;
   thisMirrorTheta,thisMirrorCs,thisDiodeTheta,thisDiodeCs,gradient:Extended;
   finished:Boolean;
begin
	if Pol='s' then
	begin
		polVector1[1]:=0;
		polVector1[2]:=0;
		polVector1[3]:=1;
	end
	else
	begin
		polVector1[1]:=1;
		polVector1[2]:=0;
		polVector1[3]:=0;
	end;
	cMirror:=CalculatePolarisationRatio(polVector1,MirrorNormal,BeamVector1);
	polVector2:=PolarisationVector(cMirror,MirrorNormal,BeamVector2);
	cDiode:=CalculatePolarisationRatio(polVector2,SiNormal,BeamVector3);
  mirrorReflectanceP:=CalculateCompoundReflectanceMirror(Lambda,205,MirrorTheta,'p');
  mirrorReflectanceS:=CalculateCompoundReflectanceMirror(Lambda,205,MirrorTheta,'s');

  (*// Look up mirror reflectance from measured data
  case Round(Lambda) of
    440:wavelengthInd:=2;
    460:wavelengthInd:=4;
    480:wavelengthInd:=6;
    530:wavelengthInd:=8;
    580:wavelengthInd:=10;
    630:wavelengthInd:=12;
    680:wavelengthInd:=14;
    730:wavelengthInd:=16;
    780:wavelengthInd:=18;
    830:wavelengthInd:=20;
    900:wavelengthInd:=22;
  end;
  // Find two closest values to incident angle
  mirrorAngleDeg:=MirrorTheta*180/Pi;
  finished:=False;
	for i:=1 to 56 do
	begin
		if not finished then
		begin
			if MirrorRefl[1,i]>mirrorAngleDeg then
			begin
				lower:=i-1;
				upper:=i;
				finished:=True;
			end;
		end;
	end;
  gradient:=(MirrorRefl[wavelengthInd,upper]-MirrorRefl[wavelengthInd,lower])/0.2;
  mirrorReflectanceS:=MirrorRefl[wavelengthInd,lower]+gradient*(mirrorAngleDeg-0.2);
  gradient:=(MirrorRefl[wavelengthInd+1,upper]-MirrorRefl[wavelengthInd+1,lower])/0.2;
  mirrorReflectanceP:=MirrorRefl[wavelengthInd+1,lower]+gradient*(mirrorAngleDeg-0.2);*)

  {mirrorR:=Abs(cMirror[1])*mirrorReflectanceS+Abs(cMirror[2])*mirrorReflectanceP;
	siReflectanceP:=CalculateCompoundReflectanceDiode(Lambda,Thickness,Theta,'p');
	siReflectanceS:=CalculateCompoundReflectanceDiode(Lambda,Thickness,Theta,'s');
	absorbanceP:=(1-siReflectanceP);
	absorbanceS:=(1-siReflectanceS);
  if IncludeMirrorRefl then
    absorbance:=mirrorR*(Abs(cDiode[1])*absorbanceS+Abs(cDiode[2])*absorbanceP)
  else
  	absorbance:=Abs(cDiode[1])*absorbanceS+Abs(cDiode[2])*absorbanceP;
	CalculateAbsorbance:=absorbance;}

  // Using cMirror[1], cDiode[1], MirrorTheta, Theta (diodeTheta), find closest
  //point in 4-D space from measured data and use that value as absorbance

  // sqrt sum squares of distances. go through each option and find smallest
  minDistance:=10000;

  {if Lambda=560 then
    wavelengthInd:=5
  else
    if Lambda<490 then
      wavelengthInd:=Round(Lambda/20-12)
    else
      wavelengthInd:=Round(Lambda/50+2.4);}

  case Round(Lambda) of
    560:wavelengthInd:=19;
    360:wavelengthInd:=6;
    380:wavelengthInd:=7;
    420:wavelengthInd:=8;
    480:wavelengthInd:=9;
    530:wavelengthInd:=10;
    680:wavelengthInd:=11;
    780:wavelengthInd:=12;
    1000:wavelengthInd:=13;
    830:wavelengthInd:=14;
    900:wavelengthInd:=15;
  end;

  {if Lambda=360 then
    wavelengthInd:=5
  else
    wavelengthInd:=6;}

  for i:=1 to 275 do
  begin
    thisMirrorTheta:=MeasuredData[1,i];
    thisMirrorCs:=MeasuredData[2,i];
    thisDiodeTheta:=MeasuredData[3,i];
    thisDiodeCs:=MeasuredData[4,i];
    thisDistance:=Sqrt(Sqr(MirrorTheta-thisMirrorTheta)+Sqr(cMirror[1]-thisMirrorCs)+Sqr(Theta-thisDiodeTheta)+Sqr(cDiode[1]-thisDiodeCs));
    if thisDistance<minDistance then
    begin
      minDistance:=thisDistance;
      minInd:=i;
    end;
  end;
  absorbance:=MeasuredData[wavelengthInd,minInd];
  if PrintC then
  begin
    Write(fl,Pol,#9,Theta*180/Pi,#9,MirrorTheta*180/Pi,#9,Abs(cDiode[1]),#9,Abs(cDiode[2]),#9,Abs(cMirror[1]),#9,absorbance);
    Writeln(fl);
  end;
  CalculateAbsorbance:=absorbance;

end;

{.......................................................}

function CalculateMirrorReflectance(Lambda,Thickness,Theta:Extended;{MirrorNormal,BeamVector1:TVector;}Pol:String):Extended;
var
	 reflectance:Extended;
begin
  reflectance:=CalculateCompoundReflectanceMirror(Lambda,Thickness,Theta,Pol);
  CalculateMirrorReflectance:=reflectance;
end;

{.......................................................}

procedure CreateSiRefractiveIndexTable;
begin
	lambdaTable[1]:=350;
	SiReal[1]:=5.486;
	SiImaginary[1]:=2.904;
	lambdaTable[2]:=360;
	SiReal[2]:=6.018;
	SiImaginary[2]:=2.912;
	lambdaTable[3]:=370;
	SiReal[3]:=6.871;
	SiImaginary[3]:=2.049;
	lambdaTable[4]:=380;
	SiReal[4]:=6.548;
	SiImaginary[4]:=0.875;
	lambdaTable[5]:=390;
	SiReal[5]:=5.972;
	SiImaginary[5]:=0.457;
	lambdaTable[6]:=400;
	SiReal[6]:=5.585;
	SiImaginary[6]:=0.296;
	lambdaTable[7]:=410;
	SiReal[7]:=5.301;
	SiImaginary[7]:=0.215;
	lambdaTable[8]:=420;
	SiReal[8]:=5.087;
	SiImaginary[8]:=0.165;
	lambdaTable[9]:=430;
	SiReal[9]:=4.921;
	SiImaginary[9]:=0.133;
	lambdaTable[10]:=440;
	SiReal[10]:=4.79;
	SiImaginary[10]:=0.109;
	lambdaTable[11]:=450;
	SiReal[11]:=4.673;
	SiImaginary[11]:=0.092;
	lambdaTable[12]:=460;
	SiReal[12]:=4.574;
	SiImaginary[12]:=0.079;
	lambdaTable[13]:=470;
	SiReal[13]:=4.488;
	SiImaginary[13]:=0.068;
	lambdaTable[14]:=480;
	SiReal[14]:=4.413;
	SiImaginary[14]:=0.060;
	lambdaTable[15]:=490;
	SiReal[15]:=4.345;
	SiImaginary[15]:=0.053;
	lambdaTable[16]:=500;
	SiReal[16]:=4.290;
	SiImaginary[16]:=0.047;
	lambdaTable[17]:=510;
	SiReal[17]:=4.237;
	SiImaginary[17]:=0.042;
	lambdaTable[18]:=520;
	SiReal[18]:=4.190;
	SiImaginary[18]:=0.038;
	lambdaTable[19]:=530;
	SiReal[19]:=4.148;
	SiImaginary[19]:=0.034;
	lambdaTable[20]:=540;
	SiReal[20]:=4.108;
	SiImaginary[20]:=0.031;
	lambdaTable[21]:=550;
	SiReal[21]:=4.075;
	SiImaginary[21]:=0.029;
	lambdaTable[22]:=560;
	SiReal[22]:=4.042;
	SiImaginary[22]:=0.026;
	lambdaTable[23]:=570;
	SiReal[23]:=4.013;
	SiImaginary[23]:=0.025;
	lambdaTable[24]:=580;
	SiReal[24]:=3.984;
	SiImaginary[24]:=0.023;
	lambdaTable[25]:=590;
	SiReal[25]:=3.960;
	SiImaginary[25]:=0.022;
	lambdaTable[26]:=600;
	SiReal[26]:=3.937;
	SiImaginary[26]:=0.019;
	lambdaTable[27]:=610;
	SiReal[27]:=3.914;
	SiImaginary[27]:=0.019;
	lambdaTable[28]:=620;
	SiReal[28]:=3.893;
	SiImaginary[28]:=0.017;
	lambdaTable[29]:=630;
	SiReal[29]:=3.877;
	SiImaginary[29]:=0.016;
	lambdaTable[30]:=640;
	SiReal[30]:=3.859;
	SiImaginary[30]:=0.015;
	lambdaTable[31]:=650;
	SiReal[31]:=3.842;
	SiImaginary[31]:=0.014;
	lambdaTable[32]:=660;
	SiReal[32]:=3.828;
	SiImaginary[32]:=0.014;
	lambdaTable[33]:=670;
	SiReal[33]:=3.813;
	SiImaginary[33]:=0.013;
	lambdaTable[34]:=680;
	SiReal[34]:=3.798;
	SiImaginary[34]:=0.013;
	lambdaTable[35]:=690;
	SiReal[35]:=3.785;
	SiImaginary[35]:=0.012;
	lambdaTable[36]:=700;
	SiReal[36]:=3.772;
	SiImaginary[36]:=0.011;
	lambdaTable[37]:=710;
	SiReal[37]:=3.760;
	SiImaginary[37]:=0.010;
	lambdaTable[38]:=720;
	SiReal[38]:=3.750;
	SiImaginary[38]:=0.010;
	lambdaTable[39]:=730;
	SiReal[39]:=3.738;
	SiImaginary[39]:=0.011;
	lambdaTable[40]:=740;
	SiReal[40]:=3.731;
	SiImaginary[40]:=0.009;
	lambdaTable[41]:=750;
	SiReal[41]:=3.720;
	SiImaginary[41]:=0.007;
	lambdaTable[42]:=760;
	SiReal[42]:=3.712;
	SiImaginary[42]:=0.008;
	lambdaTable[43]:=770;
	SiReal[43]:=3.706;
	SiImaginary[43]:=0.006;
	lambdaTable[44]:=780;
	SiReal[44]:=3.695;
	SiImaginary[44]:=0.006;
	lambdaTable[45]:=790;
	SiReal[45]:=3.686;
	SiImaginary[45]:=0.007;
	lambdaTable[46]:=800;
	SiReal[46]:=3.682;
	SiImaginary[46]:=0.006;
	lambdaTable[47]:=810;
	SiReal[47]:=3.673;
	SiImaginary[47]:=0.007;
	lambdaTable[48]:=820;
	SiReal[48]:=3.666;
	SiImaginary[48]:=0.005;
	lambdaTable[49]:=830;
	SiReal[49]:=3.663;
	SiImaginary[49]:=0.006;
	lambdaTable[50]:=840;
	SiReal[50]:=3.659;
	SiImaginary[50]:=0.004;
end;

{.......................................................}

procedure CreateAlRefractiveIndexTable;
begin
  AlLambdaTable[1]:=349.25;
  AlReal[1]:=0.3744;
  AlImaginary[1]:=4.23375;
  AlLambdaTable[2]:=354.24;
  AlReal[2]:=0.385;
  AlImaginary[2]:=4.3;
  AlLambdaTable[3]:=359.38;
  AlReal[3]:=0.3958;
  AlImaginary[3]:=4.365;
  AlLambdaTable[4]:=364.66;
  AlReal[4]:=0.407;
  AlImaginary[4]:=4.43;
  AlLambdaTable[5]:=370.11;
  AlReal[5]:=0.4191;
  AlImaginary[5]:=4.49375;
  AlLambdaTable[6]:=375.71;
  AlReal[6]:=0.432;
  AlImaginary[6]:=4.56;
  AlLambdaTable[7]:=381.49;
  AlReal[7]:=0.4457;
  AlImaginary[7]:=4.63375;
  AlLambdaTable[8]:=387.45;
  AlReal[8]:=0.46;
  AlImaginary[8]:=4.71;
  AlLambdaTable[9]:=393.6;
  AlReal[9]:=0.4747;
  AlImaginary[9]:=4.784375;
  AlLambdaTable[10]:=399.95;
  AlReal[10]:=0.49;
  AlImaginary[10]:=4.86;
  AlLambdaTable[11]:=406.51;
  AlReal[11]:=0.5062;
  AlImaginary[11]:=4.938125;
  AlLambdaTable[12]:=413.28;
  AlReal[12]:=0.523;
  AlImaginary[12]:=5.02;
  AlLambdaTable[13]:=420.29;
  AlReal[13]:=0.5401;
  AlImaginary[13]:=5.10875;
  AlLambdaTable[14]:=427.54;
  AlReal[14]:=0.558;
  AlImaginary[14]:=5.2;
  AlLambdaTable[15]:=435.04;
  AlReal[15]:=0.5773;
  AlImaginary[15]:=5.29;
  AlLambdaTable[16]:=442.8;
  AlReal[16]:=0.598;
  AlImaginary[16]:=5.38;
  AlLambdaTable[17]:=450.86;
  AlReal[17]:=0.6203;
  AlImaginary[17]:=5.48;
  AlLambdaTable[18]:=459.2;
  AlReal[18]:=0.644;
  AlImaginary[18]:=5.58;
  AlLambdaTable[19]:=467.87;
  AlReal[19]:=0.6686;
  AlImaginary[19]:=5.69;
  AlLambdaTable[20]:=476.87;
  AlReal[20]:=0.695;
  AlImaginary[20]:=5.8;
  AlLambdaTable[21]:=486.22;
  AlReal[21]:=0.7238;
  AlImaginary[21]:=5.915;
  AlLambdaTable[22]:=495.94;
  AlReal[22]:=0.755;
  AlImaginary[22]:=6.03;
  AlLambdaTable[23]:=506.06;
  AlReal[23]:=0.789;
  AlImaginary[23]:=6.15;
  AlLambdaTable[24]:=516.6;
  AlReal[24]:=0.826;
  AlImaginary[24]:=6.28;
  AlLambdaTable[25]:=527.6;
  AlReal[25]:=0.867;
  AlImaginary[25]:=6.42;
  AlLambdaTable[26]:=539.07;
  AlReal[26]:=0.912;
  AlImaginary[26]:=6.55;
  AlLambdaTable[27]:=551.05;
  AlReal[27]:=0.963;
  AlImaginary[27]:=6.7;
  AlLambdaTable[28]:=563.57;
  AlReal[28]:=1.02;
  AlImaginary[28]:=6.85;
  AlLambdaTable[29]:=576.68;
  AlReal[29]:=1.08;
  AlImaginary[29]:=7.0;
  AlLambdaTable[30]:=590.41;
  AlReal[30]:=1.15;
  AlImaginary[30]:=7.15;
  AlLambdaTable[31]:=604.81;
  AlReal[31]:=1.22;
  AlImaginary[31]:=7.31;
  AlLambdaTable[32]:=619.93;
  AlReal[32]:=1.3;
  AlImaginary[32]:=7.48;
  AlLambdaTable[33]:=635.82;
  AlReal[33]:=1.39;
  AlImaginary[33]:=7.65;
  AlLambdaTable[34]:=652.55;
  AlReal[34]:=1.49;
  AlImaginary[34]:=7.82;
  AlLambdaTable[35]:=670.19;
  AlReal[35]:=1.6;
  AlImaginary[35]:=8.01;
  AlLambdaTable[36]:=688.81;
  AlReal[36]:=1.74;
  AlImaginary[36]:=8.21;
  AlLambdaTable[37]:=708.49;
  AlReal[37]:=1.91;
  AlImaginary[37]:=8.39;
  AlLambdaTable[38]:=729.32;
  AlReal[38]:=2.14;
  AlImaginary[38]:=8.57;
  AlLambdaTable[39]:=751.43;
  AlReal[39]:=2.41;
  AlImaginary[39]:=8.62;
  AlLambdaTable[40]:=774.91;
  AlReal[40]:=2.63;
  AlImaginary[40]:=8.6;
  AlLambdaTable[41]:=799.9;
  AlReal[41]:=2.8;
  AlImaginary[41]:=8.45;
  AlLambdaTable[42]:=826.57;
  AlReal[42]:=2.74;
  AlImaginary[42]:=8.31;
  AlLambdaTable[43]:=855.07;
  AlReal[43]:=2.58;
  AlImaginary[43]:=8.21;
end;

{.......................................................}

procedure ReadBeamFile(FileS,FileP:string;var Valid:Boolean);
var
	i,j:Integer;
	f:TextFile;

	procedure ReadFile(FileName:string;var BeamArray:TBeamArray);
	var
		f:TextFile;
		S:string;
		i,j,pos1:Integer;
	begin
		if FileExists(FileName) then
		begin
			AssignFile(f,FileName);
			Reset(f);
			for j:=N downto -N do
			begin
				Readln(f,S);
				for i:=-N to N do
				begin
					pos1:=Pos(#9,S);
					if pos1=0 then
						pos1:=Length(S)+1;
					if (i+XOffsetVF>=-N) and (i+XOffsetVF<=N) and (j+YOffsetVF>=-N) and (j+YOffsetVF<=N) then
						BeamArray[i+XOffsetVF,j+YOffsetVF]:=StrToFloat(Copy(S,1,pos1-1));
					S:=Copy(S,pos1+1,Length(S)-pos1);
				end;
			end;
			CloseFile(f);
			Valid:=True;
		end
		else
		begin
			ShowMessage('The file "'+FileName+'" doesn''t exist.');
			Valid:=False;
		end;
	end;

begin
	if Mode<>ViewFactor then
	begin
		XOffsetVF:=0;
		YOffsetVF:=0;
	end;
	for i:=-N to N do
		for j:=-N to N do
		begin
			SBeam[i,j]:=0;
			PBeam[i,j]:=0;
		end;
	ReadFile(FileS,SBeam);
	if Valid then
		ReadFile(FileP,PBeam);
	{AssignFile(f,'Output.txt');
	Rewrite(f);
	for j:=N downto -N do
	begin
		for i:=-N to N do
			Write(f,sBeam[i,j],#9);
		Writeln(f);
	end;
	CloseFile(f);}
end;

{.......................................................}

function CalculateRDiffuse(Lambda,Thickness,DetAngle:Extended;var rDiffuseS,rDiffuseP:Extended):Extended;
var
	i,j,ii,jj:Integer;
	cxi,cyi,cxm,cym,thetaD,L,cosThetaD,lengthRatio,siIncidentAngle:Extended;
	t,xs,ys,L2,td,pitchRad:Extended;
	sampleVector,sampleNormal,detVector,lengthVector,mirrorPos:TVector;
	mirrorNormal,diodeNormal,beamVector1,beamVector2,beamVector3:TVector;
	r:TMatrix;
	sAbsorbance,pAbsorbance,perfectBeam,mirrorAngle,cos45:Extended;
  siAngles:TVector;
begin
	sAbsorbance:=0;
	pAbsorbance:=0;
	perfectBeam:=0;
  PrintC:=False;
  cos45:=Cos(45*Pi/180);
	// Iterate through all points in sample beam and all points in detector
	for i:=-20 to 20 do
		for j:=-20 to 20 do
		begin
			cxi:=i;
			cyi:=j;
			if Sqr(cxi)+Sqr(cyi)<=Sqr(BeamRadius) then
      {if Sqr(cxi/(BeamRadius/cos45))+Sqr(cyi/BeamRadius)<=1 then}
			begin
				// Rotate pitch
				if DiffusePitch<>0 then
				begin
					sampleVector[1]:=cxi;
					sampleVector[2]:=0;
					sampleVector[3]:=cyi;
					sampleNormal[1]:=cxi;
					sampleNormal[2]:=1;
					sampleNormal[3]:=cyi;
          pitchRad:=DiffusePitch*Pi/180;
					CreateRotationMatrix(pitchRad,'x',r);
					sampleVector:=MatrixMultiplication(r,sampleVector);
					sampleNormal:=MatrixMultiplication(r,sampleNormal);
				end;
				for ii:=-20 to 20 do
					for jj:=-20 to 20 do
					begin
						cxm:=ii;
						cym:=jj;
						if Sqr(cxm)+Sqr(cym)<=Sqr(DetectorRadius) then
						begin
							if DiffusePitch=0 then
							begin
                siAngles:=CalculateSiAngleDiffuse(DetAngle,cxi,cyi,cxm,cym,mirrorNormal,diodeNormal,beamVector1,beamVector2,beamVector3,mirrorPos,thetaD,L);
								siIncidentAngle:=siAngles[1];
                mirrorAngle:=siAngles[2];
								cosThetaD:=Abs(Cos(thetaD));
                sampleVector[1]:=cxi;
                sampleVector[2]:=0;
                sampleVector[3]:=cyi;
                sampleNormal[1]:=cxi;
                sampleNormal[2]:=1;
                sampleNormal[3]:=cyi;
                td:=AngleBetweenThreePoints(sampleNormal,sampleVector,mirrorPos){AngleBetweenVectors(sampleNormal,mirrorPos)};
								cosThetaD:=Abs(Cos(td));
								lengthRatio:=Sqr(R1)/Sqr(L);
								sAbsorbance:=sAbsorbance+CalculateAbsorbance(Lambda,Thickness,siIncidentAngle,mirrorAngle,diodeNormal,mirrorNormal,beamVector1,beamVector2,beamVector3,'s')*cosThetaD*lengthRatio;
								pAbsorbance:=pAbsorbance+CalculateAbsorbance(Lambda,Thickness,siIncidentAngle,mirrorAngle,diodeNormal,mirrorNormal,beamVector1,beamVector2,beamVector3,'p')*cosThetaD*lengthRatio;
								perfectBeam:=perfectBeam+cosThetaD*lengthRatio;
                {Write(fl,pol,#9,FloatToStr(td*180/Pi),#9,FloatToStr(lengthRatio),#9,R1,#9,L);
                Writeln(fl);}
							end
							else
							begin
								detVector[1]:=cxm;
								detVector[2]:=R1;
								detVector[3]:=cym;

								// Calculate the x and y coordinates for the beam when the z coordinate is zero (xs,ys - positions on sample) and calculate theta d
								t:=-sampleVector[2]/(R1-sampleVector[2]);
								xs:=t*(cxm-sampleVector[1])+sampleVector[1];
								ys:=t*(cym-sampleVector[2])+sampleVector[3];
								CreateRotationMatrix(DetAngle,'z',r);
								detVector:=MatrixMultiplication(r,detVector);

								// Calculate the si incident angle
                siAngles:=CalculateSiAngleDiffuse(DetAngle,xs,ys,cxm,cym,mirrorNormal,diodeNormal,beamVector1,beamVector2,beamVector3,mirrorPos,thetaD,L);
								siIncidentAngle:=siAngles[1];
                mirrorAngle:=siAngles[2];

								// Calculate cos theta d and the length ratio
                td:=AngleBetweenThreePoints(sampleNormal,sampleVector,mirrorPos){AngleBetweenVectors(sampleNormal,mirrorPos)};
								cosThetaD:=Abs(Cos(td));
								lengthVector:=(VectorSubtraction(sampleVector,mirrorPos));
								L2:=Sqrt(DotProduct(lengthVector,lengthVector));
								lengthRatio:=Sqr(R1)/Sqr(L2);

								// Calculate absorbances and perfect beam value
								sAbsorbance:=sAbsorbance+CalculateAbsorbance(Lambda,Thickness,siIncidentAngle,mirrorAngle,diodeNormal,mirrorNormal,beamVector1,beamVector2,beamVector3,'s')*cosThetaD*lengthRatio;
								pAbsorbance:=pAbsorbance+CalculateAbsorbance(Lambda,Thickness,siIncidentAngle,mirrorAngle,diodeNormal,mirrorNormal,beamVector1,beamVector2,beamVector3,'p')*cosThetaD*lengthRatio;
								perfectBeam:=perfectBeam+cosThetaD*lengthRatio;

                {Write(fl,pol,#9,FloatToStr(td*180/Pi),#9,FloatToStr(lengthRatio),#9,L2,#9,L);
                Writeln(fl);}
              end;
						end;
						Application.ProcessMessages;
					end;
			end;
		end;
  rDiffuseS:=sAbsorbance/perfectBeam;
  rDiffuseP:=pAbsorbance/perfectBeam;
	CalculateRDiffuse:=(sAbsorbance+pAbsorbance)/(2*perfectBeam);
end;

{.......................................................}

function CalculateRDiffuseBeamData(Lambda,Thickness,DetAngle:Extended;var RDiffuseS,RDiffuseP:Extended):Boolean;
var
	i,j,ii,jj:Integer;
	cxi,cyi,cxm,cym,thetaD,L,cosThetaD,lengthRatio,siIncidentAngle:Extended;
	mirrorNormal,diodeNormal,beamVector1,beamVector2,beamVector3,mirrorPos:TVector;
	sAbsorbanceS,sAbsorbanceP,pAbsorbanceS,pAbsorbanceP,perfectBeamS,perfectBeamP:Extended;
  avgDiodeAngle,sRefl,pRefl,mirrorAngle:Extended;
  ind:Integer;
  siAngles:TVector;
begin
	sAbsorbanceS:=0;
	sAbsorbanceP:=0;
	pAbsorbanceS:=0;
	pAbsorbanceP:=0;
	perfectBeamS:=0;
	perfectBeamP:=0;
  ind:=0;
  avgDiodeAngle:=0;
	for i:=-20 to 20 do
		for j:=-20 to 20 do
		begin
			cxi:=i;
			cyi:=j;
			for ii:=-20 to 20 do
				for jj:=-20 to 20 do
				begin
					cxm:=ii;
					cym:=jj;
					if Sqr(cxm)+Sqr(cym)<=Sqr(DetectorRadius) then
					begin
            siAngles:=CalculateSiAngleDiffuse(DetAngle,cxi,cyi,cxm,cym,mirrorNormal,diodeNormal,beamVector1,beamVector2,beamVector3,mirrorPos,thetaD,L);
						siIncidentAngle:=siAngles[1];
            mirrorAngle:=siAngles[2];
						cosThetaD:=Cos(thetaD);
						lengthRatio:=Sqr(R1)/Sqr(L);
						sAbsorbanceS:=sAbsorbanceS+CalculateAbsorbance(Lambda,Thickness,siIncidentAngle,mirrorAngle,diodeNormal,mirrorNormal,beamVector1,beamVector2,beamVector3,'s')*SBeam[i,j]*cosThetaD*lengthRatio;
						sAbsorbanceP:=sAbsorbanceP+CalculateAbsorbance(Lambda,Thickness,siIncidentAngle,mirrorAngle,diodeNormal,mirrorNormal,beamVector1,beamVector2,beamVector3,'p')*SBeam[i,j]*cosThetaD*lengthRatio;
						pAbsorbanceS:=pAbsorbanceS+CalculateAbsorbance(Lambda,Thickness,siIncidentAngle,mirrorAngle,diodeNormal,mirrorNormal,beamVector1,beamVector2,beamVector3,'s')*PBeam[i,j]*cosThetaD*lengthRatio;
						pAbsorbanceP:=pAbsorbanceP+CalculateAbsorbance(Lambda,Thickness,siIncidentAngle,mirrorAngle,diodeNormal,mirrorNormal,beamVector1,beamVector2,beamVector3,'p')*PBeam[i,j]*cosThetaD*lengthRatio;
						perfectBeamS:=perfectBeamS+cosThetaD*lengthRatio*SBeam[i,j];
						perfectBeamP:=perfectBeamP+cosThetaD*lengthRatio*PBeam[i,j];
            avgDiodeAngle:=avgDiodeAngle+siIncidentAngle;
            Inc(ind);
					end;
					Application.ProcessMessages;
				end;
		end;
	RDiffuseS:=(sAbsorbanceS+sAbsorbanceP)/(2*perfectBeamS);
	RDiffuseP:=(pAbsorbanceS+pAbsorbanceP)/(2*perfectBeamP);
  avgDiodeAngle:=avgDiodeAngle*180/Pi/ind;
  sRefl:=CalculateCompoundReflectanceDiode(Lambda,Thickness,avgDiodeAngle*Pi/180,'s');
  pRefl:=CalculateCompoundReflectanceDiode(Lambda,Thickness,avgDiodeAngle*Pi/180,'p');
	CalculateRDiffuseBeamData:=True;
end;

{.......................................................}

function CalculateRCollimated(Lambda,Thickness,DetAngle,XOffset,YOffset:Extended;Pol:string;UseBeamData:Boolean):Extended;
var
	absorbance,perfectBeam:Extended;
	i,j,cx2,cy2,ind:Integer;
	cx,cy,siIncidentAngle:Extended;
	mirrorNormal,diodeNormal,beamVector1,beamVector2,beamVector3:TVector;
	thisBeamData:TBeamArray;
  avgDiodeAngle,sRefl,pRefl,mirrorAngle:Extended;
  siAngles:TVector;
begin
	absorbance:=0;
	perfectBeam:=0;
  ind:=0;
  avgDiodeAngle:=0;
  PrintC:=True;
	if UseBeamData then
	begin
		if Pol='s' then
			thisBeamData:=SBeam
		else
			thisBeamData:=PBeam;
  	for i:=-15 to 15 do
			for j:=-15 to 15 do
			begin
				cx:=i+XOffset;
				cy:=j-YOffset;
				// Calculate Si angle, mirror normal, polarisation vectors, and Si normal at detector angle
        siAngles:=CalculateSiAngle(DetAngle,cx,cy,mirrorNormal,diodeNormal,beamVector1,beamVector2,beamVector3);
				siIncidentAngle:=siAngles[1];
        mirrorAngle:=siAngles[2];
				cx2:=Round(cx);
				cy2:=Round(cy);
				if cx2>15 then
					cx2:=15
				else
					if cx2<-15 then
						cx2:=-15;
				if cy2>15 then
					cy2:=15
				else
					if cy2<-15 then
						cy2:=-15;
				absorbance:=absorbance+CalculateAbsorbance(Lambda,Thickness,siIncidentAngle,mirrorAngle,diodeNormal,mirrorNormal,beamVector1,beamVector2,beamVector3,Pol)*thisBeamData[cx2,cy2];
				perfectBeam:=perfectBeam+thisBeamData[cx2,cy2];
        avgDiodeAngle:=avgDiodeAngle+siIncidentAngle;
        Inc(ind);
			end;
	end
	else
	begin
		for j:=-20 to 20 do
			for i:=-20 to 20 do
      {if (i mod 2=0) and (j mod 2=0) then}
			begin
				cx:=i+XOffset;
				cy:=j-YOffset;
				if Sqr(i+90*Sin(DetAngle))+Sqr(j)<Sqr(BeamRadius) then
				begin
					// Calculate Si angle, mirror normal, polarisation vectors, and Si normal at detector angle
          siAngles:=CalculateSiAngle(DetAngle,cx,cy,mirrorNormal,diodeNormal,beamVector1,beamVector2,beamVector3);
					siIncidentAngle:=siAngles[1];
          mirrorAngle:=siAngles[2];
					absorbance:=absorbance+CalculateAbsorbance(Lambda,Thickness,siIncidentAngle,mirrorAngle,diodeNormal,mirrorNormal,beamVector1,beamVector2,beamVector3,Pol);
					perfectBeam:=perfectBeam+1;
          avgDiodeAngle:=avgDiodeAngle+siIncidentAngle;
          Inc(ind);
				end
        else
        begin
          Write(fl,Pol);
          Writeln(fl);
        end;
			end;
	end;
  avgDiodeAngle:=avgDiodeAngle*180/Pi/ind;
  sRefl:=CalculateCompoundReflectanceDiode(Lambda,Thickness,avgDiodeAngle*Pi/180,'s');
  pRefl:=CalculateCompoundReflectanceDiode(Lambda,Thickness,avgDiodeAngle*Pi/180,'p');
	CalculateRCollimated:=absorbance/perfectBeam;
end;

{.......................................................}

{procedure ReadMirrorReflectanceFile(MirrorReflectanceFile:string;var Valid:Boolean);

	procedure ReadFile(FileName:string;var ReflectanceData:TReflectanceArray);
	var
		f:TextFile;
		S:string;
		i,pos1:Integer;
	begin
		if FileExists(FileName) then
		begin
			AssignFile(f,FileName);
			Reset(f);
      Readln(f,S); // Read first line, with titles. Ignore this line.
			for i:=1 to 35 do
      begin
        Readln(f,S);
        pos1:=Pos(#9,S);
        ReflectanceData[1,i]:=StrToFloat(Copy(S,1,pos1-1)); // Save the incident angle
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        ReflectanceData[2,i]:=StrToFloat(Copy(S,1,pos1-1)); // Save the s Reflectance
        S:=Copy(S,pos1+1,Length(S)-pos1);
        ReflectanceData[3,i]:=StrToFloat(Copy(S,1,Length(S))); // Save the p Reflectance
      end;
			CloseFile(f);
			Valid:=True;
		end
		else
		begin
			ShowMessage('The file "'+FileName+'" doesn''t exist.');
			Valid:=False;
		end;
	end;

begin
	ReadFile(MirrorReflectanceFile,MirrorReflectanceData);
end;}

{.......................................................}

procedure ReadMeasuredData(var Valid:Boolean);
var
  fileName:string;

	procedure ReadFile(FileName:string;var MeasuredData:TMeasuredDataArray);
	var
		f:TextFile;
		S:string;
		i,pos1:Integer;
	begin
		if FileExists(FileName) then
		begin
			AssignFile(f,FileName);
			Reset(f);
      Readln(f,S); // Read first line, with titles. Ignore this line.
			for i:=1 to {275} 260 do
      begin
        Readln(f,S);
        pos1:=Pos(#9,S);
        MeasuredData[1,i]:=StrToFloat(Copy(S,1,pos1-1)); // Save the mirror angle
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MeasuredData[2,i]:=StrToFloat(Copy(S,1,pos1-1)); // Save the mirror Cs
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MeasuredData[3,i]:=StrToFloat(Copy(S,1,pos1-1)); // Save the diode angle
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MeasuredData[4,i]:=StrToFloat(Copy(S,1,pos1-1)); // Save the diode Cs
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MeasuredData[5,i]:=StrToFloat(Copy(S,1,pos1-1)); // Save the 560 nm absorbance
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MeasuredData[6,i]:=StrToFloat(Copy(S,1,pos1-1)); // Save the 360 nm absorbance
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MeasuredData[7,i]:=StrToFloat(Copy(S,1,pos1-1)); // Save the 380 nm absorbance
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MeasuredData[8,i]:=StrToFloat(Copy(S,1,pos1-1)); // Save the 400 nm absorbance
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MeasuredData[9,i]:=StrToFloat(Copy(S,1,pos1-1)); // Save the 420 nm absorbance
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MeasuredData[10,i]:=StrToFloat(Copy(S,1,pos1-1)); // Save the 440 nm absorbance
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MeasuredData[11,i]:=StrToFloat(Copy(S,1,pos1-1)); // Save the 460 nm absorbance
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MeasuredData[12,i]:=StrToFloat(Copy(S,1,pos1-1)); // Save the 480 nm absorbance
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MeasuredData[13,i]:=StrToFloat(Copy(S,1,pos1-1)); // Save the 530 nm absorbance
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MeasuredData[14,i]:=StrToFloat(Copy(S,1,pos1-1)); // Save the 580 nm absorbance
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MeasuredData[15,i]:=StrToFloat(Copy(S,1,pos1-1)); // Save the 630 nm absorbance
        (*S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MeasuredData[16,i]:=StrToFloat(Copy(S,1,pos1-1)); // Save the 680 nm absorbance
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MeasuredData[17,i]:=StrToFloat(Copy(S,1,pos1-1)); // Save the 730 nm absorbance
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MeasuredData[18,i]:=StrToFloat(Copy(S,1,pos1-1)); // Save the 780 nm absorbance  *)
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MeasuredData[19,i]:=StrToFloat(Copy(S,1,Length(S))); // Save the 830 nm absorbance
      end;
			CloseFile(f);
			Valid:=True;
		end
		else
		begin
			ShowMessage('The file "'+FileName+'" doesn''t exist.');
			Valid:=False;
		end;
	end;

begin
  fileName:='G:\Shared drives\MSL - Photometry & Radiometry\STANDARDS\GonioSpectrometry\Software\Detector Model\MeasuredAbsorbances2.txt';
	ReadFile(fileName,MeasuredData);
end;

{.......................................................}

procedure ReadMirrorReflectanceFile(var Valid:Boolean);
var
  fileName:string;

	procedure ReadFile(FileName:string;var MirrorRefl:TMirrorReflArray);
	var
		f:TextFile;
		S:string;
		i,pos1:Integer;
	begin
		if FileExists(FileName) then
		begin
			AssignFile(f,FileName);
			Reset(f);
      Readln(f,S); // Read first line, with titles. Ignore this line.
			for i:=1 to 55 do
      begin
        Readln(f,S);
        pos1:=Pos(#9,S);
        MirrorRefl[1,i]:=StrToFloat(Copy(S,1,pos1-1)); // Save the angle of incidence
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MirrorRefl[2,i]:=StrToFloat(Copy(S,1,pos1-1)); // 440 nm, s
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MirrorRefl[3,i]:=StrToFloat(Copy(S,1,pos1-1)); // 440 nm, p
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MirrorRefl[4,i]:=StrToFloat(Copy(S,1,pos1-1)); // 460 nm, s
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MirrorRefl[5,i]:=StrToFloat(Copy(S,1,pos1-1)); // 460 nm, p
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MirrorRefl[6,i]:=StrToFloat(Copy(S,1,pos1-1)); // 480 nm, s
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MirrorRefl[7,i]:=StrToFloat(Copy(S,1,pos1-1)); // 480 nm, p
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MirrorRefl[8,i]:=StrToFloat(Copy(S,1,pos1-1)); // 530 nm, s
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MirrorRefl[9,i]:=StrToFloat(Copy(S,1,pos1-1)); // 530 nm, p
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MirrorRefl[10,i]:=StrToFloat(Copy(S,1,pos1-1)); // 580 nm, s
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MirrorRefl[11,i]:=StrToFloat(Copy(S,1,pos1-1)); // 580 nm, p
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MirrorRefl[12,i]:=StrToFloat(Copy(S,1,pos1-1)); // 630 nm, s
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MirrorRefl[13,i]:=StrToFloat(Copy(S,1,pos1-1)); // 630 nm, p
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MirrorRefl[14,i]:=StrToFloat(Copy(S,1,pos1-1)); // 680 nm, s
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MirrorRefl[15,i]:=StrToFloat(Copy(S,1,pos1-1)); // 680 nm, p
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MirrorRefl[16,i]:=StrToFloat(Copy(S,1,pos1-1)); // 730 nm, s
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MirrorRefl[17,i]:=StrToFloat(Copy(S,1,pos1-1)); // 730 nm, p
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MirrorRefl[18,i]:=StrToFloat(Copy(S,1,pos1-1)); // 780 nm, s
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MirrorRefl[19,i]:=StrToFloat(Copy(S,1,pos1-1)); // 780 nm, p
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MirrorRefl[20,i]:=StrToFloat(Copy(S,1,pos1-1)); // 830 nm, s
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MirrorRefl[21,i]:=StrToFloat(Copy(S,1,pos1-1)); // 830 nm, p
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MirrorRefl[22,i]:=StrToFloat(Copy(S,1,pos1-1)); // 900 nm, s
        S:=Copy(S,pos1+1,Length(S)-pos1);
        pos1:=Pos(#9,S);
        MirrorRefl[23,i]:=StrToFloat(Copy(S,1,Length(S))); // 900 nm, p
      end;
			CloseFile(f);
			Valid:=True;
		end
		else
		begin
			ShowMessage('The file "'+FileName+'" doesn''t exist.');
			Valid:=False;
		end;
	end;

begin
  fileName:='G:\Shared drives\MSL - Photometry & Radiometry\STANDARDS\GonioSpectrometry\Software\Detector Model\MirrorReflectanceE02.txt';
	ReadFile(fileName,MirrorRefl);
end;

{.......................................................}

end.

