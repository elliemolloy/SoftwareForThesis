unit DetColumnFormatDlg;

interface

uses
	Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
	Buttons, ExtCtrls, ComCtrls, Dialogs, DetGlobal;

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
    SaveDefButton: TSpeedButton;
    LoadDefButton: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure GeneralRadioClick(Sender: TObject);
    procedure DecimalRadioClick(Sender: TObject);
		procedure ScientificRadioClick(Sender: TObject);
		function CheckValidInputs:Boolean;
    procedure OKBtnClick(Sender: TObject);
    procedure SaveDefButtonClick(Sender: TObject);
    procedure LoadDefButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
		{ Public declarations }
		FormShown:Boolean;
		ColumnNum,FormTag:Integer;
  end;

var
	ColumnFormatDlg: TColumnFormatDlg;

implementation

uses
	DetSpreadsheet, DetMainForm;
	
{$R *.DFM}

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
				NumPlacesUpDown.Max:=18;
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

procedure TColumnFormatDlg.SaveDefButtonClick(Sender: TObject);
begin
	if CheckValidInputs then
	begin
		if GeneralRadio.Checked then
		begin
			if Mode=DiffuseDetectorModel then
			begin
				DiffuseDefColFormat[1,ColumnNum]:=gen;
				DiffuseDefColPlaces[1,ColumnNum]:=0;
			end
			else
			begin
				DefColFormat[1,ColumnNum]:=gen;
				DefColPlaces[1,ColumnNum]:=0;
			end;
		end
		else
		begin
			if Mode=DiffuseDetectorModel then
			begin
      	if DecimalRadio.Checked then
					DiffuseDefColFormat[1,ColumnNum]:=deci
				else
					DiffuseDefColFormat[1,ColumnNum]:=sci;
				DiffuseDefColPlaces[1,ColumnNum]:=StrToInt(NumPlacesEdit.Text);
			end
			else
			begin
				if DecimalRadio.Checked then
					DefColFormat[1,ColumnNum]:=deci
				else
					DefColFormat[1,ColumnNum]:=sci;
				DefColPlaces[1,ColumnNum]:=StrToInt(NumPlacesEdit.Text);
			end;
		end;
	end;
end;

procedure TColumnFormatDlg.LoadDefButtonClick(Sender: TObject);
begin
	if Mode=DiffuseDetectorModel then
	begin
		GeneralRadio.Checked:=DiffuseDefColFormat[1,ColumnNum]=gen;
		DecimalRadio.Checked:=DiffuseDefColFormat[1,ColumnNum]=deci;
		ScientificRadio.Checked:=DiffuseDefColFormat[1,ColumnNum]=sci;
		NumPlacesUpDown.Position:=DiffuseDefColPlaces[1,ColumnNum];
		NumPlacesEdit.Text:=IntToStr(DiffuseDefColPlaces[1,ColumnNum]);
	end
	else
	begin
		GeneralRadio.Checked:=DefColFormat[1,ColumnNum]=gen;
		DecimalRadio.Checked:=DefColFormat[1,ColumnNum]=deci;
		ScientificRadio.Checked:=DefColFormat[1,ColumnNum]=sci;
		NumPlacesUpDown.Position:=DefColPlaces[1,ColumnNum];
		NumPlacesEdit.Text:=IntToStr(DefColPlaces[1,ColumnNum]);
	end;
end;

end.
