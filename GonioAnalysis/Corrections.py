import numpy as np
from GonioAnalysis.InitialiseErrorsK5 import *
from GonioAnalysis.ReadingData import *
from GTC import *

"""
Functions in this file:
    ApplySpectralonTestCorrection(Flux,Flux180)
    ReadVFData(Source,SolidAngle,Aperture17=False)
    ApplyViewFactorCorrection(Source,SolidAngle,BRDFData,Aperture17=False)
    EvaluateStrayLightCorrection(Wavelengths)
    ApplyStrayLightCorrection(Wavelengths,BRDF)
    ReadNoSampleCorrection(NWavelengths,NTheta,Source)
    ApplyNoSampleCorrection(NWavelengths,NTheta,Source,BRDFData)
    ReadDetectorUniformityCorrection(Source,Aperture17=False)
    ApplyDetectorUniformityCorrection(Source,BRDFData,Aperture17=False)
    ReadSensitivityCoefficients(Sample)
    IncludeWavelengthSensitivity(NWavelengths,NTheta,NPhi,Wavelengths,BRDF,WavelengthSensitivity)
    IncludeThetaDSensitivity(NWavelengths,NTheta,NPhi,Thetas,BRDF,ThetaDSensitivity)
    IncludeThetaISensitivity(NWavelengths,NTheta,NPhi,ThetaI,BRDF,ThetaISensitivity)
"""


def ApplySpectralonTestCorrection(NWavelengths,NTheta,NPhi,Flux,Flux180):
    correctedFlux180=Flux180*ureal(0,0)
    correctedFlux=Flux*ureal(0,0)
    for w in range(0,NWavelengths):
        for t in range(0,NTheta):
            if t==0:
                correctionS=(Flux[w,0,t,0].x+Flux180[w,0,t,0].x)/(2*Flux[w,0,t,0].x)
                correctionP=(Flux[w,1,t,0].x+Flux180[w,1,t,0].x)/(2*Flux[w,1,t,0].x)
            elif t==NTheta-1:
                correctionS=(Flux[w,0,t-2,0].x+Flux180[w,0,t-3,0].x)/(2*Flux[w,0,t-2,0].x)
                correctionP=(Flux[w,1,t-2,0].x+Flux180[w,1,t-3,0].x)/(2*Flux[w,1,t-2,0].x)
            else:
                if t%2:
                    correctionS=(Flux[w,0,t,4].x+Flux180[w,0,t-1,0].x)/(2*Flux[w,0,t,4].x)
                    correctionP=(Flux[w,1,t,4].x+Flux180[w,1,t-1,0].x)/(2*Flux[w,1,t,4].x)
                    correction180S=(Flux[w,0,t,4].x+Flux180[w,0,t-1,0].x)/(2*Flux180[w,0,t-1,0].x)
                    correction180P=(Flux[w,1,t,4].x+Flux180[w,1,t-1,0].x)/(2*Flux180[w,1,t-1,0].x)
                    correctedFlux180[w,0,t-1]=Flux180[w,0,t-1,0]*correction180S
                    correctedFlux180[w,1,t-1]=Flux180[w,1,t-1,0]*correction180P
                else:
                    correctionS=(Flux[w,0,t,0].x+Flux180[w,0,t-1,0].x)/(2*Flux[w,0,t,0].x)
                    correctionP=(Flux[w,1,t,0].x+Flux180[w,1,t-1,0].x)/(2*Flux[w,1,t,0].x)
                    correction180S=(Flux[w,0,t,0].x+Flux180[w,0,t-1,0].x)/(2*Flux180[w,0,t-1,0].x)
                    correction180P=(Flux[w,1,t,0].x+Flux180[w,1,t-1,0].x)/(2*Flux180[w,1,t-1,0].x)
                    correctedFlux180[w,0,t-1]=Flux180[w,0,t-1,0]*correction180S
                    correctedFlux180[w,1,t-1]=Flux180[w,1,t-1,0]*correction180P
            for p in range(0,NPhi):
                correctedFlux[w,0,t,p]=Flux[w,0,t,p]*correctionS
                correctedFlux[w,1,t,p]=Flux[w,1,t,p]*correctionP
    return correctedFlux,correctedFlux180

def GetSpectralonTestCorrection(NWavelengths,NTheta,Flux,Flux180):
    correctionS=np.zeros((NWavelengths,NTheta))
    correctionP=np.zeros((NWavelengths,NTheta))
    for w in range(0,NWavelengths):
        for t in range(0,NTheta):
            if t==0:
                #print(w,t,'a')
                correctionS[w,t]=(Flux[w,0,t,0].x/Flux180[w,0,t,0].x)
                correctionP[w,t]=(Flux[w,1,t,0].x/Flux180[w,1,t,0].x)
            elif t==NTheta-1:
                #print(w, t, 'b')
                correctionS[w,t]=(Flux[w,0,t-2,0].x/Flux180[w,0,t-3,0].x)
                correctionP[w,t]=(Flux[w,1,t-2,0].x/Flux180[w,1,t-3,0].x)
            else:
                if t%2==0:
                    #print(w, t, 'c')
                    if w == 0 and t == 1:
                        print(Flux180[w,0,t-1].x,Flux[w,0,t,4].x)
                    correctionS[w,t]=(Flux[w,0,t,0].x/Flux180[w,0,t-1].x)
                    correctionP[w,t]=(Flux[w,1,t,0].x/Flux180[w,1,t-1].x)
                else:
                    #print(w, t, 'd')
                    #if w == 0 and t == 1:
                        #print(Flux180[w,0,t-1].x,Flux[w,0,t,4].x)
                    correctionS[w,t]=(Flux180[w,0,t-1].x/Flux[w,0,t,4].x)
                    correctionP[w,t]=(Flux180[w,1,t-1].x/Flux[w,1,t,4].x)

    return correctionS,correctionP


def ReadVFData(Source,SolidAngle,Aperture17=False,NWavelengths=None,WithBeamImaging=True):
    """
        Read in view factor data (including beam imaging data) at the wavelengths used in the K5 comparison. If other
        wavelengths have been used, or fewer wavelengths, this will need updating
        :param Source: str (either 'LDLS' or 'Supercontinuum')
        :param SolidAngle: float (the solid angle)
        :param Aperture17: boolean (says if the 17 mm aperture was used)
        :return: vfCorrection: la uarray with the view factor corrections
        """
    if WithBeamImaging:
        if Aperture17:
            beamSensitivtyCoefficientsFile=VFSensitivityCoefficients17
            if Source=='LDLS':
                vfDataFile=VFDataFileLDLS17
                nWavelengths=7
            elif Source=='Supercontinuum':
                vfDataFile=VFDataFileSuperK17
                nWavelengths=9
        else:
            beamSensitivtyCoefficientsFile=VFSensitivityCoefficients30
            if Source=='LDLS':
                vfDataFile=VFDataFileLDLS30
                nWavelengths=7
            elif Source=='Supercontinuum':
                vfDataFile=VFDataFileSuperK30
                nWavelengths=9
        if NWavelengths:
            nWavelengths=NWavelengths
        vfData=la.uarray([la.uarray([la.uarray([ureal(0,0) for i in range(0,3)]) for j in range(0,17)]) for k in range(0,nWavelengths)])
        vf=np.loadtxt(VFDataDirectory+vfDataFile)
        beamSensitivtyCoefficients=np.loadtxt(VFDataDirectory+beamSensitivtyCoefficientsFile)
        row=0
        for t in range(0,17):
            for w in range(0, nWavelengths):
                beamDataError=result(beamSensitivtyCoefficients[t]*EBeamData,label='View factor beam imaging data')
                vfData[w,t,0]=ureal(np.radians(abs(vf[row,0])),0)
                vfData[w,t,1]=ureal(vf[row,2],0,label='View factor correction, s',df=inf)*(1-EViewFactor)-beamDataError
                vfData[w,t,2]=ureal(vf[row,4],0,label='View factor correction, p',df=inf)*(1-EViewFactor)-beamDataError
                row+=1
        vfData=vfData[:,(vfData[0,:,0].x).argsort(),:]
        vfCorrection=la.uarray([la.uarray([la.uarray([ureal(0,0) for i in range(0,2)]) for j in range(0,16)]) for k in range(0,nWavelengths)])
        vfCorrection[:,:]=SolidAngle.x/vfData[:,1:,1:]
    else:
        vfDataFile=VFDataFileNoBeamImaging
        vfData=la.uarray([la.uarray([la.uarray([ureal(0,0) for i in range(0,3)]) for j in range(0,16)]) for k in range(0,NWavelengths)])
        vf=np.loadtxt(vfDataFile)
        row=0
        for t in range(0,16):
            for w in range(0, NWavelengths):
                vfData[w,t,0]=np.radians(abs(vf[row,0]))
                vfData[w,t,1]=ureal(vf[row,2],0,label='View factor correction',df=inf)*(1-EViewFactor)
                vfData[w,t,2]=ureal(vf[row,4],0,label='View factor correction',df=inf)*(1-EViewFactor)
            row+=1
        vfCorrection=SolidAngle.x/vfData[:,:,1:]

    return vfCorrection


def ApplyViewFactorCorrection(Source,SolidAngle,BRDFData,Aperture17=False,NWavelengths=None,WithBeamImaging=True):
    """
        Applies the stray light correction using the above function. If wavelengths other than those used in the K5
        comparison are used, then this will need updating.
        :param Source: str (either 'LDLS' or 'Supercontinuum')
        :param SolidAngle: float (the solid angle)
        :param Aperture17: boolean (says whether the 17 mm aperture was used)
        :return: correctedBRDF: la uarray with the corrected BRDF values
    """
    vfData=ReadVFData(Source,SolidAngle,Aperture17,NWavelengths,WithBeamImaging)
    correctedBRDF=BRDFData*vfData
    return correctedBRDF


def EvaluateStrayLightCorrection(Wavelengths):
    """
        Calculates the stray light correction factors given the wavelengths used
        :param Wavelengths: np array (array of the wavelengths)
        :return: CStrayLight: uarray of the correction factors to correct for stray light
        """
    CStrayLight=la.uarray([ureal(0,0) for i in range(0,len(Wavelengths))])
    for w in range(0,len(Wavelengths)):
        if Wavelengths[w]<750:
            CStrayLight[w]=EStrayLight1+EUStrayLight
        else:
            correctionFactor=1-(EStrayLight2m*Wavelengths[w]-EStrayLight2c)
            CStrayLight[w]=correctionFactor+EUStrayLight
    return CStrayLight


def ApplyStrayLightCorrection(Wavelengths,BRDF):
    nWavelengths=len(Wavelengths)
    nTheta=16
    correctedBRDF=la.uarray([la.uarray([ureal(0,0) for i in range(0,nTheta)]) for j in range(0,nWavelengths)])
    strayLightCorrection=EvaluateStrayLightCorrection(Wavelengths)
    for w in range(0,nWavelengths):
        for t in range(0,nTheta):
            correctedBRDF[w,t]=BRDF[w,t]*strayLightCorrection[w]
    return correctedBRDF


def ReadNoSampleCorrection(NWavelengths,NTheta,Source,Wavelengths=None):
    """
        Reads in the data for when there is no sample
        :param Source: string (either 'LDLS' or 'Supercontinuum')
        :return: CNoSample: uarray of the correction factors to correct for no sample
        """
    CNoSample=la.uarray([ureal(0,0) for i in range(0,NWavelengths)])
    if Wavelengths:
        # If wavelengths are given, read in data for all wavelengths then look up index for each wavelength
        noSampleData=np.loadtxt(NoSampleSuperK)
        for w in range(0,NWavelengths):
            ind=int(np.where(noSampleData[:,0]==Wavelengths[w])[0])
            CNoSample[w]=ureal(1-noSampleData[ind,1],uNoSample,df=dfNoSample,label="No sample correction")
    else:
        if Source=='Supercontinuum':
            noSampleData=np.loadtxt(NoSampleSuperK)
        elif Source=='LDLS':
            # noSampleData=np.zeros((NWavelengths*NTheta))
            noSampleData=np.zeros((NWavelengths))
        # CNoSample=la.uarray([ureal(0,0) for i in range(0,NWavelengths*NTheta)])
        # for i in range(0,NWavelengths*NTheta):
        #     CNoSample[i]=ureal(1-noSampleData[i],uNoSample,df=dfNoSample,label="No sample correction")
        for i in range(0,NWavelengths):
            CNoSample[i]=ureal(1-noSampleData[i],uNoSample,df=dfNoSample,label="No sample correction")
    return CNoSample


def ApplyNoSampleCorrection(NWavelengths,NTheta,Source,BRDFData,Wavelengths=None):
    # # For correcting BRDF
    # CNoSample=ReadNoSampleCorrection(NWavelengths,NTheta,Source)
    # k=0
    # correctedBRDF=la.uarray([la.uarray([ureal(0,0) for i in range(0,NTheta)]) for j in range(0,NWavelengths)])
    # for i in range(0,NWavelengths):
    #     for j in range(0,NTheta):
    #         correctedBRDF[i,j]=CNoSample[k]*BRDFData[i,j]
    #   k+=1

    # For correcting reflectance (instead of BRDF)
    CNoSample=ReadNoSampleCorrection(NWavelengths,NTheta,Source,Wavelengths=Wavelengths)
    correctedBRDF=la.zeros(NWavelengths)
    for i in range(0,NWavelengths):
        correctedBRDF[i]=CNoSample[i]*BRDFData[i]
    return correctedBRDF


def ReadDetectorUniformityCorrection(Source,Aperture17=False,NWavelengths=None,Wavelengths=None):
    """
        Read in detector non-uniformity correction data
        :param Source: str (either 'LDLS' or 'Supercontinuum')
        :param Aperture17: boolean (says if the 17 mm aperture was used)
        :return:
        """
    directory=DetUniformityDirectory
    if Aperture17:
        file=DetUDataFile2022_17
        # if Source=='LDLS':
        #     file=DetUDataFileLDLS17
        #     beamSensitivtyCoefficientsFile=DetUSensitivityCoefficientsLDLS
        # elif Source=='Supercontinuum':
        #     file=DetUDataFileSuperK17
        #     beamSensitivtyCoefficientsFile=DetUSensitivityCoefficientsSuperK
    else:
        file=DetUDataFile2022_30
        # if Source=='LDLS':
        #     file=DetUDataFileLDLS30
        #     beamSensitivtyCoefficientsFile=DetUSensitivityCoefficientsLDLS
        # elif Source=='Supercontinuum':
        #     file=DetUDataFileSuperK30
        #     beamSensitivtyCoefficientsFile=DetUSensitivityCoefficientsSuperK
    detModelData=np.loadtxt(directory+file)
    if Source=='Supercontinuum':
        if Wavelengths:
            # Look up row starting with first wavelength if wavelengths given
            row=int(np.where(detModelData[:,0]==Wavelengths[0])[0][0])
        else:
            # Want to start with the 460 nm correction, which is in row 85
            row=85
    else:
        row=0
    # beamSensitivtyCoefficients=np.loadtxt(directory+beamSensitivtyCoefficientsFile)
    detData=la.uarray([la.uarray([la.uarray([ureal(0,0) for i in range(0,3)]) for j in range(0,17)]) for k in range(0,NWavelengths)])
    # row=0
    for w in range(0,NWavelengths):
        # beamDataError=result(beamSensitivtyCoefficients[w]*EBeamData,label='Detector model beam imaging data')
        for t in range(0,17):
            detData[w,t,0]=ureal(np.radians(abs(detModelData[row,1])),0)
            # detData[w,t,1]=ureal(detModelData[16-row,4]/detModelData[16-row,2],0,label='Detector uniformity correction, s')*(1-EDetectorModel)-beamDataError
            # detData[w,t,2]=ureal(detModelData[16-row,5]/detModelData[16-row,3],0,label='Detector uniformity correction, p')*(1-EDetectorModel)-beamDataError
            detData[w,t,1]=ureal(detModelData[row,2]/detModelData[row,4],0,label='Detector uniformity correction, s')*(1-EDetectorModel)
            detData[w,t,2]=ureal(detModelData[row,3]/detModelData[row,5],0,label='Detector uniformity correction, p')*(1-EDetectorModel)
            row+=1
    detDataSorted=detData[:,(detData[0,:,0].x).argsort(),:]
    detCorrection=detDataSorted[:,1:,1:]
    return detCorrection


def ApplyDetectorUniformityCorrection(Source,BRDFData,Aperture17=False,NWavelengths=None,Wavelengths=None):
    detCorrection=ReadDetectorUniformityCorrection(Source,Aperture17,NWavelengths,Wavelengths=Wavelengths)
    correctedBRDF=BRDFData*detCorrection
    return correctedBRDF

def ReadSensitivityCoefficients(Sample):
    if Sample=='Tile':
        directory=SampleSensitivityCoefficientDir
        wavelengthData=np.loadtxt(directory+T13WavelengthSensitivityCoefficients)
        thetaDData=np.loadtxt(directory+T13ThetaDSensitivityCoefficients)
        thetaIData=np.loadtxt(directory+T13ThetaISensitivityCoefficients)
    elif Sample=='Fluorilon':
        directory=SampleSensitivityCoefficientDir
        wavelengthData=np.loadtxt(directory+P15WavelengthSensitivityCoefficients)
        thetaDData=np.loadtxt(directory+P15ThetaDSensitivityCoefficients)
        thetaIData=np.loadtxt(directory+P15ThetaISensitivityCoefficients)
    elif Sample=='Spectralon':
        directory=S7SampleSensitivityCoefficientDir
        wavelengthData=np.loadtxt(directory+PTB41WavelengthSensitivityCoefficients)
        thetaDData=np.loadtxt(directory+PTB41ThetaDSensitivityCoefficients)
        thetaIData=np.loadtxt(directory+PTB41ThetaISensitivityCoefficients)
    elif Sample=='MSL Grey 40%':
        directory=S7SampleSensitivityCoefficientDir
        wavelengthData=np.loadtxt(directory+Grey40WavelengthSensitivityCoefficients)
        thetaDData=np.loadtxt(directory+Grey40ThetaDSensitivityCoefficients)
        thetaIData=np.loadtxt(directory+Grey40ThetaISensitivityCoefficients)
    elif Sample=='MSL Grey 5%':
        directory=S7SampleSensitivityCoefficientDir
        wavelengthData=np.loadtxt(directory+Grey5WavelengthSensitivityCoefficients)
        thetaDData=np.loadtxt(directory+Grey5ThetaDSensitivityCoefficients)
        thetaIData=np.loadtxt(directory+Grey5ThetaISensitivityCoefficients)
    elif Sample=='S6-II':
        directory=S7SampleSensitivityCoefficientDir
        wavelengthData=np.loadtxt(directory+S6IIWavelengthSensitivityCoefficients)
        thetaDData=np.loadtxt(directory+S6IIThetaDSensitivityCoefficients)
        thetaIData=np.loadtxt(directory+S6IIThetaISensitivityCoefficients)
    elif Sample=='S6-III':
        directory=S7SampleSensitivityCoefficientDir
        wavelengthData=np.loadtxt(directory+S6IIIWavelengthSensitivityCoefficients)
        thetaDData=np.loadtxt(directory+S6IIIThetaDSensitivityCoefficients)
        thetaIData=np.loadtxt(directory+S6IIIThetaISensitivityCoefficients)

    # Save wavelength sensitivity - one value for each wavelength
    nWavelengths=wavelengthData.shape[0]
    wavelengthSensitivity=np.array([np.array([0,ureal(0,0)]) for i in range(0,nWavelengths)])
    for w in range(0,nWavelengths):
        wavelengthSensitivity[w,0]=wavelengthData[w,0]
        wavelengthSensitivity[w,1]=ureal(wavelengthData[w,1],wavelengthData[w,2],df=wavelengthData[w,3],
                                    label='Wavelength sensitivity coefficient, '+str(round(wavelengthData[w,0]))+' nm')

    # Save thetaD sensitivity - one value for each theta
    nThetaD=thetaDData.shape[0]
    thetaDSensitivity=np.array([np.array([0,ureal(0,0)]) for i in range(0,nThetaD)])
    for t in range(0,nThetaD):
        thetaDSensitivity[t,0]=thetaDData[t,0]
        thetaDSensitivity[t,1]=ureal(thetaDData[t,1],thetaDData[t,2],df=thetaDData[t,3],
                                    label='Theta d sensitivity coefficient, '+str(round(thetaDData[t,0]))+' degrees')

    # Save thetaI sensitivity - one value for each sample
    thetaISensitivity=ureal(thetaIData[0],thetaIData[1],df=thetaIData[2],label='Theta i sensitivity coefficient')

    return [wavelengthSensitivity,thetaDSensitivity,thetaISensitivity]


def IncludeWavelengthSensitivity(NWavelengths,NTheta,NPhi,Wavelengths,Flux,WavelengthSensitivity,Source):
    if Source=='LDLS':
        uWavelength=uWavelengthLDLS
        dfWavelength=dfWavelengthLDLS
    else:
        uWavelength=uWavelengthSuperK
        dfWavelength=dfWavelengthSuperK
    for pol in range(0,2):
        for w in range(0,NWavelengths):
            # treat wavelength error as independent every time monochromator moves
            EWavelength=ureal(0,uWavelength,df=dfWavelength,label="Wavelength")
            # treat wavelength sensitivity error as correlated - same sensitivity with same error whenever at a particular wavelength
            if Wavelengths[w]>440:
                # for wavelengths above 440 nm, set sensitivity coefficient to zero with uncertainty from initialise errors
                wSensitivity=ureal(0,WavelengthSensitivityU,df=WavelengthSensitivityDF,label='Wavelength sensitivity coefficient')
            else:
                # otherwise use measured sensitivity coefficient
                ind=int(np.where(WavelengthSensitivity[:,0]==Wavelengths[w])[0])
                wSensitivity=WavelengthSensitivity[ind,1]
            for t in range(0,NTheta):
                for p in range(0,NPhi):
                    Flux[w,pol,t,p]=Flux[w,pol,t,p]*(1-fn.mul2(wSensitivity,EWavelength))
    return Flux


def IncludeThetaDSensitivity(NWavelengths,NTheta,NPhi,Thetas,Flux,ThetaDSensitivity):
    for pol in range(0,2):
        for w in range(0,NWavelengths):
            for t in range(0,NTheta):
                # td sensitivity is correlated - every time at same td, get same sensitivity and same sensitivity error
                tdSensitivity=ThetaDSensitivity[t,1]
                for p in range(0,NPhi):
                    # error in td is td.x-td, convert to degrees since sensitivity coefficients in per degree
                    thisT=Thetas[w,pol,t,p]
                    EthisT=(thisT.x-thisT)*180/np.pi
                    Flux[w,pol,t,p]=Flux[w,pol,t,p]*(1-fn.mul2(tdSensitivity,EthisT))
    return Flux


def IncludeThetaISensitivity(NWavelengths,NTheta,NPhi,ThetaI,Flux,ThetaISensitivity):
    # ti sensitivity is a single value - independent of wavelength and td etc
    for w in range(0,NWavelengths):
        for pol in range(0,2):
            for t in range(0,NTheta):
                for p in range(0,NPhi):
                    # error in ti is ti.x-ti, convert to degrees since sensitivity coefficients in per degree
                    ti=ThetaI[w,pol,t,p]
                    Eti=(ti.x-ti)*180/np.pi
                    Flux[w,pol,t,p]=Flux[w,pol,t,p]*(1-fn.mul2(ThetaISensitivity,Eti))
    return Flux