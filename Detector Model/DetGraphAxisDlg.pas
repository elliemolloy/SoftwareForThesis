unit DetGraphAxisDlg;

interface

uses
	Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
	Buttons, ExtCtrls, ComCtrls, Dialogs, DetGlobal;

type
	TAxisSettingsDlg = class(TForm)
		OKBtn: TButton;
		CancelBtn: TButton;
		Bevel1: TBevel;
		MinimumEdit: TEdit;
		MaximumEdit: TEdit;
		Label2: TLabel;
		Label1: TLabel;
		MinAutoCheck: TCheckBox;
		MaxAutoCheck: TCheckBox;
		Bevel2: TBevel;
		MajorIncEdit: TEdit;
		MinorTicksEdit: TEdit;
		DecPlacesEdit: TEdit;
		MajorIncAutoCheck: TCheckBox;
		MinorTicksAutoCheck: TCheckBox;
		DecPlacesAutoCheck: TCheckBox;
		Label3: TLabel;
		Label4: TLabel;
		Label5: TLabel;
		GroupBox1: TGroupBox;
		MajorGridCheck: TCheckBox;
		MinorGridCheck: TCheckBox;
		MinorTicksUpDown: TUpDown;
		DecPlacesUpDown: TUpDown;
    AxisTitleEdit: TEdit;
    Label6: TLabel;
    TitleFontDialog: TFontDialog;
    TitleFontButton: TButton;
    NumberFontButton: TButton;
    NumberFontDialog: TFontDialog;
    Label7: TLabel;
    Label8: TLabel;
    Bevel4: TBevel;
    MajorTickSizeEdit: TEdit;
    MajorTickSizeUpDown: TUpDown;
    MinorTickSizeEdit: TEdit;
    MinorTickSizeUpDown: TUpDown;
    Label9: TLabel;
    AxisLengthEdit: TEdit;
    ScaleToWindowCheckBox: TCheckBox;
    TitleAutoCheck: TCheckBox;
		procedure MinimumEditKeyPress(Sender: TObject; var Key: Char);
		procedure MaximumEditKeyPress(Sender: TObject; var Key: Char);
		procedure MajorIncEditKeyPress(Sender: TObject; var Key: Char);
		procedure MinorTicksEditKeyPress(Sender: TObject; var Key: Char);
		procedure DecPlacesEditKeyPress(Sender: TObject; var Key: Char);
		procedure MinorTicksUpDownChanging(Sender: TObject;
			var AllowChange: Boolean);
		procedure DecPlacesUpDownChanging(Sender: TObject;
			var AllowChange: Boolean);
		procedure OKBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TitleFontButtonClick(Sender: TObject);
		procedure NumberFontButtonClick(Sender: TObject);
    procedure AxisLengthEditKeyPress(Sender: TObject; var Key: Char);
    procedure AxisTitleEditKeyPress(Sender: TObject; var Key: Char);
    procedure TitleAutoCheckClick(Sender: TObject);
	private
		{ Private declarations }
	public
		{ Public declarations }
		TitleFont,NumberFont:TFont;
		AutoTitle:string[255];
	end;

var
	AxisSettingsDlg: TAxisSettingsDlg;

implementation

{$R *.DFM}

procedure TAxisSettingsDlg.MinimumEditKeyPress(Sender: TObject;
	var Key: Char);
begin
	MinAutoCheck.Checked:=False;
end;

procedure TAxisSettingsDlg.MaximumEditKeyPress(Sender: TObject;
	var Key: Char);
begin
	MaxAutoCheck.Checked:=False;
end;

procedure TAxisSettingsDlg.MajorIncEditKeyPress(Sender: TObject;
	var Key: Char);
begin
	MajorIncAutoCheck.Checked:=False;
end;

procedure TAxisSettingsDlg.MinorTicksEditKeyPress(Sender: TObject;
	var Key: Char);
begin
	MinorTicksAutoCheck.Checked:=False;
end;

procedure TAxisSettingsDlg.DecPlacesEditKeyPress(Sender: TObject;
	var Key: Char);
begin
	DecPlacesAutoCheck.Checked:=False;
end;

procedure TAxisSettingsDlg.MinorTicksUpDownChanging(Sender: TObject;
	var AllowChange: Boolean);
begin
	MinorTicksAutoCheck.Checked:=False;
end;

procedure TAxisSettingsDlg.DecPlacesUpDownChanging(Sender: TObject;
	var AllowChange: Boolean);
begin
	DecPlacesAutoCheck.Checked:=False;
end;

procedure TAxisSettingsDlg.OKBtnClick(Sender: TObject);
var
	valid:Boolean;
	min,max,range:Extended;
	m1,m2:string;
begin
	valid:=True;
	if not MaxAutoCheck.Checked then
	begin
		m1:='Maximum value must be a real number.';
		max:=ValidDlgReal(MaximumEdit,'i',0,0,'i',False,m1,m1,valid);
	end;
	if valid and not MinAutoCheck.Checked then
	begin
		m1:='Minimum value must be a real number.';
		m2:='Minimum value must be less than maximum value.';
		if MaxAutoCheck.Checked then
			min:=ValidDlgReal(MinimumEdit,'i',0,0,'i',False,m1,m1,valid)
		else
			min:=ValidDlgReal(MinimumEdit,'i',0,max,')',False,m1,m2,valid);
	end;
	if valid and not MinAutoCheck.Checked and not MaxAutoCheck.Checked then
		range:=Abs(max-min);
	if valid and not MajorIncAutoCheck.Checked then
	begin
		m1:='Major increment must be a positive real number.';
		m2:='Major increment must be smaller.';
		if not MinAutoCheck.Checked and not MaxAutoCheck.Checked then
			ValidDlgReal(MajorIncEdit,'(',0,range,']',False,m1,m2,valid)
		else
			ValidDlgReal(MajorIncEdit,'i',0,0,'i',False,m1,m1,valid)
	end; 
	if valid and not MinorTicksAutoCheck.Checked then
	begin
		m1:='Number of minor ticks must be an integer from 0 to 9.';
		ValidDlgInteger(MinorTicksEdit,0,9,False,m1,m1,valid);
	end;
	if valid and not DecPlacesAutoCheck.Checked then
	begin
		m1:='Number of decimal places must be an integer from 0 to 9.';
		ValidDlgInteger(DecPlacesEdit,0,9,False,m1,m1,valid);
	end;
	if valid and not ScaleToWindowCheckBox.Checked then
	begin
		m1:='Axis length must be a positive real number less than or equal to 3000.';
		ValidDlgReal(AxisLengthEdit,'(',0,3000,']',False,m1,m1,valid);
	end;
	if not valid then
		ModalResult:=mrNone;
end;

procedure TAxisSettingsDlg.FormShow(Sender: TObject);
begin
	MinimumEdit.SelectAll;
	MinimumEdit.SetFocus;
end;

procedure TAxisSettingsDlg.TitleFontButtonClick(Sender: TObject);
begin
	TitleFontDialog.Font.Assign(TitleFont);
	if TitleFontDialog.Execute then
		TitleFont.Assign(TitleFontDialog.Font);
end;

procedure TAxisSettingsDlg.NumberFontButtonClick(Sender: TObject);
begin
	NumberFontDialog.Font.Assign(NumberFont);
	if NumberFontDialog.Execute then
		NumberFont.Assign(NumberFontDialog.Font);
end;

procedure TAxisSettingsDlg.AxisLengthEditKeyPress(Sender: TObject;
  var Key: Char);
begin
	ScaleToWindowCheckBox.Checked:=False;
end;

procedure TAxisSettingsDlg.AxisTitleEditKeyPress(Sender: TObject;
  var Key: Char);
begin
	TitleAutoCheck.Checked:=False;
end;

procedure TAxisSettingsDlg.TitleAutoCheckClick(Sender: TObject);
begin
	if TitleAutoCheck.Checked then
		AxisTitleEdit.Text:=AutoTitle;	
end;

end.
