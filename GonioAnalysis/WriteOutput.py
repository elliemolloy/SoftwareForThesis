import xlsxwriter
import numpy as np
from GTC import *

def SaveErrors(Workbook):
    # Add new worksheet and write all errors into results file
    ws=Workbook.add_worksheet('Errors')
    row=0
    col=0
    f=open(r'C:\Users\e.molloy\PycharmProjects\GonioAnalysis\GonioAnalysis\InitialiseErrorsK5.py')
    lines=f.readlines()
    for line in lines:
        ws.write(row,col,line)
        row+=1

def SaveInputFiles(Workbook,InputFiles,SheetName='Inputs'):
    # Add new worksheet and write all the input files
    ws=Workbook.add_worksheet(SheetName)
    row=0
    col=0
    for item in InputFiles:
        ws.write(row,col,str(item))
        row+=1

def SaveBRDFvalues(Workbook,BRDF,Wavelengths,Averaged=False,AveragedPhi=False,SheetName='BRDF Values',Title=''):
    # Add new worksheet and save BRDF values
    nWavelengths=len(Wavelengths)
    thetas=np.arange(5,85,5)
    ws=Workbook.add_worksheet(SheetName)
    ws.write(0,0,Title)
    ws.write(1,0,'Theta (degrees)')
    row=2
    if Averaged:
        ws.write(row,1,'BRDF')
        ws.write(row,2,'u(BRDF)')
    else:
        if AveragedPhi:
            ws.write(row,1,'s')
            ws.write(row,2,'p')
            ws.write(row,4,'Uncertainty, s')
            ws.write(row,5,'Uncertainty, p')
        else:
            ws.write(row,1,'s')
            ws.write(row,10,'p')
            ws.write(row,19,'Uncertainty, s')
            ws.write(row,28,'Uncertainty, p')
        row+=1
    for w in range(0,nWavelengths):
        ws.write(row,1,Wavelengths[w])
        row+=1
        for t in range(0,16):
            ws.write(row,0,thetas[t])
            if Averaged:
                ws.write(row,1,BRDF[w,t].x)
                ws.write(row,2,BRDF[w,t].u)
            else:
                if AveragedPhi:
                    ws.write(row,1,BRDF[w,t,0].x)
                    ws.write(row,2,BRDF[w,t,1].x)
                    ws.write(row,4,BRDF[w,t,0].u)
                    ws.write(row,5,BRDF[w,t,1].u)
                else:
                    for phi in range(0,8):
                        ws.write(row,phi+1,BRDF[w,0,t,phi].x)
                        ws.write(row,phi+10,BRDF[w,1,t,phi].x)
                        ws.write(row,phi+19,BRDF[w,0,t,phi].u)
                        ws.write(row,phi+28,BRDF[w,1,t,phi].u)
            row+=1
        row+=1

def SaveDiffR(Workbook,DiffR,Wavelengths,SheetName='BRDF Values',Title=''):
    # Add new worksheet and save diff R values
    nWavelengths=len(Wavelengths)
    ws=Workbook.add_worksheet(SheetName)
    ws.write(0,0,Title)
    ws.write(1,0,'Wavelength (nm)')
    ws.write(1,1,'Diff R')
    ws.write(1,2,'u(diffR)')
    ws.write(1,3,'DoF')
    row=2
    for w in range(0,nWavelengths):
        ws.write(row,0,Wavelengths[w])
        ws.write(row,1,DiffR[w].x)
        ws.write(row,2,DiffR[w].u)
        ws.write(row,3,DiffR[w].df)
        row+=1

def SaveUncertaintyBudget(Workbook,DiffR,Wavelengths,SheetName='Uncertainty Budget',Title=''):
    # Add new worksheet and save diff R values
    nWavelengths=len(Wavelengths)
    ws=Workbook.add_worksheet(SheetName)
    ws.write(0,0,Title)
    ws.write(1,0,'Component')
    ws.write(1,1,'Uncertainty')
    col=1
    for w in range(0,nWavelengths):
        row=2
        ws.write(row,col,Wavelengths[w])
        row+=1
        Angles=ureal(0,0)
        ApertureRadius=ureal(0,0)
        AxisAlignment=ureal(0,0)
        BeamImagingData=ureal(0,0)
        DetUniformity=ureal(0,0)
        GainRatio=ureal(0,0)
        Interpolation=ureal(0,0)
        LengthSetting=ureal(0,0)
        Noise=ureal(0,0)
        NonIsotropy=ureal(0,0)
        PolPosition=ureal(0,0)
        RefRatio=ureal(0,0)
        SampleUniformity=ureal(0,0)
        StrayLight=ureal(0,0)
        ViewFactor=ureal(0,0)
        WavelengthE=ureal(0,0)
        Other=ureal(0,0)

        for infl in rp.budget(DiffR[w],trim=0):
            if infl.label[0:14]=='Aperture depth':
                LengthSetting =result(LengthSetting+ureal(0,infl.u))
            elif infl.label=='Aperture radius':
                ApertureRadius=result(ApertureRadius+ureal(0,infl.u))
            elif infl.label=='Beam imaging data':
                BeamImagingData=result(BeamImagingData+ureal(0,infl.u))
            elif infl.label=='I Detector Noise':
                Noise=result(Noise+ureal(0,infl.u))
            elif infl.label=='Detector Ref Noise':
                Noise=result(Noise+ureal(0,infl.u))
            elif infl.label=='Detector axis zero':
                Angles=result(Angles+ureal(0,infl.u))
            elif infl.label[0:13]=='Detector dark':
                Noise=result(Noise+ureal(0,infl.u))
            elif infl.label=='Detector height':
                AxisAlignment=result(AxisAlignment+ureal(0,infl.u))
            elif infl.label=='Detector uniformity model':
                DetUniformity=result(DetUniformity+ureal(0,infl.u))
            elif infl.label[0:13]=='Detector, Acc':
                Angles=result(Angles+ureal(0,infl.u))
            elif infl.label[0:13]=='Detector, Res':
                Angles=result(Angles+ureal(0,infl.u))
            elif infl.label[0:7]=='E Delta':
                AxisAlignment=result(AxisAlignment+ureal(0,infl.u))
            elif infl.label[0:3]=='E T':
                AxisAlignment=result(AxisAlignment+ureal(0,infl.u))
            elif infl.label[0:10]=='Gain ratio':
                GainRatio=result(GainRatio+ureal(0,infl.u))
            elif infl.label=='Interpolation error':
                Interpolation=result(Interpolation+ureal(0,infl.u))
            elif infl.label[0:6]=='Length':
                LengthSetting=result(LengthSetting+ureal(0,infl.u))
            elif infl.label=='I Monitor Noise':
                Noise=result(Noise+ureal(0,infl.u))
            elif infl.label=='Monitor Ref Noise':
                Noise=result(Noise+ureal(0,infl.u))
            elif infl.label[0:12]=='Monitor dark':
                Noise=result(Noise+ureal(0,infl.u))
            elif infl.label[0:9]=='No sample':
                StrayLight=result(StrayLight+ureal(0,infl.u))
            elif infl.label=='Non-isotropy of sample':
                NonIsotropy=result(NonIsotropy+ureal(0,infl.u))
            elif infl.label=='Pitch axis zero':
                Angles=result(Angles+ureal(0,infl.u))
            elif infl.label[0:6]=='Pitch,':
                Angles=result(Angles+ureal(0,infl.u))
            elif infl.label[0:13]=='Polariser pos':
                PolPosition=result(PolPosition+ureal(0,infl.u))
            elif infl.label=='Reference ratio':
                RefRatio=result(RefRatio+ureal(0,infl.u))
            elif infl.label[0:5]=='Roll,':
                Angles=result(Angles+ureal(0,infl.u))
            elif 'sensitivity coefficient' in infl.label:
                Angles=result(Angles+ureal(0,infl.u))
            elif infl.label[0:21]=='Sample non-uniformity':
                SampleUniformity=result(SampleUniformity+ureal(0,infl.u))
            elif infl.label[0:11]=='Stray light':
                StrayLight=result(StrayLight+ureal(0,infl.u))
            elif infl.label=='View factor quantised beam':
                ViewFactor=result(ViewFactor+ureal(0,infl.u))
            elif infl.label=='Yaw axis zero':
                Angles=result(Angles+ureal(0,infl.u))
            elif infl.label=='Roll axis zero':
                Angles=result(Angles+ureal(0,infl.u))
            elif infl.label=='Angle sensitivity coefficients':
                Angles=result(Angles+ureal(0,infl.u))
            elif infl.label=='Yaw sensitivity coefficient':
                Angles=result(Angles+ureal(0,infl.u))
            elif infl.label=='Roll sensitivity coefficient':
                Angles=result(Angles+ureal(0,infl.u))
            elif infl.label[0:4]=='Yaw,':
                Angles=result(Angles+ureal(0,infl.u))
            elif infl.label[0:10]=='Wavelength':
                WavelengthE=result(WavelengthE+ureal(0,infl.u))
            elif infl.label[0:17]=='Beam displacement':
                AxisAlignment=result(AxisAlignment+ureal(0,infl.u))
            else:
                Other=result(Other+ureal(0,infl.u))

        allUncertainties=[Angles,ApertureRadius,AxisAlignment,BeamImagingData,DetUniformity,GainRatio,Interpolation,
                          LengthSetting,Noise,NonIsotropy,PolPosition,RefRatio,SampleUniformity,StrayLight,ViewFactor,
                          WavelengthE,Other]
        allLabels=['Angles','Aperture Radius','Axis Alignment','Beam Imaging Data','Detector Uniformity','Gain Ratio',
                   'Interpolation','Length','Noise','Non-Isotropy','Polariser Position','Ref ratio','SampleUniformtiy',
                   'Stray Light','View Factor','Wavelength','Other']

        for i in range(0,len(allUncertainties)):
            if w==0:
                ws.write(row,0,allLabels[i])
            ws.write(row,col,allUncertainties[i].u)
            row+=1

        if w==0:
            ws.write(row,0,'TOTAL')
        ws.write(row,col,DiffR[w].u)
        col+=1

def SaveFullUncertaintyBudget(Workbook,DiffR,Wavelengths,SheetName='Uncertainty Budget',Title=''):
    # Add new worksheet and save diff R values
    nWavelengths=len(Wavelengths)
    ws=Workbook.add_worksheet(SheetName)
    ws.write(0,0,Title)
    ws.write(1,0,'Component')
    ws.write(1,1,'Uncertainty')
    col=1

    for w in range(0,nWavelengths):
        row=2
        ws.write(row,col,Wavelengths[w])
        ApertureDepth=ureal(0,0)
        ApertureDepthGauge=ureal(0,0)
        ApertureRadius=ureal(0,0)
        AngleSensitivtyCoeff=ureal(0,0)
        BeamImagingData=ureal(0,0)
        BeamDisplacementS=ureal(0,0)
        BeamDisplacementP=ureal(0,0)
        DetNoise=ureal(0,0)
        DetRefNoise=ureal(0,0)
        DetectorZero=ureal(0,0)
        DetectorDark=ureal(0,0)
        DetectorHeight=ureal(0,0)
        DetUniformity=ureal(0,0)
        DetAccuracy=ureal(0,0)
        DetResolution=ureal(0,0)
        EDeltaDx=ureal(0,0)
        EDeltaDz=ureal(0,0)
        EDeltaPy=ureal(0,0)
        EDeltaPz=ureal(0,0)
        EDeltaRx=ureal(0,0)
        EDeltaRy=ureal(0,0)
        EDeltaYx=ureal(0,0)
        EDeltaYz=ureal(0,0)
        ETDx=ureal(0,0)
        ETDz=ureal(0,0)
        ETPy=ureal(0,0)
        ETPz=ureal(0,0)
        ETRx=ureal(0,0)
        ETRy=ureal(0,0)
        ETYx=ureal(0,0)
        ETYz=ureal(0,0)
        GainRatio=ureal(0,0)
        Homing=ureal(0,0)
        Interpolation=ureal(0,0)
        LengthRod=ureal(0,0)
        LengthSetting=ureal(0,0)
        MonNoise=ureal(0,0)
        MonRefNoise=ureal(0,0)
        MonDark=ureal(0,0)
        NoSample=ureal(0,0)
        NonIsotropy=ureal(0,0)
        PitchZero=ureal(0,0)
        PitchAccuracy=ureal(0,0)
        PitchResolution=ureal(0,0)
        PolError=ureal(0,0)
        RefRatio=ureal(0,0)
        RollAccuracy=ureal(0,0)
        RollResolution=ureal(0,0)
        RollSensitivity=ureal(0,0)
        RollZero=ureal(0,0)
        SampleNonUniformity=ureal(0,0)
        StrayLight=ureal(0,0)
        ViewFactor=ureal(0,0)
        YawZero=ureal(0,0)
        YawAccuracy=ureal(0,0)
        YawResolution=ureal(0,0)
        YawSensitivity=ureal(0,0)
        EWavelength=ureal(0,0)
        ThetaDSensitivity=ureal(0,0)
        ThetaISensitivity=ureal(0,0)
        Other=ureal(0,0)

        for infl in rp.budget(DiffR[w],trim=0):
            if infl.label=='Aperture depth':
                ApertureDepth =result(ApertureDepth+ureal(0,infl.u))
            elif infl.label[0:20]=='Aperture depth gauge':
                ApertureDepthGauge=result(ApertureDepthGauge+ureal(0,infl.u))
            elif infl.label=='Aperture radius':
                ApertureRadius=result(ApertureRadius+ureal(0,infl.u))
            elif infl.label[0:20]=='Angle sensitivity co':
                AngleSensitivtyCoeff=result(AngleSensitivtyCoeff+ureal(0,infl.u))
            elif infl.label=='Beam displacement, s pol':
                BeamDisplacementS=result(BeamDisplacementS+ureal(0,infl.u))
            elif infl.label=='Beam displacement, p pol':
                BeamDisplacementP=result(BeamDisplacementP+ureal(0,infl.u))
            elif infl.label=='Beam imaging data':
                BeamImagingData=result(BeamImagingData+ureal(0,infl.u))
            elif infl.label=='I Detector Noise':
                DetNoise=result(DetNoise+ureal(0,infl.u))
            elif infl.label=='Detector Ref Noise':
                DetRefNoise=result(DetRefNoise+ureal(0,infl.u))
            elif infl.label=='Detector axis zero':
                DetectorZero=result(DetectorZero+ureal(0,infl.u))
            elif infl.label[0:13]=='Detector dark':
                DetectorDark=result(DetectorDark+ureal(0,infl.u))
            elif infl.label=='Detector height':
                DetectorHeight=result(DetectorHeight+ureal(0,infl.u))
            elif infl.label=='Detector uniformity model':
                DetUniformity=result(DetUniformity+ureal(0,infl.u))
            elif infl.label[0:13]=='Detector, Acc':
                DetAccuracy=result(DetAccuracy+ureal(0,infl.u))
            elif infl.label[0:13]=='Detector, Res':
                DetResolution=result(DetResolution+ureal(0,infl.u))
            elif infl.label=='E Delta Dx':
                EDeltaDx=result(EDeltaDx+ureal(0,infl.u))
            elif infl.label=='E Delta Dz':
                EDeltaDz=result(EDeltaDz+ureal(0,infl.u))
            elif infl.label=='E Delta Py':
                EDeltaPy=result(EDeltaPy+ureal(0,infl.u))
            elif infl.label=='E Delta Pz':
                EDeltaPz=result(EDeltaPz+ureal(0,infl.u))
            elif infl.label=='E Delta Rx':
                EDeltaRx=result(EDeltaRx+ureal(0,infl.u))
            elif infl.label=='E Delta Ry':
                EDeltaRy=result(EDeltaRy+ureal(0,infl.u))
            elif infl.label=='E Delta Yx':
                EDeltaYx=result(EDeltaYx+ureal(0,infl.u))
            elif infl.label=='E Delta Yz':
                EDeltaYz=result(EDeltaYz+ureal(0,infl.u))
            elif infl.label=='E TDx':
                ETDx=result(ETDx+ureal(0,infl.u))
            elif infl.label=='E TDz':
                ETDz=result(ETDz+ureal(0,infl.u))
            elif infl.label=='E TPy':
                ETPy=result(ETPy+ureal(0,infl.u))
            elif infl.label=='E TPz':
                ETPz=result(ETPz+ureal(0,infl.u))
            elif infl.label=='E TRx':
                ETRx=result(ETRx+ureal(0,infl.u))
            elif infl.label=='E TRy':
                ETRy=result(ETRy+ureal(0,infl.u))
            elif infl.label=='E TYx':
                ETYx=result(ETYx+ureal(0,infl.u))
            elif infl.label=='E TYz':
                ETYz=result(ETYz+ureal(0,infl.u))
            elif infl.label[0:10]=='Gain ratio':
                GainRatio=result(GainRatio+ureal(0,infl.u))
            elif 'homing' in infl.label:
                Homing=result(Homing+ureal(0,infl.u))
            elif infl.label=='Interpolation error':
                Interpolation=result(Interpolation+ureal(0,infl.u))
            elif infl.label=='Length rod calibration':
                LengthRod=result(LengthRod+ureal(0,infl.u))
            elif infl.label=='Length setting':
                LengthSetting=result(LengthSetting+ureal(0,infl.u))
            elif infl.label=='I Monitor Noise':
                MonNoise=result(MonNoise+ureal(0,infl.u))
            elif infl.label=='Monitor Ref Noise':
                MonRefNoise=result(MonRefNoise+ureal(0,infl.u))
            elif infl.label[0:12]=='Monitor dark':
                MonDark=result(MonDark+ureal(0,infl.u))
            elif infl.label[0:9]=='No sample':
                NoSample=result(NoSample+ureal(0,infl.u))
            elif infl.label=='Non-isotropy of sample':
                NonIsotropy=result(NonIsotropy+ureal(0,infl.u))
            elif infl.label=='Pitch axis zero':
                PitchZero=result(PitchZero+ureal(0,infl.u))
            elif infl.label[0:10]=='Pitch, Acc':
                PitchAccuracy=result(PitchAccuracy+ureal(0,infl.u))
            elif infl.label[0:10]=='Pitch, Res':
                PitchResolution=result(PitchResolution+ureal(0,infl.u))
            elif infl.label[0:13]=='Polariser pos':
                PolError=result(PolError+ureal(0,infl.u))
            elif infl.label=='Reference ratio':
                RefRatio=result(RefRatio+ureal(0,infl.u))
            elif infl.label[0:9]=='Roll, Acc':
                RollAccuracy=result(RollAccuracy+ureal(0,infl.u))
            elif infl.label[0:9]=='Roll, Res':
                RollResolution=result(RollResolution+ureal(0,infl.u))
            elif infl.label=='Roll axis zero':
                RollZero=result(RollZero+ureal(0,infl.u))
            elif infl.label=='Roll sensitivity coefficient':
                RollSensitivity=result(RollSensitivity+ureal(0,infl.u))
            elif infl.label[0:21]=='Sample non-uniformity':
                SampleNonUniformity=result(SampleNonUniformity+ureal(0,infl.u))
            elif infl.label[0:11]=='Stray light':
                StrayLight=result(StrayLight+ureal(0,infl.u))
            elif infl.label=='View factor quantised beam':
                ViewFactor=result(ViewFactor+ureal(0,infl.u))
            elif infl.label=='Yaw axis zero':
                YawZero=result(YawZero+ureal(0,infl.u))
            elif infl.label[0:8]=='Yaw, Acc':
                YawAccuracy=result(YawAccuracy+ureal(0,infl.u))
            elif infl.label[0:8]=='Yaw, Res':
                YawResolution=result(YawResolution+ureal(0,infl.u))
            elif infl.label=='Yaw sensitivity coefficient':
                YawSensitivity=result(YawSensitivity+ureal(0,infl.u))
            elif infl.label[0:10]=='Wavelength':
                EWavelength=result(EWavelength+ureal(0,infl.u))
            elif infl.label[0:7]=='Theta d':
                ThetaDSensitivity=result(ThetaDSensitivity+ureal(0,infl.u))
            elif infl.label[0:7]=='Theta i':
                ThetaISensitivity=result(ThetaISensitivity+ureal(0,infl.u))
            else:
                Other=result(Other+ureal(0,infl.u))
                print(infl.label)

        allUncertainties=[ApertureDepth,ApertureDepthGauge,ApertureRadius,AngleSensitivtyCoeff,BeamDisplacementS,
                          BeamDisplacementP,BeamImagingData,DetNoise,DetRefNoise,DetectorZero,DetectorDark,
                          DetectorHeight,DetUniformity,DetAccuracy,DetResolution,EDeltaDx,EDeltaDz,EDeltaPy,EDeltaPz,
                          EDeltaRx,EDeltaRy,EDeltaYx,EDeltaYz,ETDx,ETDz,ETPy,ETPz,ETRx,ETRy,ETYx,ETYz,GainRatio,Homing,
                          Interpolation,LengthRod,LengthSetting,MonNoise,MonRefNoise,MonDark,NoSample,NonIsotropy,
                          PitchZero,PitchAccuracy,PitchResolution,PolError,RefRatio,RollAccuracy,RollResolution,
                          RollSensitivity,RollZero,SampleNonUniformity,StrayLight,ViewFactor,YawZero,YawAccuracy,
                          YawResolution,YawSensitivity,EWavelength,ThetaDSensitivity,ThetaISensitivity,Other]
        allLabels=['ApertureDepth','ApertureDepthGauge','ApertureRadius','AngleSensitivtyCoeff','BeamDisplacementS',
                   'BeamDisplacementP','BeamImagingData','DetNoise','DetRefNoise','DetectorZero','DetectorDark',
                   'DetectorHeight','DetUniformity','DetAccuracy','DetResolution','EDeltaDx','EDeltaDz','EDeltaPy',
                   'EDeltaPz','EDeltaRx','EDeltaRy','EDeltaYx','EDeltaYz','ETDx','ETDz','ETPy','ETPz','ETRx','ETRy',
                   'ETYx','ETYz','GainRatio','Homing','Interpolation','LengthRod','LengthSetting','MonNoise','MonRefNoise',
                   'MonDark','NoSample','NonIsotropy','PitchZero','PitchAccuracy','PitchResolution','PolError',
                   'Ref ratio','RollAccuracy','RollResolution','RollSensitivity','RollZero','SampleNonUniformity',
                   'StrayLight','ViewFactor','YawZero','YawAccuracy','YawResolution','YawSensitivity','EWavelength',
                   'ThetaDSensitivity','ThetaISensitivity','Other']

        for i in range(0,len(allUncertainties)):
            if w==0:
                ws.write(row,0,allLabels[i])
            ws.write(row,col,allUncertainties[i].u)
            row+=1

        if w==0:
            ws.write(row,0,'TOTAL')
        ws.write(row,col,DiffR[w].u)
        col+=1

def SaveValues(WorkBook,WavelengthsL,brdf,avgBRDFPhi,avgBRDFnoSample,RF,SheetTitle):
    SaveBRDFvalues(WorkBook,brdf,WavelengthsL,Averaged=False,SheetName=SheetTitle+' BRDF Values',Title=SheetTitle+' BRDF Values')
    SaveBRDFvalues(WorkBook,avgBRDFPhi,WavelengthsL,Averaged=False,AveragedPhi=True,SheetName=SheetTitle+' Avg Phi',Title=SheetTitle+' BRDF Values after averaging phi')
    SaveBRDFvalues(WorkBook,avgBRDFnoSample,WavelengthsL,Averaged=True,SheetName=SheetTitle+' Corrected BRDF',Title=SheetTitle+' Corrected BRDF')
    SaveDiffR(WorkBook,RF,WavelengthsL,SheetName=SheetTitle+' DiffR',Title=SheetTitle+' DiffR')


def SaveCorrelationMatrix(FileName,Wavelengths,CorrMatrix):
    # Create Excel file and write out correlation matrices for correlations between measurements of different samples
    # at the same wavelengths
    nWavelengths=len(Wavelengths)
    wb=xlsxwriter.Workbook(FileName+'.xlsx')
    for w in range(0,nWavelengths):
        ws=wb.add_worksheet(str(Wavelengths[w])+' nm')
        ws.write(1,0,'T13')
        ws.write(2,0,'T14')
        ws.write(3,0,'P15')
        ws.write(4,0,'P16')
        ws.write(0,1,'T13')
        ws.write(0,2,'T14')
        ws.write(0,3,'P15')
        ws.write(0,4,'P16')
        for i in range(0,4):
            for j in range(0,4):
                ws.write(i+1,j+1,CorrMatrix[w,i,j])
    wb.close()



def WriteBTDFToFile(Worksheet,BTDFData,Theta,Phi,StartRow,StartCol):
    nWavelengths=np.shape(BTDFData)[0]
    nPol=np.shape(BTDFData)[1]
    nTheta=np.shape(BTDFData)[2]
    nPhi=np.shape(BTDFData)[3]

    row=StartRow+1
    col=StartCol
    for w in range(0,nWavelengths):
        Worksheet.write(StartRow,col,'Theta (degrees)')
        Worksheet.write(StartRow,col+1,'Phi (degrees)')
        Worksheet.write(StartRow,col+2,'BTDF (1/sr)')
        Worksheet.write(StartRow,col+3,'u(BTDF) (1/sr)')
        Worksheet.write(StartRow,col+4,'df')
        Worksheet.write(StartRow,col+5,'k')
        Worksheet.write(StartRow,col+6,'U(BTDF) (1/sr)')
        Worksheet.write(StartRow,col+7,'U(BTDF) (%)')
        for pol in range(0,nPol):
            Worksheet.write(row,StartCol-1,'Wavelength '+str(w)+', polarisation '+str(pol))
            for t in range(0,nTheta):
                for p in range(0,nPhi):
                    Worksheet.write(row,col,round(np.degrees(Theta[w,pol,t,p].x),0))
                    Worksheet.write(row,col+1,round(np.degrees(Phi[w,pol,t,p].x),0))
                    Worksheet.write(row,col+2,BTDFData[w,pol,t,p].x)
                    Worksheet.write(row,col+3,BTDFData[w,pol,t,p].u)
                    Worksheet.write(row,col+4,BTDFData[w,pol,t,p].df)
                    Worksheet.write(row,col+5,rp.k_factor(BTDFData[w,pol,t,p].df,95))
                    Worksheet.write(row,col+6,rp.k_factor(BTDFData[w,pol,t,p].df,95)*BTDFData[w,pol,t,p].u)
                    Worksheet.write(row,col+7,(rp.k_factor(BTDFData[w,pol,t,p].df,95)*BTDFData[w,pol,t,p].u/BTDFData[w,pol,t,p].x)*100)
                    row+=1
        col+=9
        row=StartRow+1

    return Worksheet