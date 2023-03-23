unit GonioThroughputGlobal;

interface

uses
	Windows, StdCtrls, Forms, SysUtils, Math, Dialogs;

const
	ThisSoftwareVersion='1.0';
  Pi=3.141592653589793;

function ValidDlgReal(TheEdit:TEdit;MinB:Char;Min,Max:Extended;
							MaxB:Char;NilAllowed:Boolean;
							ErrorMessage,RangeMessage:string;var Valid:Boolean):Extended;
function ValidDlgInteger(TheEdit:TEdit;Min,Max:Int64;NilAllowed:Boolean;
					ErrorMessage,RangeMessage:string;var Valid:Boolean):Int64;
function ValidRealString(S:string;MinB:Char;Min,Max:Extended;
							MaxB:Char;NilAllowed:Boolean;
							ErrorMessage,RangeMessage:string;var Valid:Boolean):Extended;

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

function ValidDlgInteger(TheEdit:TEdit;Min,Max:Int64;NilAllowed:Boolean;
					ErrorMessage,RangeMessage:string;var Valid:Boolean):Int64;
var
	code:Integer;
	number:Int64;
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

end.
