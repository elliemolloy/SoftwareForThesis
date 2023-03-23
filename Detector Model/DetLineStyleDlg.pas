unit DetLineStyleDlg;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
	Buttons, ExtCtrls, Dialogs, DetGraph;

type
  TLineStyleDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    RadioGroup1: TRadioGroup;
    SmallSymbolsRadio: TRadioButton;
    BigSymbolsRadio: TRadioButton;
    SolidLineRadio: TRadioButton;
    DashedLineRadio: TRadioButton;
    SolidLineBigRadio: TRadioButton;
    LineColourButton: TButton;
    LineColourDlg: TColorDialog;
    CurveComboBox: TComboBox;
    Label1: TLabel;
    PreviewButton: TButton;
    procedure LineColourButtonClick(Sender: TObject);
    procedure CurveComboBoxChange(Sender: TObject);
    procedure SmallSymbolsRadioMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure BigSymbolsRadioMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure SolidLineRadioMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DashedLineRadioMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure SolidLineBigRadioMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PreviewButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
		{ Public declarations }
		GraphWindow:TGraphWindow;
	end;

var
  LineStyleDlg: TLineStyleDlg;

implementation

{$R *.DFM}

procedure TLineStyleDlg.LineColourButtonClick(Sender: TObject);
begin
	LineColourDlg.Color:=GraphWindow.GraphStyle.CurveColour[CurveComboBox.ItemIndex+1];
	if LineColourDlg.Execute then
		GraphWindow.GraphStyle.CurveColour[CurveComboBox.ItemIndex+1]:=LineColourDlg.Color;
end;

procedure TLineStyleDlg.CurveComboBoxChange(Sender: TObject);
var
	index:Integer;
begin
	index:=CurveComboBox.ItemIndex+1;
	with GraphWindow.GraphStyle do
	begin
		SmallSymbolsRadio.Checked:=PlotType[index]=Small;
		BigSymbolsRadio.Checked:=PlotType[index]=Big;
		SolidLineRadio.Checked:=PlotType[index]=Line;
		DashedLineRadio.Checked:=PlotType[index]=DashLine;
		SolidLineBigRadio.Checked:=PlotType[index]=BigLine;
	end;
end;

procedure TLineStyleDlg.SmallSymbolsRadioMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
	GraphWindow.GraphStyle.PlotType[CurveComboBox.ItemIndex+1]:=Small;
end;

procedure TLineStyleDlg.BigSymbolsRadioMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
	GraphWindow.GraphStyle.PlotType[CurveComboBox.ItemIndex+1]:=Big;
end;

procedure TLineStyleDlg.SolidLineRadioMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
	GraphWindow.GraphStyle.PlotType[CurveComboBox.ItemIndex+1]:=Line;
end;

procedure TLineStyleDlg.DashedLineRadioMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
	GraphWindow.GraphStyle.PlotType[CurveComboBox.ItemIndex+1]:=DashLine;
end;

procedure TLineStyleDlg.SolidLineBigRadioMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
	GraphWindow.GraphStyle.PlotType[CurveComboBox.ItemIndex+1]:=BigLine;
end;

procedure TLineStyleDlg.PreviewButtonClick(Sender: TObject);
begin
	GraphWindow.Repaint;
end;

end.
