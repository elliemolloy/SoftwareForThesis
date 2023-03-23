from GonioAnalysis.Calculations import *
from GonioAnalysis.Corrections import *
from GonioAnalysis.Rotations import *
from GonioAnalysis.SensitivityCoefficients import *
from GonioAnalysis.WriteUncertaintyBudget import *
from GonioAnalysis.WriteOutput import *

WavelengthsS=[460,480,530,580,630,680,730,780,830]
ThetaAll=np.arange(5,81,5)
PhiAll=np.arange(0,360,45)
NWavelengths=9
NTheta=16
NPhi=8
GainDifference=100
Directory="G:\Shared drives\MSL - Photometry & Radiometry\STANDARDS\GonioSpectrometry\K5 Comparison 2020\Measurements\\"
Source='Supercontinuum'

def CalculateDiffR(Wavelengths,Source,Directory,SRef,PRef,SData,PData,BothRef,Aperture):
    aperture17=(Aperture=='17')
    nTheta=16
    nPhi=8
    nWavelengths=len(Wavelengths)
    [sRef,pRef,allData]=ReadData(nWavelengths,Directory,Source,SRef,PRef,SData,PData,BothRef=BothRef)
    refSignal=CalculateRefSignal(nWavelengths,sRef,pRef,Plot=False)
    [signal,signal180,detSignal,detSignal180,monSignal,monSignal180]=CalculateSignal(nWavelengths,nTheta,nPhi,allData,Plot=False)
    [length,length180,thetaD,thetaD180,thetaI]=ApplyRotations(nWavelengths,nTheta,nPhi,allData,Aperture17=aperture17)
    signal=SortData(nWavelengths,nTheta,signal,SortPhi=True)
    thetaD=SortData(nWavelengths,nTheta,thetaD,SortPhi=True)
    length=SortData(nWavelengths,nTheta,length,SortPhi=True)
    signal180=SortData(nWavelengths,nTheta,signal180,Sort180=True)
    [flux,flux180]=CalculatePhi(nWavelengths,nTheta,nPhi,signal,signal180,refSignal)
    brdf=CalculateBRDF(length,flux,thetaD,Aperture17=aperture17)
    brdfTi=IncludeThetaISensitivity(nWavelengths,nTheta,nPhi,thetaI,brdf,thetaISensitivity)
    brdfWavelength=IncludeWavelengthSensitivity(nWavelengths,nTheta,nPhi,Wavelengths,brdfTi,wavelengthSensitivity)
    brdfTd=IncludeThetaDSensitivity(nWavelengths,nTheta,nPhi,thetaD,brdfWavelength,thetaDSensitivity)
    avgBRDFPhi=AveragePhi(nWavelengths,nTheta,nPhi,brdfTd)
    avgThetaPhi=AveragePhi(nWavelengths,nTheta,nPhi,thetaD)
    avgTheta=AveragePol(nWavelengths,nTheta,avgThetaPhi)
    solidAngle=M17**2/(4*length**2)
    solidAngle=AveragePhi(nWavelengths,nTheta,nPhi,solidAngle)
    vfBRDF=ApplyViewFactorCorrection(Source,solidAngle,avgBRDFPhi,Aperture17=aperture17)
    detBRDF=ApplyDetectorUniformityCorrection(Source,vfBRDF,Aperture17=aperture17)
    avgBRDFdet=AveragePol(nWavelengths,nTheta,detBRDF)
    avgBRDFstrayLight=ApplyStrayLightCorrection(Wavelengths,avgBRDFdet)
    avgBRDFnoSample=ApplyNoSampleCorrection(nWavelengths,nTheta,Source,avgBRDFstrayLight)
    BRDFDataCorrected=la.uarray([la.uarray([la.uarray([ureal(0,0),ureal(0,0)])for i in range(0,nTheta)])for j in range(0,nWavelengths)])
    BRDFDataCorrected[:,:,0]=avgBRDFnoSample
    BRDFDataCorrected[:,:,1]=avgTheta
    diffR=CalculateRF(nWavelengths,nTheta,BRDFDataCorrected,IntegrationMethod='Lagrange')
    return diffR

samples={'P15':['K5 P15\\17 mm Aperture\\Supercontinuum November\\',['REF__000453_.csv','REF__000454_.csv'],'BSDF_000453a.csv',['REF__000442_.csv','REF__000443_.csv'],'BSDF_000442a.csv',
                'K5 P15\\30 mm Aperture\\Supercontinuum October\\',['REF__000405_.csv','REF__000406_.csv'],'BSDF_000405a.csv',['REF__000420_.csv','REF__000421_.csv'],'BSDF_000420a.csv',
                'K5 P15\\30 mm Aperture\\Supercontinuum August\\',['REF__000324_.csv','REF__000325_.csv'],'BSDF_000324a.csv',['REF__000335_.csv','REF__000336_.csv'],'BSDF_000335a.csv']}

# Create Excel file to write results in
wb=xlsxwriter.Workbook('P15 Supercontinuum.xlsx')
SaveErrors(wb)

for sample in samples:
    sampleData=samples[sample]
    Directory17=Directory+sampleData[0]
    sRefFiles17=sampleData[1]
    sDataFile17=sampleData[2]
    pRefFiles17=sampleData[3]
    pDataFile17=sampleData[4]
    Directory30=Directory+sampleData[5]
    sRefFiles30=sampleData[6]
    sDataFile30=sampleData[7]
    pRefFiles30=sampleData[8]
    pDataFile30=sampleData[9]
    Directory302=Directory+sampleData[10]
    sRefFiles302=sampleData[11]
    sDataFile302=sampleData[12]
    pRefFiles302=sampleData[13]
    pDataFile302=sampleData[14]

    # Save input file names in output file
    SaveInputFiles(wb,sampleData)

    # Read in sensitivity coefficient data
    [wavelengthSensitivity,thetaDSensitivity,thetaISensitivity]=ReadSensitivityCoefficients('Fluorilon')

    # 17 mm calculations


    # Save BRDF values before and after correction and diffR
    SaveBRDFvalues(wb,brdf,WavelengthsS,Averaged=False,SheetName='BRDF Values',Title='17 mm BRDF Values')
    SaveBRDFvalues(wb,avgBRDFnoSample,WavelengthsS,Averaged=True,SheetName='Corrected BRDF',Title='17 mm Corrected BRDF')
    SaveDiffR(wb,RFLagrangeCorrected17,WavelengthsS,SheetName='17 mm DiffR',Title='17 mm DiffR')

    # 30 mm October calculation
    [sRef,pRef,allData]=ReadData(NWavelengths,Directory30,Source,sRefFiles30,pRefFiles30,sDataFile30,pDataFile30,BothRef=False)
    refSignal=CalculateRefSignal(NWavelengths,sRef,pRef,Plot=False)
    [signal,signal180,detSignal,detSignal180,monSignal,monSignal180]=CalculateSignal(NWavelengths,NTheta,NPhi,allData,Plot=False)
    [length,length180,thetaD,thetaD180,thetaI]=ApplyRotations(NWavelengths,NTheta,NPhi,allData,Aperture17=False)
    signal=SortData(NWavelengths,NTheta,signal,SortPhi=True)
    detSignal=SortData(NWavelengths,NTheta,detSignal,SortPhi=True)
    monSignal=SortData(NWavelengths,NTheta,monSignal,SortPhi=True)
    thetaD=SortData(NWavelengths,NTheta,thetaD,SortPhi=True)
    length=SortData(NWavelengths,NTheta,length,SortPhi=True)
    signal180=SortData(NWavelengths,NTheta,signal180,Sort180=True)
    detSignal180=SortData(NWavelengths,NTheta,detSignal180,Sort180=True)
    monSignal180=SortData(NWavelengths,NTheta,monSignal180,Sort180=True)
    length180=SortData(NWavelengths,NTheta,length180,Sort180=True)
    thetaD180=SortData(NWavelengths,NTheta,thetaD180,Sort180=True)
    [flux,flux180]=CalculatePhi(NWavelengths,NTheta,NPhi,signal,signal180,refSignal)
    brdf=CalculateBRDF(length,flux,thetaD,Aperture17=False)
    brdfTi=IncludeThetaISensitivity(NWavelengths,NTheta,NPhi,thetaI,brdf,thetaISensitivity)
    brdfWavelength=IncludeWavelengthSensitivity(NWavelengths,NTheta,NPhi,WavelengthsS,brdfTi,wavelengthSensitivity)
    brdfTd=IncludeThetaDSensitivity(NWavelengths,NTheta,NPhi,thetaD,brdfWavelength,thetaDSensitivity)
    avgBRDFPhi=AveragePhi(NWavelengths,NTheta,NPhi,brdfTd)
    avgThetaPhi=AveragePhi(NWavelengths,NTheta,NPhi,thetaD)
    avgTheta=AveragePol(NWavelengths,NTheta,avgThetaPhi)
    solidAngle=M**2/(4*length**2)
    solidAngle=AveragePhi(NWavelengths,NTheta,NPhi,solidAngle)
    vfBRDF=ApplyViewFactorCorrection(Source,solidAngle,avgBRDFPhi,Aperture17=False)
    detBRDF=ApplyDetectorUniformityCorrection(Source,vfBRDF,Aperture17=False)
    avgBRDFdet=AveragePol(NWavelengths,NTheta,detBRDF)
    avgBRDFstrayLight=ApplyStrayLightCorrection(WavelengthsS,avgBRDFdet)
    avgBRDFnoSample=ApplyNoSampleCorrection(NWavelengths,NTheta,Source,avgBRDFstrayLight)
    BRDFDataCorrected=la.uarray([la.uarray([la.uarray([ureal(0,0),ureal(0,0)])for i in range(0,NTheta)])for j in range(0,NWavelengths)])
    BRDFDataCorrected[:,:,0]=avgBRDFnoSample
    BRDFDataCorrected[:,:,1]=avgTheta
    RFLagrangeCorrected30=CalculateRF(NWavelengths,NTheta,BRDFDataCorrected,IntegrationMethod='Lagrange')

    # Save BRDF values before and after correction and diffR
    SaveBRDFvalues(wb,brdf,WavelengthsS,Averaged=False,SheetName='BRDF Values 2',Title='30 mm October BRDF Values')
    SaveBRDFvalues(wb,avgBRDFnoSample,WavelengthsS,Averaged=True,SheetName='Corrected BRDF 2',Title='30 mm October Corrected BRDF')
    SaveDiffR(wb,RFLagrangeCorrected30,WavelengthsS,SheetName='30 mm DiffR',Title='30 mm October DiffR')

    # 30 mm August calculation
    [sRef,pRef,allData]=ReadData(NWavelengths,Directory302,Source,sRefFiles302,pRefFiles302,sDataFile302,pDataFile302,BothRef=False)
    refSignal=CalculateRefSignal(NWavelengths,sRef,pRef,Plot=False)
    [signal,signal180,detSignal,detSignal180,monSignal,monSignal180]=CalculateSignal(NWavelengths,NTheta,NPhi,allData,Plot=False)
    [length,length180,thetaD,thetaD180,thetaI]=ApplyRotations(NWavelengths,NTheta,NPhi,allData,Aperture17=False)
    signal=SortData(NWavelengths,NTheta,signal,SortPhi=True)
    detSignal=SortData(NWavelengths,NTheta,detSignal,SortPhi=True)
    monSignal=SortData(NWavelengths,NTheta,monSignal,SortPhi=True)
    thetaD=SortData(NWavelengths,NTheta,thetaD,SortPhi=True)
    length=SortData(NWavelengths,NTheta,length,SortPhi=True)
    signal180=SortData(NWavelengths,NTheta,signal180,Sort180=True)
    detSignal180=SortData(NWavelengths,NTheta,detSignal180,Sort180=True)
    monSignal180=SortData(NWavelengths,NTheta,monSignal180,Sort180=True)
    length180=SortData(NWavelengths,NTheta,length180,Sort180=True)
    thetaD180=SortData(NWavelengths,NTheta,thetaD180,Sort180=True)
    [flux,flux180]=CalculatePhi(NWavelengths,NTheta,NPhi,signal,signal180,refSignal)
    brdf=CalculateBRDF(length,flux,thetaD,Aperture17=False)
    brdfTi=IncludeThetaISensitivity(NWavelengths,NTheta,NPhi,thetaI,brdf,thetaISensitivity)
    brdfWavelength=IncludeWavelengthSensitivity(NWavelengths,NTheta,NPhi,WavelengthsS,brdfTi,wavelengthSensitivity)
    brdfTd=IncludeThetaDSensitivity(NWavelengths,NTheta,NPhi,thetaD,brdfWavelength,thetaDSensitivity)
    avgBRDFPhi=AveragePhi(NWavelengths,NTheta,NPhi,brdfTd)
    avgThetaPhi=AveragePhi(NWavelengths,NTheta,NPhi,thetaD)
    avgTheta=AveragePol(NWavelengths,NTheta,avgThetaPhi)
    solidAngle=M**2/(4*length**2)
    solidAngle=AveragePhi(NWavelengths,NTheta,NPhi,solidAngle)
    vfBRDF=ApplyViewFactorCorrection(Source,solidAngle,avgBRDFPhi,Aperture17=False)
    detBRDF=ApplyDetectorUniformityCorrection('Supercontinuum',vfBRDF,Aperture17=False)
    avgBRDFdet=AveragePol(NWavelengths,NTheta,detBRDF)
    avgBRDFstrayLight=ApplyStrayLightCorrection(WavelengthsS,avgBRDFdet)
    avgBRDFnoSample=ApplyNoSampleCorrection(NWavelengths,NTheta,Source,avgBRDFstrayLight)
    BRDFDataCorrected=la.uarray([la.uarray([la.uarray([ureal(0,0),ureal(0,0)])for i in range(0,NTheta)])for j in range(0,NWavelengths)])
    BRDFDataCorrected[:,:,0]=avgBRDFnoSample
    BRDFDataCorrected[:,:,1]=avgTheta
    RFLagrangeCorrected302=CalculateRF(NWavelengths,NTheta,BRDFDataCorrected,IntegrationMethod='Lagrange')

    # Save BRDF values before and after correction and diffR
    SaveBRDFvalues(wb,brdf,WavelengthsS,Averaged=False,SheetName='BRDF Values 3',Title='30 mm August BRDF Values')
    SaveBRDFvalues(wb,avgBRDFnoSample,WavelengthsS,Averaged=True,SheetName='Corrected BRDF 3',Title='30 mm August Corrected BRDF')
    SaveDiffR(wb,RFLagrangeCorrected302,WavelengthsS,SheetName='30 mm DiffR 2',Title='30 mm August DiffR')

    avg=(RFLagrangeCorrected30+RFLagrangeCorrected302+RFLagrangeCorrected17)/3
    weightedAvg=(RFLagrangeCorrected30/RFLagrangeCorrected30.u**2+RFLagrangeCorrected302/RFLagrangeCorrected302.u**2+RFLagrangeCorrected17/RFLagrangeCorrected17.u**2)/(1/RFLagrangeCorrected30.u**2+1/RFLagrangeCorrected302.u**2+1/RFLagrangeCorrected17.u**2)

    print(sample,'30 mm October: ',RFLagrangeCorrected30)
    print(sample,'30 mm August: ',RFLagrangeCorrected302)
    print(sample,'17 mm: ',RFLagrangeCorrected17)
    print(sample,'Average: ',avg)
    print(sample,'Weighted Average: ',weightedAvg)

    # print(sample,'Uncertainty Budget: ')
    # PrintUncertaintyBudget(NWavelengths,weightedAvg)

    # Save weighted average and uncertainty budget, then close file
    SaveDiffR(wb,weightedAvg,WavelengthsS,SheetName='Weighted Avg',Title='DiffR Weighted Average')
    SaveUncertaintyBudget(wb,weightedAvg,WavelengthsS,SheetName='Uncertainty Budget',Title='Uncertainty budget for weighted average diffR')
    wb.close()