from scipy.interpolate import lagrange
from GonioAnalysis.Corrections import *
from GonioAnalysis.NumericalIntegration import *
from GonioAnalysis.Rotations import *
from GonioAnalysis.InitialiseErrorsK5 import *


"""
Functions in this file:
    CalculateRefSignal(SRef, PRef, Plot=False)
    CalculateSignal(AllData, Plot=False)
    CalculatePhi(NWavelengths,NTheta,NPhi,GainDifference,Signal,Signal180,RefSignal)
    CalculateBRDF(L,Flux,ThetaD,Aperture17=False)
    CalculateRF(AverageBRDF,integrationMethod='Lagrange')
    CalculateSolidAngle(ApertureDiameter,Length)
    CalculateWeightedAverage(DiffRValues)
    CalculateDiffR()
"""


def CalculateSignal(Source,NWavelengths,NTheta,NPhi,AllData,SRef,PRef,Data180=False,SphereDet=False,Gain8=False,
                    CalculateDark=False,ApplyPolCorrection=False,FeedbackCableAttached=False,RefGain7=True,
                    AddRefRatioError=False):
    """
    Takes the uncertain arrays of reference data and calculates the detector monitor ratios for each wavelength. Averages
    the detector monitor ratios if there is more than one reference file used. If plot is True (it's False by default),
    this also plots the reference data and the signal to noise (want to add 'typical' data to compare with).

    Takes in all the data and calculates the detector monitor ratios for each point after subtracting the dark current.
    Returns an uncertain array with all the detector monitor ratios. If plot is True (it's False by default), this also
    plots the data and the signal to noise (want to add 'typical' data to compare with).

    :param SRef:np array with s reference data
    :param PRef:np array with p reference data
    :param Plot:Boolean saying whether to plot the data
    :return:np array with reference signal

    :param AllData:np array with all measured data
    :param Plot:Boolean
    :param SphereDet:Boolean, True if sphere detector was used
    :param Gain8:Boolean, True if measurements were done with gain set to 10^8, False if measurements were done with gain set to 10^9 (affects dark current)
    :param CalculateDark:Boolean, if True, dark current is calculated as average of readings during run
    :return:arrays of signal and signal at 180
    """

    # Calculate signal from measurement file
    nPoints=len(AllData)

    # Save measured values and their errors
    EIDetNoise=la.uarray([ureal(0,AllData[i,7],9,label='I Detector Noise') for i in range(0,nPoints)])
    EIMonNoise=la.uarray([ureal(0,AllData[i,11],9,label='I Monitor Noise') for i in range(0,nPoints)])
    IDet=la.uarray([result(AllData[i,6]-EIDetNoise[i],label='I Detector') for i in range(0,nPoints)])
    IMon=la.uarray([result(AllData[i,10]-EIMonNoise[i],label='I Monitor') for i in range(0,nPoints)])

    # Subtract dark current and calculate the detector monitor ratio
    detSignal=CreateUArray(NWavelengths,NTheta,NPhi)
    monSignal=CreateUArray(NWavelengths,NTheta,NPhi)
    if Data180:
        detSignal180=CreateUArray(NWavelengths,NTheta-2,1)
        monSignal180=CreateUArray(NWavelengths,NTheta-2,1)
    row=0

    if CalculateDark:
        avgDetDark=np.average(np.unique(AllData[:,8])[1:])
        uAvgDetDark=np.std(np.unique(AllData[:,8])[1:])
        # Pick greater of uDetectorDark8 and uncertainty in mean and set as dark uncertainty
        if uAvgDetDark>uDetectorDark8:
            uDark=uAvgDetDark
            dfDark=len(np.unique(AllData[:,8])[1:])-1
        else:
            uDark=uDetectorDark8
            dfDark=dfDetectorDark8
        detDark=ureal(avgDetDark,uDark,df=dfDark,label='Detector dark, gain 8')
        avgMonDark=np.average(np.unique(AllData[:,12])[1:])
        if FeedbackCableAttached:
            monDark=ureal(avgMonDark,uMonitorDark1,df=dfMonitorDark1,label='Monitor dark, feedback cable attached')
        else:
            monDark=ureal(avgMonDark,uMonitorDark2,df=dfMonitorDark2,label='Monitor dark, feedback cable not attached')
        detDark7=ureal(DetectorDark7.x,DetectorDark7.u,df=DetectorDark7.df,label='Detector dark, gain 7')
    else:
        # Dark current is fully correlated for this file, but uncorrelated with respect to other files (so need to create errors here)
        detDark7=ureal(DetectorDark7.x,DetectorDark7.u,df=DetectorDark7.df,label='Detector dark, gain 7')
        detDark8=ureal(DetectorDark8.x,DetectorDark8.u,df=DetectorDark8.df,label='Detector dark, gain 8')
        detDark9=ureal(DetectorDark9.x,DetectorDark9.u,df=DetectorDark9.df,label='Detector dark, gain 9')
        detDarkSphere=ureal(DetectorDarkSphere.x,DetectorDarkSphere.u,df=DetectorDarkSphere.df,label='Detector dark, sphere detector')
        monDark=ureal(MonitorDark.x,MonitorDark.u,df=MonitorDark.df,label='Monitor dark')
        monDarkK52=ureal(MonitorDarkK52.x,MonitorDarkK52.u,df=MonitorDarkK52.df,label='Monitor dark')
        monDarkK53=ureal(MonitorDarkK53.x,MonitorDarkK53.u,df=MonitorDarkK53.df,label='Monitor dark')
        monDarkK54=ureal(MonitorDarkK54.x,MonitorDarkK54.u,df=MonitorDarkK54.df,label='Monitor dark')

    for pol in range(0,2):
        for w in range(0,NWavelengths):
            for t in range(0,NTheta):
                for p in range(0,NPhi):
                    if CalculateDark:
                        thisKDet=detDark
                        thisKMon=monDark
                    else:
                        # Detector dark current
                        if SphereDet:
                            thisKDet=detDarkSphere
                        elif Gain8:
                            thisKDet=detDark8
                        else:
                            thisKDet=detDark9
                        # Set monitor dark current, picking out the appropriate values for K5
                        if 44296<AllData[row,-1]<44299:
                            thisKMon=monDarkK52
                        elif 44342<AllData[row,-1]<44348:
                            thisKMon=monDarkK53
                        elif 44348<AllData[row,-1]<44359:
                            thisKMon=monDarkK54
                        else:
                            thisKMon=monDark
                    detSignal[w,pol,t,p]=result(IDet[row]-thisKDet,label='Detector Signal')
                    monSignal[w,pol,t,p]=result(IMon[row]-thisKMon,label='Monitor Signal')
                    row+=1
            if Data180:
                for t in range(0,NTheta-2):
                    # Use same dark values as previous reading
                    detSignal180[w,pol,t]=result(IDet[row]-thisKDet,label='Detector Signal')
                    monSignal180[w,pol,t]=result(IMon[row]-thisKMon,label='Monitor Signal')
                    row+=1
    signal=detSignal/monSignal

    print(thisKDet,thisKMon)

    # Calculate reference signal
    nSRefFiles=np.shape(SRef)[0]
    nPRefFiles=np.shape(PRef)[0]

    sDetRefSignal=0*SRef[:,:,1]
    sMonRefSignal=0*SRef[:,:,1]
    pDetRefSignal=0*PRef[:,:,1]
    pMonRefSignal=0*PRef[:,:,1]

    sRefSignalAvg=0*SRef[0,:,1]
    pRefSignalAvg=0*PRef[0,:,1]

    # Generate reference ratio uncertainties
    # Set uncertainty in reference ratio
    if AddRefRatioError:
        if Source=='Supercontinuum':
            ERefRatio=ureal(1,uRefRatioSuperK,label='Reference ratio')
        else:
            ERefRatio=ureal(1,uRefRatioLDLS,label='Reference ratio')
            ERefRatio360=ureal(1,uRefRatio360,label='Reference ratio')
    else:
        ERefRatio=ureal(1,0)
        ERefRatio360=ureal(1,0)

    for i in range(0,nSRefFiles):
        if ApplyPolCorrection:
            ePolariserS=la.uarray([1+ureal(0,UPolariserPositionS,df=6,label='Polariser position, s') for i in range(0,NWavelengths)])
        else:
            ePolariserS=np.ones(NWavelengths)
        for j in range(0,NWavelengths):
            if RefGain7:
                SRef[i,j,2]=detDark7
            else:
                SRef[i,j,2]=thisKDet
            SRef[i,j,4]=thisKMon

        sDetRefSignal[i,:]=la.uarray([result(SRef[i,w,1]-SRef[i,0,2],label='sDetRefSignal '+str(SRef[i,w,0])+' nm') for w in range(0,NWavelengths)])
        sMonRefSignal[i,:]=la.uarray([result(SRef[i,w,3]-SRef[i,0,4],label='sMonRefSignal '+str(SRef[i,w,0])+' nm') for w in range(0,NWavelengths)])
        sRefSignal=la.uarray([result(sDetRefSignal[i,w]/sMonRefSignal[i,w]*ePolariserS[w],label='sRefSignal '+str(SRef[i,w,0])+' nm') for w in range(0,NWavelengths)])
        for w in range(0,NWavelengths):
            if SRef[i,w,0]<370:
                sRefSignal[w]=sRefSignal[w]*ERefRatio360
            else:
                sRefSignal[w]=sRefSignal[w]*ERefRatio
        sRefSignalAvg=result(sRefSignalAvg+sRefSignal)

    for i in range(0,nPRefFiles):
        if ApplyPolCorrection:
            ePolariserP=la.uarray([1+ureal(0,UPolariserPositionP,df=6,label='Polariser position, s') for i in range(0,NWavelengths)])
        else:
            ePolariserP=np.ones(NWavelengths)
        for j in range(0,NWavelengths):
            if RefGain7:
                PRef[i,j,2]=detDark7
            else:
                PRef[i,j,2]=thisKDet
            PRef[i,j,4]=thisKMon
        pDetRefSignal[i,:]=la.uarray([result(PRef[i,w,1]-PRef[i,0,2],label='pDetRefSignal '+str(PRef[i,w,0])+' nm') for w in range(0,NWavelengths)])
        pMonRefSignal[i,:]=la.uarray([result(PRef[i,w,3]-PRef[i,0,4],label='pMonRefSignal '+str(PRef[i,w,0])+' nm') for w in range(0,NWavelengths)])
        pRefSignal=la.uarray([result(pDetRefSignal[i,w]/pMonRefSignal[i,w]*ePolariserP[w],label='pRefSignal '+str(PRef[i,w,0])+' nm') for w in range(0,NWavelengths)])
        for w in range(0,NWavelengths):
            if PRef[i,w,0]<370:
                pRefSignal[w]=pRefSignal[w]*ERefRatio360
            else:
                pRefSignal[w]=pRefSignal[w]*ERefRatio
        pRefSignalAvg=result(pRefSignalAvg+pRefSignal)

    sRefSignalAvg=sRefSignalAvg/nSRefFiles
    pRefSignalAvg=pRefSignalAvg/nPRefFiles
    refSignal=la.uarray([la.uarray([sRefSignalAvg[i],pRefSignalAvg[i],SRef[0,i,0]]) for i in range(0,NWavelengths)])

    if Data180:
        signal180=detSignal180/monSignal180
        toReturn=[signal,signal180,detSignal,detSignal180,monSignal,monSignal180,refSignal]
    else:
        toReturn=[signal,detSignal,monSignal,refSignal]

    return toReturn


def CalculatePhi(NWavelengths,NTheta,NPhi,Signal,RefSignal,Signal180=None,GainSettings='79'):
    """
    Calculates the flux ratio from the reference data and the measurements. Uses the array of all the data to determine
    which wavelength and polarisation to use from the reference data (the polarisation index should be 0 for s polarised
    and 1 for p polarised, the wavelength index should be 0 for the smallest wavelength and increase as the wavelength
    increases). Takes into account the gain change (using the global variable 'GainDifference') and the associated
    error. Returns an uncertain array with all the flux ratios.
    :param NWavelengths:number of wavelengths measured
    :param NTheta:number of thetas measured
    :param NPhi:number of phi angles measured
    :param Signal:array of the signal
    :param RefSignal:array of reference signal
    :param Signal180:array of the signal (for spectralon test)
    :return:array of the signal normalised by the reference signal
    """
    if GainSettings=='79':
        GainDifference=EGainChange
    elif GainSettings=='78':
        GainDifference=EGainChange78
    elif GainSettings=='88' or GainSettings=='77':
        GainDifference=1
    flux=CreateUArray(NWavelengths,NTheta,NPhi)
    if Signal180 is not None:
        flux180=CreateUArray(NWavelengths,NTheta-2,1)
    for pol in range(0,2):
        for w in range(0,NWavelengths):
            for t in range(0,NTheta):
                for p in range(0,NPhi):
                    flux[w,pol,t,p]=GainDifference*Signal[w,pol,t,p]/RefSignal[w,pol]
            if Signal180 is not None:
                for t in range(0,NTheta-2):
                    flux180[w,pol,t]=GainDifference*Signal180[w,pol,t]/RefSignal[w,pol]
    if Signal180 is not None:
        toReturn=[flux,flux180]
    else:
        toReturn=flux
    return toReturn


def CalculateBRDF(L,Flux,ThetaD,Aperture=30):
    """
    Calculates BRDF
    :param L:
    :param Flux:
    :param ThetaD:
    :param Aperture17:
    :return:
    """
    if Aperture==30:
        M=M30
    elif Aperture==17:
        M=M17
    elif Aperture==8:
        M=M8
    elif Aperture==4:
        M=M4
    else:
        print('Unrecognised aperture, using value only')
        M=Aperture
    omega=result((np.pi*M**2)/(4*L**2),label='Solid Angle')
    brdf=Flux*np.pi/(omega*cos(ThetaD.x))
    return brdf


def CalculateRF(NWavelengths,NTheta,AverageBRDF,IntegrationMethod='Lagrange'):
    """
    Integrate the BRDF to calculate the hemispherical reflectance
    :param AverageBRDF:
    :param integrationMethod:
    :return:
    """
    RF=la.uarray([ureal(0,0) for i in range(0,NWavelengths)])
    for w in range(0,NWavelengths):
        tdAll=AverageBRDF[w,:,1]
        tdAll=np.insert(np.insert(tdAll,0,0,axis=0),NTheta+1,np.radians(90),axis=0)
        brdfCurrent=AverageBRDF[w,:,0]
        brdfCurrent=np.insert(np.insert(brdfCurrent,0,0,axis=0),NTheta+1,0,axis=0)
        for i in range(0,NTheta+2):
            brdfCurrent[i]=brdfCurrent[i]*sin(2*tdAll[i])
        if IntegrationMethod=='Lagrange':
            RF[w]=IntegrateLagrangeCubic(tdAll,brdfCurrent)
        elif IntegrationMethod=='Simpson':
            RF[w]=SimpsonNonuniform(tdAll,brdfCurrent)
    return RF


def CalculateSolidAngle(ApertureDiameter,Length):
    solidAngle=ApertureDiameter**2/(np.pi*4*Length**2)
    return solidAngle


def CalculateWeightedAverage(DiffRValues,NWavelengths):
    # Takes an array of diffR values and calculates the weighted average using the GLS weighted mean.
    weightedAvg=la.uarray([ureal(0,0) for i in range(0,NWavelengths)])
    for w in range(0,NWavelengths):
        weights=CalculateWeights(DiffRValues[:,w])
        weightedAvg[w]=sum(weights*DiffRValues[:,w])
    return weightedAvg


def CalculateDiffR(Source,Sample,Wavelengths,NWavelengths,NTheta,NPhi,Directory,DataFile,RefFiles,
                   PDataFile=None,PRefFiles=None,Aperture17=False):
    """
    Runs all the functions needed to read data files and calculate diffR. Returns values to write into Excel file with
    results.
    :param Source:string, either 'LDLS' or 'Supercontinuum'.
    :param Sample:string, for K5 will be 'T13', 'T14', 'P15', or 'P16'.
    :param Wavelengths:array of the int, wavelengths measured at.
    :param NWavelengths:int, number of wavelengths measured at.
    :param NTheta:int, number of theta values measured at (16 for K5 measurements).
    :param NPhi:int, number of phi values measured at (8 for K5 measurements).
    :param Directory:string, directory containing measurement files.
    :param DataFile:string, file containing measurement data.
    :param RefFiles:array of strings, files containing the reference data.
    :param PDataFile:string, file containing the p data. If None, assume that DataFile has both polarisations.
    :param PRefFiles:array of strings, files containing the p reference data. If None, then assume RefFiles contains
    both s and p ref data. If given, then RefFiles contains s ref data.
    :param Aperture17:boolean, True if 17 mm aperture used, False if 30 mm aperture used.
    """

    # Determine which aperture
    if Aperture17:
        aperture=17
    else:
        aperture=30

    # Read in sensitivity coefficient data
    if Sample in ['T13','T14']:
        [wavelengthSensitivity,thetaDSensitivity,thetaISensitivity]=ReadSensitivityCoefficients('Tile')
    else:
        [wavelengthSensitivity,thetaDSensitivity,thetaISensitivity]=ReadSensitivityCoefficients('Fluorilon')

    # Read reference files, data files, and calculate signals
    if PRefFiles:
        BothRef=False
    else:
        BothRef=True
        PRefFiles=RefFiles
    if Source=='LDLS':
        applyPolCorrection=True
    else:
        applyPolCorrection=False
    [sRef,pRef,allData]=ReadData(NWavelengths,Directory,Source,RefFiles,PRefFiles,DataFile,PData=PDataFile,
                                 BothRef=BothRef)
    # refSignal=CalculateRefSignal(NWavelengths,sRef,pRef,Plot=False,PlotTitle=Sample,Source=Source)
    # [signal,signal180,detSignal,detSignal180,monSignal,monSignal180]=CalculateSignal(NWavelengths,NTheta,NPhi,allData,
    #                                                                         Data180=True,Plot=False,PlotTitle=Sample)
    [signal,signal180,detSignal,detSignal180,monSignal,monSignal180,refSignal]=CalculateSignal(Source,NWavelengths,
                                NTheta,NPhi,allData,sRef,pRef,Data180=True,SphereDet=False,Gain8=False,
                                                        CalculateDark=False,ApplyPolCorrection=applyPolCorrection)

    # Apply rotations, sort outputs
    [length,length180,thetaD,thetaD180,thetaI]=ApplyRotations(NWavelengths,NTheta,NPhi,allData,Aperture=aperture,
                                                              Data180=True)
    signal=SortData(NWavelengths,NTheta,signal,SortPhi=True)
    thetaD=SortData(NWavelengths,NTheta,thetaD,SortPhi=True)
    length=SortData(NWavelengths,NTheta,length,SortPhi=True)
    signal180=SortData(NWavelengths,NTheta,signal180,Sort180=True)

    # Calculate flux ratios
    [flux,flux180]=CalculatePhi(NWavelengths,NTheta,NPhi,signal,refSignal,signal180)

    # Include sensitivity coefficients for ti, td, wavelength
    fluxTi=IncludeThetaISensitivity(NWavelengths,NTheta,NPhi,thetaI,flux,thetaISensitivity)
    fluxTiTd=IncludeThetaDSensitivity(NWavelengths,NTheta,NPhi,thetaD,fluxTi,thetaDSensitivity)
    fluxTiTdWavelength=IncludeWavelengthSensitivity(NWavelengths,NTheta,NPhi,Wavelengths,fluxTiTd,wavelengthSensitivity,Source)

    # Calculate BRDF
    brdf=CalculateBRDF(length,fluxTiTdWavelength,thetaD,Aperture=aperture)

    # Average the phi values
    avgBRDFPhi=AveragePhi(NWavelengths,NTheta,NPhi,brdf,AveragingBRDF=True)
    avgThetaPhi=AveragePhi(NWavelengths,NTheta,NPhi,thetaD)

    # Apply the view factor and detector non-uniformity corrections
    if Aperture17:
        solidAngle=M17**2/(4*length**2)
    else:
        solidAngle=M30**2/(4*length**2)
    solidAngle=AveragePhi(NWavelengths,NTheta,NPhi,solidAngle)
    vfBRDF=ApplyViewFactorCorrection(Source,solidAngle,avgBRDFPhi,Aperture17,NWavelengths)
    detBRDF=ApplyDetectorUniformityCorrection(Source,vfBRDF,Aperture17,NWavelengths)

    # Average the two polarisations
    avgTheta=AveragePol(NWavelengths,NTheta,avgThetaPhi)
    avgBRDFdet=AveragePol(NWavelengths,NTheta,detBRDF)

    # Apply the stray light and no sample corrections
    avgBRDFstrayLight=ApplyStrayLightCorrection(Wavelengths,avgBRDFdet)
    # avgBRDFnoSample=ApplyNoSampleCorrection(NWavelengths,NTheta,Source,avgBRDFstrayLight)

    # Put data into an array, then integrate the BRDF over theta values to get RF
    BRDFDataCorrected=la.uarray([la.uarray([la.uarray([ureal(0,0),ureal(0,0)])for i in range(0,NTheta)])for j in range(0,NWavelengths)])
    BRDFDataCorrected[:,:,0]=avgBRDFstrayLight#avgBRDFnoSample
    BRDFDataCorrected[:,:,1]=avgTheta
    RFLagrangeCorrected=CalculateRF(NWavelengths,NTheta,BRDFDataCorrected,IntegrationMethod='Lagrange')

    # Apply no sample correction to reflectance values
    RFnoSample=ApplyNoSampleCorrection(NWavelengths,NTheta,Source,RFLagrangeCorrected)

    # return [brdf,avgBRDFPhi,avgBRDFnoSample,RFLagrangeCorrected]
    return [brdf,avgBRDFPhi,avgBRDFstrayLight,RFnoSample]

def CalculateCorrelations(NWavelengths,AllValues,Samples):
    """
    Calculate correlation matrix between measurements of the different samples at the same wavelengths.
    """
    N=len(Samples)
    corrMatrix=np.zeros((NWavelengths,N,N))
    for w in range(0,NWavelengths):
        for i in range(0,N):
            for j in range(0,N):
                corrMatrix[w,i,j]=get_correlation(AllValues[Samples[i]][w],AllValues[Samples[j]][w])
    return corrMatrix


def CalculateDiffRS7(Source,Sample,Wavelengths,NWavelengths,NTheta,NPhi,Directory,DataFile,SRefFile,PRefFile,
                     GainSettings='78',FeedbackCableAttached=False):
    """
    Runs all the functions needed to read data files and calculate diffR. Returns values to write into Excel file with
    results.
    :param Source:string, either 'LDLS' or 'Supercontinuum'.
    :param Sample:string.
    :param Wavelengths:array of the int, wavelengths measured at.
    :param NWavelengths:int, number of wavelengths measured at.
    :param NTheta:int, number of theta values measured at (16 for K5 measurements).
    :param NPhi:int, number of phi values measured at (8 for K5 measurements).
    :param Directory:string, directory containing measurement files.
    :param DataFile:string, file containing measurement data.
    :param RefFiles:array of strings, files containing the reference data.
    """

    # Determine reference gain
    if GainSettings=='78':
        refGain7=True
    else:
        refGain7=False

    # Read in sensitivity coefficient data
    if Sample in ['PTB41','S2-I']:
        [wavelengthSensitivity,thetaDSensitivity,thetaISensitivity]=ReadSensitivityCoefficients('Spectralon')
    elif Sample=='Geal':
        [wavelengthSensitivity,thetaDSensitivity,thetaISensitivity]=ReadSensitivityCoefficients('Tile')
    else:
        [wavelengthSensitivity,thetaDSensitivity,thetaISensitivity]=ReadSensitivityCoefficients(Sample)

    # Read reference files, data files, and calculate signals
    [sRef,pRef,allData]=ReadData(NWavelengths,Directory,Source,SRefFile,PRefFile,DataFile,PData=None,BothRef=False)
    [signal,signal180,detSignal,detSignal180,monSignal,monSignal180,refSignal]=CalculateSignal(Source,NWavelengths,NTheta,NPhi,
            allData,sRef,pRef,Data180=True,SphereDet=False,Gain8=True,CalculateDark=True,ApplyPolCorrection=False,
                                    FeedbackCableAttached=FeedbackCableAttached,RefGain7=refGain7,AddRefRatioError=True)

    # Apply rotations, sort outputs
    PitchSampleHoming=ureal(math.radians(0),tb.distribution['gaussian'](math.radians(0.3)),df=19,label='Pitch sample homing')
    YawSampleHoming=ureal(math.radians(0),tb.distribution['gaussian'](math.radians(0.1)),df=19,label='Yaw sample homing')
    [length,length180,thetaD,thetaD180,thetaI]=ApplyRotations(NWavelengths,NTheta,NPhi,allData,Aperture=30,Data180=True,
                                                    PitchSampleHoming=PitchSampleHoming,YawSampleHoming=YawSampleHoming)
    signal=SortData(NWavelengths,NTheta,signal,SortPhi=True)
    thetaD=SortData(NWavelengths,NTheta,thetaD,SortPhi=True)
    length=SortData(NWavelengths,NTheta,length,SortPhi=True)
    signal180=SortData(NWavelengths,NTheta,signal180,Sort180=True)

    # Calculate flux ratios
    [flux,flux180]=CalculatePhi(NWavelengths,NTheta,NPhi,signal,refSignal,GainSettings=GainSettings,Signal180=signal180)

    # Include sensitivity coefficients for ti, td, wavelength
    fluxTi=IncludeThetaISensitivity(NWavelengths,NTheta,NPhi,thetaI,flux,thetaISensitivity)
    fluxTiTd=IncludeThetaDSensitivity(NWavelengths,NTheta,NPhi,thetaD,fluxTi,thetaDSensitivity)
    fluxTiTdWavelength=IncludeWavelengthSensitivity(NWavelengths,NTheta,NPhi,Wavelengths,fluxTiTd,wavelengthSensitivity,Source)

    # Calculate BRDF
    brdf=CalculateBRDF(length,fluxTiTdWavelength,thetaD,Aperture=30)

    # Average the phi values
    avgBRDFPhi=AveragePhi(NWavelengths,NTheta,NPhi,brdf,AveragingBRDF=True)
    avgThetaPhi=AveragePhi(NWavelengths,NTheta,NPhi,thetaD)

    # Apply the view factor and detector non-uniformity corrections
    solidAngle=M30**2/(4*length**2)
    solidAngle=AveragePhi(NWavelengths,NTheta,NPhi,solidAngle)
    vfBRDF=ApplyViewFactorCorrection(Source,solidAngle,avgBRDFPhi,Aperture17=False,NWavelengths=NWavelengths,WithBeamImaging=False)
    detBRDF=ApplyDetectorUniformityCorrection(Source,vfBRDF,Aperture17=False,NWavelengths=NWavelengths,Wavelengths=Wavelengths)

    # Average the two polarisations
    avgTheta=AveragePol(NWavelengths,NTheta,avgThetaPhi)
    avgBRDFdet=AveragePol(NWavelengths,NTheta,detBRDF)

    # Apply the stray light correction
    avgBRDFstrayLight=ApplyStrayLightCorrection(Wavelengths,avgBRDFdet)

    # Put data into an array, then integrate the BRDF over theta values to get RF
    BRDFDataCorrected=la.uarray([la.uarray([la.uarray([ureal(0,0),ureal(0,0)])for i in range(0,NTheta)])for j in range(0,NWavelengths)])
    BRDFDataCorrected[:,:,0]=avgBRDFstrayLight
    BRDFDataCorrected[:,:,1]=avgTheta
    RFLagrange=CalculateRF(NWavelengths,NTheta,BRDFDataCorrected,IntegrationMethod='Lagrange')

    # Apply no sample correction
    RFLagrangeCorrected=ApplyNoSampleCorrection(NWavelengths,NTheta,Source,RFLagrange,Wavelengths=Wavelengths)

    return [brdf,avgBRDFPhi,avgBRDFstrayLight,RFLagrangeCorrected]


def InterpolateDiffR(Sample,MeasuredWavelengths,DiffR,InterpolatedWavelengths,LinearInterpolation=True):
    """
        Interpolate diffuse reflectance to other wavelengths and apply interpolation error.
        Requires the interpolated wavelengths and measured wavelengths to be evenly spaced.
    """
    nInterpolated=len(InterpolatedWavelengths)
    nMeasured=len(MeasuredWavelengths)
    diffR=la.zeros(nInterpolated+nMeasured)

    # Read interpolation errors and save this sample's errors as uncertain numbers
    allInterpolationCorrections=np.loadtxt(InterpolationCorrectionFile,skiprows=1)
    samples=open(InterpolationCorrectionFile,'r').readline().strip('\n').split("\t")
    if Sample=='PTB41':
        sampleInd=samples.index('S2-I')
    else:
        sampleInd=samples.index(Sample)
    interpolationCorrections=la.zeros(nInterpolated)
    for w in range(0,nInterpolated):
        if Sample=='MSL Grey 5%':
            # Interpolation error is bigger to ensure that interpolated values have bigger uncertainties
            interpolationCorrections[w]=allInterpolationCorrections[w,sampleInd]*(1-EInterpolationMSL5)
        else:
            interpolationCorrections[w]=allInterpolationCorrections[w,sampleInd]*(1-EInterpolation)

    if LinearInterpolation:
        ind=0
        interpolatedInd=0
        for w in range(0,nMeasured):
            if MeasuredWavelengths[w]<InterpolatedWavelengths[0]:
                # If the measured wavelength is below the first interpolated wavelength, store the diffuse reflectance
                diffR[ind]=DiffR[w]
                ind+=1
            else:
                # Otherwise, calculate the interpolated wavelength and apply the interpolation correction relatively
                # Then save the diffuse reflectance for this measured wavelength
                # Correction is interpolated / measured, so need to divide interpolated value by correction
                diffR[ind]=((DiffR[w-1]+DiffR[w])/2)/interpolationCorrections[interpolatedInd]
                diffR[ind+1]=DiffR[w]
                ind+=2
                interpolatedInd+=1
    else:
        # If not linear interpolation, do quadratic interpolation using two values below and one above
        ind=1
        interpolatedInd=0
        # Save first measured wavelength
        diffR[0]=DiffR[0]
        for w in range(1,nMeasured):
            if MeasuredWavelengths[w]<InterpolatedWavelengths[0]:
                # If the measured wavelength is below the first interpolated wavelength, store the diffuse reflectance
                diffR[ind]=DiffR[w]
                ind+=1
            else:
                # Otherwise, calculate the interpolated wavelength using Lagrange quadratic and apply the interpolation
                # correction relatively
                # Then save the diffuse reflectance for this measured wavelength
                x=MeasuredWavelengths[w-1:w+2]
                y=DiffR[w-1:w+2]
                poly=lagrange(x,y)
                diffR[ind]=poly(InterpolatedWavelengths[interpolatedInd])/interpolationCorrections[interpolatedInd]
                diffR[ind+1]=DiffR[w]
                ind+=2
                interpolatedInd+=1
    return diffR