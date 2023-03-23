import csv
import numpy as np
from GonioAnalysis.InitialiseErrorsK5 import *

"""
Functions in this file:
    CreateUArray(NWavelengths,NTheta,NPhi)
    FindDataRow(File)
    ReadRefFiles(RefFiles)
    ReadBothRefFiles(RefFiles)
    ReadData(Directory,Source,SRef,PRef,SData,PData=None,BothRef=False)
    SortData(NWavelengths,NTheta,Array,SortPhi=False,Sort180=False,Backwards=False)
    CalculateWeights(Values)
    AveragePhi(BRDF)
    AveragePol(AvgPhi)
"""


def CreateUArray(NWavelengths,NTheta,NPhi):
    """
    Creates array of uncertain numbers of given size
    """
    uArray=la.uarray([la.uarray([la.uarray([la.uarray([ureal(0,0) for i in range(0,NPhi)]) for j in range(0,NTheta)]) for k in range(0,2)]) for l in range(0,NWavelengths)])
    return uArray


def FindDataRow(File):
    """
    Find row in data file which contains the first measurement (so we ignore all the headers and can add more information
     to the headers without having to change the number of rows we skip. Returns the number of rows needed to be skipped
     to get straight to the data by looking for the row with a 1 in the first column (maybe it would be better to look
     for the headings?)
    :param File:String
    :return:int
    """
    with open(File,'r') as readObj:
        csvReader=csv.reader(readObj)
        header=next(csvReader)
        skipRows = 0
        i=0
        if header!=None:
            for row in csvReader:
                i+=1
                if not (row):
                    continue
                if row[0]=='1':
                    skipRows=i
                    break
    return skipRows


def ReadRefFiles(RefFiles, NWavelengths, Directory):
    """
    Reads in all the reference files (given to it in a list). Reads the wavelength, detector voltage, u(detector),
    detector dark, u(detector dark), monitor voltage, u(monitor), monitor dark, u(monitor dark). Puts the averages and
    standard deviations in uncertain arrays and calculates the averages from all the reference files given to it.
    :param RefFiles:array of strings
    :return:np array
    """
    n=len(RefFiles)
    refCols=(1,3,4,5,6,7,8,9,10)
    refFile=la.uarray([la.uarray([[0,ureal(0,0),ureal(0,0),ureal(0,0),ureal(0,0)] for j in range(0,NWavelengths)]) for i in range(0,n)])

    # Save all the measurements as uncertain numbers
    for i in range(0,n):
        file=RefFiles[i]
        thisFile=np.loadtxt(Directory+file,skiprows=FindDataRow(Directory+file),delimiter=',',usecols=refCols)

        if NWavelengths==1:
            # Add second dimension to thisFile if there is only one wavelength
            thisFile=np.array([thisFile])

        for j in range(0,NWavelengths):
            # Save detector and monitor values
            refFile[i,j,0]=thisFile[j,0]
            refFile[i,j,1]=ureal(thisFile[j,1],thisFile[j,2],df=9,label='Detector Ref Noise')
            refFile[i,j,3]=ureal(thisFile[j,5],thisFile[j,6],df=9,label='Monitor Ref Noise')
            refFile[i,0,2]=ureal(DetectorDark7.x,DetectorDark7.u,DetectorDark7.df,label='Detector dark')
            refFile[i,0,4]=ureal(MonitorDark.x,MonitorDark.u,MonitorDark.df,label='Monitor dark')

    return refFile


def ReadBothRefFiles(RefFiles,NWavelengths,Directory,PFirst=False):
    """
    Reads ref data from one file
    :param RefFiles: string
    :return: np array of reference data
    """
    n=len(RefFiles)
    refCols=(1,3,4,5,6,7,8,9,10)
    refFileS=la.uarray([la.uarray([[0,ureal(0,0),ureal(0,0),ureal(0,0),ureal(0,0)] for j in range(0,NWavelengths)]) for i in range(0,n)])
    refFileP=la.uarray([la.uarray([[0,ureal(0,0),ureal(0,0),ureal(0,0),ureal(0,0)] for j in range(0,NWavelengths)]) for i in range(0,n)])

    # Save all the measurements as uncertain numbers
    for i in range(0,n):
        file=RefFiles[i]
        thisFile=np.loadtxt(Directory+file,skiprows=FindDataRow(Directory+file),delimiter=',',usecols=refCols)
        refFileS[i,:,0]=thisFile[0:NWavelengths,0]
        refFileP[i,:,0]=thisFile[NWavelengths:2*NWavelengths,0]

        for j in range(0, NWavelengths):
            # Save detector and monitor values
            refFileS[i,j,1]=ureal(thisFile[j,1],thisFile[j,2],df=9,label='Detector Ref Noise')
            refFileS[i,j,3]=ureal(thisFile[j,5],thisFile[j,6],df=9,label='Monitor Ref Noise')
            refFileP[i,j,1]=ureal(thisFile[j+NWavelengths,1],thisFile[j+NWavelengths,2],df=9,label='Detector Ref Noise')
            refFileP[i,j,3]=ureal(thisFile[j+NWavelengths,5],thisFile[j+NWavelengths,6],df=9,label='Monitor Ref Noise')

            refFileS[i,j,2]=ureal(DetectorDark7.x,DetectorDark7.u,DetectorDark7.df,label='Detector dark')
            refFileP[i,j,2]=ureal(DetectorDark7.x,DetectorDark7.u,DetectorDark7.df,label='Detector dark')
            refFileS[i,j,4]=ureal(MonitorDark.x,MonitorDark.u,MonitorDark.df,label='Monitor dark')
            refFileP[i,j,4]=ureal(MonitorDark.x,MonitorDark.u,MonitorDark.df,label='Monitor dark')

    if PFirst: # if p first, then swap the order of the s,p references when returning
        toReturn=[refFileP,refFileS]
    else:
        toReturn=[refFileS,refFileP]

    return toReturn


def ReadData(NWavelengths,Directory,Source,SRef,PRef,SData,PData=None,BothRef=False,PFirst=False):
    """
    Reads in the data file(s): if the source is supercontinuum and PData is given, it looks for both SData and PData,
    otherwise it only looks at SData and assumes that this has all the measurements. Calls the above function to read in
    the reference files, and also reads the data files. From the data files, it reads the wavelength, pitch, yaw, roll,
    detector angle, polariser angle, detector voltage, u(detector), detector dark, u(detector dark), monitor voltage,
    u(monitor), monitor dark, u(monitor dark). The data is stored in an array with one row for each measurement (so
    allData has lots of rows).
    :param Directory:string giving the working directory
    :param Source:string saying if it's 'LDLS' or 'Supercontinuum'
    :param SRef:string with S reference data file
    :param PRef:string with P reference data file
    :param SData:string with S sample data file
    :param PData:string with P sample data file (if the source is Supercontinuum)
    :param BothRef:Boolean, True if both references are in one file
    :return: np arrays with s reference data, p reference data, all measurement data
    """
    try:
        dataCols=(2,11,12,13,14,15,16,17,18,19,20,21,22,23,26,1)
        if BothRef:
            sRef,pRef=ReadBothRefFiles(SRef,NWavelengths,Directory,PFirst=PFirst)
        else:
            sRef=ReadRefFiles(SRef,NWavelengths,Directory)
            pRef=ReadRefFiles(PRef,NWavelengths,Directory)
        if Source=='Supercontinuum' and PData:
            sData=np.loadtxt(Directory+SData,skiprows=FindDataRow(Directory+SData),delimiter=',',usecols=dataCols)
            pData=np.loadtxt(Directory+PData,skiprows=FindDataRow(Directory+PData),delimiter=',',usecols=dataCols)
            allData=np.concatenate((sData,pData),axis=0)
        else:
            allData=np.loadtxt(Directory+SData,skiprows=FindDataRow(Directory+SData),delimiter=',',usecols=dataCols)
    except IndexError:
        dataCols=(2,11,12,13,14,15,16,17,18,19,20,21,22,23,25,1)
        if BothRef:
            sRef,pRef=ReadBothRefFiles(SRef,NWavelengths,Directory,PFirst=PFirst)
        else:
            sRef=ReadRefFiles(SRef,NWavelengths,Directory)
            pRef=ReadRefFiles(PRef,NWavelengths,Directory)
        if Source=='Supercontinuum' and PData:
            sData=np.loadtxt(Directory+SData,skiprows=FindDataRow(Directory+SData),delimiter=',',usecols=dataCols)
            pData=np.loadtxt(Directory+PData,skiprows=FindDataRow(Directory+PData),delimiter=',',usecols=dataCols)
            allData=np.concatenate((sData,pData),axis=0)
        else:
            allData=np.loadtxt(Directory+SData,skiprows=FindDataRow(Directory+SData),delimiter=',',usecols=dataCols)
    except ValueError:
        dataCols=(2,11,12,13,14,15,16,17,18,19,20,21,22,23,25)
        if BothRef:
            sRef,pRef=ReadBothRefFiles(SRef,NWavelengths,Directory,PFirst=PFirst)
        else:
            sRef=ReadRefFiles(SRef,NWavelengths,Directory)
            pRef=ReadRefFiles(PRef,NWavelengths,Directory)
        if Source=='Supercontinuum' and PData:
            sData=np.loadtxt(Directory+SData,skiprows=FindDataRow(Directory+SData),delimiter=',',usecols=dataCols)
            pData=np.loadtxt(Directory+PData,skiprows=FindDataRow(Directory+PData),delimiter=',',usecols=dataCols)
            allData=np.concatenate((sData,pData),axis=0)
        else:
            allData=np.loadtxt(Directory+SData,skiprows=FindDataRow(Directory+SData),delimiter=',',usecols=dataCols)
    return [sRef,pRef,allData]


def SortData(NWavelengths,NTheta,DataArray,SortPhi=False,Sort180=False,Backwards=False):
    """
    Sort the data into a big multidimensional matrix, with the measurements ordered by theta and phi
    :param DataArray:
    :param SortPhi:
    :param Sort180:
    :param Backwards:
    :return:
    """
    if Sort180:
        if Backwards:
            thetaInd=[13,6,12,5,11,4,10,3,9,2,8,1,7,0]
        else:
            thetaInd=[13,0,12,1,11,2,10,3,9,4,8,5,7,6]
        SortPhi=False
    else:
        if Backwards:
            thetaInd=[7,15,6,14,5,13,4,12,3,11,2,10,1,9,0,8]
        else:
            thetaInd=[0,8,1,9,2,10,3,11,4,12,5,13,6,14,7,15]
        phiInd1=[0,7,6,5,4,3,2,1]
        phiInd2=[4,3,2,1,0,7,6,5]
    if SortPhi:
        for pol in range(0,2):
            for w in range(0,NWavelengths):
                for t in range(0,NTheta):
                    if t<8:
                        DataArray[w,pol,t,:]=DataArray[w,pol,t,:][phiInd1]
                    else:
                        DataArray[w,pol,t,:]=DataArray[w,pol,t,:][phiInd2]
    for pol in range(0,2):
        for w in range(0,NWavelengths):
            DataArray[w,pol,:,:]=DataArray[w,pol,:,:][thetaInd,:]
    return DataArray


def CalculateWeights(Values):
    # Calculate the weights needed to calculate weighted average of all elements in Values using the
    # GLS weighted mean formula
    n=len(Values)
    covarianceMatrix=np.zeros((n,n))
    for i in range(0,n):
        for j in range(0,n):
            covarianceMatrix[i,j]=get_covariance(Values[i],Values[j])
    covMatrixInv=np.linalg.inv(covarianceMatrix)
    one=np.ones((n,1))
    a=1/(np.matmul(np.matmul(one.T,covMatrixInv),one))
    b=np.matmul(one.T,covMatrixInv)
    weights=np.matmul(a,b)
    return weights[0,:]


def AveragePhi(NWavelengths,NTheta,NPhi,BRDF,AveragingBRDF=False,WeightedMean=False):
    """
    Average the BRDF by phi
    :param BRDF:
    :return:
    """
    AvgPhi=la.uarray([la.uarray([la.uarray([ureal(0,0) for i in range(0,2)]) for j in range(0,NTheta)]) for k in range(0,NWavelengths)])
    if WeightedMean:
        for w in range(0,NWavelengths):
            for t in range(0,NTheta):
                for pol in range(0,2):
                    weights=CalculateWeights(BRDF[w,pol,t,:])
                    AvgPhi[w,t,pol]=sum(weights*BRDF[w,pol,t,:])
                    if AveragingBRDF:
                        # If we are averaging BRDF over phi, then include the sample non-isotropy error
                        phiStdev=0
                        for i in range(0,NPhi):
                            phiStdev+=(BRDF[w,pol,t,i]-AvgPhi[w,t,pol])**2
                        phiStdev=np.sqrt(phiStdev.x/(NPhi*(NPhi-1)))
                        ESampleNonIsotropy=ureal(0,phiStdev,df=7,label='Non-isotropy of sample')
                        AvgPhi[w,t,pol]=AvgPhi[w,t,pol]-ESampleNonIsotropy
    else:
        for w in range(0,NWavelengths):
            for t in range(0,NTheta):
                for pol in range(0,2):
                    # Find average and standard deviation of the dark readings
                    AvgPhi[w,t,pol]=sum(BRDF[w,pol,t,:])/NPhi
                    if AveragingBRDF:
                        # If we are averaging BRDF over phi, then include the sample non-isotropy error
                        phiStdev=0
                        for i in range(0,NPhi):
                            phiStdev+=(BRDF[w,pol,t,i]-AvgPhi[w,t,pol])**2
                        phiStdev=np.sqrt(phiStdev.x/(NPhi*(NPhi-1)))
                        ESampleNonIsotropy=ureal(0,phiStdev,df=7,label='Non-isotropy of sample')
                        AvgPhi[w,t,pol]=AvgPhi[w,t,pol]-ESampleNonIsotropy
    return AvgPhi


def AveragePol(NWavelengths,NTheta,AvgPhi,WeightedMean=False):
    """
    Average the two polarisations
    :param AvgPhi:
    :return:
    """
    AvgBRDF=la.uarray([la.uarray([ureal(0,0) for i in range(0,NTheta)]) for j in range(0,NWavelengths)])
    if WeightedMean:
        for w in range(0,NWavelengths):
            for t in range(0,NTheta):
                weights=CalculateWeights(AvgPhi[w,t,:])
                AvgBRDF[w,t]=sum(weights*AvgPhi[w,t,:])
    else:
        for w in range(0,NWavelengths):
            for t in range(0,NTheta):
                AvgBRDF[w,t]=sum(AvgPhi[w,t,:])/2
    return AvgBRDF