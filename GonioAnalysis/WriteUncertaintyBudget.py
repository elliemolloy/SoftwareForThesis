from GTC import *

def PrintUncertaintyBudget(NWavelengths,Sample):
    for i in range(0,NWavelengths):
        ApertureDepth=ureal(0,0)
        ApertureDepthGauge=ureal(0,0)
        ApertureRadius=ureal(0,0)
        AngleSensitivtyCoeff=ureal(0,0)
        BeamDisplacementS=ureal(0,0)
        BeamDisplacementP=ureal(0,0)
        BeamImagingData=ureal(0,0)
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
        RefRatioError=ureal(0,0)
        RollAccuracy=ureal(0,0)
        RollResolution=ureal(0,0)
        RollZero=ureal(0,0)
        StrayLight=ureal(0,0)
        ViewFactor=ureal(0,0)
        YawZero=ureal(0,0)
        YawAccuracy=ureal(0,0)
        YawResolution=ureal(0,0)
        EWavelength=ureal(0,0)
        ThetaDSensitivity=ureal(0,0)
        ThetaISensitivity=ureal(0,0)

        for infl in rp.budget(Sample[i],trim=0):
            if infl.label=='Aperture depth':
                ApertureDepth =result(ApertureDepth+ureal(0,infl.u))
            elif infl.label[0:20]=='Aperture depth gauge':
                ApertureDepthGauge=result(ApertureDepthGauge+ureal(0,infl.u))
            elif infl.label=='Aperture radius':
                ApertureRadius=result(ApertureRadius+ureal(0,infl.u))
            elif infl.label[0:20]=='Angle sensitivity co':
                AngleSensitivtyCoeff=result(AngleSensitivtyCoeff+ureal(0,infl.u))
            elif infl.label=='Beam imaging data':
                BeamImagingData=result(BeamImagingData+ureal(0,infl.u))
            elif infl.label=='Beam displacement, s pol':
                BeamDisplacementS=result(BeamDisplacementS+ureal(0,infl.u))
            elif infl.label=='Beam displacement, p pol':
                BeamDisplacementP=result(BeamDisplacementP+ureal(0,infl.u))
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
            elif infl.label=='No sample correction':
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
                RefRatioError=result(RefRatioError+ureal(0,infl.u))
            elif infl.label[0:9]=='Roll, Acc':
                RollAccuracy=result(RollAccuracy+ureal(0,infl.u))
            elif infl.label[0:9]=='Roll, Res':
                RollResolution=result(RollResolution+ureal(0,infl.u))
            elif infl.label=='Roll axis zero':
                RollZero=result(RollZero+ureal(0,infl.u))
            elif infl.label=='Stray light correction':
                StrayLight=result(StrayLight+ureal(0,infl.u))
            elif infl.label=='View factor quantised beam':
                ViewFactor=result(ViewFactor+ureal(0,infl.u))
            elif infl.label=='Yaw axis zero':
                YawZero=result(YawZero+ureal(0,infl.u))
            elif infl.label[0:8]=='Yaw, Acc':
                YawAccuracy=result(YawAccuracy+ureal(0,infl.u))
            elif infl.label[0:8]=='Yaw, Res':
                YawResolution=result(YawResolution+ureal(0,infl.u))
            elif infl.label[0:10]=='Wavelength':
                EWavelength=result(EWavelength+ureal(0,infl.u))
            elif infl.label[0:7]=='Theta d':
                ThetaDSensitivity=result(ThetaDSensitivity+ureal(0,infl.u))
            elif infl.label[0:7]=='Theta i':
                ThetaISensitivity=result(ThetaISensitivity+ureal(0,infl.u))
            else:
                print(infl.label,infl.u)

        print(i,'\n',AngleSensitivtyCoeff.u,'\n',ApertureDepth.u,'\n',ApertureDepthGauge.u,'\n',ApertureRadius.u,'\n',
              BeamDisplacementS.u,'\n',BeamDisplacementP.u,'\n',BeamImagingData.u,'\n',DetectorHeight.u,'\n',DetNoise.u,
              '\n',DetRefNoise.u,'\n',DetectorZero.u,'\n',DetectorDark.u,'\n',DetUniformity.u,'\n',DetAccuracy.u,'\n',
              DetResolution.u,'\n',EDeltaDx.u,'\n',EDeltaDz.u,'\n',EDeltaPy.u,'\n',EDeltaPz.u,'\n',EDeltaRx.u,'\n',
              EDeltaRy.u,'\n',EDeltaYx.u,'\n',EDeltaYz.u,'\n',ETDx.u,'\n',ETDz.u,'\n',ETPy.u,'\n',ETPz.u,'\n',ETRx.u,
              '\n',ETRy.u,'\n',ETYx.u,'\n',ETYz.u,'\n',GainRatio.u,'\n',LengthRod.u,'\n',LengthSetting.u,'\n',
              MonNoise.u,'\n',MonRefNoise.u,'\n',MonDark.u,'\n',NoSample.u,'\n',NonIsotropy.u,'\n',PitchZero.u,
              '\n',PitchAccuracy.u,'\n',PitchResolution.u,'\n',PolError.u,'\n',RefRatioError,'\n',RollAccuracy.u,'\n',
              RollResolution.u,'\n',RollZero.u,'\n',StrayLight.u,'\n',ViewFactor.u,'\n',YawZero.u,'\n',
              YawAccuracy.u,'\n',YawResolution.u,'\n',EWavelength.u,'\n',ThetaDSensitivity.u,'\n',ThetaISensitivity.u)



def PrintUncertaintyBudgetBTDF(NWavelengths,Sample):
    for i in range(0,NWavelengths):
        ApertureRadius=ureal(0,0)
        DetNoise=ureal(0,0)
        DetectorDark=ureal(0,0)
        MonNoise=ureal(0,0)
        MonDark=ureal(0,0)
        EDeltaDx=ureal(0,0)
        EDeltaDz=ureal(0,0)
        EDeltaPz=ureal(0,0)
        ETPz=ureal(0,0)
        LengthSetting=ureal(0,0)
        MonRefNoise=ureal(0,0)
        DetRefNoise=ureal(0,0)
        DetZero=ureal(0,0)
        YawZero=ureal(0,0)
        DetAccuracy=ureal(0,0)
        YawAccuracy=ureal(0,0)

        for infl in rp.budget(Sample[i],trim=0):
            if infl.label=='Aperture radius':
                ApertureRadius=result(ApertureRadius+ureal(0,infl.u))
            elif infl.label=='I Detector Noise':
                DetNoise=result(DetNoise+ureal(0,infl.u))
            elif infl.label=='Detector Ref Noise':
                DetRefNoise=result(DetRefNoise+ureal(0,infl.u))
            elif infl.label=='Detector axis zero':
                DetZero=result(DetZero+ureal(0,infl.u))
            elif infl.label=='Detector dark':
                DetectorDark=result(DetectorDark+ureal(0,infl.u))
            elif infl.label=='E Delta Dx':
                EDeltaDx=result(EDeltaDx+ureal(0,infl.u))
            elif infl.label=='E Delta Dz':
                EDeltaDz=result(EDeltaDz+ureal(0,infl.u))
            elif infl.label=='E Delta Pz':
                EDeltaPz=result(EDeltaPz+ureal(0,infl.u))
            elif infl.label=='E TPz':
                ETPz=result(ETPz+ureal(0,infl.u))
            elif infl.label[0:6]=='Length':
                LengthSetting=result(LengthSetting+ureal(0,infl.u))
            elif infl.label[0:8]=='Aperture':
                LengthSetting=result(LengthSetting+ureal(0,infl.u))
            elif infl.label=='I Monitor Noise':
                MonNoise=result(MonNoise+ureal(0,infl.u))
            elif infl.label=='Monitor Ref Noise':
                MonRefNoise=result(MonRefNoise+ureal(0,infl.u))
            elif infl.label=='Monitor dark':
                MonDark=result(MonDark+ureal(0,infl.u))
            elif infl.label=='Yaw axis zero':
                YawZero=result(YawZero+ureal(0,infl.u))
            elif infl.label[0:13]=='Yaw, Accuracy':
                YawAccuracy=result(YawAccuracy+ureal(0,infl.u))
            elif infl.label[0:18]=='Detector, Accuracy':
                DetAccuracy=result(DetAccuracy+ureal(0,infl.u))
            else:
                if infl.u>1e-5:
                    print(infl.label,infl.u)

        print(i,',',ApertureRadius.u,',',DetNoise.u,',',DetectorDark.u,',',MonNoise.u,',',EDeltaDx.u,',',EDeltaDz.u,',',
              EDeltaPz.u,',',LengthSetting.u,',',MonDark.u,',',ETPz.u,',',DetZero.u,',',MonRefNoise.u,
              ',',DetRefNoise.u,',',YawZero.u,',',DetAccuracy.u,',',YawAccuracy.u,',',Sample[i].x,',',Sample[i].u)