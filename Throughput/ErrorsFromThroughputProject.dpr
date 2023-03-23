program ErrorsFromThroughputProject;

uses
  Vcl.Forms,
  ThroughputErrorsMainForm in 'ThroughputErrorsMainForm.pas' {TEMainForm},
  BRDFmodel in 'BRDFmodel.pas',
  LinearAlgebra in '..\Detector Model\LinearAlgebra.pas',
  GonioThroughputGlobal in '..\Gonio Throughput\GonioThroughputGlobal.pas',
  gonioThroughputMain in '..\Gonio Throughput\gonioThroughputMain.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TTEMainForm, TEMainForm);
  Application.Run;
end.
