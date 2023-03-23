unit ComplexNumbers;

interface

uses
	SysUtils, Classes, Math, Dialogs;

type
	ComplexNumber=array[1..2] of Extended;

function MakeComplex(a,b:Extended):ComplexNumber;
function ComplexNegative(z:ComplexNumber):ComplexNumber;
function ComplexConjugate(z:ComplexNumber):ComplexNumber;
function ComplexModulus(z:ComplexNumber):Extended;
function ComplexArg(z:ComplexNumber):Extended;
function ComplexAddition(a,b:ComplexNumber):ComplexNumber;
function ComplexSubtraction(a,b:ComplexNumber):ComplexNumber;
function ComplexMultiplication(a,b:ComplexNumber):ComplexNumber;
function ComplexDivision(a,b:ComplexNumber):ComplexNumber;
function ComplexSqrt(z:ComplexNumber):ComplexNumber;
function ComplexSin(z:ComplexNumber):ComplexNumber;
function ComplexCos(z:ComplexNumber):ComplexNumber;
function ComplexLn(z:ComplexNumber):ComplexNumber;
function ComplexArcSin(z:ComplexNumber):ComplexNumber;

const
	Pi=3.14159265;

var
	Error:Boolean;
	ErrorString:string;

implementation

{.......................................................}

function MakeComplex(a,b:Extended):ComplexNumber;
begin
	MakeComplex[1]:=a;
	MakeComplex[2]:=b;
end;

{.......................................................}

function ComplexNegative(z:ComplexNumber):ComplexNumber;
begin
	ComplexNegative[1]:=-z[1];
	ComplexNegative[2]:=-z[2];
end;

{.......................................................}

function ComplexConjugate(z:ComplexNumber):ComplexNumber;
begin
	ComplexConjugate[1]:=z[1];
	ComplexConjugate[2]:=-z[2];
end;

{.......................................................}

function ComplexModulus(z:ComplexNumber):Extended;
var
	a2,b2,a2b2:Extended;
begin
	a2:=Sqr(z[1]);
	b2:=Sqr(z[2]);
	a2b2:=a2+b2;
	ComplexModulus:=Sqrt(a2b2);
end;

{.......................................................}

function ComplexArg(z:ComplexNumber):Extended;
var
	a,b:Extended;
begin
	a:=z[1];
	b:=z[2];
	ComplexArg:=ArcTan2(b,a);
end;

{.......................................................}

function ComplexAddition(a,b:ComplexNumber):ComplexNumber;
var
	real,complex:Extended;
begin
	real:=a[1]+b[1];
	complex:=a[2]+b[2];
	ComplexAddition[1]:=real;
	ComplexAddition[2]:=complex;
end;

{.......................................................}

function ComplexSubtraction(a,b:ComplexNumber):ComplexNumber;
var
	real,complex:Extended;
begin
	real:=a[1]-b[1];
	complex:=a[2]-b[2];
	ComplexSubtraction[1]:=real;
	ComplexSubtraction[2]:=complex;
end;

{.......................................................}

function ComplexMultiplication(a,b:ComplexNumber):ComplexNumber;
var
	real,complex:Extended;
begin
	real:=a[1]*b[1]-a[2]*b[2];
	complex:=a[1]*b[2]+a[2]*b[1];
	ComplexMultiplication[1]:=real;
	ComplexMultiplication[2]:=complex;
end;

{.......................................................}

function ComplexDivision(a,b:ComplexNumber):ComplexNumber;
var
	real,complex:Extended;
	denominator,numerator:ComplexNumber;
begin
	numerator:=ComplexMultiplication(a,ComplexConjugate(b));
	denominator:=ComplexMultiplication(b,ComplexConjugate(b));
	if denominator[1]<>0 then
	begin
		real:=numerator[1]/denominator[1];
		complex:=numerator[2]/denominator[1];
		ComplexDivision[1]:=real;
		ComplexDivision[2]:=complex;
	end
	else
	begin
		Error:=True;
		ErrorString:='Can''t divide by 0';
	end;
end;

{.......................................................}

function ComplexSqrt(z:ComplexNumber):ComplexNumber;
// Calculates the square root of a complex number using Sqrt(a+bi)=Sqrt((r+a)/2)+Sqrt((r-a)/2)i
// See http://stanleyrabinowitz.com/bibliography/complexSquareRoot.pdf for proof
var
	a,b,r:Extended;
begin
	r:=ComplexModulus(z);
	a:=(r+z[1])/2;
	b:=(r-z[1])/2;
	ComplexSqrt[1]:=Sqrt(a);
	if z[2]<0 then
		ComplexSqrt[2]:=-Sqrt(b)
	else
		ComplexSqrt[2]:=Sqrt(b);
end;

{.......................................................}

function ComplexSin(z:ComplexNumber):ComplexNumber;
// Calculates the sine of a complex number using https://en.wikibooks.org/wiki/Trigonometry/Functions_of_complex_variables
var
	x,y,Sinx,Cosx,Coshy,Sinhy:Extended;
begin
	x:=z[1];
	y:=z[2];
	Sinx:=Sin(x);
	Cosx:=Cos(x);
	Coshy:=Cosh(y);
	Sinhy:=Sinh(y);
	ComplexSin[1]:=Sinx*Coshy;
	ComplexSin[2]:=Cosx*Sinhy;
end;

{.......................................................}

function ComplexCos(z:ComplexNumber):ComplexNumber;
// Calculates the cosine of a complex number using https://en.wikibooks.org/wiki/Trigonometry/Functions_of_complex_variables
var
	x,y,Sinx,Cosx,Coshy,Sinhy:Extended;
begin
	x:=z[1];
	y:=z[2];
	Sinx:=Sin(x);
	Cosx:=Cos(x);
	Coshy:=Cosh(y);
	Sinhy:=Sinh(y);
	ComplexCos[1]:=Cosx*Coshy;
	ComplexCos[2]:=-Sinx*Sinhy;
end;

{.......................................................}

function ComplexLn(z:ComplexNumber):ComplexNumber;
// Calculates the logarithm of a complex number using https://en.wikipedia.org/wiki/Complex_logarithm
var
	r,arg:Extended;
begin
	r:=ComplexModulus(z);
	arg:=ComplexArg(z);
	ComplexLn[1]:=Ln(r);
	ComplexLn[2]:=arg;
end;

{.......................................................}

function ComplexArcSin(z:ComplexNumber):ComplexNumber;
// Calculates the inverse sine of a complex number using https://mathworld.wolfram.com/InverseSine.html
// ArcSin(z)=-i Ln(iz+Sqrt(1-z^2))
var
	i,iz,z2,a,b,c,d,e,f,j:ComplexNumber;
begin
	i:=MakeComplex(0,1);
	iz:=ComplexMultiplication(i,z);
	z2:=ComplexMultiplication(z,z);
	a:=MakeComplex(1,0);
	b:=ComplexSubtraction(a,z2);
	c:=ComplexSqrt(b);
	d:=ComplexAddition(iz,c);
	e:=ComplexLn(d);
	j:=MakeComplex(0,-1);
	f:=ComplexMultiplication(e,j);
	ComplexArcSin:=f;
end;

{.......................................................}

end.
