unit SplashScreen;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

procedure InitSplash (ts : String);
procedure InitOK;
procedure InitNOK;
procedure InitPOK;

type
  TfrmSplashScreen = class(TForm)
    InitLabel: TLabel;
    InitBox: TListBox;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Version: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Panel2: TPanel;
    Image2: TImage;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var frmSplashScreen : TfrmSplashScreen;

implementation

uses MainForm;

{$R *.DFM}

Procedure InitSplash (ts : String);
begin
  frmSplashScreen.InitBox.Items.Add (ts);
  frmSplashScreen.InitBox.Update;
end;

Procedure InitOK;
begin
  frmSplashScreen.InitBox.Items[frmSplashScreen.InitBox.Items.Count-1] := frmSplashScreen.InitBox.Items[frmSplashScreen.InitBox.Items.Count-1] + ' - OK';
  frmSplashScreen.InitBox.Update;
end;

Procedure InitNOK;
begin
  frmSplashScreen.InitBox.Items[frmSplashScreen.InitBox.Items.Count-1] := frmSplashScreen.InitBox.Items[frmSplashScreen.InitBox.Items.Count-1] + ' - Fail';
  frmSplashScreen.InitBox.Update;
end;

Procedure InitPOK;
begin
	frmSplashScreen.InitBox.Items[frmSplashScreen.InitBox.Items.Count-1] := frmSplashScreen.InitBox.Items[frmSplashScreen.InitBox.Items.Count-1] + ' - Partial fail';
  frmSplashScreen.InitBox.Update;
end;

procedure TfrmSplashScreen.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := False;
end;

procedure TfrmSplashScreen.FormCreate(Sender: TObject);
var ts : String;
    i : Integer;
begin
  Caption := Application.Title;
	{if DebugMode then
		Caption := Caption + '  - Debug Mode';}
  ts := Application.Title;                                 {Make Version label show current Version}
  for i := Length (ts) downto 1 do
    if ts [i] = 'v' then
      Break;
  Delete (ts, 1, i);
  Version.Caption := Version.Caption + ts;
  InitSplash ('Initialising System Resources');
end;

end.
