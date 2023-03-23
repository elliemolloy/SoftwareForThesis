unit gonioThroughputMain;

interface
{$R+}

uses
	Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
	System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
	Vcl.StdCtrls, Math, LinearAlgebra, GonioThroughputGlobal, Vcl.ExtDlgs;

type
  PAngleArray=^TAngleArray;
  TAngleArray=array[0..99,0..99] of Extended;

  TMainForm = class(TForm)
    ThetaIEdit: TEdit;
    PhiIEdit: TEdit;
    ThetaDEdit: TEdit;
    PhiDEdit: TEdit;
    BeamRadiusEdit: TEdit;
    DetRadiusEdit: TEdit;
    LengthEdit: TEdit;
    NEdit: TEdit;
    CalculateButton: TButton;
    StopButton: TButton;
    SaveFileCheckBox: TCheckBox;
    SaveTdFileDialog: TSaveDialog;
    GroupBox1: TGroupBox;
    IterateAnglesCheckbox: TCheckBox;
    StartAngleEdit: TEdit;
    StopAngleEdit: TEdit;
    StepAngleEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
		procedure CalculateButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure IterateAnglesCheckboxClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure StopButtonClick(Sender: TObject);
  private
    { Private declarations }
    procedure EnableButtons(ToWhat:Boolean);
  public
    { Public declarations }
	end;

procedure CreateRotationMatrixY(angle:Extended;var R:TMatrix);
procedure CreateRotationMatrixZ(Angle:Extended;var R:TMatrix);
function CalculateThetaMin(Ti,Td,R,A,L:Extended):Extended;
function CalculateThetaMax(Ti,Td,R,A,L:Extended):Extended;
function CalculatePhiMax(Ti,Td,R,A,L:Extended):Extended;
procedure CalculateAnglesMonteCarlo(BeamRadius,DetRadius,ThetaI,PhiI,ThetaD,PhiD,L:Extended;N:Integer);
function ConvertToRadians(Angle:Extended):Extended;
function ConvertToDegrees(Angle:Extended):Extended;
function CheckValidInput(TheEdit:TEdit;Variable,Units:string;Min,Max:Extended;var Valid:Boolean):Extended;
function CheckValidInputInteger(TheEdit:TEdit;Variable,Units:string;Min,Max:Int64;var Valid:Boolean):Int64;

var
	MainForm: TMainForm;
  IterateAngles,Started:Boolean;
  AllAnglesD:PAngleArray;

implementation

{$R *.dfm}

procedure TMainForm.CalculateButtonClick(Sender: TObject);
var
  tiSet,phiiSet,tdSet,pdSet,detRadius,beamRadius,L:Extended;
  startAngle,stopAngle,stepAngle:Extended;
  N:Int64;
	i,j,k,nAngles:Integer;
	fD:TextFile;
	valid,saveFile:Boolean;
  dataFileNameD,fileDirectory:string;
begin
  valid:=True;
  Started:=True;
	Screen.Cursor:=crHourGlass;

	// Set variables from form
  tiSet:=CheckValidInput(ThetaIEdit,'Theta i','degrees',0,180,valid);
  phiiSet:=CheckValidInput(PhiIEdit,'Phi i','degrees',-360,360,valid);
	tdSet:=CheckValidInput(ThetaDEdit,'Theta d','degrees',0,180,valid);
	pdSet:=CheckValidInput(PhiDEdit,'Phi d','degrees',-360,360,valid);
	L:=CheckValidInput(LengthEdit,'Length','mm',0,100000,valid);
	beamRadius:=CheckValidInput(BeamRadiusEdit,'Beam radius','mm',0,100000,valid);
	detRadius:=CheckValidInput(DetRadiusEdit,'Detector radius','mm',0,100000,valid);
  N:=CheckValidInputInteger(NEdit,'Number of beams','',0,10000000000,valid);
	saveFile:=SaveFileCheckbox.Checked;

  if IterateAngles then
  begin
    startAngle:=CheckValidInput(StartAngleEdit,'Start angle','degrees',0,360,valid);
    stopAngle:=CheckValidInput(StopAngleEdit,'Stop angle','degrees',startAngle,360,valid);
    stepAngle:=CheckValidInput(StepAngleEdit,'Step angle','degrees',0,stopAngle-startAngle,valid);
    nAngles:=Trunc((stopAngle-startAngle)/stepAngle);
  end;

  EnableButtons(False);

  if valid then
    if IterateAngles then
    begin
      // If saving files, then pick directory and file names
      if saveFile then
        fileDirectory:='G:\Shared drives\MSL - Photometry & Radiometry\STANDARDS\GonioSpectrometry\Throughput\Output data from Delphi\';
      for k:=0 to nAngles do
        if valid then
        begin
          tdSet:=startAngle+k*stepAngle;
          dataFileNameD:=fileDirectory+FloatToStr(tiSet)+','+FloatToStr(phiiSet)+','+FloatToStr(tdSet)+','+FloatToStr(pdSet)+','+FloatToStr(beamRadius)+','+FloatToStr(detRadius)+','+FloatToStr(L)+'.txt';

          // Initialise arrays to save results
          for i:=0 to 99 do
            for j:=0 to 99 do
              AllAnglesD[i,j]:=0;

          // Calculate frequencies of the angles
          CalculateAnglesMonteCarlo(beamRadius,detRadius,tiSet,phiiSet,tdSet,pdSet,L,N);

          // Save angles
          if saveFile then
          begin
            AssignFile(fD,dataFileNameD);
            Rewrite(fD);
            for i:=0 to 99 do
            begin
              for j:=0 to 99 do
                Write(fD,allAnglesD[j,i],#9); // writing so that theta changes along rows and phi down columns
              Writeln(fD);
            end;
            CloseFile(fD);
          end;
        end;
    end
    else
    begin
      // If saving files, then pick directory and file names
      SaveTdFileDialog.FileName:=FloatToStr(tiSet)+','+FloatToStr(phiiSet)+','+FloatToStr(tdSet)+','+FloatToStr(pdSet)+','+FloatToStr(beamRadius)+','+FloatToStr(detRadius)+','+FloatToStr(L)+'.txt';
      if saveFile then
        with SaveTdFileDialog do
          if Execute then
          begin
            dataFileNameD:=FileName;
          end
          else
            valid:=False;

      if valid then
      begin
        // Initialise arrays to save results
        for i:=0 to 99 do
          for j:=0 to 99 do
            AllAnglesD[i,j]:=0;

        // Calculate frequencies of the angles
        CalculateAnglesMonteCarlo(beamRadius,detRadius,tiSet,phiiSet,tdSet,pdSet,L,N);

        // Save angles
        if saveFile then
        begin
          AssignFile(fD,dataFileNameD);
          Rewrite(fD);
          for i:=0 to 99 do
          begin
            for j:=0 to 99 do
              Write(fD,allAnglesD[j,i],#9); // writing so that theta changes along rows and phi down columns
            Writeln(fD);
          end;
          CloseFile(fD);
        end;
      end;
    end;
  Started:=False;
	EnableButtons(True);
	Screen.Cursor:=crDefault;
end;

procedure CreateRotationMatrixY(Angle:Extended;var R:TMatrix);
begin
	R[1,1]:=Cos(Angle);
	R[1,2]:=0;
	R[1,3]:=Sin(Angle);
	R[2,1]:=0;
	R[2,2]:=1;
	R[2,3]:=0;
	R[3,1]:=-Sin(Angle);
	R[3,2]:=0;
	R[3,3]:=Cos(Angle);
end;

procedure CreateRotationMatrixZ(Angle:Extended;var R:TMatrix);
begin
	R[1,1]:=Cos(Angle);
	R[1,2]:=-Sin(Angle);
	R[1,3]:=0;
	R[2,1]:=Sin(Angle);
	R[2,2]:=Cos(Angle);
	R[2,3]:=0;
	R[3,1]:=0;
	R[3,2]:=0;
	R[3,3]:=1;
end;

function CalculateThetaMax(Ti,Td,R,A,L:Extended):Extended;
var
  cosTi,sinTi:Extended;
  sampleVector,detVector,sampleNormal:TVector;
  tdRotationMatrix:TMatrix;
begin
  CreateRotationMatrixY(Td*Pi/180,tdRotationMatrix);
  cosTi:=Cos(Ti*Pi/180);
  sinTi:=Sin(Ti*Pi/180);
  sampleNormal[1]:=0;
  sampleNormal[2]:=0;
  sampleNormal[3]:=1;
  sampleVector[1]:=-R*cosTi-R*Sqr(sinTi)/cosTi;
  sampleVector[2]:=0;
  sampleVector[3]:=0;
  detVector[1]:=A;
  detVector[2]:=0;
  detVector[3]:=L;
  detVector:=MatrixMultiplication(tdRotationMatrix,detVector);
  detVector:=VectorSubtraction(detVector,sampleVector);
  CalculateThetaMax:=ConvertToDegrees(AngleBetweenVectors(sampleNormal,detVector));
end;

function CalculateThetaMin(Ti,Td,R,A,L:Extended):Extended;
var
  cosTi,sinTi:Extended;
  sampleVector,detVector,sampleNormal:TVector;
  tdRotationMatrix:TMatrix;
begin
  CreateRotationMatrixY(Td*Pi/180,tdRotationMatrix);
  cosTi:=Cos(Ti*Pi/180);
  sinTi:=Sin(Ti*Pi/180);
  sampleNormal[1]:=0;
  sampleNormal[2]:=0;
  sampleNormal[3]:=1;
  sampleVector[1]:=R*cosTi+R*Sqr(sinTi)/cosTi;
  sampleVector[2]:=0;
  sampleVector[3]:=0;
  detVector[1]:=-A;
  detVector[2]:=0;
  detVector[3]:=L;
  detVector:=MatrixMultiplication(tdRotationMatrix,detVector);
  detVector:=VectorSubtraction(detVector,sampleVector);
  CalculateThetaMin:=ConvertToDegrees(AngleBetweenVectors(sampleNormal,detVector));
end;

function CalculatePhiMax(Ti,Td,R,A,L:Extended):Extended;
var
  e1,e2,e3,cosTi,cosTd,sinTi,sinTd:Extended;
  cosTi2,cosTd2,sinTi2,sinTd2,r2,a2,L2:Extended;
  x1,x2,y1,y2,z,phi:Extended;
begin
  cosTi:=Cos(Ti*Pi/180);
  cosTd:=Cos(Td*Pi/180);
  sinTi:=Sin(Ti*Pi/180);
  sinTd:=Sin(Td*Pi/180);
  cosTi2:=Sqr(cosTi);
  cosTd2:=Sqr(cosTd);
  sinTi2:=Sqr(sinTi);
  sinTd2:=Sqr(sinTd);
  r2:=Sqr(R);
  a2:=Sqr(A);
  L2:=Sqr(L);
  e1:=a2*(sinTd2*cosTi2*(L2-r2)-r2*sinTi2+a2*(1-cosTi2*cosTd2));
  e2:=sinTd2*cosTi2*(L2+a2)+a2*sinTi2;
  e3:=L*R*sinTd*cosTi;
  x1:=(e3+Sqrt(e1))*R/e2;
  x2:=cosTi*cosTd*(x1*e3/R+a2-r2)/(x1*(1-cosTi2*cosTd2)-L*sinTd*cosTi);
  y1:=-Sqrt(r2-Sqr(x1));
  y2:=Sqrt(a2-Sqr(x2));
  z:=(y2-y1)/(x2*cosTd+L*sinTd-x1/cosTi);
  phi:=ArcTan(z)*180/Pi;
  CalculatePhiMax:=phi;
end;

procedure CalculateAnglesMonteCarlo(BeamRadius,DetRadius,ThetaI,PhiI,ThetaD,PhiD,L:Extended;N:Integer);
var
  tiRadians,phiiRadians,tdRadians,pdRadians:Extended;
  i,j,tdInd,pdInd:Integer;
  sinThetaI,cosThetaI,sinThetaD,cosThetaD:Extended;
  sinPhiI,cosPhiI,sinPhiD,cosPhiD:Extended;
  tdMin,tdMax,pdMin,pdMax,tdRange,pdRange:Extended;
  x1,y1,x2,y2,thisTi,thisPhii,thisTd,thisPd,t:Extended;
  sampleNormal,beamVector,detVector,sampleVector,beamDirection:TVector;
	tiRotationMatrix,phiiRotationMatrix,tdRotationMatrix,pdRotationMatrix:TMatrix;
begin
  // Convert theta and phi to radians
  tiRadians:=ConvertToRadians(ThetaI);
  if ThetaI=0 then // phiI is undefined if thetaI is zero
    phiiRadians:=0
  else
    phiiRadians:=ConvertToRadians(PhiI);
  tdRadians:=ConvertToRadians(ThetaD);
  pdRadians:=ConvertToRadians(PhiD);

  // Initialise rotation matrices for theta/phi
  CreateRotationMatrixY(tiRadians,tiRotationMatrix);
  CreateRotationMatrixZ(phiiRadians,phiiRotationMatrix);
	CreateRotationMatrixY(tdRadians,tdRotationMatrix);
  CreateRotationMatrixZ(pdRadians,pdRotationMatrix);

  // Initialise sample normal
  sampleNormal[1]:=0;
  sampleNormal[2]:=0;
  sampleNormal[3]:=1;

  // Calculate cos and sine of angles
  sinThetaI:=Sin(tiRadians);
  cosThetaI:=Cos(tiRadians);
  sinPhiI:=Sin(phiiRadians);
  cosPhiI:=Cos(phiiRadians);
  sinThetaD:=Sin(tdRadians);
  cosThetaD:=Cos(tdRadians);
  sinPhiD:=Sin(pdRadians);
  cosPhiD:=Cos(pdRadians);

  // Determine limits of bins for storing results
  tdMin:=CalculateThetaMin(ThetaI,ThetaD,BeamRadius,DetRadius,L);
  tdMax:=CalculateThetaMax(ThetaI,ThetaD,BeamRadius,DetRadius,L);

  if ThetaD=0 then
  begin
    pdMin:=-180;
    pdMax:=180;
  end
  else
  begin
    pdMin:=PhiD-CalculatePhiMax(ThetaI,ThetaD,BeamRadius,DetRadius,L)-2;
    pdMax:=PhiD+CalculatePhiMax(ThetaI,ThetaD,BeamRadius,DetRadius,L)+2;
  end;

  if tdMin=tdMax then
    tdMin:=0;
  tdRange:=100/(tdMax-tdMin);
  pdRange:=100/(pdMax-pdMin);

  for i:=1 to N do
    if Started then
    begin
      x1:=2*BeamRadius*Random-BeamRadius;
      y1:=2*BeamRadius*Random-BeamRadius;
      if Sqr(x1)+Sqr(y1)<=Sqr(BeamRadius) then
      begin
        x2:=2*DetRadius*Random-DetRadius;
        y2:=2*DetRadius*Random-DetRadius;
        if Sqr(x2)+Sqr(y2)<=Sqr(DetRadius) then
        begin
          // Calculate beam vector
          beamVector[1]:=x1;
          beamVector[2]:=y1;
          beamVector[3]:=L;
          beamVector:=MatrixMultiplication(phiiRotationMatrix,MatrixMultiplication(tiRotationMatrix,beamVector));

          // Initialise beam direction vector
          beamDirection[1]:=-sinThetaI*cosPhiI;
          beamDirection[2]:=-sinThetaI*sinPhiI;
          beamDirection[3]:=-cosThetaI;

          // Calculate t, then use t to calculate the position on the sample
          t:=beamVector[3]/cosThetaI;
          for j:=1 to 3 do
            beamDirection[j]:=beamDirection[j]*t;
          sampleVector:=VectorAddition(beamVector,beamDirection);

          // Calculate beam vector, using position on sample as origin
          beamVector:=VectorSubtraction(beamVector,sampleVector);

          // Calculate detector vector, using position on sample as origin
          detVector[1]:=x2;
          detVector[2]:=y2;
          detVector[3]:=L;
          detVector:=MatrixMultiplication(pdRotationMatrix,MatrixMultiplication(tdRotationMatrix,detVector));
          detVector:=VectorSubtraction(detVector,sampleVector);

          // Calculate theta and phi for this beam
          thisTi:=ConvertToDegrees(AngleBetweenVectors(sampleNormal,beamVector));
          thisPhii:=ConvertToDegrees(ArcTan2(beamVector[2],beamVector[1]));
          thisTd:=ConvertToDegrees(AngleBetweenVectors(sampleNormal,detVector));
          thisPd:=ConvertToDegrees(ArcTan2(detVector[2],detVector[1]));

          // If pd is outside of expected range, adjust by 360 degrees to get within range
          if thisPd<pdMin then
            thisPd:=thisPd+360;
          if thisPd>pdMax then
            thisPd:=thisPd-360;

          // Increment appropriate points in I/D matrices
          tdInd:=Trunc((thisTd-tdMin)*tdRange);
          pdInd:=Trunc((thisPd-pdMin)*pdRange);
          AllAnglesD[tdInd,pdInd]:=AllAnglesD[tdInd,pdInd]+1;
          Application.ProcessMessages;
        end;
      end;
    end;
end;

function ConvertToRadians(Angle:Extended):Extended;
begin
	ConvertToRadians:=Angle*Pi/180;
end;

function ConvertToDegrees(Angle:Extended):Extended;
begin
	ConvertToDegrees:=Angle*180/Pi;
end;

procedure TMainForm.EnableButtons(ToWhat:Boolean);
begin
	CalculateButton.Enabled:=ToWhat;
  ThetaIEdit.Enabled:=ToWhat;
  PhiIEdit.Enabled:=ToWhat;
  ThetaDEdit.Enabled:=not IterateAngles and not Started;
	PhiDEdit.Enabled:=ToWhat;
	LengthEdit.Enabled:=ToWhat;
	BeamRadiusEdit.Enabled:=ToWhat;
	DetRadiusEdit.Enabled:=ToWhat;
	SaveFileCheckbox.Enabled:=ToWhat;
  NEdit.Enabled:=ToWhat;
  IterateAnglesCheckbox.Enabled:=ToWhat;
  StartAngleEdit.Enabled:=IterateAngles and not Started;
  StopAngleEdit.Enabled:=IterateAngles and not Started;
  StepAngleEdit.Enabled:=IterateAngles and not Started;
  Application.ProcessMessages;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Dispose(AllAnglesD);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Randomize;
  IterateAngles:=IterateAnglesCheckbox.Checked;
  StartAngleEdit.Enabled:=IterateAngles;
  StopAngleEdit.Enabled:=IterateAngles;
  StepAngleEdit.Enabled:=IterateAngles;
  ThetaDEdit.Enabled:=not IterateAngles;
  AllAnglesD:=New(PAngleArray);
end;

procedure TMainForm.IterateAnglesCheckboxClick(Sender: TObject);
begin
  IterateAngles:=not IterateAngles;
  StartAngleEdit.Enabled:=IterateAngles;
  StopAngleEdit.Enabled:=IterateAngles;
  StepAngleEdit.Enabled:=IterateAngles;
  ThetaDEdit.Enabled:=not IterateAngles;
end;

procedure TMainForm.StopButtonClick(Sender: TObject);
begin
  Started:=False;
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

function CheckValidInputInteger(TheEdit:TEdit;Variable,Units:string;Min,Max:Int64;var Valid:Boolean):Int64;
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

end.
