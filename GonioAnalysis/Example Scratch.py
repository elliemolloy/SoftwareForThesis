from GonioAnalysis.Calculations import *
from GonioAnalysis.Corrections import *
from GonioAnalysis.Rotations import *

Wavelengths=[360,380,400,420,440,460,480]
ThetaAll=np.arange(5,81,5)
PhiAll=np.arange(0,360,45)
NWavelengths=7
NTheta=16
NPhi=8

Directory30=r'G:\Shared drives\MSL - Photometry & Radiometry\STANDARDS\GonioSpectrometry\K5 Comparison 2020\Measurements\PTB 44341\30 mm Aperture\LDLS May 2021\\'
Source='LDLS'
sRefFiles30=['REF__000584_.csv', 'REF__000585_.csv']
dataFile30='BSDF_000584a.csv'

[sRef,pRef,allData]=ReadData(NWavelengths,Directory30,Source,sRefFiles30,sRefFiles30,dataFile30,BothRef=True)
refSignal=CalculateRefSignal(NWavelengths,sRef,pRef,Plot=False)
[signal,signal180,detSignal,detSignal180,monSignal,monSignal180]=CalculateSignal(NWavelengths,NTheta,NPhi,allData,Plot=False)
[length,length180,thetaD,thetaD180,thetaI]=ApplyRotations(NWavelengths,NTheta,NPhi,allData,Aperture17=False)
signal=SortData(NWavelengths,NTheta,signal,SortPhi=True)
detSignal=SortData(NWavelengths,NTheta,detSignal,SortPhi=True)
monSignal=SortData(NWavelengths,NTheta,monSignal,SortPhi=True)
thetaD=SortData(NWavelengths,NTheta,thetaD,SortPhi=True)
length=SortData(NWavelengths,NTheta,length,SortPhi=True)
signal180=SortData(NWavelengths,NTheta,signal180,Sort180=True)
length180=SortData(NWavelengths,NTheta,length180,Sort180=True)
thetaD180=SortData(NWavelengths,NTheta,thetaD180,Sort180=True)
[flux,flux180]=CalculatePhi(NWavelengths,NTheta,NPhi,signal,signal180,refSignal)
brdf=CalculateBRDF(length,flux,thetaD,Aperture17=False)
avgBRDFPhi=AveragePhi(NWavelengths,NTheta,NPhi,brdf)
solidAngle=M**2/(4*length**2)
solidAngle=AveragePhi(NWavelengths,NTheta,NPhi,solidAngle)
vfBRDF=ApplyViewFactorCorrection(Source,solidAngle,avgBRDFPhi,Aperture17=False)
detBRDF=ApplyDetectorUniformityCorrection('LDLS',vfBRDF,Aperture17=False)
avgBRDFdet=AveragePol(NWavelengths,NTheta,detBRDF)
avgBRDFstrayLight=ApplyStrayLightCorrection(Wavelengths,avgBRDFdet)
BRDF=ApplyNoSampleCorrection(NWavelengths,NTheta,Source,avgBRDFstrayLight)

print(BRDF)