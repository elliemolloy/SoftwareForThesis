unit ThroughputErrorsMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, LinearAlgebra, gonioThroughputMain,
  GonioThroughputGlobal, BRDFmodel, VclTee.TeeGDIPlus, VCLTee.TeEngine,
  Vcl.ExtCtrls, VCLTee.TeeProcs, VCLTee.Chart, VCLTee.Series, Vcl.ExtDlgs;

type
  T2AngleArray=array[0..99,0..99] of Extended;

  TTEMainForm = class(TForm)
    ThetaIEdit: TEdit;
    PhiIEdit: TEdit;
    ThetaDEdit: TEdit;
    PhiDEdit: TEdit;
    BeamRadiusEdit: TEdit;
    DetRadiusEdit: TEdit;
    LEdit: TEdit;
    wEdit: TEdit;
    nEdit: TEdit;
    kEdit: TEdit;
    RhoEdit: TEdit;
    OpenDialog: TOpenDialog;
    CalculateButton: TButton;
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
    GroupBox1: TGroupBox;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    sResultsLabel: TLabel;
    pResultsLabel: TLabel;
    avgResultsLabel: TLabel;
    brdfChart: TChart;
    PlotBRDFButton: TButton;
    Series1: TLineSeries;
    Series2: TLineSeries;
    SaveResultsCheckBox: TCheckBox;
    OpenResultFileDialog: TOpenDialog;
    GroupBox2: TGroupBox;
    StartAngleEdit: TEdit;
    StopAngleEdit: TEdit;
    StepAngleEdit: TEdit;
    IterateAnglesCheckBox: TCheckBox;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    procedure CalculateButtonClick(Sender: TObject);
    procedure PlotBRDFButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure IterateAnglesCheckBoxClick(Sender: TObject);
  private
    { Private declarations }
    procedure EnableButtons(ToWhat:Boolean);
  public
    { Public declarations }
  end;

procedure ReadFile(FileName:string;var Valid:Boolean);
function CheckIntegral:Extended;


var
  TEMainForm: TTEMainForm;
  Started,PlotStarted,IterateAnglesE:Boolean;
  AngleArray:T2AngleArray;

implementation

{$R *.dfm}

procedure TTEMainForm.CalculateButtonClick(Sender: TObject);
var
  ti,phii,td,pd,w,n,k,rho,beamRadius,detRadius,L,avgError:Extended;
  brdfNomS,brdfNomP,tdMin,tdMax,tdRange,pdMin,pdMax,pdRange,total:Extended;
  thisTd,thisPd,thisBRDFS,brdfSumS,thisBRDFP,brdfSumP,errorS,errorP:Extended;
  startAngle,stopAngle,stepAngle,tdSet,thisFraction:Extended;
  i,j,ii,nAngles:Integer;
  valid,saveResults:Boolean;
  fileDirectory,resultsFileName,anglesFileName,thisFileName,saveFileDir:string;
  thisFileName2:string;
  f:TextFile;
begin
  Started:=not Started;
  if Started then
  begin
    valid:=True;
    CalculateButton.Caption:='Stop';

    // Set variables from form
    ti:=CheckValidInput(ThetaIEdit,'Theta i','degrees',0,180,valid);
    phii:=CheckValidInput(PhiIEdit,'Phi i','degrees',-360,360,valid);
    td:=CheckValidInput(ThetaDEdit,'Theta d','degrees',0,180,valid);
    pd:=CheckValidInput(PhiDEdit,'Phi d','degrees',-360,360,valid);
    beamRadius:=CheckValidInput(BeamRadiusEdit,'Beam radius','mm',0,100000,valid);
    detRadius:=CheckValidInput(DetRadiusEdit,'Detector radius','mm',0,100000,valid);
    L:=CheckValidInput(LEdit,'Length','mm',0,100000,valid);
    w:=CheckValidInput(wEdit,'w','',0,1,valid);
    n:=CheckValidInput(nEdit,'Refractive index, n','',0,10,valid);
    k:=CheckValidInput(kEdit,'Extinction coefficient, k','',0,10,valid);
    rho:=CheckValidInput(rhoEdit,'rho','',0,10,valid);
    saveResults:=SaveResultsCheckBox.Checked;

    if IterateAnglesE then
    begin
      startAngle:=CheckValidInput(StartAngleEdit,'Start angle','degrees',0,360,valid);
      stopAngle:=CheckValidInput(StopAngleEdit,'Stop angle','degrees',startAngle,360,valid);
      stepAngle:=CheckValidInput(StepAngleEdit,'Step angle','degrees',0,stopAngle-startAngle,valid);
      nAngles:=Trunc((stopAngle-startAngle)/stepAngle);
      {thisFileName:=FloatToStr(beamRadius)+','+FloatToStr(detRadius)+',';}
      thisFileName:=FloatToStr(beamRadius)+','+FloatToStr(detRadius)+','+FloatToStr(L)+'.txt';
    end;

    EnableButtons(False);
    Screen.Cursor:=crHourGlass;

    if saveResults then
    begin
      fileDirectory:='G:\Shared drives\MSL - Photometry & Radiometry\STANDARDS\GonioSpectrometry\Throughput\Output data from Delphi\Microfacet model';
      OpenResultFileDialog.FileName:='Microfacet model.txt';
      if saveResults then
        with OpenResultFileDialog do
          if Execute then
            resultsFileName:=FileName
          else
            valid:=False;
    end;

    if IterateAnglesE then
    begin
      for ii:=0 to nAngles do
        if valid then
        begin
          tdSet:=startAngle+ii*stepAngle;

          // Calculate nominal BRDF for s, p pol
          brdfNomS:=CalculateBRDF(ti,tdSet,pd,w,n,k,rho,'s');
          brdfNomP:=CalculateBRDF(ti,tdSet,pd,w,n,k,rho,'p');

          // Calculate limits of bins from results
          tdMin:=CalculateThetaMin(ti,tdSet,BeamRadius,DetRadius,L);
          tdMax:=CalculateThetaMax(ti,tdSet,BeamRadius,DetRadius,L);
          tdRange:=tdMax-tdMin;

          if tdSet=0 then
          begin
            pdMin:=-180;
            pdMax:=180;
          end
          else
          begin
            pdMin:=pd-CalculatePhiMax(ti,tdSet,BeamRadius,DetRadius,L)-2;
            pdMax:=pd+CalculatePhiMax(ti,tdSet,BeamRadius,DetRadius,L)+2;
          end;
          pdRange:=pdMax-pdMin;

          // Initialise arrays to read results
          for i:=0 to 99 do
            for j:=0 to 99 do
              AngleArray[i,j]:=0;

          // Read in results
          if valid then
          begin
            if ti=45 then
              saveFileDir:='G:\Shared drives\MSL - Photometry & Radiometry\STANDARDS\GonioSpectrometry\Throughput\Output data from Delphi\45 degrees incidence\'
            else
              saveFileDir:='G:\Shared drives\MSL - Photometry & Radiometry\STANDARDS\GonioSpectrometry\Throughput\Output data from Delphi\Normal incidence\';
            {anglesFileName:=saveFileDir+thisFileName+FloatToStr(tdSet)+'.txt';}
            thisFileName2:=FloatToStr(ti)+','+FloatToStr(phii)+','+FloatToStr(tdSet)+','+FloatToStr(pd)+',';
            anglesFileName:=saveFileDir+thisFileName2+thisFileName;
            if FileExists(anglesFileName) then
              ReadFile(anglesFileName,valid)
            else
              with OpenDialog do
                if Execute then
                  ReadFile(FileName,valid)
                else
                  valid:=False;
          end;

          // Evaluate BRDF model at each of these points to calculate error from throughput
          if valid and Started then
          begin
            // Normalise data, then calculate BRDF
            total:=0;
            brdfSumS:=0;
            brdfSumP:=0;
            for i:=0 to 99 do
              for j:=0 to 99 do
                total:=total+AngleArray[i,j];
            for i:=0 to 99 do
            begin
              thisTd:=i*tdRange/100+tdMin;
              for j:=0 to 99 do
                if Started then
                begin
                  thisFraction:=AngleArray[i,j]/total;
                  thisPd:=j*pdRange/100+pdMin;
                  thisBRDFS:=CalculateBRDF(ti,thisTd,thisPd,w,n,k,rho,'s');
                  brdfSumS:=brdfSumS+thisBRDFS*thisFraction;
                  thisBRDFP:=CalculateBRDF(ti,thisTd,thisPd,w,n,k,rho,'p');
                  brdfSumP:=brdfSumP+thisBRDFP*thisFraction;
                  Application.ProcessMessages;
                end;
            end;
            errorS:=brdfSumS/brdfNomS;
            errorP:=brdfSumP/brdfNomP;
            avgError:=(errorS+errorP)/2;

            // Save angles
            if saveResults then
            begin
              AssignFile(f,resultsFileName);
              if FileExists(resultsFileName) then
                Append(f)
              else
                Rewrite(f);
              Writeln(f);
              Write(f,tdSet,#9,errorS,#9,errorP,#9,avgError);
              CloseFile(f);
            end;
        end;
      end;
    end
    else // if not iterating angles
    begin
      // Calculate nominal BRDF for s, p pol
      brdfNomS:=CalculateBRDF(ti,td,pd,w,n,k,rho,'s');
      brdfNomP:=CalculateBRDF(ti,td,pd,w,n,k,rho,'p');

      // Calculate limits of bins from results
      tdMin:=CalculateThetaMin(ti,td,BeamRadius,DetRadius,L);
      tdMax:=CalculateThetaMax(ti,td,BeamRadius,DetRadius,L);
      tdRange:=tdMax-tdMin;

      if td=0 then
      begin
        pdMin:=-180;
        pdMax:=180;
      end
      else
      begin
        pdMin:=pd-CalculatePhiMax(ti,td,BeamRadius,DetRadius,L)-2;
        pdMax:=pd+CalculatePhiMax(ti,td,BeamRadius,DetRadius,L)+2;
      end;
      pdRange:=pdMax-pdMin;

      // Initialise arrays to read results
      for i:=0 to 99 do
        for j:=0 to 99 do
          AngleArray[i,j]:=0;

      // Read in results
      if valid then
        with OpenDialog do
          if Execute then
            ReadFile(FileName,valid)
          else
            valid:=False;

      // Evaluate BRDF model at each of these points to calculate error from throughput
      if valid and Started then
      begin
        // Normalise data, then calculate BRDF
        total:=0;
        brdfSumS:=0;
        brdfSumP:=0;
        for i:=0 to 99 do
          for j:=0 to 99 do
            total:=total+AngleArray[i,j];
        for i:=0 to 99 do
        begin
          thisTd:=i*tdRange/100+tdMin;
          for j:=0 to 99 do
            if Started then
            begin
              thisFraction:=AngleArray[i,j]/total;
              thisPd:=j*pdRange/100+pdMin;
              thisBRDFS:=CalculateBRDF(ti,thisTd,thisPd,w,n,k,rho,'s');
              brdfSumS:=brdfSumS+thisBRDFS*thisFraction;
              thisBRDFP:=CalculateBRDF(ti,thisTd,thisPd,w,n,k,rho,'p');
              brdfSumP:=brdfSumP+thisBRDFP*thisFraction;
              Application.ProcessMessages;
            end;
        end;
        errorS:=brdfSumS/brdfNomS;
        errorP:=brdfSumP/brdfNomP;
        avgError:=(errorS+errorP)/2;
      end;

      // Save angles
      if saveResults then
      begin
        AssignFile(f,resultsFileName);
        if FileExists(resultsFileName) then
          Append(f)
        else
          Rewrite(f);
        Writeln(f);
        Write(f,td,#9,errorS,#9,errorP,#9,avgError);
        CloseFile(f);
      end;
    end;

    // Show results
    sResultsLabel.Caption:=FloatToStr(errorS);
    pResultsLabel.Caption:=FloatToStr(errorP);
    avgResultsLabel.Caption:=FloatToStr(avgError);

    Started:=False;
    EnableButtons(True);
    Screen.Cursor:=crDefault;
    CalculateButton.Caption:='Calculate';
  end
  else
    CalculateButton.Caption:='Calculate';
end;

{.......................................................}

procedure ReadFile(FileName:string;var Valid:Boolean);
var
  f:TextFile;
  S:string;
  i,j,pos1:Integer;
begin
  if FileExists(FileName) then
  begin
    AssignFile(f,FileName);
    Reset(f);
    for i:=0 to 99 do
    begin
      Readln(f,S);
      for j:=0 to 99 do
      begin
        pos1:=Pos(#9,S);
        AngleArray[j,i]:=StrToFloat(Copy(S,1,pos1-1));
        S:=Copy(S,pos1+1,Length(S)-pos1);
      end;
    end;
    CloseFile(f);
    Valid:=True;
  end
  else
  begin
    ShowMessage('The file "'+FileName+'" doesn''t exist.');
    Valid:=False;
  end;
end;

{.......................................................}

function CheckIntegral:Extended;
// Integral check code (make SimpleBRDF return 1 and the integral code return integralTest), then this should return pi
begin
  CheckIntegral:=Integrate(0,1,1,0,'s');
end;

{.......................................................}

procedure TTEMainForm.IterateAnglesCheckBoxClick(Sender: TObject);
begin
  IterateAnglesE:=not IterateAnglesE;
  StartAngleEdit.Enabled:=IterateAnglesE;
  StopAngleEdit.Enabled:=IterateAnglesE;
  StepAngleEdit.Enabled:=IterateAnglesE;
  ThetaDEdit.Enabled:=not IterateAnglesE;
end;

procedure TTEMainForm.EnableButtons(ToWhat:Boolean);
begin
  ThetaIEdit.Enabled:=ToWhat;
  PhiIEdit.Enabled:=ToWhat;
  ThetaDEdit.Enabled:=not IterateAngles and not Started;
	PhiDEdit.Enabled:=ToWhat;
	BeamRadiusEdit.Enabled:=ToWhat;
	DetRadiusEdit.Enabled:=ToWhat;
  LEdit.Enabled:=ToWhat;
  WEdit.Enabled:=ToWhat;
  NEdit.Enabled:=ToWhat;
  KEdit.Enabled:=ToWhat;
  RhoEdit.Enabled:=ToWhat;
  IterateAnglesCheckbox.Enabled:=ToWhat;
  StartAngleEdit.Enabled:=IterateAngles and not Started;
  StopAngleEdit.Enabled:=IterateAngles and not Started;
  StepAngleEdit.Enabled:=IterateAngles and not Started;
  Application.ProcessMessages;
end;

procedure TTEMainForm.FormCreate(Sender: TObject);
begin
    with Series1 do
  begin
    Clear;
    Repaint;
  end;

  with Series2 do
  begin
    Clear;
    Repaint;
  end;

  IterateAnglesE:=IterateAnglesCheckBox.Checked;
  StartAngleEdit.Enabled:=IterateAnglesE;
  StopAngleEdit.Enabled:=IterateAnglesE;
  StepAngleEdit.Enabled:=IterateAnglesE;
  ThetaDEdit.Enabled:=not IterateAnglesE;
end;

procedure TTEMainForm.PlotBRDFButtonClick(Sender: TObject);
var
  ti,phii,td,pd,beamRadius,detRadius,L,w,n,k,rho,tdCalc,pdCalc:Extended;
  tdAll,brdfAllS,brdfAllP:array of Double;
  i:Integer;
  valid:Boolean;
begin
  PlotStarted:=not PlotStarted;

  if PlotStarted then
  begin
    valid:=True;
    PlotBRDFButton.Caption:='Stop';

    // Set variables from form
    ti:=CheckValidInput(ThetaIEdit,'Theta i','degrees',0,180,valid);
    phii:=CheckValidInput(PhiIEdit,'Phi i','degrees',-360,360,valid);
    td:=CheckValidInput(ThetaDEdit,'Theta d','degrees',0,180,valid);
    pd:=CheckValidInput(PhiDEdit,'Phi d','degrees',-360,360,valid);
    beamRadius:=CheckValidInput(BeamRadiusEdit,'Beam radius','mm',0,100000,valid);
    detRadius:=CheckValidInput(DetRadiusEdit,'Detector radius','mm',0,100000,valid);
    L:=CheckValidInput(LEdit,'Length','mm',0,100000,valid);
    w:=CheckValidInput(wEdit,'w','',0,1,valid);
    n:=CheckValidInput(nEdit,'Refractive index, n','',0,10,valid);
    k:=CheckValidInput(kEdit,'Extinction coefficient, k','',0,10,valid);
    rho:=CheckValidInput(rhoEdit,'rho','',0,10,valid);

    EnableButtons(False);
    Screen.Cursor:=crHourGlass;

    // Calculate BRDF varying td from -75 to 75 degrees
    SetLength(tdAll,151);
    SetLength(brdfAllS,151);
    SetLength(brdfAllP,151);

    for i:=0 to 150 do
    begin
      tdAll[i]:=-75+i;
      if tdAll[i]<0 then
      begin
        tdCalc:=-tdAll[i];
        pdCalc:=pd+180;
        if pdCalc>360 then
          pdCalc:=pdCalc-360;
      end
      else
      begin
        tdCalc:=tdAll[i];
        pdCalc:=pd;
      end;
      brdfAllS[i]:=CalculateBRDF(ti,tdCalc,pdCalc,w,n,k,rho,'s');
      brdfAllP[i]:=CalculateBRDF(ti,tdCalc,pdCalc,w,n,k,rho,'p');
    end;

    with Series1.XValues do
    begin
      Value:=TChartValues(tdAll);
      Count:=151;
      Modified:=True;
    end;

    with Series1.YValues do
    begin
      Value:=TChartValues(brdfAllS);
      Count:=151;
      Modified:=True;
    end;

    with Series2.XValues do
    begin
      Value:=TChartValues(tdAll);
      Count:=151;
      Modified:=True;
    end;

    with Series2.YValues do
    begin
      Value:=TChartValues(brdfAllP);
      Count:=151;
      Modified:=True;
    end;

    Series1.Repaint;
    Series2.Repaint;

    EnableButtons(True);
    PlotStarted:=False;
    Screen.Cursor:=crDefault;
    PlotBRDFButton.Caption:='Plot BRDF';
  end
  else
  begin
    PlotBRDFButton.Caption:='Plot BRDF';
    EnableButtons(True);
    Screen.Cursor:=crDefault;
  end;
end;

end.
