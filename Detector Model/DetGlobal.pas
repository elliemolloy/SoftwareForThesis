unit DetGlobal;

interface

uses
	Windows, StdCtrls, Forms, SysUtils, Math, Dialogs;

const
	ThisSoftwareVersion='1.06';
	MaxPastFileNames=9;
	MaxColumns=9;
	MaxPoints=1001;
	MaxParameters=4;
	Directory='I:\MSL\Private\Temperature\Software Archive\Ellie\Detector Model\Beam Imaging\Supercontinuum\19 October\';
	Date='19 October';

type
	TCellFormat=(gen,deci,sci);

	PGraphData=^TGraphData;
	TGraphData=array[1..MaxPoints] of Extended;

	PSquareMatrix=^TSquareMatrix;
	TSquareMatrix=array[1..MaxParameters,1..MaxParameters] of Extended;

function ValidDlgReal(TheEdit:TEdit;MinB:Char;Min,Max:Extended;
							MaxB:Char;NilAllowed:Boolean;
							ErrorMessage,RangeMessage:string;var Valid:Boolean):Extended;
function ValidDlgInteger(TheEdit:TEdit;Min,Max:Longint;NilAllowed:Boolean;
					ErrorMessage,RangeMessage:string;var Valid:Boolean):Longint;
function ValidRealString(S:string;MinB:Char;Min,Max:Extended;
							MaxB:Char;NilAllowed:Boolean;
							ErrorMessage,RangeMessage:string;var Valid:Boolean):Extended;
procedure GetAxisExtremes(var Min,Max,Interval:Extended;var NumMajorTicks,NumMinorTicks:Integer);
function GetNumDecimalPlaces(Number:Extended):Integer;
function GetWindowsFileName(TheName:string):string;

var
	PathName:string;
	IniFile,DefaultStyleFileName,FileDirectory,BeamDataSFileName,BeamDataPFileName:string;
	PastFileNames:array[1..MaxPastFileNames] of string;
	JustLoaded,IncludeOnlyOutside,DefIncludeOnlyOutside:Boolean;
	HorSplitterPos,HorSplitterPosDiffuse,VertSplitterPos,DataLeft,LastColumn:Integer;
	DefWindowState:TWindowState;
	Stopped,Failed,BeamData,OffsetP,Polar:Boolean;
	IsDirty,IsNewFile,FirstStart,Autosave,Started,Paused:Boolean;
	NGauLeg:Integer;
  fl:TextFile;

implementation
	
{.......................................................}

function ValidDlgReal(TheEdit:TEdit;MinB:Char;Min,Max:Extended;
							MaxB:Char;NilAllowed:Boolean;
							ErrorMessage,RangeMessage:string;var Valid:Boolean):Extended;
var
	number:Extended;
	code:Integer;
begin
	Valid:=True;
	if TheEdit.Text='' then
	begin
		if not NilAllowed then
    begin
			Valid:=False;
			if ErrorMessage<>'' then
				Application.MessageBox(PChar(ErrorMessage),'Invalid Input',mb_IconStop or mb_Ok);
		end;
    ValidDlgReal:=0;
	end
	else
	begin
		Val(TheEdit.Text,number,code);
		if (code<>0) then
    begin
			Valid:=False;
			Application.MessageBox(PChar(ErrorMessage),'Invalid Input',mb_IconStop or mb_Ok);
    end
		else
		begin
			if (TheEdit.Text[1]='.') then
				TheEdit.Text:='0'+TheEdit.Text;
			if ((TheEdit.Text[1]='-') and (TheEdit.Text[2]='.')) or ((TheEdit.Text[1]='+') and (TheEdit.Text[2]='.')) then
				TheEdit.Text:=TheEdit.Text[1]+'0'+Copy(TheEdit.Text,2,Length(TheEdit.Text));
			if MinB='[' then
				if number<Min then
					Valid:=False;
			if MinB='(' then
				if number<=Min then
					Valid:=False;
			if MaxB=']' then
				if number>Max then
					Valid:=False;
		 	if MaxB=')' then
		 		if number>=Max then
					Valid:=False;
			if not Valid then
				Application.MessageBox(PChar(RangeMessage),'Invalid Range',mb_IconStop or mb_Ok);
		end;
		if Valid then
			ValidDlgReal:=number
		else
    	ValidDlgReal:=0;
	end;
	if not Valid then
	begin
		TheEdit.SelectAll;
		TheEdit.SetFocus;
	end;
end;

{.......................................................}

function ValidDlgInteger(TheEdit:TEdit;Min,Max:Longint;NilAllowed:Boolean;
					ErrorMessage,RangeMessage:string;var Valid:Boolean):Longint;
var
	code:Integer;
	number:Longint;
begin
	Valid:=True;
	if TheEdit.Text='' then
	begin
		if not NilAllowed then
    begin
			Valid:=False;
			if ErrorMessage<>'' then
				Application.MessageBox(PChar(ErrorMessage),'Invalid Input',mb_IconStop or mb_Ok);
		end;
    ValidDlgInteger:=0;
	end
	else
	begin
		Val(TheEdit.Text,number,code);
		if (code<>0) or ((Length(TheEdit.Text)=1) and (TheEdit.Text[1]='-'))	then
    begin
			Valid:=False;
			if ErrorMessage<>'' then
				Application.MessageBox(PChar(ErrorMessage),'Invalid Input',mb_IconStop or mb_Ok);
		end
		else
		begin
			if number<Min then
					Valid:=False;
			if number>Max then
					Valid:=False;
			if not Valid then
				if ErrorMessage<>'' then
					Application.MessageBox(PChar(RangeMessage),'Invalid Range',mb_IconStop or mb_Ok);
		end;
		if Valid then
			ValidDlgInteger:=number
		else
			ValidDlgInteger:=0;
	end;
	if not Valid and ((ErrorMessage<>'') or (RangeMessage<>'')) then
	begin
		TheEdit.SelectAll;
		TheEdit.SetFocus;
	end;
end;

{.......................................................}

function ValidRealString(S:string;MinB:Char;Min,Max:Extended;
							MaxB:Char;NilAllowed:Boolean;
							ErrorMessage,RangeMessage:string;var Valid:Boolean):Extended;
var
	number:Extended;
	code:Integer;
begin
	Valid:=True;
	if S='' then
	begin
		if not NilAllowed then
		begin
			Valid:=False;
			if ErrorMessage<>'' then
				Application.MessageBox(PChar(ErrorMessage),'Invalid Input',mb_IconStop or mb_Ok);
		end;
		ValidRealString:=0;
	end
	else
	begin
		Val(S,number,code);
		if (code<>0) or (S[1]='.')
				 or ((S[1]='-') and (S[2]='.'))  then
    begin
			Valid:=False;
			if ErrorMessage<>'' then
				Application.MessageBox(PChar(ErrorMessage),'Invalid Input',mb_IconStop or mb_Ok);
    end
		else
		begin
			if MinB='[' then
				if number<Min then
					Valid:=False;
			if MinB='(' then
				if number<=Min then
					Valid:=False;
			if MaxB=']' then
				if number>Max then
					Valid:=False;
		 	if MaxB=')' then
		 		if number>=Max then
					Valid:=False;
			if not Valid then
				if RangeMessage<>'' then
					Application.MessageBox(PChar(RangeMessage),'Invalid Range',mb_IconStop or mb_Ok);
		end;
		if Valid then
			ValidRealString:=number
		else
			ValidRealString:=0;
	end;
end;

{.......................................................}

function Power(X,N:Extended):Extended;
var
	sign:Integer;
	intPower:Boolean;
begin
	sign:=1;
	if Int(N)=N then
  begin
		intPower:=True;
		if Odd(Round(n)) and (X<0) then
			sign:=-1;
	end
	else
		intPower:=False;
	if n=0 then
		Power:=1
  else
		if (X>0) or (intPower and (X<>0)) then
  		Power:=sign*Exp(N*Ln(Abs(X)))
		else
			Power:=0;
end;

{.......................................................}

procedure GetNumAndExp(Value:Extended;var Num:Extended;var Exponent:Integer);
var
	approxExp:Extended;
begin
	if Value=0.0 then
	begin
		Exponent:=0;
		Num:=Value;
	end
	else
	begin
		approxExp:=ln(Abs(Value))/ln(10.0);
		if (Int(approxExp)=approxExp) or (approxExp>0.0) then
			Exponent:=Trunc(approxExp)
		else
			Exponent:=Trunc(approxExp)-1;
		Num:=Value/Power(10.0,Exponent);
	end;
end;

{.......................................................}

procedure GetAxisExtremes(var Min,Max,Interval:Extended;var NumMajorTicks,NumMinorTicks:Integer);
var
	range,steps:Extended;
	exponent,extra:Integer;
begin
	range:=Max-Min;
	if range=0 then
	begin
		Max:=Max+1;
		range:=1;
	end;
	GetNumAndExp(Abs(range/10),Interval,exponent);
	NumMinorTicks:=1;
	if Interval<>1 then
		if Interval<=2 then
		begin
			Interval:=2;
			NumMinorTicks:=1;
		end
		else if Interval<=5 then
		begin
			Interval:=5;
			NumMinorTicks:=4;
		end
		else
			Interval:=10;
	Interval:=Interval*Power(10,exponent);
	steps:=Int(Max/Interval);
	if Max<0 then
		extra:=0
	else
		if steps*1.0=Max/Interval then
			extra:=0
		else
			extra:=1;
	Max:=(steps+extra)*Interval;
	steps:=Int(Min/Interval);
	if Min>=0 then
		extra:=0
	else
		if steps*1.0=Min/Interval then
			extra:=0
		else
    	extra:=-1;
	Min:=(steps+extra)*Interval;
	NumMajorTicks:=Round((Max-Min)/Interval);
end;

{.......................................................}

function GetNumDecimalPlaces(Number:Extended):Integer;
var
	k:Extended;
	numPlaces:Integer;
begin
	if Number=0 then
		numPlaces:=0
	else
	begin
		k:=ln(Abs(Number))/ln(10.0);
		if Int(k)=k then
			numPlaces:=-Trunc(k)
		else
			numPlaces:=-Trunc(k)+1;
		if numPlaces<0 then
			numPlaces:=0;
		end;
	GetNumDecimalPlaces:=numPlaces;
end;

{.......................................................}

function GetWindowsFileName(TheName:string):string;
var
	WindowsDirectory:PChar;
	S:string;
begin
	GetMem(WindowsDirectory,255);
	if GetWindowsDirectory(WindowsDirectory,255)=0 then
		S:=TheName
	else
	begin
		S:=StrPas(WindowsDirectory);
		if WindowsDirectory[StrLen(WindowsDirectory)-1]='\' then
			S:=S+TheName
		else
			S:=S+'\'+TheName;
	end;
	FreeMem(WindowsDirectory,255);
	GetWindowsFileName:=S;
end;

{.......................................................}

end.
