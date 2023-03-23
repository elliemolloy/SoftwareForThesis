unit DetMainForm;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	Reflectance3D, ExtCtrls, DetGlobal, IniFiles, StdCtrls, Menus, ImgList,
	ViewFactors, ComCtrls, ToolWin, System.ImageList, Vcl.Grids;

type
	TXVariable=(DetAngle,XOffset,YOffset);
	TCalculationMode=(CollimatedDetectorModel,DiffuseDetectorModel,ViewFactor);

  TMainForm = class(TForm)
    ResultsPanel: TPanel;
    CalculateButton: TButton;
    RDiffLabel: TLabel;
    RDiffuseLabel: TLabel;
    MainMenu: TMainMenu;
    FileMenu: TMenuItem;
    ExitMenu: TMenuItem;
    EditMenu: TMenuItem;
    CutMenu: TMenuItem;
    CopyMenu: TMenuItem;
    PasteMenu: TMenuItem;
    DeleteMenu: TMenuItem;
    SelectAllMenu: TMenuItem;
    GraphMenu: TMenuItem;
    xAxisMenu: TMenuItem;
		yAxisMenu: TMenuItem;
    LineStyleMenu: TMenuItem;
    DetInputVariablesGroupBox: TGroupBox;
    WavelengthLabel: TLabel;
    WavelengthEdit: TEdit;
    ThicknessLabel: TLabel;
    ThicknessEdit: TEdit;
    DiffuseDetAngleLabel: TLabel;
    DiffuseDetAngleEdit: TEdit;
    PolLabel: TLabel;
    BeamRadiusEdit: TEdit;
    Label1: TLabel;
    DetectorRadiusEdit: TEdit;
    ParameterSelectionGroupBox: TGroupBox;
    DetectorAngleRadioButton: TRadioButton;
    xOffsetRadioButton: TRadioButton;
    yOffsetRadioButton: TRadioButton;
    OtherParameter1Label: TLabel;
    OtherParameter1Edit: TEdit;
    OtherParameter2Label: TLabel;
    OtherParameter2Edit: TEdit;
    BeamImagingGroupBox: TGroupBox;
    BeamDataCheckBox: TCheckBox;
    OpenDialog: TOpenDialog;
    Label2: TLabel;
    FileNameSEdit: TEdit;
    sBrowseButton: TButton;
    Label3: TLabel;
    FileNamePEdit: TEdit;
    pBrowseButton: TButton;
    pOffsetCheckBox: TCheckBox;
    Label4: TLabel;
    pOffsetEdit: TEdit;
    N1: TMenuItem;
    LoadStyleMenu: TMenuItem;
    SaveCurrentStyleMenu: TMenuItem;
    LoadDefaultStyleMenu: TMenuItem;
    SaveCurrentStyleAsDefaultMenu: TMenuItem;
    RDiffPLabel: TLabel;
    RDiffusePLabel: TLabel;
    VFInputVariablesGroupBox: TGroupBox;
    Label7: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    BeamRadiusVFEdit: TEdit;
    DetectorRadiusVFEdit: TEdit;
    LengthEdit: TEdit;
    CoordinateSystemGroupBox: TGroupBox;
    PolarRadioButton: TRadioButton;
    RectangularRadioButton: TRadioButton;
    GraphPanel: TPanel;
    DataPanel: TPanel;
		HorizontalSplitter: TSplitter;
		VerticalSplitter: TSplitter;
    OptionsMenu: TMenuItem;
    CollimatedDetectorModelMenu: TMenuItem;
    DiffuseDetectorModelMenu: TMenuItem;
    ViewFactorsMenu: TMenuItem;
    N2: TMenuItem;
    ShowPanelMenu: TMenuItem;
    ToolBar1: TToolBar;
    NewButton: TToolButton;
    OpenButton: TToolButton;
    SaveButton: TToolButton;
    ToolButton4: TToolButton;
    CutButton: TToolButton;
    CopyButton: TToolButton;
    PasteButton: TToolButton;
    ToolButton8: TToolButton;
    xAxisButton: TToolButton;
    yAxisButton: TToolButton;
    LineStyleButton: TToolButton;
    ToolButton12: TToolButton;
    PrintButton: TToolButton;
    MenuImageList: TImageList;
    SaveFileDialog: TSaveDialog;
    NewMenu: TMenuItem;
    ExitSeparator: TMenuItem;
    SaveAsMenu: TMenuItem;
    SaveMenu: TMenuItem;
    OpenMenu: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
		OpenFileDialog: TOpenDialog;
    DiffuseDetModelGroupBox: TGroupBox;
    Label9: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label15: TLabel;
    DiffuseThicknessEdit: TEdit;
    DiffuseBeamRadiusEdit: TEdit;
    DiffuseDetectorRadiusEdit: TEdit;
    DiffusePOffsetCheckBox: TCheckBox;
    DiffusePOffsetEdit: TEdit;
    DiffuseYOffsetEdit: TEdit;
    Label14: TLabel;
    Label8: TLabel;
    DiffuseXOffsetEdit: TEdit;
    AutosaveMenu: TMenuItem;
    PauseButton: TButton;
    SaveDataAsTextFileMenu: TMenuItem;
    SaveTextFileDialog: TSaveDialog;
    Label10: TLabel;
    Label13: TLabel;
    xOffsetVFEdit: TEdit;
    yOffsetVFEdit: TEdit;
    VaryingLambdaCheckBox: TCheckBox;
    NGauLegEdit: TEdit;
    NGauLegLabel: TLabel;
    PlotDataMenu: TMenuItem;
    N3: TMenuItem;
    Label16: TLabel;
    DiffusePitchEdit: TEdit;
    MirrorReflCheckBox: TCheckBox;
		procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DataPanelResize(Sender: TObject);
    procedure CalculateButtonClick(Sender: TObject);
    procedure DetectorAngleRadioButtonClick(Sender: TObject);
    procedure xOffsetRadioButtonClick(Sender: TObject);
    procedure yOffsetRadioButtonClick(Sender: TObject);
		procedure ExitMenuClick(Sender: TObject);
    procedure HorizontalSplitterCanResize(Sender: TObject;
      var NewSize: Integer; var Accept: Boolean);
    procedure CutMenuClick(Sender: TObject);
    procedure CopyMenuClick(Sender: TObject);
    procedure PasteMenuClick(Sender: TObject);
    procedure DeleteMenuClick(Sender: TObject);
		procedure SelectAllMenuClick(Sender: TObject);
		procedure GraphMenuClick(Sender: TObject);
    procedure xAxisMenuClick(Sender: TObject);
    procedure yAxisMenuClick(Sender: TObject);
		procedure LineStyleMenuClick(Sender: TObject);
    procedure sBrowseButtonClick(Sender: TObject);
    procedure pBrowseButtonClick(Sender: TObject);
    procedure BeamDataCheckBoxClick(Sender: TObject);
		procedure pOffsetCheckBoxClick(Sender: TObject);
    procedure LoadStyleMenuClick(Sender: TObject);
    procedure SaveCurrentStyleMenuClick(Sender: TObject);
    procedure LoadDefaultStyleMenuClick(Sender: TObject);
    procedure SaveCurrentStyleAsDefaultMenuClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PolarRadioButtonClick(Sender: TObject);
    procedure RectangularRadioButtonClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure VerticalSplitterCanResize(Sender: TObject;
      var NewSize: Integer; var Accept: Boolean);
    procedure OptionsMenuClick(Sender: TObject);
		procedure CollimatedDetectorModelMenuClick(Sender: TObject);
		procedure DiffuseDetectorModelMenuClick(Sender: TObject);
    procedure ViewFactorsMenuClick(Sender: TObject);
		procedure ShowPanelMenuClick(Sender: TObject);
		procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure NewMenuClick(Sender: TObject);
    procedure OpenMenuClick(Sender: TObject);
    procedure SaveAsMenuClick(Sender: TObject);
    procedure SaveMenuClick(Sender: TObject);
    procedure FileMenuClick(Sender: TObject);
    procedure VerticalSplitterMoved(Sender: TObject);
		procedure HorizontalSplitterMoved(Sender: TObject);
		procedure PastFileNameClick(Sender: TObject);
    procedure DiffusePOffsetCheckBoxClick(Sender: TObject);
    procedure EditChange(Sender: TObject);
    procedure AutosaveMenuClick(Sender: TObject);
    procedure PauseButtonClick(Sender: TObject);
    procedure SaveDataAsTextFileMenuClick(Sender: TObject);
    procedure VaryingLambdaCheckBoxClick(Sender: TObject);
    procedure PlotDataMenuClick(Sender: TObject);
	private
		{ Private declarations }
		procedure LoadPreferences;
		procedure SavePreferences;
		procedure SetSpreadsheetTitles;
		procedure EnableButtons(ToWhat:Boolean);
		procedure ResetDataSpreadsheet;
		procedure AddPastFileName(FileName:string);
		function FileSaveAs:Boolean;
		procedure StoreFile;
		procedure SetModeToCollimatedDetectorModel;
		procedure SetModeToDiffuseDetectorModel;
		procedure SetModeToViewFactor;
		procedure UpdateFileMenu;
		procedure MyIdleHandler(Sender: TObject; var Done: Boolean);
		procedure CalculateCollimated(var Valid:Boolean);
		procedure CalculateDiffuse(var Valid:Boolean);
		procedure CalculateAllViewFactors(var Valid:Boolean);
	public
		{ Public declarations }
		procedure ResetFile;
		procedure LoadFile(FileName: string);
	end;

var
	MainForm: TMainForm;
	IniFile,Pol:string;
	Lambda,Thickness,DiffuseDetAngle,BeamRadius,DetectorRadius,POffsetSize,DiffusePitch:Extended;
	XOffsetVF,YOffsetVF:Integer;
	VaryingLambda,IncludeMirrorRefl:Boolean;
	LengthL:Extended;
	XVariable:TXVariable;
	Mode:TCalculationMode;

function CheckValidInput(TheEdit:TEdit;Variable,Units:string;Min,Max:Extended;var Valid:Boolean):Extended;
function CheckValidInputInteger(TheEdit:TEdit;Variable,Units:string;Min,Max:Integer;var Valid:Boolean):Integer;
function CheckValidTableData(Row,Col:Integer;Variable,Units:string;Min,Max:Extended;var Valid:Boolean):Extended;

implementation

uses
	DetGraph, DetSpreadsheet;

{$R *.DFM}

procedure TMainForm.FormCreate(Sender: TObject);
begin
	FirstStart:=True;
	IniFile:='DetectorModel.ini';
	DefaultStyleFileName:=GetWindowsFileName('DetectorModelDef.qgs');
	LoadPreferences;
	IsDirty:=False;
	if Mode=DiffuseDetectorModel then
		DataPanel.Width:=HorSplitterPosDiffuse
	else
		DataPanel.Width:=HorSplitterPos;
	HorizontalSplitter.Left:=DataPanel.Left+DataPanel.Width+1;
	ResultsPanel.Height:=VertSplitterPos;
	ResultsPanel.Align:=alBottom;
	ResultsPanel.Top:=Height-ResultsPanel.Height-1;
	VerticalSplitter.Top:=ResultsPanel.Top-VerticalSplitter.Height-1;
	GraphPanel.Align:=alClient;
	with DefaultGraphFonts do
	begin
		xTitleFont:=TFont.Create;
		yTitleFont:=TFont.Create;
		xNumberFont:=TFont.Create;
		yNumberFont:=TFont.Create;
	end;
	if FileExists(DefaultStyleFileName) then
		LoadGraphStyle(DefaultGraphStyle,DefaultGraphFonts,DefaultStyleFileName)
	else
		SetGraphStyleDefaults;
	GraphWindow:=TGraphWindow.Create(GraphPanel);
	GraphWindow.Parent:=GraphPanel;
	GraphWindow.ResetGraph;
	DataSpreadSheet:=TDataSpreadSheet.Create(DataPanel,1,DataSpreadsheetColumns,1,1,True,False,True);
	DataSpreadSheet.Parent:=DataPanel;
	DataSpreadsheet.ResetSpreadsheet;
	FileNameSEdit.Text:=BeamDataSFileName;
	FileNamePEdit.Text:=BeamDataPFileName;
	BeamDataCheckBox.Checked:=BeamData;
	sBrowseButton.Enabled:=BeamData;
	pBrowseButton.Enabled:=BeamData;
	FileNameSEdit.Enabled:=BeamData;
	FileNamePEdit.Enabled:=BeamData;
	NGauLegEdit.Text:=IntToStr(NGauLeg);
	case Mode of
		CollimatedDetectorModel:SetModeToCollimatedDetectorModel;
		DiffuseDetectorModel:SetModeToDiffuseDetectorModel;
		ViewFactor:SetModeToViewFactor;
	end;
	AutosaveMenu.Checked:=Autosave;
	Started:=False;
	Application.OnIdle:=MyIdleHandler;
	FirstStart:=False;
	ResetFile;
end;

procedure TMainForm.LoadPreferences;
{Loads the preferences from the file "DetectorModel.ini".}
var
	f:TIniFile;
	i:Integer;
begin
	Screen.Cursor:=crHourGlass;
	f:=TIniFile.Create(ExtractFilePath(Application.ExeName)+'\'+IniFile);
	with f do
	begin
		HorSplitterPos:=ReadInteger('Splitter Positions','HorSplitterPos',200);
		HorSplitterPosDiffuse:=ReadInteger('Splitter Positions','HorSplitterPosDiffuse',200);
		VertSplitterPos:=ReadInteger('Splitter Positions','VertSplitterPos',200);
		DataLeft:=ReadInteger('Settings','DataLeft',2);
		Autosave:=ReadBool('Settings','Autosave',False);
		Lambda:=ReadFloat('Beam Variables','Wavelength',530);
		Thickness:=ReadFloat('Beam Variables','Thickness',30);
		DiffuseDetAngle:=ReadFloat('Beam Variables','Diffuse Detector Angle',20);
		BeamRadius:=ReadFloat('Beam Variables','Beam Radius',7.5);
		DetectorRadius:=ReadFloat('Beam Variables','Detector Radius',15);
		XVariable:=TXVariable(ReadInteger('Beam Variables','X Variable',0));
		Mode:=TCalculationMode(ReadInteger('Beam Variables','Calculation Mode',0));
		BeamData:=ReadBool('Beam Variables','UseBeamData',False);
		BeamDataSFileName:=ReadString('Beam Variables','BeamDataSFileName','');
		BeamDataPFileName:=ReadString('Beam Variables','BeamDataPFileName','');
		OffsetP:=ReadBool('Beam Variables','OffsetP',False);
		POffsetSize:=ReadFloat('Beam Variables','POffsetSize',1);
		DiffusePitch:=ReadFloat('Beam Variables','Pitch',0);
    IncludeMirrorRefl:=ReadBool('Beam variables','Include mirror reflection',True);
		Polar:=ReadBool('View Factor Parameters','Polar',True);
		LengthL:=ReadFloat('View Factor Parameters','Length',500);
		XOffsetVF:=ReadInteger('View Factor Parameters','X Offset VF',0);
		YOffsetVF:=ReadInteger('View Factor Parameters','Y Offset VF',0);
		VaryingLambda:=ReadBool('View Factor Parameters','VaryingLambda',False);
		NGauLeg:=ReadInteger('View Factor Parameters','NGauLeg',20);
		for i:=0 to MaxColumns-1 do
		begin
			DefColWidth[1,i]:=ReadInteger('Column Widths','Column Width '+IntToStr(i),60);
			DefColFormat[1,i]:=TCellFormat(ReadInteger('Column Formats','Column Format '+IntToStr(i),0));
			DefColPlaces[1,i]:=ReadInteger('Column Places','Column Places '+IntToStr(i),0);
			DiffuseDefColWidth[1,i]:=ReadInteger('Column Widths','Diffuse Column Width '+IntToStr(i),60);
			DiffuseDefColFormat[1,i]:=TCellFormat(ReadInteger('Column Formats','Diffuse Column Format '+IntToStr(i),0));
			DiffuseDefColPlaces[1,i]:=ReadInteger('Column Places','Diffuse Column Places '+IntToStr(i),0);
		end;
		for i:=1 to MaxPastFileNames do
			PastFileNames[i]:=ReadString('Past File Names','Past File Names '+IntToStr(i),'');
	end;
	Screen.Cursor:=crDefault;
end;

procedure TMainForm.SavePreferences;
{Stores the preferences to the file "DetectorModel.ini".}
var
	f:TIniFile;
	i:Integer;
begin
	Screen.Cursor:=crHourGlass;
	Visible:=False;
	f:=TIniFile.Create(ExtractFilePath(Application.ExeName)+'\'+IniFile);
	with f do
	begin
		WriteInteger('Splitter Positions','HorSplitterPos',HorSplitterPos);
		WriteInteger('Splitter Positions','HorSplitterPosDiffuse',HorSplitterPosDiffuse);
		WriteInteger('Splitter Positions','VertSplitterPos',ResultsPanel.Height);
		WriteInteger('Settings','DataLeft',DataLeft);
		WriteBool('Settings','Autosave',Autosave);
		WriteFloat('Beam Variables','Wavelength',Lambda);
		WriteFloat('Beam Variables','Thickness',Thickness);
		WriteFloat('Beam Variables','Diffuse Detector Angle',DiffuseDetAngle);
		WriteFloat('Beam Variables','Beam Radius',BeamRadius);
		WriteFloat('Beam Variables','Detector Radius',DetectorRadius);
		WriteInteger('Beam Variables','X Variable',Ord(XVariable));
		WriteInteger('Beam Variables','Calculation Mode',Ord(Mode));
		WriteBool('Beam Variables','UseBeamData',BeamData);
		WriteString('Beam Variables','BeamDataSFileName',BeamDataSFileName);
		WriteString('Beam Variables','BeamDataPFileName',BeamDataPFileName);
		WriteBool('Beam Variables','OffsetP',OffsetP);
		WriteFloat('Beam Variables','POffsetSize',POffsetSize);
		WriteFloat('Beam Variables','Pitch',DiffusePitch);
    WriteBool('Beam variables','Include mirror reflection',IncludeMirrorRefl);
		WriteBool('View Factor Parameters','Polar',Polar);
		WriteFloat('View Factor Parameters','Length',LengthL);
		WriteFloat('View Factor Parameters','X Offset VF',XOffsetVF);
		WriteFloat('View Factor Parameters','Y Offset VF',YOffsetVF);
		WriteBool('View Factor Parameters','VaryingLambda',VaryingLambda);
		WriteInteger('View Factor Parameters','NGauLeg',NGauLeg);
		for i:=0 to MaxColumns-1 do
		begin
			WriteInteger('Column Widths','Column Width '+IntToStr(i),DefColWidth[1,i]);
			WriteInteger('Column Formats','Column Format '+IntToStr(i),Ord(DefColFormat[1,i]));
			WriteInteger('Column Places','Column Places '+IntToStr(i),DefColPlaces[1,i]);
			WriteInteger('Column Widths','Diffuse Column Width '+IntToStr(i),DiffuseDefColWidth[1,i]);
			WriteInteger('Column Formats','Diffuse Column Format '+IntToStr(i),Ord(DiffuseDefColFormat[1,i]));
			WriteInteger('Column Places','Diffuse Column Places '+IntToStr(i),DiffuseDefColPlaces[1,i]);
		end;
		for i:=1 to MaxPastFileNames do
			WriteString('Past File Names','Past File Names '+IntToStr(i),PastFileNames[i]);
		Free;
	end;
	Screen.Cursor:=crDefault;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	SavePreferences;
	with DefaultGraphFonts do
	begin
		xTitleFont.Free;
		yTitleFont.Free;
		xNumberFont.Free;
		yNumberFont.Free;
	end;
end;

procedure TMainForm.SetSpreadsheetTitles;
begin
	case Mode of
		CollimatedDetectorModel:
			begin
				with DataSpreadsheet do
				begin
					case XVariable of
						DetAngle:InsertData(1,0,'Det. Angle (°)');
						XOffset:InsertData(1,0,'x-Offset (mm)');
						YOffset:InsertData(1,0,'y-Offset (mm)');
					end;
					InsertData(2,0,'Rc,s');
					InsertData(3,0,'Rc,p');
					InsertData(4,0,'Rc,s/Rd');
					InsertData(5,0,'Rc,p/Rd');
					InsertData(6,0,'');
				end;
			end;
		DiffuseDetectorModel:
			begin
      	with DataSpreadsheet do
				begin
					InsertData(1,0,'Wavelength (nm)');
					InsertData(2,0,'Det. Angle (°)');
					InsertData(3,0,'Rc,s');
					InsertData(4,0,'Rc,p');
					InsertData(5,0,'Rd,s');
					InsertData(6,0,'Rd,p');
				end;
			end;
		ViewFactor:
			begin
				with DataSpreadsheet do
				begin
					InsertData(1,0,'Det. Angle (°)');
					InsertData(2,0,'VF s');
					InsertData(3,0,'VF s/cos(td)');
					InsertData(4,0,'VF p');
					InsertData(5,0,'VF p/cos(td)');
					InsertData(6,0,'');
				end;
			end;
	end;
end;

procedure TMainForm.DataPanelResize(Sender: TObject);
var
	theRowCount,oldRowCount,i,j:Integer;
begin
	with DataSpreadSheet.StringGrid do
	begin
		theRowCount:=Height div DefaultRowHeight;
		if RowCount<theRowCount then
		begin
			oldRowCount:=RowCount;
			RowCount:=theRowCount;
			for i:=0 to ColCount-1 do
				for j:=oldRowCount to RowCount-1 do
					if DataSpreadSheet.AutoNumber and (i=0) and (j>0) then
						Cells[i,j]:=IntToStr(j)
					else
						Cells[i,j]:='';
		end;
		if DataSpreadSheet.Editable then
			DataSpreadSheet.StringGridEdit.Width:=DataSpreadSheet.TopPanel.Width-2;
	end;
end;

function CheckValidInput(TheEdit:TEdit;Variable,Units:string;Min,Max:Extended;var Valid:Boolean):Extended;
var
	m1,m2,S:string;
begin
	if Valid then
	begin
		m1:=Variable+' must be a real number.';
		if Units='' then
			S:=''
		else
			S:=' ';
		m2:=Variable+' must be between '+FloatToStr(Min)+S+Units+' and '+FloatToStr(Max)+S+Units+'.';
		CheckValidInput:=ValidDlgReal(TheEdit,'[',Min,Max,']',False,m1,m2,Valid);
	end;
end;

function CheckValidInputInteger(TheEdit:TEdit;Variable,Units:string;Min,Max:Integer;var Valid:Boolean):Integer;
var
	m1,m2,S:string;
begin
	if Valid then
	begin
		m1:=Variable+' must be an integer.';
		if Units='' then
			S:=''
		else
			S:=' ';
		m2:=Variable+' must be between '+FloatToStr(Min)+S+Units+' and '+FloatToStr(Max)+S+Units+'.';
		CheckValidInputInteger:=ValidDlgInteger(TheEdit,Min,Max,False,m1,m2,Valid);
	end;
end;

function CheckValidTableData(Row,Col:Integer;Variable,Units:string;Min,Max:Extended;var Valid:Boolean):Extended;
var
	m1,m2:string;
	number:Extended;
begin
	if Valid then
	begin
		m1:=Variable+' must be a real number.';
		m2:=Variable+' must be between '+FloatToStr(Min)+' '+Units+' and '+FloatToStr(Max)+' '+Units+'.';
		number:=ValidRealString(DataSpreadsheet.StringGrid.Cells[Col,Row],'[',Min,Max,']',False,m1,m2,Valid);
		if Valid then
			CheckValidTableData:=number
		else
			DataSpreadsheet.SelectCell(Col,Row);
	end;
end;

procedure TMainForm.CalculateButtonClick(Sender: TObject);
var
	valid:Boolean;
	startTime,endTime,totalTime:Cardinal;
begin
	Started:=not Started;
	Paused:=False;
	if Started then
	begin
		startTime:=GetTickCount;
		Screen.Cursor:=crHourGlass;
		GraphWindow.Empty:=True;
		GraphWindow.Repaint;
		CalculateButton.Caption:='Stop';
		if Autosave and IsNewFile then
			Autosave:=FileSaveAs;
		valid:=True;
		DataSpreadsheet.SelectCells(DataLeft,DataSpreadsheetColumns,1,DataSpreadsheet.StringGrid.RowCount);
		DataSpreadsheet.DeleteCells;
		DataSpreadsheet.DeselectAll;
		BeamDataSFileName:=FileNameSEdit.Text;
		BeamDataPFileName:=FileNamePEdit.Text;
		GraphWindow.NumCurves:=2;
		case Mode of
			CollimatedDetectorModel:CalculateCollimated(valid);
			DiffuseDetectorModel:CalculateDiffuse(valid);
			ViewFactor:CalculateAllViewFactors(valid);
		end;
		if valid then
		begin
      GraphWindow.Empty:=False;
			GraphWindow.Repaint;
			if Autosave then
				StoreFile
			else
				IsDirty:=True;
		end;
		endTime:=GetTickCount;
		EnableButtons(True);
		CalculateButton.Caption:='Calculate';
		Screen.Cursor:=crDefault;
		totalTime:=endTime-startTime;
		{ShowMessage(FloatToStr(totalTime));}
		Started:=False;
	end
	else
	begin
		CalculateButton.Caption:='Calculate';
		EnableButtons(True);
		Screen.Cursor:=crDefault;
	end;
end;

procedure TMainForm.CalculateCollimated(var Valid:Boolean);
{Allows the collimated beam to be displaced in the x and y directions, and the detector
angle to be changed (by a small amount) to see the effect on the ratio between the
diffuse and collimated beams for the I0 measurement.}
var
	rDiffuse,thisRCollimatedS,thisRCollimatedP,ratioS,ratioP:Extended;
	i,lastRow:Integer;
	thisDetAngleDeg,thisDetAngle,thisXOffset,thisYOffset:Extended;
	rDiffuseS,rDiffuseP:Extended;
begin
	RDiffuseLabel.Caption:='';
	RDiffusePLabel.Caption:='';
	Lambda:=CheckValidInput(WavelengthEdit,'Wavelength','nm',200,2000,Valid);
	Thickness:=CheckValidInput(ThicknessEdit,'Thickness','nm',0,100,Valid);
	DiffuseDetAngle:=CheckValidInput(DiffuseDetAngleEdit,'Diffuse beam detector angle','°',-180,180,Valid);
	BeamRadius:=CheckValidInput(BeamRadiusEdit,'Beam radius','mm',0,50,Valid);
	DetectorRadius:=CheckValidInput(DetectorRadiusEdit,'Detector radius','mm',0,50,Valid);
	if OffsetP then
		POffsetSize:=CheckValidInput(pOffsetEdit,'P offset','mm',-10,10,Valid)
	else
		POffsetSize:=0;
	if Valid and Started then
	begin
		CreateSiRefractiveIndexTable;
    CreateAlRefractiveIndexTable;
		with DataSpreadsheet.StringGrid do
		begin
			lastRow:=0;
			for i:=1 to RowCount-1 do
				if not (Cells[1,i]='') then
					lastRow:=i;
			GraphWindow.NumPoints[1]:=lastRow;
			GraphWindow.NumPoints[2]:=lastRow;
			if lastRow=0 then
			begin
				MessageDlg('Please enter some data.',mtWarning,[mbOk],0);
				Valid:=False;
				DataSpreadsheet.SelectCell(1,1);
			end
			else
			begin
				for i:=1 to lastRow do
				begin
					case XVariable of
						DetAngle:
							begin
								CheckValidTableData(i,1,'Detector angle','°',-360,360,Valid);
								thisXOffset:=CheckValidInput(OtherParameter1Edit,'X offset','mm',-20,20,Valid);
								thisYOffset:=CheckValidInput(OtherParameter2Edit,'Y offset','mm',-20,20,Valid);
							end;
						XOffset:
							begin
								CheckValidTableData(i,1,'X offset','mm',-20,20,Valid);
								thisYOffset:=CheckValidInput(OtherParameter2Edit,'Y offset','mm',-20,20,Valid);
								thisDetAngleDeg:=CheckValidInput(OtherParameter1Edit,'Detector angle','°',-360,360,Valid);
								if Valid then
									thisDetAngle:=(thisDetAngleDeg-180)*Pi/180;
							end;
						yOffset:
							begin
								CheckValidTableData(i,1,'Y offset','m',-20,20,Valid);
								thisXOffset:=CheckValidInput(OtherParameter2Edit,'X offset','mm',-20,20,Valid);
								thisDetAngleDeg:=CheckValidInput(OtherParameter1Edit,'Detector angle','°',-360,360,Valid);
								if Valid then
									thisDetAngle:=(thisDetAngleDeg-180)*Pi/180;
							end;
					end;
				end;
			end;
			if Valid and Started then
			begin
				EnableButtons(False);
				if BeamData then
					ReadBeamFile(BeamDataSFileName,BeamDataPFileName,Valid);
				if Valid and Started then
				begin
					if BeamData then
					begin
						CalculateRDiffuseBeamData(Lambda,Thickness,DiffuseDetAngle*Pi/180,rDiffuseS,rDiffuseP);
						RDiffLabel.Caption:='R diffuse s:';
						RDiffuseLabel.Caption:=FloatToStr(rDiffuseS);
						RDiffuseLabel.Visible:=True;
						RDiffPLabel.Visible:=True;
						RDiffusePLabel.Visible:=True;
						RDiffusePLabel.Caption:=FloatToStr(rDiffuseP);
					end
					else
					begin
						rDiffuse:=CalculateRDiffuse(Lambda,Thickness,DiffuseDetAngle*Pi/180,rDiffuseS,rDiffuseP);
						RDiffLabel.Caption:='R diffuse unpolarised:';
						RDiffuseLabel.Caption:=FloatToStr(rDiffuse);
						RDiffuseLabel.Visible:=True;
						RDiffPLabel.Visible:=False;
						RDiffusePLabel.Visible:=False;
					end;
				end;
				for i:=1 to lastRow do
				begin
					case XVariable of
						DetAngle:
							begin
								thisDetAngleDeg:=StrToFloat(DataSpreadsheet.StringGrid.Cells[1,i]);
								thisDetAngle:=(thisDetAngleDeg-180)*Pi/180;
							end;
						XOffset:thisXOffset:=StrToFloat(DataSpreadsheet.StringGrid.Cells[1,i]);
						yOffset:thisYOffset:=StrToFloat(DataSpreadsheet.StringGrid.Cells[1,i]);
					end;
					if Valid and Started then
					begin
						thisRCollimatedS:=CalculateRCollimated(Lambda,Thickness,thisDetAngle,thisXOffset,thisYOffset,'s',BeamData);
						thisRCollimatedP:=CalculateRCollimated(Lambda,Thickness,thisDetAngle,thisXOffset+POffsetSize,thisYOffset+POffsetSize,'p',BeamData);
						if BeamData then
						begin
							ratioS:=thisRCollimatedS/rDiffuseS;
							ratioP:=thisRCollimatedP/rDiffuseP;
						end
						else
						begin
							ratioS:=thisRCollimatedS/rDiffuse;
							ratioP:=thisRCollimatedP/rDiffuse;
						end;
						Cells[2,i]:=FloatToStr(thisRCollimatedS);
						Cells[4,i]:=FloatToStr(ratioS);
						Cells[3,i]:=FloatToStr(thisRCollimatedP);
						Cells[5,i]:=FloatToStr(ratioP);
						with GraphWindow do
						begin
							xData[1]^[i]:=StrToFloat(Cells[1,i]);
							yData[1]^[i]:=ratioS;
							xData[2]^[i]:=StrToFloat(Cells[1,i]);
							yData[2]^[i]:=ratioP;
							xTitle:=Cells[1,0];
							yTitle:='R collimated/R diffuse';
						end;
						if Autosave then
							if IsNewFile then
								Autosave:=FileSaveAs;
						if Autosave then
							StoreFile
						else
							IsDirty:=True;
					end;
				end;
			end;
		end;
	end;
end;

procedure TMainForm.CalculateDiffuse(var Valid:Boolean);
var
	rDiffuse,thisRCollimatedS,thisRCollimatedP,ratioS,ratioP:Extended;
	i,lastRow:Integer;
	thisDetAngleDeg,thisDetAngle,thisXOffset,thisYOffset:Extended;
	rDiffuseS,rDiffuseP,thisLambda:Extended;
begin
	Thickness:=CheckValidInput(DiffuseThicknessEdit,'Thickness','nm',0,100,Valid);
	BeamRadius:=CheckValidInput(DiffuseBeamRadiusEdit,'Beam radius','mm',0,50,Valid);
	DetectorRadius:=CheckValidInput(DiffuseDetectorRadiusEdit,'Detector radius','mm',0,50,Valid);
	thisXOffset:=CheckValidInput(DiffuseXOffsetEdit,'X offset','mm',-20,20,Valid);
	thisYOffset:=CheckValidInput(DiffuseYOffsetEdit,'Y offset','mm',-20,20,Valid);
	DiffusePitch:=CheckValidInput(DiffusePitchEdit,'Pitch','°',-180,180,Valid);
  IncludeMirrorRefl:=MirrorReflCheckBox.Checked;
  {ReadMirrorReflectanceFile('G:\Shared drives\MSL - Photometry & Radiometry\STANDARDS\GonioSpectrometry\Software\Detector Model\MirrorReflectance560.txt',Valid);}
  ReadMeasuredData(Valid);
  ReadMirrorReflectanceFile(Valid);
  AssignFile(fl,'Output.txt');
	Rewrite(fl);
	if OffsetP then
		POffsetSize:=CheckValidInput(DiffusePOffsetEdit,'P offset','mm',-10,10,Valid)
	else
		POffsetSize:=0;
	if Valid and Started then
	begin
		CreateSiRefractiveIndexTable;
    CreateAlRefractiveIndexTable;
		with DataSpreadsheet.StringGrid do
		begin
			lastRow:=0;
			for i:=1 to RowCount-1 do
				if not (Cells[1,i]='') and not (Cells[2,i]='') then
					lastRow:=i;
			GraphWindow.NumPoints[1]:=lastRow;
			GraphWindow.NumPoints[2]:=lastRow;
			if lastRow=0 then
			begin
				MessageDlg('Please enter some data.',mtWarning,[mbOk],0);
				valid:=False;
				DataSpreadsheet.SelectCell(1,1);
			end
			else
			begin
				for i:=1 to lastRow do
				begin
					CheckValidTableData(i,1,'Wavelength','nm',200,2000,Valid);
					CheckValidTableData(i,2,'Detector angle','°',-360,360,Valid);
				end;
				if valid and Started then
				begin
					EnableButtons(False);
					for i:=1 to lastRow do
					begin
						thisLambda:=StrToFloat(DataSpreadsheet.StringGrid.Cells[1,i]);
						thisDetAngleDeg:=-StrToFloat(DataSpreadsheet.StringGrid.Cells[2,i]);
						thisDetAngle:=thisDetAngleDeg*Pi/180;
						if Started then
						begin
							if BeamData then
							begin
								BeamDataSFileName:=Directory+Date+IntToStr(Round(thisLambda))+'s.txt';
								BeamDataPFileName:=Directory+Date+IntToStr(Round(thisLambda))+'p.txt';
								ReadBeamFile(BeamDataSFileName,BeamDataPFileName,Valid);
							end;
							if valid and Started then
							begin
								if BeamData then
									CalculateRDiffuseBeamData(thisLambda,Thickness,thisDetAngle,rDiffuseS,rDiffuseP)
								else
									rDiffuse:=CalculateRDiffuse(thisLambda,Thickness,thisDetAngle,rDiffuseS,rDiffuseP);
							end;
							if Valid and Started then
							begin
								thisRCollimatedS:=CalculateRCollimated(thisLambda,Thickness,0{thisDetAngle},thisXOffset,thisYOffset,'s',BeamData);
								thisRCollimatedP:=CalculateRCollimated(thisLambda,Thickness,0{thisDetAngle},thisXOffset+POffsetSize,thisYOffset+POffsetSize,'p',BeamData);
								if BeamData then
								begin
									ratioS:=thisRCollimatedS/rDiffuseS;
									ratioP:=thisRCollimatedP/rDiffuseP;
									Cells[3,i]:=FloatToStr(thisRCollimatedS);
									Cells[4,i]:=FloatToStr(thisRCollimatedP);
									Cells[5,i]:=FloatToStr(rDiffuseS);
									Cells[6,i]:=FloatToStr(rDiffuseP);
								end
								else
								begin
									ratioS:=thisRCollimatedS/rDiffuse;
									ratioP:=thisRCollimatedP/rDiffuse;
									Cells[3,i]:=FloatToStr(thisRCollimatedS);
									Cells[4,i]:=FloatToStr(thisRCollimatedP);
									Cells[5,i]:=FloatToStr(rDiffuseS);
									Cells[6,i]:=FloatToStr(rDiffuseP);
								end;
								with GraphWindow do
								begin
									xData[1]^[i]:=StrToFloat(Cells[2,i]);
									yData[1]^[i]:=ratioS;
									xData[2]^[i]:=StrToFloat(Cells[2,i]);
									yData[2]^[i]:=ratioP;
									xTitle:=Cells[1,0];
									yTitle:='R collimated/R diffuse';
								end;
								if Autosave then
									if IsNewFile then
										Autosave:=FileSaveAs;
								if Autosave then
									StoreFile
								else
									IsDirty:=True;
							end;
						end;
					end;
				end;
			end;
		end;
	end;
  CloseFile(fl);
end;

procedure TMainForm.CalculateAllViewFactors(var Valid:Boolean);
var
	rDiffuse,thisRCollimatedS,thisRCollimatedP,ratioS,ratioP:Extended;
	i,lastRow,ind,lam:Integer;
	thisDetAngleDeg,thisDetAngle,thisXOffset,thisYOffset:Extended;
	rDiffuseS,rDiffuseP,thisVFs,thisVFp,thisLambda:Extended;
	startTime,endTime,totalTime:Cardinal;
begin
	startTime:=GetTickCount;
	BeamRadius:=CheckValidInput(BeamRadiusVFEdit,'Beam radius','mm',0,50,Valid);
	DetectorRadius:=CheckValidInput(DetectorRadiusVFEdit,'Detector radius','mm',0,50,Valid);
	LengthL:=CheckValidInput(LengthEdit,'Length','mm',0,1000,Valid);
	XOffsetVF:=CheckValidInputInteger(XOffsetVFEdit,'x-Offset','mm',-20,20,Valid);
	YOffsetVF:=CheckValidInputInteger(YOffsetVFEdit,'y-Offset','mm',-20,20,Valid);
	NGauLeg:=CheckValidInputInteger(NGauLegEdit,'NGauLeg','',1,MaxNGauLeg,Valid);
	if Valid and Started then
	begin
		GauLeg(-1,1,NGauLeg);
		with DataSpreadsheet.StringGrid do
		begin
			lastRow:=0;
			for i:=1 to RowCount-1 do
				if not (Cells[1,i]='') then
					lastRow:=i;
			GraphWindow.NumPoints[1]:=lastRow;
			GraphWindow.NumPoints[2]:=lastRow;
			if lastRow=0 then
			begin
				MessageDlg('Please enter some data.',mtWarning,[mbOk],0);
				Valid:=False;
				DataSpreadsheet.SelectCell(1,1);
			end
			else
			begin
				for i:=1 to lastRow do
				begin
					CheckValidTableData(i,1,'Detector angle','°',-360,360,valid);
				end;
				if Valid and Started then
				begin
					EnableButtons(False);
					if BeamData then
						ReadBeamFile(BeamDataSFileName,BeamDataPFileName,Valid);
					if Valid and Started then
					begin
						for i:=1 to lastRow do
						begin
							if VaryingLambda then
							begin
								ind:=(i-1) div 33;
								lam:=360+20*ind;
								{if ind=0 then
									lam:=460
								else
									lam:=480+50*(ind-1);}
								if ((i-1) mod 33=0) and BeamData then
								begin
									BeamDataSFileName:=Directory+Date+IntToStr(lam)+'s.txt';
									BeamDataPFileName:=Directory+Date+IntToStr(lam)+'p.txt';
									ReadBeamFile(BeamDataSFileName,BeamDataPFileName,Valid);
								end;
							end;
							if Started then
							begin
								thisDetAngleDeg:=StrToFloat(DataSpreadsheet.StringGrid.Cells[1,i]);
								thisVFs:=CalculateViewFactor(thisDetAngleDeg,DetectorRadius,BeamRadius,LengthL,'s');
								thisVFp:=CalculateViewFactor(thisDetAngleDeg,DetectorRadius,BeamRadius,LengthL,'p');
								Cells[2,i]:=FloatToStr(thisVFs);
								Cells[3,i]:=FloatToStr(thisVFs/Cos(thisDetAngleDeg*Pi/180));
								Cells[4,i]:=FloatToStr(thisVFp);
								Cells[5,i]:=FloatToStr(thisVFp/Cos(thisDetAngleDeg*Pi/180));
								with GraphWindow do
								begin
									xData[1]^[i]:=StrToFloat(Cells[1,i]);
									yData[1]^[i]:=StrToFloat(Cells[3,i]);
									xData[2]^[i]:=StrToFloat(Cells[1,i]);
									yData[2]^[i]:=StrToFloat(Cells[5,i]);
									xTitle:=Cells[1,0];
									yTitle:='View Factor / Cos(Theta)';
								end;
								if Autosave then
									if IsNewFile then
										Autosave:=FileSaveAs;
								if Autosave then
									StoreFile
								else
									IsDirty:=True;
							end;
						end;
					end;
				end;
			end;
		end;
	end;
end;

procedure TMainForm.DetectorAngleRadioButtonClick(Sender: TObject);
begin
	OtherParameter1Label.Caption:='x offset:';
	OtherParameter2Label.Caption:='y offset:';
	OtherParameter1Edit.Text:='0';
	DataSpreadsheet.InsertData(1,0,'Det. angle (°)');
	XVariable:=DetAngle;
	IsDirty:=True;
end;

procedure TMainForm.xOffsetRadioButtonClick(Sender: TObject);
begin
	OtherParameter1Label.Caption:='Detector angle:';
	OtherParameter1Edit.Text:='180';
	OtherParameter2Label.Caption:='y offset:';
	DataSpreadsheet.InsertData(1,0,'X offset (mm)');
	XVariable:=XOffset;
	IsDirty:=True;
end;

procedure TMainForm.yOffsetRadioButtonClick(Sender: TObject);
begin
	OtherParameter1Label.Caption:='Detector angle:';
	OtherParameter1Edit.Text:='180';
	OtherParameter2Label.Caption:='x offset:';
	DataSpreadsheet.InsertData(1,0,'Y offset (mm)');
	XVariable:=YOffset;
	IsDirty:=True;
end;

procedure TMainForm.ExitMenuClick(Sender: TObject);
begin
	Close;
end;

procedure TMainForm.EnableButtons(ToWhat: Boolean);
begin
	WavelengthEdit.Enabled:=ToWhat;
	ThicknessEdit.Enabled:=ToWhat;
	DiffuseDetAngleEdit.Enabled:=ToWhat;
	DetectorAngleRadioButton.Enabled:=ToWhat;
	XOffsetRadioButton.Enabled:=ToWhat;
	YOffsetRadioButton.Enabled:=ToWhat;
	OtherParameter1Edit.Enabled:=ToWhat;
	OtherParameter2Edit.Enabled:=ToWhat;
	BeamRadiusEdit.Enabled:=ToWhat;
	DetectorRadiusEdit.Enabled:=ToWhat;
	BeamDataCheckBox.Enabled:=ToWhat;
	sBrowseButton.Enabled:=(ToWhat and BeamData);
	pBrowseButton.Enabled:=(ToWhat and BeamData);
	FileNameSEdit.Enabled:=(ToWhat and BeamData);
	FileNamePEdit.Enabled:=(ToWhat and BeamData);
	pOffsetCheckBox.Enabled:=ToWhat;
	pOffsetEdit.Enabled:=(ToWhat and OffsetP);
	BeamRadiusVFEdit.Enabled:=ToWhat;
	DetectorRadiusVFEdit.Enabled:=ToWhat;
	LengthEdit.Enabled:=ToWhat;
	PolarRadioButton.Enabled:=ToWhat;
	RectangularRadioButton.Enabled:=ToWhat;
	VaryingLambdaCheckBox.Enabled:=ToWhat;
	XOffsetVFEdit.Enabled:=ToWhat;
	YOffsetVFEdit.Enabled:=ToWhat;
	DiffuseThicknessEdit.Enabled:=ToWhat;
	DiffuseBeamRadiusEdit.Enabled:=ToWhat;
	DiffuseDetectorRadiusEdit.Enabled:=ToWhat;
	DiffuseXOffsetEdit.Enabled:=ToWhat;
	DiffuseYOffsetEdit.Enabled:=ToWhat;
	DiffusePOffsetEdit.Enabled:=(ToWhat and OffsetP);
	DiffusePOffsetCheckBox.Enabled:=ToWhat;
	DiffusePitchEdit.Enabled:=ToWhat;
  MirrorReflCheckBox.Enabled:=ToWhat;
end;

procedure TMainForm.HorizontalSplitterCanResize(Sender: TObject;
	var NewSize: Integer; var Accept: Boolean);
begin
	Accept:=NewSize>HorizontalSplitter.MinSize;
end;

procedure TMainForm.CutMenuClick(Sender: TObject);
begin
	DataSpreadsheet.CopyDataToClipboard;
	DataSpreadsheet.DeleteCells;
	IsDirty:=True;
end;

procedure TMainForm.CopyMenuClick(Sender: TObject);
begin
	DataSpreadsheet.CopyDataToClipboard;
end;

procedure TMainForm.PasteMenuClick(Sender: TObject);
begin
	DataSpreadsheet.PasteData;
	IsDirty:=True;
end;

procedure TMainForm.DeleteMenuClick(Sender: TObject);
begin
	DataSpreadsheet.DeleteCells;
	IsDirty:=True;
end;

procedure TMainForm.SelectAllMenuClick(Sender: TObject);
begin
	DataSpreadsheet.SelectAll;
end;

procedure TMainForm.GraphMenuClick(Sender: TObject);
begin
	xAxisMenu.Enabled:=not GraphWindow.Empty;
	yAxisMenu.Enabled:=not GraphWindow.Empty;
	LineStyleMenu.Enabled:=not GraphWindow.Empty;
end;

procedure TMainForm.xAxisMenuClick(Sender: TObject);
begin
	GraphWindow.xAxisMenuClick(Sender);
end;

procedure TMainForm.yAxisMenuClick(Sender: TObject);
begin
	GraphWindow.yAxisMenuClick(Sender);
end;

procedure TMainForm.LineStyleMenuClick(Sender: TObject);
begin
	GraphWindow.LineStyleMenuClick(Sender);
end;

procedure TMainForm.sBrowseButtonClick(Sender: TObject);
begin
	with OpenDialog do
	begin
		FileName:='';
		InitialDir:=ExtractFileDir(FileNameSEdit.Text);
		if Execute then
		begin
			FileNameSEdit.Text:=FileName;
			BeamDataSFileName:=FileName;
		end;
	end;
end;

procedure TMainForm.pBrowseButtonClick(Sender: TObject);
begin
	with OpenDialog do
	begin
		FileName:='';
		InitialDir:=ExtractFileDir(FileNamePEdit.Text);
		if Execute then
		begin
			FileNamePEdit.Text:=FileName;
			BeamDataPFileName:=FileName;
		end;
	end;
end;

procedure TMainForm.BeamDataCheckBoxClick(Sender: TObject);
begin
	BeamData:=BeamDataCheckBox.Checked;
	sBrowseButton.Enabled:=BeamData;
	pBrowseButton.Enabled:=BeamData;
	FileNameSEdit.Enabled:=BeamData;
	FileNamePEdit.Enabled:=BeamData;
	IsDirty:=True;
	if Mode=ViewFactor then
		if BeamData then
		begin
			RectangularRadioButton.Checked:=not Polar;
			PolarRadioButton.Checked:=Polar;
		end
		else
		begin
			RectangularRadioButton.Checked:=not Polar;
			PolarRadioButton.Checked:=Polar;
		end;
end;

procedure TMainForm.pOffsetCheckBoxClick(Sender: TObject);
begin
	OffsetP:=pOffsetCheckBox.Checked;
	pOffsetEdit.Enabled:=OffsetP;
	IsDirty:=True;
end;

procedure TMainForm.LoadStyleMenuClick(Sender: TObject);
begin
	GraphWindow.SetGraphStyle;
end;

procedure TMainForm.SaveCurrentStyleMenuClick(Sender: TObject);
begin
	GraphWindow.SaveGraphStyleAs;
end;

procedure TMainForm.LoadDefaultStyleMenuClick(Sender: TObject);
begin
	GraphWindow.SetToDefaultStyle;
end;

procedure TMainForm.SaveCurrentStyleAsDefaultMenuClick(Sender: TObject);
begin
	GraphWindow.SetCurrentStyleAsDefault;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
	SetSpreadsheetTitles;
	DataSpreadsheet.SelectCell(1,1);
end;

procedure TMainForm.PolarRadioButtonClick(Sender: TObject);
begin
	Polar:=PolarRadioButton.Checked;
	IsDirty:=True;
end;

procedure TMainForm.RectangularRadioButtonClick(Sender: TObject);
begin
	Polar:=not RectangularRadioButton.Checked;
	IsDirty:=True;
end;

procedure TMainForm.SetModeToCollimatedDetectorModel;
begin
	Mode:=CollimatedDetectorModel;
	if not FirstStart then
	begin
		DataSpreadsheet.ResetSpreadsheet;
		DataSpreadsheet.SelectCell(1,1);
	end;
	DataLeft:=2;
	LastColumn:=6;
	DataPanel.Width:=HorSplitterPos;
	DetInputVariablesGroupBox.Visible:=True;
	VFInputVariablesGroupBox.Visible:=False;
	DiffuseDetModelGroupBox.Visible:=False;
	BeamImagingGroupBox.Left:=DetInputVariablesGroupBox.Left+DetInputVariablesGroupBox.Width+10;
	CalculateButton.Left:=BeamImagingGroupBox.Left;
	PauseButton.Left:=CalculateButton.Left;
	WavelengthEdit.Text:=FloatToStr(Lambda);
	ThicknessEdit.Text:=FloatToStr(Thickness);
	DiffuseDetAngleEdit.Text:=FloatToStr(DiffuseDetAngle);
	BeamRadiusEdit.Text:=FloatToStr(BeamRadius);
	DetectorRadiusEdit.Text:=FloatToStr(DetectorRadius);
	RDiffuseLabel.Visible:=False;
	pOffsetEdit.Text:=FloatToStr(POffsetSize);
	pOffsetCheckBox.Checked:=OffsetP;
	pOffsetEdit.Enabled:=OffsetP;
	SetSpreadsheetTitles;
	case XVariable of
		DetAngle:
			begin
				DetectorAngleRadioButton.Checked:=True;
				OtherParameter1Label.Caption:='x-Offset:';
				OtherParameter2Label.Caption:='y-Offset:';
			end;
		XOffset:
			begin
				XOffsetRadioButton.Checked:=True;
				OtherParameter1Label.Caption:='Detector angle:';
				OtherParameter1Edit.Text:='180';
				OtherParameter2Label.Caption:='y-Offset:';
			end;
		YOffset:
			begin
				YOffsetRadioButton.Checked:=True;
				OtherParameter1Label.Caption:='Detector angle:';
				OtherParameter1Edit.Text:='180';
				OtherParameter2Label.Caption:='x-Offset:';
			end;
	end;
	BeamImagingGroupBox.Width:=ResultsPanel.Width-BeamImagingGroupBox.Left-10;
	sBrowseButton.Left:=BeamImagingGroupBox.Width-sBrowseButton.Width-8;
	pBrowseButton.Left:=BeamImagingGroupBox.Width-pBrowseButton.Width-8;
	FileNameSEdit.Width:=BeamImagingGroupBox.Width-FileNameSEdit.Left-sBrowseButton.Width-15;
	FileNamePEdit.Width:=BeamImagingGroupBox.Width-FileNamePEdit.Left-pBrowseButton.Width-15;
	NGauLegLabel.Visible:=False;
	NGauLegEdit.Visible:=False;
end;

procedure TMainForm.SetModeToDiffuseDetectorModel;
begin
	Mode:=DiffuseDetectorModel;
	if not FirstStart then
	begin
		DataSpreadsheet.ResetSpreadsheet;
		DataSpreadsheet.SelectCell(1,1);
	end;
	DataLeft:=3;
	LastColumn:=7;
	DataPanel.Width:=HorSplitterPosDiffuse;
	DetInputVariablesGroupBox.Visible:=False;
	VFInputVariablesGroupBox.Visible:=False;
	DiffuseDetModelGroupBox.Visible:=True;
	BeamImagingGroupBox.Left:=DiffuseDetModelGroupBox.Left+DiffuseDetModelGroupBox.Width+10;
	CalculateButton.Left:=BeamImagingGroupBox.Left;
	PauseButton.Left:=CalculateButton.Left;
	DiffuseThicknessEdit.Text:=FloatToStr(Thickness);
	DiffusePitchEdit.Text:=FloatToStr(DiffusePitch);
  MirrorReflCheckBox.Checked:=IncludeMirrorRefl;
	DiffuseBeamRadiusEdit.Text:=FloatToStr(BeamRadius);
	DiffuseDetectorRadiusEdit.Text:=FloatToStr(DetectorRadius);
	DiffuseXOffsetEdit.Text:='0';
	DiffuseYOffsetEdit.Text:='0';
	DiffusePOffsetEdit.Text:=FloatToStr(POffsetSize);
	DiffusePOffsetCheckBox.Checked:=OffsetP;
	DiffusePOffsetEdit.Enabled:=OffsetP;
	RDiffLabel.Visible:=False;
	RDiffuseLabel.Visible:=False;
	RDiffPLabel.Visible:=False;
	RDiffusePLabel.Visible:=False;
	SetSpreadsheetTitles;
	BeamImagingGroupBox.Width:=ResultsPanel.Width-BeamImagingGroupBox.Left-10;
	sBrowseButton.Left:=BeamImagingGroupBox.Width-sBrowseButton.Width-8;
	pBrowseButton.Left:=BeamImagingGroupBox.Width-pBrowseButton.Width-8;
	FileNameSEdit.Width:=BeamImagingGroupBox.Width-FileNameSEdit.Left-sBrowseButton.Width-15;
	FileNamePEdit.Width:=BeamImagingGroupBox.Width-FileNamePEdit.Left-pBrowseButton.Width-15;
	NGauLegLabel.Visible:=False;
	NGauLegEdit.Visible:=False;
end;

procedure TMainForm.SetModeToViewFactor;
begin
	Mode:=ViewFactor;
	if not FirstStart then
	begin
		DataSpreadsheet.ResetSpreadsheet;
		DataSpreadsheet.SelectCell(1,1);
	end;
	DataLeft:=2;
	LastColumn:=6;
	DataPanel.Width:=HorSplitterPos;
	VFInputVariablesGroupBox.Visible:=True;
	DetInputVariablesGroupBox.Visible:=False;
	DiffuseDetModelGroupBox.Visible:=False;
	BeamImagingGroupBox.Left:=VFInputVariablesGroupBox.Left+VFInputVariablesGroupBox.Width+10;
	CalculateButton.Left:=BeamImagingGroupBox.Left;
	PauseButton.Left:=CalculateButton.Left;
	BeamRadiusVFEdit.Text:=FloatToStr(BeamRadius);
	DetectorRadiusVFEdit.Text:=FloatToStr(DetectorRadius);
	LengthEdit.Text:=FloatToStr(LengthL);
	XOffsetVFEdit.Text:=FloatToStr(XOffsetVF);
	YOffsetVFEdit.Text:=FloatToStr(YOffsetVF);
	PolarRadioButton.Checked:=Polar;
	RectangularRadioButton.Checked:=not Polar;
	VaryingLambdaCheckbox.Checked:=VaryingLambda;
	RDiffLabel.Visible:=False;
	RDiffuseLabel.Visible:=False;
	RDiffPLabel.Visible:=False;
	RDiffusePLabel.Visible:=False;
	SetSpreadsheetTitles;
	BeamImagingGroupBox.Width:=ResultsPanel.Width-BeamImagingGroupBox.Left-10;
	sBrowseButton.Left:=BeamImagingGroupBox.Width-sBrowseButton.Width-8;
	pBrowseButton.Left:=BeamImagingGroupBox.Width-pBrowseButton.Width-8;
	FileNameSEdit.Width:=BeamImagingGroupBox.Width-FileNameSEdit.Left-sBrowseButton.Width-15;
	FileNamePEdit.Width:=BeamImagingGroupBox.Width-FileNamePEdit.Left-pBrowseButton.Width-15;
	NGauLegLabel.Visible:=True;
	NGauLegEdit.Visible:=True;
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
	BeamImagingGroupBox.Width:=ResultsPanel.Width-BeamImagingGroupBox.Left-10;
	sBrowseButton.Left:=BeamImagingGroupBox.Width-sBrowseButton.Width-15;
	pBrowseButton.Left:=BeamImagingGroupBox.Width-pBrowseButton.Width-15;
	FileNameSEdit.Width:=BeamImagingGroupBox.Width-FileNameSEdit.Left-sBrowseButton.Width-20;
	FileNamePEdit.Width:=BeamImagingGroupBox.Width-FileNamePEdit.Left-pBrowseButton.Width-20;
	NGauLegEdit.Left:=BeamImagingGroupBox.Width+BeamImagingGroupBox.Left-NGauLegEdit.Width;
	NGauLegLabel.Left:=NGauLegEdit.Left-NGauLegLabel.Width-10;
end;

procedure TMainForm.VerticalSplitterCanResize(Sender: TObject;
  var NewSize: Integer; var Accept: Boolean);
begin
	Accept:=NewSize>VerticalSplitter.MinSize;
end;

procedure TMainForm.OptionsMenuClick(Sender: TObject);
begin
	case Mode of
		CollimatedDetectorModel:
			begin
				CollimatedDetectorModelMenu.Checked:=True;
				DiffuseDetectorModelMenu.Checked:=False;
				ViewFactorsMenu.Checked:=False;
			end;
		DiffuseDetectorModel:
			begin
				CollimatedDetectorModelMenu.Checked:=False;
				DiffuseDetectorModelMenu.Checked:=True;
				ViewFactorsMenu.Checked:=False;
			end;
		ViewFactor:
			begin
				CollimatedDetectorModelMenu.Checked:=False;
				DiffuseDetectorModelMenu.Checked:=False;
				ViewFactorsMenu.Checked:=True;
			end;
	end;
	if ResultsPanel.Visible=True then
		ShowPanelMenu.Caption:='Hide Panel'
	else
		ShowPanelMenu.Caption:='Show Panel';
end;

procedure TMainForm.CollimatedDetectorModelMenuClick(Sender: TObject);
begin
	Mode:=CollimatedDetectorModel;
	SetModeToCollimatedDetectorModel;
	CollimatedDetectorModelMenu.Checked:=True;
	DiffuseDetectorModelMenu.Checked:=False;
	ViewFactorsMenu.Checked:=False;
end;

procedure TMainForm.DiffuseDetectorModelMenuClick(Sender: TObject);
begin
	Mode:=DiffuseDetectorModel;
	SetModeToDiffuseDetectorModel;
	CollimatedDetectorModelMenu.Checked:=False;
	DiffuseDetectorModelMenu.Checked:=True;
	ViewFactorsMenu.Checked:=False;
end;

procedure TMainForm.ViewFactorsMenuClick(Sender: TObject);
begin
	Mode:=ViewFactor;
	SetModeToViewFactor;
	CollimatedDetectorModelMenu.Checked:=False;
	DiffuseDetectorModelMenu.Checked:=False;
	ViewFactorsMenu.Checked:=True;
end;

procedure TMainForm.ShowPanelMenuClick(Sender: TObject);
begin
	if ResultsPanel.Visible=True then
		ResultsPanel.Visible:=False
	else
		ResultsPanel.Visible:=True;
end;

procedure TMainForm.ResetFile;
begin
	GraphWindow.ResetGraph;
	ResetDataSpreadsheet;
	PathName:='untitled.dml';
	Caption:='Detector Model - untitled.dml';
	IsDirty:=False;
	DataSpreadsheet.IsDirty:=False;
	GraphWindow.IsDirty:=False;
	IsNewFile:=True;
end;

procedure TMainForm.ResetDataSpreadsheet;
begin
	DataSpreadsheet.ResetSpreadSheet;
	SetSpreadsheetTitles;
end;

procedure TMainForm.AddPastFileName(FileName: string);
var
	fileCount,i,repeatIndex:Integer;
begin
	fileCount:=0;
	for i:=1 to MaxPastFileNames do
		if PastFileNames[i]<>'' then
			Inc(fileCount);
	repeatIndex:=0;
	for i:=1 to MaxPastFileNames do
		if LowerCase(PastFileNames[i])=LowerCase(FileName) then
			repeatIndex:=i;
	if repeatIndex>0 then
	begin
		for i:=repeatIndex to MaxPastFileNames-1 do
			PastFileNames[i]:=PastFileNames[i+1];
		PastFileNames[MaxPastFileNames]:='';
	end;
	for i:=MaxPastFileNames-1 downto 1 do
		PastFileNames[i+1]:=PastFileNames[i];
	PastFileNames[1]:=FileName;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
	reply:Word;
	S:string;
begin
	CanClose:=True;
	if IsDirty or DataSpreadsheet.IsDirty or GraphWindow.IsDirty then
	begin
		Beep;
		S:='Do you want to save changes to the file "'+PathName+'"?';
		reply:=MessageDlg(S,mtConfirmation,[mbYes,mbNo,mbCancel],0);
		if reply=mrYes then
			if IsNewFile then
				CanClose:=FileSaveAs
			else
			begin
				StoreFile;
				CanClose:=True;
			end
		else if reply=mrCancel then
			CanClose:=False;
	end;
end;

function TMainForm.FileSaveAs: Boolean;
begin
	with SaveFileDialog do
	begin
		FileName:=ExtractFileName(PathName);
		if PathName='untitled.dml' then
			InitialDir:=FileDirectory
		else
			InitialDir:=ExtractFileDir(PathName);
		if SaveFileDialog.Execute then
		begin
			PathName:=FileName;
			Caption:='Detector Model - '+ExtractFileName(PathName);
			StoreFile;
			FileSaveAs:=True;
			FileDirectory:=ExtractFileDir(FileName);
			AddPastFileName(FileName);
		end
		else
			FileSaveAs:=False;
	end;
end;

procedure TMainForm.StoreFile;
var
	theStream:TFileStream;
	i,j,maxCount:Integer;
	S:string;
	S1:PChar;
	bool:Boolean;

	procedure StoreString(S:string);
	var
		theLength:Integer;
    len: cardinal;
    oString: UTF8String;
	begin
		{theLength:=Length(S);
		theStream.Write(theLength,SizeOf(theLength));
		StrPCopy(S1,S);
		theStream.WriteBuffer(S1^,theLength);}
    oString:=UTF8String(S);
    len:=Length(oString);
    theStream.WriteBuffer(len,Sizeof(len));
    if len>0 then
      theStream.WriteBuffer(oString[1],len);
	end;

begin
	Screen.Cursor:=crHourGlass;
	try
		GetMem(S1,65536);
		theStream:=TFileStream.Create(PathName,fmCreate);
		with theStream do
		begin
			StoreString(ThisSoftwareVersion);
      Write(Mode,SizeOf(Mode));
			for j:=1 to MaxDataForms do
				for i:=1 to MaxColumns-1 do
				begin
					Write(DataColWidth[j,i],SizeOf(DataColWidth[j,i]));
					Write(DataColFormat[j,i],SizeOf(DataColFormat[j,i]));
					Write(DataColPlaces[j,i],SizeOf(DataColPlaces[j,i]));
				end;
			Write(DataPanel.Width,SizeOf(DataPanel.Width));
			Write(ResultsPanel.Height,SizeOf(ResultsPanel.Height));
			maxCount:=0;
			with DataSpreadsheet.StringGrid do
			begin
				for i:=1 to ColCount-1 do
					for j:=1 to RowCount-1 do
						if (Cells[i,j]<>'') and (j>=maxCount) then
							maxCount:=j+1;
				Write(maxCount,SizeOf(maxCount));
				for i:=1 to ColCount-1 do
					for j:=1 to maxCount-1 do
					begin
						S:=Cells[i,j];
						StoreString(S);
					end;
			end;
			StoreString(WavelengthEdit.Text);
			StoreString(ThicknessEdit.Text);
			StoreString(DiffuseDetAngleEdit.Text);
			StoreString(BeamRadiusEdit.Text);
			StoreString(DetectorRadiusEdit.Text);
			StoreString(OtherParameter1Edit.Text);
			StoreString(OtherParameter2Edit.Text);
			StoreString(pOffsetEdit.Text);
			Write(XVariable,SizeOf(XVariable));
			Write(OffsetP,SizeOf(OffsetP));
			StoreString(BeamRadiusVFEdit.Text);
			StoreString(DetectorRadiusVFEdit.Text);
			StoreString(LengthEdit.Text);
			Write(Polar,SizeOf(Polar));
			StoreString(DiffusePitchEdit.Text);
			Write(IncludeMirrorRefl,SizeOf(IncludeMirrorRefl));
			StoreString(DiffuseBeamRadiusEdit.Text);
			StoreString(DiffuseDetectorRadiusEdit.Text);
			StoreString(DiffuseXOffsetEdit.Text);
			StoreString(DiffuseYOffsetEdit.Text);
			StoreString(DiffusePOffsetEdit.Text);
			StoreString(DiffuseThicknessEdit.Text);
			Write(BeamData,SizeOf(BeamData));
			StoreString(FileNameSEdit.Text);
			StoreString(FileNamePEdit.Text);
			StoreString(RDiffLabel.Caption);
			StoreString(RDiffuseLabel.Caption);
			StoreString(RDiffPLabel.Caption);
			StoreString(RDiffusePLabel.Caption);
			bool:=RDiffuseLabel.Visible;
			Write(bool,SizeOf(bool));
			bool:=RDiffusePLabel.Visible;
			Write(bool,SizeOf(bool));
			StoreString(XOffsetVFEdit.Text);
			StoreString(YOffsetVFEdit.Text);
			Write(VaryingLambda,SizeOf(VaryingLambda));
			Write(NGauLeg,SizeOf(NGauLeg));
		end;
		GraphWindow.StoreFile(theStream);
		IsDirty:=False;
		DataSpreadsheet.IsDirty:=False;
		GraphWindow.IsDirty:=False;
		IsNewFile:=False;
	finally
		theStream.Free;
		FreeMem(S1,65536);
		if not Started then
			Screen.Cursor:=crDefault;
	end;
end;

procedure TMainForm.LoadFile(FileName: string);
var
	theStream:TFileStream;
	softwareVersion:string;
	i,j,theSize,maxCount:Integer;
	S:string;
	S1:PChar;
	bool:Boolean;
	version:Extended;

		procedure LoadString(var S:string);
		var
			theLength:Integer;
      len: integer;
      iString: UTF8String;
		begin
			{theStream.Read(theLength,SizeOf(theLength));
			theStream.ReadBuffer(S1^,theLength);
			S1[theLength]:=#0;
			S:=StrPas(S1);}
      theStream.readBuffer(len,4);
      if len>0 then
      begin
        setLength(iString,len);
        theStream.ReadBuffer(iString[1],len);
        S:=string(iString);
      end
      else
        S:='';
		end;

		procedure LoadStringEdit(TheEdit:TEdit);
		var
			S:string;
		begin
			LoadString(S);
			TheEdit.Text:=S;
		end;

		procedure LoadStringLabel(TheLabel:TLabel);
    var
			S:string;
		begin
			LoadString(S);
			TheLabel.Caption:=S;
		end;

begin
	Screen.Cursor:=crHourGlass;
	PathName:=FileName;
	try
		GetMem(S1,65536);
		theStream:=TFileStream.Create(FileName,fmOpenRead);
		with theStream do
		begin
			LoadString(softwareVersion);
			version:=StrToFloat(softwareVersion);
      if version>1.02 then
			begin
				Read(Mode,SizeOf(Mode));
				case Mode of
					CollimatedDetectorModel: SetModeToCollimatedDetectorModel;
					DiffuseDetectorModel: 	 SetModeToDiffuseDetectorModel;
					ViewFactor: 						 SetModeToViewFactor;
				end;
			end;
			for j:=1 to MaxDataForms do
				for i:=1 to MaxColumns-1 do
				begin
					Read(DataColWidth[j,i],SizeOf(DataColWidth[j,i]));
					Read(DataColFormat[j,i],SizeOf(DataColFormat[j,i]));
					Read(DataColPlaces[j,i],SizeOf(DataColPlaces[j,i]));
				end;
			Read(theSize,SizeOf(theSize));
			DataPanel.Width:=theSize;
			Read(theSize,SizeOf(theSize));
			ResultsPanel.Height:=theSize;
			ResetDataSpreadsheet;
			Read(maxCount,SizeOf(maxCount));
			with DataSpreadsheet.StringGrid do
			begin
				if maxCount>RowCount-1 then
				begin
					RowCount:=maxCount;
					for i:=1 to RowCount-1 do
					begin
						RowHeights[i]:=DefaultRowHeight;
						Cells[0,i]:=IntToStr(i);
					end;
				end;
				for i:=1 to ColCount-1 do
					for j:=1 to maxCount-1 do
					begin
						LoadString(S);
						Cells[i,j]:=S;
					end;
			end;
      if version<1.03 then
        Read(Mode,SizeOf(Mode));
			LoadStringEdit(WavelengthEdit);
			LoadStringEdit(ThicknessEdit);
			LoadStringEdit(DiffuseDetAngleEdit);
			LoadStringEdit(BeamRadiusEdit);
			LoadStringEdit(DetectorRadiusEdit);
			LoadStringEdit(OtherParameter1Edit);
			LoadStringEdit(OtherParameter2Edit);
			LoadStringEdit(pOffsetEdit);
			Read(XVariable,SizeOf(XVariable));
			Read(OffsetP,SizeOf(OffsetP));
			LoadStringEdit(BeamRadiusVFEdit);
			LoadStringEdit(DetectorRadiusVFEdit);
			LoadStringEdit(LengthEdit);
			Read(Polar,SizeOf(Polar));
      if version>1.04 then
				LoadStringEdit(DiffusePitchEdit);
      if version>1.05 then
        Read(IncludeMirrorRefl,SizeOf(IncludeMirrorRefl));
			LoadStringEdit(DiffuseThicknessEdit);
			LoadStringEdit(DiffuseBeamRadiusEdit);
			LoadStringEdit(DiffuseDetectorRadiusEdit);
			LoadStringEdit(DiffuseXOffsetEdit);
			LoadStringEdit(DiffuseYOffsetEdit);
			LoadStringEdit(DiffusePOffsetEdit);
			Read(BeamData,SizeOf(BeamData));
			LoadStringEdit(FileNameSEdit);
			LoadStringEdit(FileNamePEdit);
			LoadStringLabel(RDiffLabel);
			LoadStringLabel(RDiffuseLabel);
			LoadStringLabel(RDiffPLabel);
			LoadStringLabel(RDiffusePLabel);
			Read(bool,SizeOf(bool));
			RDiffuseLabel.Visible:=bool;
			Read(bool,SizeOf(bool));
			RDiffusePLabel.Visible:=bool;
			if version>1 then
			begin
				LoadStringEdit(XOffsetVFEdit);
				LoadStringEdit(YOffsetVFEdit);
				Read(VaryingLambda,SizeOf(VaryingLambda));
				if version>1.01 then
				begin
					Read(NGauLeg,SizeOf(NGauLeg));
          NGauLegEdit.Text:=IntToStr(NGauLeg);
				end
				else
					NGauLegEdit.Text:='';
			end
			else
			begin
				XOffsetVFEdit.Text:='0';
				YOffsetVFEdit.Text:='0';
				VaryingLambda:=False;
			end;
		end;
		BeamDataCheckBox.Checked:=BeamData;
		DiffusePOffsetCheckBox.Checked:=OffsetP;
		POffsetCheckBox.Checked:=OffsetP;
		PolarRadioButton.Checked:=Polar;
		RectangularRadioButton.Checked:=not Polar;
		case XVariable of
			DetAngle:DetectorAngleRadioButton.Checked:=True;
			XOffset:XOffsetRadioButton.Checked:=True;
			YOffset:YOffsetRadioButton.Checked:=True;
		end;
		GraphWindow.ResetGraph;
    if version<1.03 then
    // need to read first two lines from graph data
    begin
      theStream.Read(theSize,SizeOf(theSize));
      theStream.Read(theSize,SizeOf(theSize));
    end;
		GraphWindow.LoadFile(theStream);
		AddPastFileName(FileName);
		Caption:='Detector Model - '+ExtractFileName(PathName);
		VaryingLambdaCheckbox.Checked:=VaryingLambda;
	finally
		theStream.Free;
		FreeMem(S1,65536);
		IsNewFile:=False;
		IsDirty:=False;
		JustLoaded:=True;
		Screen.Cursor:=crDefault;
	end;
end;

procedure TMainForm.NewMenuClick(Sender: TObject);
var
	okToClose:Boolean;
begin
	FormCloseQuery(Sender,okToClose);
	if okToClose then
		ResetFile;
end;

procedure TMainForm.OpenMenuClick(Sender: TObject);
var
	okToClose:Boolean;
begin
	FormCloseQuery(Sender,okToClose);
	if okToClose then
		with OpenFileDialog do
		begin
			FileName:='';
			InitialDir:=FileDirectory;
			if Execute then
			begin
				LoadFile(FileName);
				FileDirectory:=ExtractFileDir(FileName);
			end;
		end;
end;

procedure TMainForm.SaveAsMenuClick(Sender: TObject);
begin
	FileSaveAs;
end;

procedure TMainForm.SaveMenuClick(Sender: TObject);
begin
	if IsNewFile then
		FileSaveAs
	else
		StoreFile;
end;

procedure TMainForm.FileMenuClick(Sender: TObject);
begin
	SaveMenu.Enabled:=IsDirty or DataSpreadSheet.IsDirty or GraphWindow.IsDirty;
	AutosaveMenu.Checked:=Autosave;
	UpdateFileMenu;
end;

procedure TMainForm.UpdateFileMenu;
var
	i,j,k,fileCount:Integer;
	item:TMenuItem;
	thePosition:Integer;
begin
	fileCount:=0;
	for i:=1 to MaxPastFileNames do
		if PastFileNames[i]<>'' then
			Inc(fileCount);
	j:=FileMenu.IndexOf(ExitSeparator);
	k:=FileMenu.IndexOf(ExitMenu);
	if k-j>1 then
		for i:=j+1 to k-1 do
			FileMenu.Delete(j+1);
	thePosition:=FileMenu.IndexOf(ExitSeparator);
	for i:=1 to fileCount do
	begin
		item:=TMenuItem.Create(Self);
		item.Caption:='&'+IntToStr(i)+' '+PastFileNames[i];
		item.OnClick:=PastFileNameClick;
		FileMenu.Insert(thePosition+i,item);
	end;
	if fileCount>0 then
	begin
		item:=TMenuItem.Create(Self);
		item.Caption:='-';
		FileMenu.Insert(thePosition+fileCount+1,item);
	end;
end;

procedure TMainForm.PastFileNameClick(Sender: TObject);
var
	i,index:Integer;
	fileName,S:string;
	okToClose:Boolean;
begin
	FormCloseQuery(Sender,okToClose);
	if okToClose then
	begin
		with Sender as TMenuItem do
			fileName:=Copy(Caption,4,Length(Caption)-2);
		ExtractFileDir(fileName);
		if FileExists(fileName) then
			LoadFile(fileName)
		else
		begin
			for i:=1 to MaxPastFileNames do
				if PastFileNames[i]=fileName then
					index:=i;
			S:='The file "'+ExtractFileName(fileName)+'" no longer exists in the directory "';
			S:=S+ExtractFilePath(fileName)+'", or the directory can''t be accessed.';
			Beep;
			MessageDlg(S,mtWarning,[mbOk],0);
			for i:=index to MaxPastFileNames-1 do
				PastFileNames[i]:=PastFileNames[i+1];
			PastFileNames[MaxPastFileNames]:='';
		end;
	end;
end;

procedure TMainForm.VerticalSplitterMoved(Sender: TObject);
begin
	IsDirty:=True;
end;

procedure TMainForm.HorizontalSplitterMoved(Sender: TObject);
begin
	IsDirty:=True;
	if Mode=DiffuseDetectorModel then
		HorSplitterPosDiffuse:=DataPanel.Width
	else
		HorSplitterPos:=DataPanel.Width;
end;

procedure TMainForm.DiffusePOffsetCheckBoxClick(Sender: TObject);
begin
	OffsetP:=DiffusePOffsetCheckBox.Checked;
	DiffusePOffsetEdit.Enabled:=OffsetP;
	IsDirty:=True;
end;

procedure TMainForm.MyIdleHandler(Sender: TObject; var Done: Boolean);
begin
	if JustLoaded then
	begin
		IsDirty:=False;
		DataSpreadsheet.IsDirty:=False;
		GraphWindow.IsDirty:=False;
		JustLoaded:=False;
	end;
	SaveButton.Enabled:=IsDirty or DataSpreadsheet.IsDirty or GraphWindow.IsDirty;
	xAxisButton.Enabled:=not GraphWindow.Empty;
	yAxisButton.Enabled:=not GraphWindow.Empty;
	LineStyleButton.Enabled:=not GraphWindow.Empty;
end;

procedure TMainForm.EditChange(Sender: TObject);
begin
	IsDirty:=True;
end;

procedure TMainForm.AutosaveMenuClick(Sender: TObject);
begin
	Autosave:=not Autosave;
end;

procedure TMainForm.PauseButtonClick(Sender: TObject);
begin
	Paused:=not Paused;
	if Paused then
		PauseButton.Caption:='Continue'
	else
		PauseButton.Caption:='Pause';
end;

procedure TMainForm.SaveDataAsTextFileMenuClick(Sender: TObject);
var
	i,j,lastRow:Integer;
	f:TextFile;
	S:string;
begin
	with SaveTextFileDialog do
	begin
		if PathName='untitled.dml' then
			InitialDir:=FileDirectory
		else
			InitialDir:=ExtractFileDir(PathName);
		FileName:=ExtractFileName(PathName);
		FileName:=Copy(FileName,1,Length(FileName)-4)+'.txt';
		if SaveTextFileDialog.Execute then
		begin
			Screen.Cursor:=crHourGlass;
			AssignFile(f,FileName);
			Rewrite(f);
			with DataSpreadsheet.StringGrid do
			begin
				lastRow:=0;
				for i:=1 to RowCount-1 do
					if not (Cells[1,i]='') then
						lastRow:=i;
				for i:=1 to lastRow do
				begin
					S:=Cells[1,i];
					for j:=2 to LastColumn do
						S:=S+#9+Cells[j,i];
					Writeln(f,S);
				end;
			end;
			CloseFile(f);
			Screen.Cursor:=crDefault;
		end;
	end;
end;

procedure TMainForm.VaryingLambdaCheckBoxClick(Sender: TObject);
begin
	VaryingLambda:=VaryingLambdaCheckBox.Checked;
	IsDirty:=True;
end;

procedure TMainForm.PlotDataMenuClick(Sender: TObject);
var
	lastRow,i:Integer;
	valid:Boolean;
begin
	Screen.Cursor:=crHourGlass;
	valid:=True;
	with DataSpreadsheet.StringGrid do
	begin
		lastRow:=0;
		for i:=1 to RowCount-1 do
			if not (Cells[1,i]='') then
				lastRow:=i;
		GraphWindow.NumPoints[1]:=lastRow;
		GraphWindow.NumPoints[2]:=lastRow;
		if lastRow=0 then
		begin
			MessageDlg('Please enter some data.',mtWarning,[mbOk],0);
			valid:=False;
			DataSpreadsheet.SelectCell(1,1);
		end
		else
		begin
			for i:=1 to lastRow do
			begin
				case Mode of
					CollimatedDetectorModel:
						with GraphWindow do
						begin
							xData[1]^[i]:=StrToFloat(Cells[1,i]);
							yData[1]^[i]:=StrToFloat(Cells[4,i]);
							xData[2]^[i]:=StrToFloat(Cells[1,i]);
							yData[2]^[i]:=StrToFloat(Cells[5,i]);
							xTitle:=Cells[1,0];
							yTitle:='R collimated/R diffuse';
						end;
					DiffuseDetectorModel:
						with GraphWindow do
						begin
							xData[1]^[i]:=StrToFloat(Cells[2,i]);
							yData[1]^[i]:=StrToFloat(Cells[5,i])/StrToFloat(Cells[3,i]);
							xData[2]^[i]:=StrToFloat(Cells[2,i]);
							yData[2]^[i]:=StrToFloat(Cells[6,i])/StrToFloat(Cells[4,i]);
							xTitle:=Cells[1,0];
							yTitle:='R collimated/R diffuse';
						end;
					ViewFactor:
						with GraphWindow do
						begin
							xData[1]^[i]:=StrToFloat(Cells[1,i]);
							yData[1]^[i]:=StrToFloat(Cells[3,i]);
							xData[2]^[i]:=StrToFloat(Cells[1,i]);
							yData[2]^[i]:=StrToFloat(Cells[5,i]);
							xTitle:=Cells[1,0];
							yTitle:='View Factor / Cos(Theta)';
						end;
				end;
			end;
			if Autosave then
				if IsNewFile then
					Autosave:=FileSaveAs;
			if Autosave then
				StoreFile
			else
				IsDirty:=True;
		end;
	end;
	if valid then
	begin
		GraphWindow.Empty:=False;
		GraphWindow.Repaint;
		if Autosave then
			StoreFile
		else
			IsDirty:=True;
	end;
	Screen.Cursor:=crDefault;
end;

end.
