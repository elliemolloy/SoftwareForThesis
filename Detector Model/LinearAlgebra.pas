unit LinearAlgebra;

interface

uses
	SysUtils, Classes, Math, Dialogs;

type
	TMatrix=array[1..3,1..3] of Extended;
	TVector=array[1..3] of Extended;

function MatrixMultiplication(M:TMatrix;v:TVector):TVector;
function DotProduct(A,B:TVector):Extended;
function CrossProduct(A,B:TVector):TVector;
function VectorAddition(A,B:TVector):TVector;
function VectorSubtraction(A,B:TVector):TVector;
function AngleBetweenVectors(A,B:TVector):Extended;
function AngleBetweenThreePoints(A,B,C:TVector):Extended;

var
	Error:Boolean;
	ErrorString:string;

implementation

{.......................................................}

function MatrixMultiplication(M:TMatrix;V:TVector):TVector;
var
	v2:TVector;
	i,j,n:Integer;
begin
	n:=Length(V);
	for i:=1 to n do
	begin
		v2[i]:=0;
		for j:=1 to n do
			v2[i]:=v2[i]+M[i,j]*V[j];
	end;
	MatrixMultiplication:=v2;
end;

{.......................................................}

function DotProduct(A,B:TVector):Extended;
var
	n,i:Integer;
	ab:Extended;
begin
	ab:=0;
	n:=Length(A);
	for i:=1 to n do
		ab:=ab+A[i]*B[i];
	DotProduct:=ab;
end;

{.......................................................}

function CrossProduct(A,B:TVector):TVector;
var
	n:Integer;
	axb:TVector;
begin
	n:=Length(A);
	if n=3 then
	begin
		axb[1]:=A[2]*B[3]-A[3]*B[2];
		axb[2]:=-A[1]*B[3]+A[3]*B[1];
		axb[3]:=A[1]*B[2]-A[2]*B[1];
		CrossProduct:=axb;
	end
	else
	begin
		Error:=True;
		ErrorString:='Can only take a cross product with 3 dimensional vectors.';
	end;
end;

{.......................................................}

function VectorAddition(A,B:TVector):TVector;
var
	n,i:Integer;
	v2:TVector;
begin
	n:=Length(A);
	for i:=1 to n do
		v2[i]:=A[i]+B[i];
	VectorAddition:=v2;
end;

{.......................................................}

function VectorSubtraction(A,B:TVector):TVector;
var
	n,i:Integer;
	v2:TVector;
begin
	n:=Length(A);
	for i:=1 to n do
		v2[i]:=A[i]-B[i];
	VectorSubtraction:=v2;
end;

{.......................................................}

function AngleBetweenVectors(A,B:TVector):Extended;
var
	aa,bb,ab,cosTheta,theta:Extended;
begin
	aa:=Sqrt(DotProduct(A,A));
	bb:=Sqrt(DotProduct(B,B));
	ab:=DotProduct(A,B);
	cosTheta:=ab/(aa*bb);
	theta:=ArcCos(cosTheta);
	AngleBetweenVectors:=theta;
end;

{.......................................................}

function AngleBetweenThreePoints(A,B,C:TVector):Extended;
var
	AB,CB:TVector;
begin
	AB:=VectorSubtraction(A,B);
	CB:=VectorSubtraction(C,B);
	AngleBetweenThreePoints:=AngleBetweenVectors(AB,CB);
end;

{.......................................................}

end.

