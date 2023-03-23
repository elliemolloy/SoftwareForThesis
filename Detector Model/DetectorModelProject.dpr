program DetectorModelProject;

uses
  Forms,
  SysUtils,
  DetColumnFormatDlg in 'DetColumnFormatDlg.pas' {ColumnFormatDlg},
  DetGraph in 'DetGraph.pas' {GraphWindow},
  DetGraphAxisDlg in 'DetGraphAxisDlg.pas' {AxisSettingsDlg},
  DetMainForm in 'DetMainForm.pas' {MainForm},
  DetSpreadsheet in 'DetSpreadsheet.pas',
  Reflectance3D in 'Reflectance3D.pas',
  ComplexNumbers in 'ComplexNumbers.pas',
  LinearAlgebra in 'LinearAlgebra.pas',
  DetGlobal in 'DetGlobal.pas',
  DetLineStyleDlg in 'DetLineStyleDlg.pas' {LineStyleDlg},
  ViewFactors in 'ViewFactors.pas',
  DirectPrint in 'DirectPrint.pas';

{$R *.RES}

begin
	Application.Initialize;
	Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TColumnFormatDlg, ColumnFormatDlg);
  Application.CreateForm(TAxisSettingsDlg, AxisSettingsDlg);
  Application.CreateForm(TLineStyleDlg, LineStyleDlg);
  if ParamCount>0 then
	begin
		MainForm.LoadFile(ParamStr(1));
		FileDirectory:=ExtractFileDir(ParamStr(1));
	end;
	Application.Run;
end.
