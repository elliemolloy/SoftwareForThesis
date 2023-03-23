unit DLColumnFormatDlg;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
	Buttons, ExtCtrls, ComCtrls,Dialogs;

type
	TColumnFormatDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    FormatGroupBox: TGroupBox;
    GeneralRadio: TRadioButton;
    DecimalRadio: TRadioButton;
    ScientificRadio: TRadioButton;
    NumPlacesLabel: TLabel;
    NumPlacesEdit: TEdit;
    NumPlacesUpDown: TUpDown;
    procedure FormShow(Sender: TObject);
    procedure GeneralRadioClick(Sender: TObject);
    procedure DecimalRadioClick(Sender: TObject);
		procedure ScientificRadioClick(Sender: TObject);
		function CheckValidInputs:Boolean;
    procedure OKBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
		{ Public declarations }
		FormShown:Boolean;
  end;

function ValidDlgReal(TheEdit:TEdit;MinB:Char;Min,Max:Double;
							MaxB:Char;NilAllowed:Boolean;
							ErrorMessage,RangeMessage:string;var Valid:Boolean):Double;
							
function ValidDlgInteger(TheEdit:TEdit;Min,Max:Longint;NilAllowed:Boolean;
					ErrorMessage,RangeMessage:string;var Valid:Boolean):Longint;

var
	ColumnFormatDlg: TColumnFormatDlg;

implementation

{$R *.DFM}

{.......................................................}

function ValidDlgReal(TheEdit:TEdit;MinB:Char;Min,Max:Double;
							MaxB:Char;NilAllowed:Boolean;
							ErrorMessage,RangeMessage:string;var Valid:Boolean):Double;
var
	number:Double;
	code:Integer;
begin
	Valid:=True;
	if TheEdit.Text='' then
	begin
		if not NilAllowed then
    begin
			Valid:=False;
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
			Application.MessageBox(PChar(ErrorMessage),'Invalid Input',mb_IconStop or mb_Ok);
		end
		else
		begin
			if number<Min then
					Valid:=False;
			if number>Max then
					Valid:=False;
			if not Valid then
				Application.MessageBox(PChar(RangeMessage),'Invalid Range',mb_IconStop or mb_Ok);
		end;
		if Valid then
			ValidDlgInteger:=number
		else
			ValidDlgInteger:=0;
	end;
	if not Valid then
	begin
		TheEdit.SelectAll;
		TheEdit.SetFocus;
	end;
end;

{.......................................................}

procedure TColumnFormatDlg.FormShow(Sender: TObject);
begin
	FormShown:=True;
	if GeneralRadio.Checked then
	begin
		NumPlacesLabel.Enabled:=False;
		NumPlacesEdit.Enabled:=False;
		NumPlacesUpDown.Enabled:=False;
		OkBtn.Enabled:=True;
	end
	else
		if DecimalRadio.Checked or ScientificRadio.Checked then
		begin
			NumPlacesLabel.Enabled:=True;
			NumPlacesEdit.Enabled:=True;
			NumPlacesUpDown.Enabled:=True;
			OkBtn.Enabled:=True;
			if DecimalRadio.Checked then
			begin
				NumPlacesLabel.Caption:='Number of decimal places:';
				NumPlacesUpDown.Min:=0;
				NumPlacesUpDown.Max:=15;
			end
			else
			begin
				NumPlacesLabel.Caption:='Number of significant figures:';
				NumPlacesUpDown.Min:=2;
				NumPlacesUpDown.Max:=15;
			end;
			NumPlacesEdit.SetFocus;
			NumPlacesEdit.SelectAll;
		end
		else
			OkBtn.Enabled:=False; 
end;

procedure TColumnFormatDlg.GeneralRadioClick(Sender: TObject);
begin
	NumPlacesLabel.Enabled:=False;
	NumPlacesEdit.Enabled:=False;
	NumPlacesUpDown.Enabled:=False;
	OkBtn.Enabled:=True;
end;

procedure TColumnFormatDlg.DecimalRadioClick(Sender: TObject);
begin
	NumPlacesLabel.Enabled:=True;
	NumPlacesEdit.Enabled:=True;
	NumPlacesUpDown.Enabled:=True;
	OkBtn.Enabled:=True;
	NumPlacesLabel.Caption:='Number of decimal places:';
	NumPlacesUpDown.Min:=0;
	NumPlacesUpDown.Max:=18;
	if FormShown then
	begin
		NumPlacesEdit.SetFocus;
		NumPlacesEdit.SelectAll;
	end;
end;

procedure TColumnFormatDlg.ScientificRadioClick(Sender: TObject);
begin
	NumPlacesLabel.Enabled:=True;
	NumPlacesEdit.Enabled:=True;
	NumPlacesUpDown.Enabled:=True;
	OkBtn.Enabled:=True;
	NumPlacesLabel.Caption:='Number of significant figures:';
	if NumPlacesUpDown.Position<2 then
		NumPlacesUpDown.Position:=2;
	if NumPlacesUpDown.Position>15 then
		NumPlacesUpDown.Position:=15;
	NumPlacesUpDown.Min:=2;
	NumPlacesUpDown.Max:=15;
	if FormShown then
	begin
		NumPlacesEdit.SetFocus;
		NumPlacesEdit.SelectAll;
	end;
end;

procedure TColumnFormatDlg.OKBtnClick(Sender: TObject);
begin
	if not CheckValidInputs then
		ModalResult:=mrNone;
end;

function TColumnFormatDlg.CheckValidInputs: Boolean;
var
	valid:Boolean;
	m1,m2:string;
begin
	if DecimalRadio.Checked then
	begin
		m1:='Number of decimal places must be an integer.';
		m2:='Number of decimal places must from 0 to 18.';
		ValidDlgInteger(NumPlacesEdit,0,18,False,m1,m2,valid);
	end
	else
		if ScientificRadio.Checked then
		begin
			m1:='Number of significant figures must be an integer.';
			m2:='Number of significant figures must from 2 to 15.';
			ValidDlgInteger(NumPlacesEdit,2,15,False,m1,m2,valid);
		end
		else
			valid:=True;
	CheckValidInputs:=valid;
end;

end.
