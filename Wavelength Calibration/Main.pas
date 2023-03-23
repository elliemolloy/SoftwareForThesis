unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
	Dialogs, StdCtrls, BenthamUnit, XEdit, Buttons, DLColumnFormatDlg,
	DLSpreadSheet, ComCtrls, ExtCtrls, IniFiles, ScktComp, UtilUnit;

const
	MaxPoints=5382;

type

	PData=^TData;
	TData=array[1..MaxPoints] of Double;
	TMonochromator=(Bentham,SpectraPro);

  TMainForm = class(TForm)
    Panel1: TPanel;
    MonochromatorGroupBox: TGroupBox;
    Label1: TLabel;
    WavelengthLabel: TLabel;
    Label2: TLabel;
    UnitLabel2: TLabel;
    MonochromatorButton: TButton;
    WavelengthEdit: TEdit;
    LSAGroupBox: TGroupBox;
    Label3: TLabel;
    LSAWavelengthLabel: TLabel;
    UnitLabel3: TLabel;
    GetWavelengthButton: TButton;
    WavelengthGroupBox: TGroupBox;
    FromWavelengthLabel: TLabel;
    Label4: TLabel;
    ToWavelengthLabel: TLabel;
    UnitLabel4: TLabel;
    StepWavelengthLabel: TLabel;
    UnitLabel5: TLabel;
    WavelengthFromEdit: TEdit;
    DoWavelengthScanButton: TBitBtn;
    WavelengthToEdit: TEdit;
    WavelengthStepEdit: TEdit;
    Panel2: TPanel;
    ProgressBar: TProgressBar;
    StatusLabel: TLabel;
    PauseButton: TBitBtn;
    NumRepeatsEdit: TEdit;
    Label5: TLabel;
    ThresholdEdit: TEdit;
    Label6: TLabel;
    UnitLabel7: TLabel;
    Label8: TLabel;
    DelayEdit: TEdit;
    UnitLabel8: TLabel;
    SpectraProClientSocket: TClientSocket;
    GroupBox1: TGroupBox;
    BenthamRadioButton: TRadioButton;
    SpectraProRadioButton: TRadioButton;
    WavelengthCorrectionEditA: TEdit;
    Label7: TLabel;
    WavelengthCorrectionEditB: TEdit;
    Label9: TLabel;
    GroupBox2: TGroupBox;
    SlitWidthEdit: TEdit;
    Label10: TLabel;
		SlitWidthButton: TButton;
    procedure FormCreate(Sender: TObject);
    procedure MonochromatorButtonClick(Sender: TObject);
		procedure GetWavelengthButtonClick(Sender: TObject);
		procedure DoWavelengthScanButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
		procedure FormResize(Sender: TObject);
		procedure PauseButtonClick(Sender: TObject);
		procedure SpectraProClientSocketConnect(Sender:TObject;Socket:TCustomWinSocket);
		procedure SpectraProClientSocketDisconnect(Sender:TObject;Socket:TCustomWinSocket);
		procedure SpectraProClientSocketError(Sender:TObject;Socket:TCustomWinSocket;ErrorEvent:TErrorEvent;var ErrorCode:Integer);
		procedure SpectraProClientSocketRead(Sender:TObject;Socket:TCustomWinSocket);
		procedure BenthamRadioButtonClick(Sender: TObject);
		procedure SpectraProRadioButtonClick(Sender: TObject);
    procedure SlitWidthButtonClick(Sender: TObject);
  private
		{ Private declarations }
		LSAConnected,MonochromatorConnected,ScanStarted,ScanPaused:Boolean;
		StartWavelength,StopWavelength,StepWavelength:Double;
		NumWavelengths,NumRepeats,Threshold,DelayTime:Integer;
		WavelengthDataX,WavelengthDataY:PData;
		Monochromator:TMonochromator;
		SpectraProHostName,SpectraProIPAddress,SpectraProPort:string;
		SlitWidth:string;
		SpectraProResponded:Boolean;
		SpectraProWavelength,CorrectionA,CorrectionB:Double;
		SpectraProFilterPos,SpectraProFilterOpenPos:Integer;
		WavelengthScanSpreadSheet:TDLDataSpreadsheet;
		procedure Delay(DelayTime:Cardinal);
		procedure SetLSARange(Wavelength:Double);
		procedure ScanWavelengths(StartWavelength,StepWavelength:Double;NumWavelengths:Integer);
		procedure SetSpreadsheetTitles;
		procedure GetIniStuff;
		procedure PutIniStuff;
		procedure InitMonochromator;
		procedure InitialiseWavelengthScan;
		procedure SetWavelength(Wavelength:Double);
		function GetMonochromatorWavelength:Double;
		function CalculateCentroid(NumPoints:Integer):Double;
		function InitSpectraPro:Boolean;
		function ExtractUUID(S:string):string;
		function ExtractResult(S:string):string;
		function CheckForError(S:string):string;
		function ExtractErrorMessage(S:string):string;
		procedure SendSpectraProCommand(Command,Value,UUID:string);
		procedure SetSpectraProWavelength(Value:Double);
		function GetSpectraProWavelength:Double;
		procedure SetSpectraProSlitWidths;
		procedure CheckScanVariables(var Valid:Boolean);
		procedure EnableButtons(Enabled:Boolean);
		procedure MeasureWavelength(Signal:PData;ItemCount:Integer);
	public
		{ Public declarations }
	end;

{$INCLUDE Data}

var
	MainForm: TMainForm;
	ExePath:string;
	IniFileRead:Boolean;
	MainFormLeft,MainFormWidth,MainFormTop,MainFormHeight:Integer;
	WavelengthStr:string;

implementation

{$R *.dfm}

procedure TMainForm.Delay(DelayTime:Cardinal);
var
	startTime:Cardinal;
begin
	startTime:=GetTickCount;
	repeat
		Application.ProcessMessages;
	until (GetTickCount-startTime>DelayTime) or not ScanStarted or ScanPaused;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
	wavelength:Double;
	valid:Integer;
begin
	ExePath:=AddSlash(ExtractFilePath(Application.ExeName));
	GetIniStuff;
	WavelengthDataX:=New(PData);
	WavelengthDataY:=New(PData);
	LSAConnected:=False;
	ScanStarted:=False;
	valid:=Instantiate(cInstReturnMode,1,0,0);
	if valid>0 then
		LSAConnected:=True
	else
		ShowMessage('Connecting to Laser Spectrum Analyser failed.');
	WavelengthScanSpreadSheet:=TDLDataSpreadSheet.Create(Self,WavelengthScanNumColumns+1,1,1,False,False,True,1);
	WavelengthScanSpreadSheet.Parent:=Self;
	WavelengthScanSpreadSheet.ResetSpreadSheet;
	Left:=MainFormLeft;
	Width:=MainFormWidth;
	Top:=MainFormTop;
	Height:=MainFormHeight;
	if Monochromator=Bentham then
		BenthamRadioButton.Checked:=True
	else
		SpectraProRadioButton.Checked:=True;
end;

procedure TMainForm.InitMonochromator;
var
	wavelength:Double;
begin
	EnableButtons(False);
	if Monochromator=Bentham then
	begin
		MonochromatorConnected:=InitialiseBentham;
		if MonochromatorConnected then
		begin
			wavelength:=GetBenthamWavelength;
			MonochromatorGroupBox.Caption:='Bentham Monochromator';
			WavelengthGroupBox.Caption:='Bentham Scan';
		end
		else
			ShowMessage('Bentham monochromator not connected.');
	end
	else
	begin
		MonochromatorConnected:=InitSpectraPro;
		if MonochromatorConnected then
		begin
			wavelength:=GetSpectraProWavelength;
			MonochromatorGroupBox.Caption:='SpectraPro Monochromator';
			WavelengthGroupBox.Caption:='SpectraPro Scan';
		end
		else
			ShowMessage('SpectraPro monochromator not connected.');
	end;
	if MonochromatorConnected then
		wavelengthLabel.Caption:=FloatToStrF(wavelength,ffFixed,15,3);
	EnableButtons(True);
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
	with WavelengthScanSpreadSheet do
	begin
		SelectAll;
		DeleteCells;
		SelectCell(1,1);
		SetSpreadSheetTitles;
		ProgressBar.Position:=0;
	end;
	WavelengthFromEdit.Text:=FloatToStr(StartWavelength);
	WavelengthToEdit.Text:=FloatToStr(StopWavelength);
	WavelengthStepEdit.Text:=FloatToStr(StepWavelength);
	DelayEdit.Text:=IntToStr(DelayTime);
	NumRepeatsEdit.Text:=IntToStr(NumRepeats);
	ThresholdEdit.Text:=IntToStr(Threshold);
	WavelengthCorrectionEditA.Text:=FloatToStr(CorrectionA);
	WavelengthCorrectionEditB.Text:=FloatToStr(CorrectionB);
	SlitWidthEdit.Text:=SlitWidth;
end;

procedure TMainForm.GetIniStuff;
var
	i:Integer;
begin
	with TIniFile.Create(ExePath+'WavelengthCalibration.ini') do
		begin
			MainFormLeft:=ReadInteger('General','MainFormLeft',10);
			MainFormWidth:=ReadInteger('General','MainFormWidth',500);
			MainFormTop:=ReadInteger('General','MainFormTop',10);
			MainFormHeight:=ReadInteger('General','MainFormHeight',500);
			StartWavelength:=ReadFloat('WavelengthScan','StartWavelength',200);
			StopWavelength:=ReadFloat('WavelengthScan','StopWavelength',900);
			StepWavelength:=ReadFloat('WavelengthScan','StepWavelength',5);
			DelayTime:=ReadInteger('WavelengthScan','DelayTime',1000);
			NumRepeats:=ReadInteger('WavelengthScan','NumRepeats',5);
			Threshold:=ReadInteger('WavelengthScan','Threshold',20);
			CorrectionA:=ReadFloat('WavelengthScan','WavelengthCorrectionA',0);
			CorrectionB:=ReadFloat('WavelengthScan','WavelengthCorrectionB',0);
			Monochromator:=TMonochromator(ReadInteger('Monochromator','Monochromator',0));
			for i:=1 to WavelengthScanNumColumns do
			begin
				DefColWidth[1,i]:=ReadInteger('WavelengthScanSpreadsheet','Column '+IntToStr(i)+' Width',60);
				DefColFormat[1,i]:=TColFormat(ReadInteger ('WavelengthScanSpreadsheet','Column '+IntToStr(i)+' Format', 0));
				DefColPlaces[1,i]:=ReadInteger('WavelengthScanSpreadsheet','Column '+IntToStr(i)+' Places', 0);
			end;
			SpectraProHostName:=ReadString('SpectraPro','HostName','CISS32803');
			SpectraProIPAddress:=ReadString('SpectraPro','IP Address','172.16.31.136');
			SpectraProPort:=ReadString('SpectraPro','Port','1875');
			SlitWidth:=ReadString('SpectraPro','Slit width','500');
			Free;
			IniFileRead:=True;
		end;
end;

procedure TMainForm.PutIniStuff;
var
	i:Integer;
begin
	with TIniFile.Create(ExePath+'WavelengthCalibration.ini') do
		begin
			WriteInteger('General','MainFormLeft',MainFormLeft);
			WriteInteger('General','MainFormWidth',MainFormWidth);
			WriteInteger('General','MainFormTop',MainFormTop);
			WriteInteger('General','MainFormHeight',MainFormHeight);
			WriteFloat('WavelengthScan','StartWavelength',StartWavelength);
			WriteFloat('WavelengthScan','StopWavelength',StopWavelength);
			WriteFloat('WavelengthScan','StepWavelength',StepWavelength);
			WriteInteger('WavelengthScan','DelayTime',DelayTime);
			WriteInteger('WavelengthScan','NumRepeats',NumRepeats);
			WriteInteger('WavelengthScan','Threshold',Threshold);
			WriteFloat('WavelengthScan','WavelengthCorrectionA',CorrectionA);
			WriteFloat('WavelengthScan','WavelengthCorrectionB',CorrectionB);
			WriteInteger('Monochromator','Monochromator',Ord(Monochromator));
			for i:=1 to WavelengthScanNumColumns do
			begin
				WriteInteger('WavelengthScanSpreadsheet','Column '+IntToStr(i)+' Width',DefColWidth[1,i]);
				WriteInteger('WavelengthScanSpreadsheet','Column '+IntToStr(i)+' Format',Ord(DefColFormat[1,i]));
				WriteInteger('WavelengthScanSpreadsheet','Column '+IntToStr(i)+' Places',DefColPlaces[1,i]);
			end;
			WriteString('SpectraPro','HostName',SpectraProHostName);
			WriteString('SpectraPro','IP Address',SpectraProIPAddress);
			WriteString('SpectraPro','Port',SpectraProPort);
			WriteString('SpectraPro','Slit width',SlitWidth);
			Free;
    end;
end;

procedure TMainForm.BenthamRadioButtonClick(Sender: TObject);
begin
	EnableButtons(False);
	SpectraProClientSocket.Close;
	Monochromator:=Bentham;
	InitMonochromator;
	EnableButtons(MonochromatorConnected);
	SpectraProRadioButton.Enabled:=True;
	WavelengthEdit.Text:='';
	if MonochromatorConnected then
		with WavelengthScanSpreadsheet do
			InsertData(1,0,'Bentham Wavelength (nm)');
end;

procedure TMainForm.SpectraProRadioButtonClick(Sender: TObject);
begin
	EnableButtons(False);
	Monochromator:=SpectraPro;
	InitMonochromator;
	EnableButtons(MonochromatorConnected);
	BenthamRadioButton.Enabled:=True;
	WavelengthEdit.Text:='';
	if MonochromatorConnected then
		with WavelengthScanSpreadsheet do
			InsertData(1,0,'SpectraPro Wavelength (nm)');
end;

procedure TMainForm.MonochromatorButtonClick(Sender: TObject);
var
	wavelength:Double;
	valid:Boolean;
	m1,m2,monochromatorString:String;
begin
	EnableButtons(False);
	if MonochromatorConnected then
	begin
		m1:='Wavelength must be a real number.';
		m2:='Wavelength must be from 200 nm to 900 nm.';
		ValidDlgReal(WavelengthEdit,'[',200,900,']',False,m1,m2,valid);
		if valid then
			begin
			SetWavelength(StrToFloat(WavelengthEdit.Text));
			wavelength:=GetMonochromatorWavelength;
			if Monochromator=Bentham then
				monochromatorString:='Bentham'
			else
				monochromatorString:='SpectraPro';
			end;
		wavelengthLabel.Caption:=FloatToStrF(wavelength,ffFixed,15,3);
	end
	else
		ShowMessage(monochromatorString+' monochromator not connected.');
	EnableButtons(True);
end;

procedure TMainForm.SetWavelength(Wavelength:Double);
begin
	if Monochromator=Bentham then
		SetBenthamWavelength(Wavelength)
	else
		SetSpectraProWavelength(Wavelength);
end;

function TMainForm.GetMonochromatorWavelength:Double;
begin
	if Monochromator=Bentham then
		GetMonochromatorWavelength:=GetBenthamWavelength
	else
		GetMonochromatorWavelength:=GetSpectraProWavelength;
end;

procedure TMainForm.GetWavelengthButtonClick(Sender: TObject);
var
	wavelength:Double;
begin
	EnableButtons(False);
	if LSAConnected then
	begin
		wavelength:=GetWavelength(0);
		LSAWavelengthLabel.Caption:=FloatToStrF(wavelength,ffFixed,15,3);
	end
	else
		ShowMessage('Laser Spectrum Analyser not connected.');
	EnableButtons(True);
end;

procedure TMainForm.EnableButtons(Enabled:Boolean);
begin
	MonochromatorButton.Enabled:=Enabled;
	GetWavelengthButton.Enabled:=Enabled;
	BenthamRadioButton.Enabled:=Enabled;
	SpectraProRadioButton.Enabled:=Enabled;
	SlitWidthButton.Enabled:=Enabled;
	if not ScanStarted then
	begin
		DoWavelengthScanButton.Enabled:=Enabled;
		PauseButton.Enabled:=Enabled;	
	end;
end;

procedure TMainForm.DoWavelengthScanButtonClick(Sender: TObject);
var
	valid:Boolean;
begin
	WavelengthEdit.Text:='';
	ScanStarted:=not ScanStarted;
	EnableButtons(False);
	if MonochromatorConnected and LSAConnected and ScanStarted then
	begin
		CheckScanRange('Wavelength',' nm',WavelengthFromEdit,WavelengthToEdit,WavelengthStepEdit,200,900,valid);
		CheckScanVariables(valid);
		if valid then
		begin
			InitialiseWavelengthScan;
			ScanWavelengths(StartWavelength,StepWavelength,NumWavelengths);
		end;
		ScanStarted:=False;
	end
	else
	begin
		ScanStarted:=False;
		if not MonochromatorConnected then
			ShowMessage('Monochromator not connected.');
		if not MonochromatorConnected then
			ShowMessage('Laser Spectrum Analyser not connected.');
	end;
	if not ScanStarted then
		DoWavelengthScanButton.Caption:='Start Wavelength Scan';
	EnableButtons(True);
end;

procedure TMainForm.CheckScanVariables(var Valid:Boolean);
var
	m1,m2:String;
begin
	if Valid then
		begin
			m1:='Delay time must be an integer.';
			m2:='Delay time must be between 0 ms and 1000000000 ms.';
			ValidDlgInteger(DelayEdit,0,1000000000,False,m1,m2,Valid);
		end;
		if Valid then
		begin
			m1:='Number of repeats must be an integer.';
			m2:='Number of repeats must be between 1 and 100000.';
			ValidDlgInteger(NumRepeatsEdit,1,100000,False,m1,m2,Valid);
		end;
		if Valid then
		begin
			m1:='Threshold percentage must be an integer.';
			m2:='Threshold must be between 1% and 100%.';
			ValidDlgInteger(ThresholdEdit,1,100,False,m1,m2,Valid);
		end;
end;

procedure TMainForm.InitialiseWavelengthScan;
begin
	DoWavelengthScanButton.Caption:='Stop Wavelength Scan';
	with WavelengthScanSpreadSheet do
	begin
		SelectAll;
		DeleteCells;
		SelectCell(1,1);
		SetSpreadSheetTitles;
		ProgressBar.Position:=0;
	end;
	ScanPaused:=False;
	DelayTime:=StrToInt(DelayEdit.Text);
	NumRepeats:=StrToInt(NumRepeatsEdit.Text);
	Threshold:=StrToInt(ThresholdEdit.Text);
	StartWavelength:=StrToFloat(WavelengthFromEdit.Text);
	StopWavelength:=StrToFloat(WavelengthToEdit.Text);
	StepWavelength:=StrToFloat(WavelengthStepEdit.Text);
	NumWavelengths:=Trunc((StopWavelength-StartWavelength)/StepWavelength)+1;
	CorrectionA:=StrToFloat(WavelengthCorrectionEditA.Text);
	CorrectionB:=StrToFloat(WavelengthCorrectionEditB.Text);
	SetWideMode(0);
end;

procedure TMainForm.ScanWavelengths(StartWavelength,
	StepWavelength: Double; NumWavelengths: Integer);
var
	i,j,k,itemCount,row:Integer;
	thisWavelength,monochromatorWavelength,realWavelength,linewidth:Double;
	realAvgWavelength:Double;
	startTime:Cardinal;
	signal:PData;
begin
	signal:=New(PData);
	row:=1;
	for i:=1 to NumWavelengths do
	begin
		if ScanStarted then
		begin
			WavelengthStr:='';
			PauseButton.Enabled:=True;
			thisWavelength:=StartWavelength+(i-1)*StepWavelength;
			thisWavelength:=thisWavelength-(CorrectionA*thisWavelength+CorrectionB);
			SetLSARange(thisWavelength);
			StatusLabel.Caption:='Setting wavelength...';
			SetWavelength(thisWavelength);
			monochromatorWavelength:=GetMonochromatorWavelength;
			WavelengthLabel.Caption:=FloatToStrF(monochromatorWavelength,ffFixed,15,3);
			StatusLabel.Caption:='Waiting delay...';
			Delay(2*DelayTime);
			startTime:=GetTickCount;
			StatusLabel.Caption:='Adjusting exposure...';
			repeat
				realAvgWavelength:=GetWavelength(0);
				Application.ProcessMessages;
			until (realAvgWavelength>0) or ((GetTickCount-startTime)>10000) or not ScanStarted;
			if ScanStarted then
			begin
				itemCount:=GetAnalysisItemCount(cSignalAnalysis);
				SetAnalysis(cSignalAnalysis,cAnalysisEnable);
			end;
			if realAvgWavelength>0 then
			begin
				for j:=1 to itemCount do
					WavelengthDataY[j]:=0;
				for k:=1 to NumRepeats do
					if ScanStarted then
					begin
						while ScanPaused and ScanStarted do
						begin
							StatusLabel.Caption:='Paused...';
							PauseButton.Enabled:=True;
							Application.ProcessMessages;
						end;
						StatusLabel.Caption:='Measuring wavelength, repeat '+IntToStr(k)+'...';
						MeasureWavelength(signal,itemCount);
						WavelengthStr:=WavelengthStr+FloatToStr(GetWavelength(0))+#9;
					end;
				{for j:=1 to itemCount do
					with WavelengthScanSpreadSheet do
					begin
						InsertData(1,j,FloatToStr(WavelengthDataX[j]));
						InsertData(2,j,FloatToStr(WavelengthDataY[j]));
						InsertData(3,j,FloatToStr(wavelengthCorrection));
					end;}
				if ScanStarted then
				begin
					realWavelength:=CalculateCentroid(itemCount);
					linewidth:=GetLinewidth(cReturnWavelengthAir,0);
					with WavelengthScanSpreadSheet do
					begin
						InsertData(1,row,FloatToStr(thisWavelength));
						{InsertData(1,row,WavelengthStr);}
						InsertData(2,row,FloatToStr(realWavelength));
						InsertData(3,row,FloatToStr(realWavelength-monochromatorWavelength));
						InsertData(4,row,FloatToStr(linewidth));
						ScrollIntoView(StringGrid.LeftCol,row);
						row:=row+1;
					end;
				end;
			end;
			ProgressBar.Position:=Round(i/NumWavelengths*100);
		end;
	end;
	if ScanStarted then
		StatusLabel.Caption:='Scan complete.'
	else
		StatusLabel.Caption:='Scan stopped.';
	PauseButton.Enabled:=False;
	PauseButton.Caption:='Pause';
	Dispose(signal);
end;

procedure TMainForm.MeasureWavelength(Signal:PData;ItemCount:Integer);
var
	startTime:Cardinal;
	realAvgWavelength:Double;
	i:Integer;
begin
	startTime:=GetTickCount;
	repeat
		realAvgWavelength:=GetWavelength(0);
		Application.ProcessMessages;
	until (realAvgWavelength>0) and ((GetTickCount-startTime)>1000);
	GetAnalysisData(cSignalAnalysisX,UIntPtr(WavelengthDataX));
	GetAnalysisData(cSignalAnalysisY,UIntPtr(Signal));
	for i:=1 to ItemCount do
		WavelengthDataY[i]:=WavelengthDataY[i]+Signal[i];
	StatusLabel.Caption:='Waiting delay...';
	Delay(DelayTime);
end;

procedure TMainForm.SetLSARange(Wavelength: Double);
var
	range:Word;
begin
	if Wavelength<322 then
		range:=0
	else
		if Wavelength<415 then
			range:=1
		else
			if Wavelength<605 then
				range:=2
			else
				range:=3;
	SetRange(range);
end;

function TMainForm.CalculateCentroid(NumPoints:Integer):Double;
var
	i:Integer;
	maxSignal,thresholdSignal:Extended;
	integralStarted:Boolean;
	y1,y2,x1,x2,num,den:Double;
begin
	StatusLabel.Caption:='Calculating centroid...';
	maxSignal:=-1000;
	for i:=1 to NumPoints do
		if WavelengthDataY[i]>maxSignal then
			maxSignal:=WavelengthDataY[i];
	thresholdSignal:=maxSignal*Threshold/100;
	integralStarted:=False;
	num:=0;
	den:=0;
	for i:=1 to NumPoints do
		if WavelengthDataY[i]>thresholdSignal then
		begin
			if not integralStarted then
			begin
				integralStarted:=True;
				x2:=WavelengthDataX[i];
				y2:=WavelengthDataY[i];
			end
			else
			begin
				x1:=x2;
				y1:=y2;
				x2:=WavelengthDataX[i];
				y2:=WavelengthDataY[i];
				num:=num+(x2-x1)*(y1*x1+y2*x2)/2;
				den:=den+(x2-x1)*(y1+y2)/2;
			end;
		end;
	if den<>0 then
		CalculateCentroid:=num/den;
end;

procedure TMainForm.PauseButtonClick(Sender: TObject);
begin
	ScanPaused:=not ScanPaused;
	if ScanPaused then
	begin
		PauseButton.Caption:='Continue';
		PauseButton.Enabled:=False;
	end
	else
		PauseButton.Caption:='Pause';
end;

procedure TMainForm.SetSpreadsheetTitles;
begin
	with WavelengthScanSpreadsheet do
	begin
		if Monochromator=Bentham then
			InsertData(1,0,'Bentham Wavelength (nm)')
		else
			InsertData(1,0,'SpectraPro Wavelength (nm)');
		InsertData(2,0,'True Wavelength (nm)');
		InsertData(3,0,'Correction (nm)');
		InsertData(4,0,'Linewidth (nm)');
	end;
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
	MainFormLeft:=Left;
	MainFormWidth:=Width;
	MainFormTop:=Top;
	MainFormHeight:=Height;
	ProgressBar.Width:=Width-30-ProgressBar.Left;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	PutIniStuff;
	Dispose(WavelengthDataX);
	Dispose(WavelengthDataY);
	SpectraProClientSocket.Close;
end;

procedure TMainForm.SpectraProClientSocketConnect(Sender: TObject;
	Socket: TCustomWinSocket);
var
	S:string;
begin
	MonochromatorConnected:=True;
	S:='{"result": {"type": "client", "name": "GonioLab", "language": "Delphi 7.0", "os": "Windows 10 AMD64"}, "requester": "CISS32803:1875", "uuid": "Gonio1", "error": false}';
	SpectraProClientSocket.Socket.SendText(S+#13+#10);
	S:='{"service": "Manager", "attribute": "link", "args": ["mono-hrs"], "kwargs": {}, "uuid": "Gonio0", "error": false}';
	SpectraProClientSocket.Socket.SendText(S+#13+#10);
end;

procedure TMainForm.SpectraProClientSocketDisconnect(Sender: TObject;
	Socket: TCustomWinSocket);
begin
	MonochromatorConnected:=False;
end;

procedure TMainForm.SpectraProClientSocketError(Sender: TObject;
	Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
	var ErrorCode: Integer);
var
	S:string;
begin
	case ErrorEvent of
		eeGeneral:		S:='Unknown socket error for SpectraPro.';
		eeSend:				S:='Error writing to SpectraPro server.';
		eeReceive:		S:='Error receiving from SpectraPro server.';
		eeConnect:		S:='Error connecting to SpectraPro server. Please check that the application is running on the server and that the IP address is correct.';
		eeDisconnect:	S:='Error disconnecting from SpectraPro server.';
		eeAccept:			S:='Error accepting a client request for SpectraPro.';
	end;
	ErrorCode:=0;
end;

function TMainForm.InitSpectraPro:Boolean;
var
	startTime:Cardinal;
begin
	MonochromatorConnected:=False;
	with SpectraProClientSocket do
	begin
		Host:=SpectraProHostName;
		Address:=SpectraProIPAddress;
		Port:=StrToInt(SpectraProPort);
		try
			Open;
			except
				on ESocketError do
					MonochromatorConnected:=False;
		end;
	end;
	startTime:=GetTickCount;
	repeat
		Application.ProcessMessages
	until MonochromatorConnected or ((GetTickCount-startTime)>5000);
	if MonochromatorConnected then
		SetSpectraProSlitWidths
	else
		ShowMessage('Unable to connect to the SpectraPro monochromator.');
	Result:=MonochromatorConnected;
end;

procedure TMainForm.SpectraProClientSocketRead(Sender: TObject;
	Socket: TCustomWinSocket);
var
	S,S1,error:string;
begin
	S:=Socket.ReceiveText;
	error:=CheckForError(S);
	if error='true' then
	begin
		S1:=ExtractErrorMessage(S);
	end
	else
	begin
		S1:=ExtractUUID(S);
		if S1='Gonio1' then
			SpectraProResponded:=True;
		if S1='Gonio2' then
		begin
			S1:=ExtractResult(S);
			SpectraProWavelength:=StrToFloat(S1);
			SpectraProResponded:=True;
		end;
		if S1='Gonio3' then
		begin
			S1:=ExtractResult(S);
			SpectraProFilterPos:=StrToInt(S1);
			SpectraProResponded:=True;
		end;
	end;
end;

function TMainForm.ExtractUUID(S: string): string;
var
	pos1,pos2:Integer;
	S1,S2:string;
begin
	pos1:=Pos('"uuid"',S);
	S1:=Copy(S,pos1+9,Length(S)-pos1);
	pos2:=Pos('"',S1);
	S2:=Copy(S1,1,pos2-1);
	ExtractUUID:=S2;
end;

function TMainForm.ExtractResult(S: string): string;
var
	pos1,pos2:Integer;
	S1,S2:string;
begin
	pos1:=Pos('"result"',S);
	S1:=Copy(S,pos1+10,Length(S)-pos1);
	pos2:=Pos(',',S1);
	S2:=Copy(S1,1,pos2-1);
	ExtractResult:=S2;
end;

function TMainForm.CheckForError(S: string): string;
var
	pos1:Integer;
	S1,S2:string;
begin
	pos1:=Pos('"error"',S);
	S1:=Copy(S,pos1+9,Length(S)-pos1);
	S2:=Copy(S1,1,4);
	CheckForError:=S2;
end;

function TMainForm.ExtractErrorMessage(S: string): string;
var
	pos1,pos2:Integer;
	S1,S2:string;
begin
	pos1:=Pos('"message"',S);
	S1:=Copy(S,pos1+11,Length(S)-pos1);
	pos2:=Pos('}',S1);
	S2:=Copy(S1,1,pos2-1);
	ExtractErrorMessage:=S2;
end;

procedure TMainForm.SendSpectraProCommand(Command,Value,UUID:string);
var
	S:string;
	startTime:Cardinal;
begin
	if MonochromatorConnected then
	begin
		SpectraProResponded:=False;
		S:='{"service": "mono-hrs", "attribute": "'+Command+'", "args": ['+Value+'], "kwargs": {}, "uuid": "'+UUID+'", "error": false}';
		SpectraProClientSocket.Socket.SendText(S+#13+#10);
		startTime:=GetTickCount;
		repeat
			Application.ProcessMessages;
		until SpectraProResponded or (GetTickCount-startTime>5000);
	end;
end;

procedure TMainForm.SetSpectraProWavelength(Value: Double);
var
	S1:string;
	wavelengthInt:integer;
begin
	S1:=FloatToStr(Value);
	SendSpectraProCommand('set_wavelength',S1,'Gonio1');
	wavelengthInt:=Round(Value);
	case wavelengthInt of
		0..629:SpectraProFilterOpenPos:=1;
		630..729:SpectraProFilterOpenPos:=3;
		730..900:SpectraProFilterOpenPos:=4;
	end;
	SendSpectraProCommand('set_filter_position',IntToStr(SpectraProFilterOpenPos),'Gonio3');
end;

function TMainForm.GetSpectraProWavelength: Double;
begin
	SendSpectraProCommand('get_wavelength','','Gonio2');
	GetSpectraProWavelength:=SpectraProWavelength;
end;

procedure TMainForm.SetSpectraProSlitWidths;
begin
	SendSpectraProCommand('set_front_entrance_slit_width',SlitWidth,'Gonio4');
	SendSpectraProCommand('set_front_exit_slit_width',SlitWidth,'Gonio5');
end;

procedure TMainForm.SlitWidthButtonClick(Sender: TObject);
begin
	SlitWidth:=SlitWidthEdit.Text;
	SendSpectraProCommand('set_front_entrance_slit_width',SlitWidth,'Gonio4');
	SendSpectraProCommand('set_front_exit_slit_width',SlitWidth,'Gonio5');
end;

end.
