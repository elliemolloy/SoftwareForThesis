import csv
import numpy as np
from GTC import *
import matplotlib.pyplot as plt
from GonioAnalysis.InitialiseErrorsK5 import *

def Test():
    print('yes it works')
    a=DeltaPy
    return a


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

def ReadRefFiles(RefFiles):
    """
    Reads in all the reference files (given to it in a list). Reads the wavelength, detector voltage, u(detector),
    detector dark, u(detector dark), monitor voltage, u(monitor), monitor dark, u(monitor dark). Puts the averages and
    standard deviations in uncertain arrays and calculates the averages from all the reference files given to it.
    :param RefFiles:array of strings
    :return:np array
    """
    n = len(RefFiles)
    refCols = (1, 3, 4, 5, 6, 7, 8, 9, 10)
    refFile = la.uarray(
        [la.uarray([[0, ureal(0, 0), ureal(0, 0), ureal(0, 0), ureal(0, 0)] for j in range(0, NWavelengths)])
         for i in range(0, n)])
    refData = la.uarray([[0, ureal(0, 0), ureal(0, 0), ureal(0, 0), ureal(0, 0)] for j in range(0, NWavelengths)])
    # Save all the measurements as uncertain numbers
    for i in range(0, n):
        file = RefFiles[i]
        thisFile = np.loadtxt(Directory + file, skiprows=FindDataRow(Directory + file), delimiter=',', usecols=refCols)
        refFile[i, :, 0] = thisFile[:, 0]
        for j in range(0, NWavelengths):
            refFile[i, j, 1] = ureal(thisFile[j, 1], thisFile[j, 2], df=9, label='detRefNoise')
            refFile[i, j, 2] = ureal(thisFile[j, 3], thisFile[j, 4], df=9, label='detRefDarkNoise')
            refFile[i, j, 3] = ureal(thisFile[j, 5], thisFile[j, 6], df=9, label='monRefNoise')
            refFile[i, j, 4] = ureal(thisFile[j, 7], thisFile[j, 8], df=9, label='monRefDarkNoise')
    # Average the measurements from the reference files
    for i in range(0, n):
        for j in range(0, NWavelengths):
            refData[j, 0] += refFile[i, j, 0]
            refData[j, 1] = result(refFile[i, j, 1] + refData[j, 1])
            refData[j, 2] = result(refFile[i, j, 2] + refData[j, 2])
            refData[j, 3] = result(refFile[i, j, 3] + refData[j, 3])
            refData[j, 4] = result(refFile[i, j, 4] + refData[j, 4])
    for j in range(0, NWavelengths):
        refData[j, 0] = int(refData[j, 0] / n)
        refData[j, 1] = result(refData[j, 1] / n, label='avgDetRefNoise' + str(refData[j, 0]) + 'nm')
        refData[j, 2] = result(refData[j, 2] / n, label='avgDetRefDarkNoise' + str(refData[j, 0]) + 'nm')
        refData[j, 3] = result(refData[j, 3] / n, label='avgMonRefNoise' + str(refData[j, 0]) + 'nm')
        refData[j, 4] = result(refData[j, 4] / n, label='avgMonRefDarkNoise' + str(refData[j, 0]) + 'nm')
    return refData

def ReadBothRefFiles(RefFiles):
    """
    Reads ref data from one file
    :param RefFiles: string
    :return: np array of reference data
    """
    n = len(RefFiles)
    refCols = (1, 3, 4, 5, 6, 7, 8, 9, 10)
    refFileS = la.uarray(
        [la.uarray([[0, ureal(0, 0), ureal(0, 0), ureal(0, 0), ureal(0, 0)] for j in range(0, NWavelengths)])
         for i in range(0, n)])
    refFileP = la.uarray(
        [la.uarray([[0, ureal(0, 0), ureal(0, 0), ureal(0, 0), ureal(0, 0)] for j in range(0, NWavelengths)])
         for i in range(0, n)])
    refDataS = la.uarray([[0, ureal(0, 0), ureal(0, 0), ureal(0, 0), ureal(0, 0)] for j in range(0, NWavelengths)])
    refDataP = la.uarray([[0, ureal(0, 0), ureal(0, 0), ureal(0, 0), ureal(0, 0)] for j in range(0, NWavelengths)])
    # Save all the measurements as uncertain numbers
    for i in range(0, n):
        file = RefFiles[i]
        thisFile = np.loadtxt(Directory + file, skiprows=FindDataRow(Directory + file), delimiter=',', usecols=refCols)
        refFileS[i, :, 0] = thisFile[0:NWavelengths, 0]
        refFileP[i, :, 0] = thisFile[NWavelengths:2 * NWavelengths, 0]
        for j in range(0, NWavelengths):
            refFileS[i, j, 1] = ureal(thisFile[j, 1], thisFile[j, 2], df=9, label='detRefNoise')
            refFileS[i, j, 2] = ureal(thisFile[j, 3], thisFile[j, 4], df=9, label='detRefDarkNoise')
            refFileS[i, j, 3] = ureal(thisFile[j, 5], thisFile[j, 6], df=9, label='monRefNoise')
            refFileS[i, j, 4] = ureal(thisFile[j, 7], thisFile[j, 8], df=9, label='monRefDarkNoise')
            refFileP[i, j, 1] = ureal(thisFile[j + NWavelengths, 1], thisFile[j + NWavelengths, 2], df=9,
                                      label='detRefNoise')
            refFileP[i, j, 2] = ureal(thisFile[j + NWavelengths, 3], thisFile[j + NWavelengths, 4], df=9,
                                      label='detRefDarkNoise')
            refFileP[i, j, 3] = ureal(thisFile[j + NWavelengths, 5], thisFile[j + NWavelengths, 6], df=9,
                                      label='monRefNoise')
            refFileP[i, j, 4] = ureal(thisFile[j + NWavelengths, 7], thisFile[j + NWavelengths, 8], df=9,
                                      label='monRefDarkNoise')
    # Average the measurements from the reference files
    for i in range(0, n):
        for j in range(0, NWavelengths):
            refDataS[j, 0] += refFileS[i, j, 0]
            refDataS[j, 1] = result(refFileS[i, j, 1] + refDataS[j, 1])
            refDataS[j, 2] = result(refFileS[i, j, 2] + refDataS[j, 2])
            refDataS[j, 3] = result(refFileS[i, j, 3] + refDataS[j, 3])
            refDataS[j, 4] = result(refFileS[i, j, 4] + refDataS[j, 4])
            refDataP[j, 0] += refFileP[i, j, 0]
            refDataP[j, 1] = result(refFileP[i, j, 1] + refDataP[j, 1])
            refDataP[j, 2] = result(refFileP[i, j, 2] + refDataP[j, 2])
            refDataP[j, 3] = result(refFileP[i, j, 3] + refDataP[j, 3])
            refDataP[j, 4] = result(refFileP[i, j, 4] + refDataP[j, 4])
    for j in range(0, NWavelengths):
        refDataS[j, 0] = int(refDataS[j, 0] / n)
        refDataS[j, 1] = result(refDataS[j, 1] / n, label='avgDetRefNoise' + str(refDataS[j, 0]) + 'nm')
        refDataS[j, 2] = result(refDataS[j, 2] / n, label='avgDetRefDarkNoise' + str(refDataS[j, 0]) + 'nm')
        refDataS[j, 3] = result(refDataS[j, 3] / n, label='avgMonRefNoise' + str(refDataS[j, 0]) + 'nm')
        refDataS[j, 4] = result(refDataS[j, 4] / n, label='avgMonRefDarkNoise' + str(refDataS[j, 0]) + 'nm')
        refDataP[j, 0] = int(refDataP[j, 0] / n)
        refDataP[j, 1] = result(refDataP[j, 1] / n, label='avgDetRefNoise' + str(refDataP[j, 0]) + 'nm')
        refDataP[j, 2] = result(refDataP[j, 2] / n, label='avgDetRefDarkNoise' + str(refDataP[j, 0]) + 'nm')
        refDataP[j, 3] = result(refDataP[j, 3] / n, label='avgMonRefNoise' + str(refDataP[j, 0]) + 'nm')
        refDataP[j, 4] = result(refDataP[j, 4] / n, label='avgMonRefDarkNoise' + str(refDataP[j, 0]) + 'nm')
    return [refDataS, refDataP]

def ReadData(Directory,Source,SRef,PRef,SData,PData=None,BothRef=False):
    """
    Reads in the data file(s): if the source is supercontinuum it looks for both SData and PData, otherwise it only looks at
    SData and assumes that this has all the measurements. Calls the above function to read in the reference files, and also
    reads the data files. From the data files, it reads the wavelength, pitch, yaw, roll, detector angle, polariser angle,
    detector voltage, u(detector), detector dark, u(detector dark), monitor voltage, u(monitor), monitor dark,
    u(monitor dark). The data is stored in an array with one row for each measurement (so allData has lots of rows).
    :param Directory:string giving the working directory
    :param Source:string saying if it's 'LDLS' or 'Supercontinuum'
    :param SRef:string with S reference data file
    :param PRef:string with P reference data file
    :param SData:string with S sample data file
    :param PData:string with P sample data file (if the source is Supercontinuum)
    :param BothRef:Boolean, True if both references are in one file
    :return: np arrays with s reference data, p reference data, all measurement data
    """
    dataCols=(2,11,12,13,14,15,16,17,18,19,20,21,22,23)
    if BothRef:
        sRef,pRef=ReadBothRefFiles(SRef)
    else:
        sRef=ReadRefFiles(SRef)
        pRef=ReadRefFiles(PRef)
    if Source=='LDLS':
        allData=np.loadtxt(Directory+SData,skiprows=FindDataRow(Directory+SData),delimiter=',',usecols=dataCols)
    elif Source=='Supercontinuum':
        sData=np.loadtxt(Directory+SData,skiprows=FindDataRow(Directory+SData),delimiter=',',usecols=dataCols)
        pData=np.loadtxt(Directory+PData,skiprows=FindDataRow(Directory+PData),delimiter=',',usecols=dataCols)
        allData=np.concatenate((sData,pData),axis=0)
    return [sRef,pRef,allData]

def CalculateRefSignal(SRef, PRef, Plot=False):
    """
    Takes the uncertain arrays of reference data and calculates the detector monitor ratios for each wavelength. If plot
    is True (it's False by default), this also plots the reference data and the signal to noise (want to add 'typical'
    data to compare with).
    :param SRef:np array with s reference data
    :param PRef:np array with p reference data
    :param Plot:Boolean saying whether to plot the data
    :return:np array with reference signal
    """
    sDetRefSignal = la.uarray([result(SRef[i, 1] - SRef[i, 2], label='sDetRefSignal' + str(SRef[i, 0]) + 'nm') for i in
                               range(0, NWavelengths)])
    pDetRefSignal = la.uarray([result(PRef[i, 1] - PRef[i, 2], label='pDetRefSignal' + str(PRef[i, 0]) + 'nm') for i in
                               range(0, NWavelengths)])
    sMonRefSignal = la.uarray([result(SRef[i, 3] - SRef[i, 4], label='sMonRefSignal' + str(SRef[i, 0]) + 'nm') for i in
                               range(0, NWavelengths)])
    pMonRefSignal = la.uarray([result(PRef[i, 3] - PRef[i, 4], label='pMonRefSignal' + str(PRef[i, 0]) + 'nm') for i in
                               range(0, NWavelengths)])
    sRefSignal = la.uarray(
        [result(sDetRefSignal[i] / sMonRefSignal[i], label='sRefSignal' + str(SRef[i, 0]) + 'nm') for i in
         range(0, NWavelengths)])
    pRefSignal = la.uarray(
        [result(pDetRefSignal[i] / pMonRefSignal[i], label='pRefSignal' + str(PRef[i, 0]) + 'nm') for i in
         range(0, NWavelengths)])
    refSignal = la.uarray([la.uarray([sRefSignal[i], pRefSignal[i], SRef[i, 0]]) for i in range(0, NWavelengths)])
    if Plot:
        fig, axes = plt.subplots(1, 4, figsize=(12, 3), constrained_layout=True)
        fig.suptitle('Reference Data Check')
        axes[0].plot(SRef[:, 0], SRef[:, 1].x, '.-', label='s detector')
        axes[0].plot(SRef[:, 0], SRef[:, 3].x, '.-', label='s monitor')
        axes[0].set_title('s Average Reference')
        axes[0].set_xlabel('Wavelength (nm)')
        axes[0].set_ylabel('Average signal (V)')
        axes[0].legend()
        axes[1].plot(PRef[:, 0], PRef[:, 1].x, '.-', label='p detector')
        axes[1].plot(PRef[:, 0], PRef[:, 3].x, '.-', label='p monitor')
        axes[1].set_title('p Average Reference')
        axes[1].set_xlabel('Wavelength (nm)')
        axes[1].set_ylabel('Average signal (V)')
        axes[1].legend()
        axes[2].plot(SRef[:, 0], SRef[:, 1].u / SRef[:, 1].x, '.-', label='s detector')
        axes[2].plot(SRef[:, 0], SRef[:, 3].u / SRef[:, 3].x, '.-', label='s monitor')
        axes[2].set_title('s Signal to Noise')
        axes[2].set_xlabel('Wavelength (nm)')
        axes[2].set_ylabel('u(signal)/Signal')
        axes[2].legend()
        axes[3].plot(PRef[:, 0], PRef[:, 1].u / PRef[:, 1].x, '.-', label='p detector')
        axes[3].plot(PRef[:, 0], PRef[:, 3].u / PRef[:, 3].x, '.-', label='p monitor')
        axes[3].set_title('p Signal to Noise')
        axes[3].set_xlabel('Wavelength (nm)')
        axes[3].set_ylabel('u(signal)/Signal')
        axes[3].legend()
    return refSignal

def CalculateSignal(AllData, Plot=False):
    """
    Takes in all the data and calculates the detector monitor ratios for each point after subtracting the dark current.
    Returns an uncertain array with all the detector monitor ratios. If plot is True (it's False by default), this also
    plots the data and the signal to noise (want to add 'typical' data to compare with).
    :param AllData:np array with all measured data
    :param Plot:Boolean
    :return:arrays of signal and signal at 180
    """
    nPoints = len(AllData)
    # Save measured values and their errors
    EIDetNoise = la.uarray([ureal(0, AllData[i, 7], 9, label='IDetNoise') for i in range(0, nPoints)])
    EKDetNoise = la.uarray([ureal(0, AllData[i, 9], 9, label='KDetNoise') for i in range(0, nPoints)])
    EKDetDrift = ureal(0, 0, 999, label='KDetDrift')
    EKDetDecay = ureal(0, 0, 999, label='KDetDecay')
    EIMonNoise = la.uarray([ureal(0, AllData[i, 11], 9, label='IMonNoise') for i in range(0, nPoints)])
    EKMonNoise = la.uarray([ureal(0, AllData[i, 13], 9, label='KMonNoise') for i in range(0, nPoints)])
    EKMonDrift = ureal(0, 0, 999, label='KMonDrift')
    IDet = la.uarray([result(AllData[i, 6] - EIDetNoise[i], label='IDet') for i in range(0, nPoints)])
    KDet = la.uarray([result(AllData[i, 8] - EKDetNoise[i] - EKDetDrift - EKDetDecay * IDet[i], label='KDet') for i in
                      range(0, nPoints)])
    IMon = la.uarray([result(AllData[i, 10] - EIMonNoise[i], label='IMon') for i in range(0, nPoints)])
    KMon = la.uarray([result(AllData[i, 12] - EKMonNoise[i] - EKMonDrift, label='KMon') for i in range(0, nPoints)])
    # Subtract dark current and calculate the detector monitor ratio
    detSignal = la.uarray([result(IDet[i] - KDet[i], label='DetSignal') for i in range(0, nPoints)])
    monSignal = la.uarray([result(IMon[i] - KMon[i], label='MonSignal') for i in range(0, nPoints)])
    ratio = result(detSignal / monSignal, label='DetMonRatio')
    detSignal = CreateUArray(NWavelengths, NTheta, NPhi)
    monSignal = CreateUArray(NWavelengths, NTheta, NPhi)
    detSignal180 = CreateUArray(NWavelengths, NTheta - 2, 1)
    monSignal180 = CreateUArray(NWavelengths, NTheta - 2, 1)
    row = 0
    for pol in range(0, 2):
        for w in range(0, NWavelengths):
            for t in range(0, NTheta):
                for p in range(0, NPhi):
                    detSignal[w, pol, t, p] = result(IDet[row] - KDet[row], label='DetSignal')
                    monSignal[w, pol, t, p] = result(IMon[row] - KMon[row], label='MonSignal')
                    row += 1
            for t in range(0, NTheta - 2):
                detSignal180[w, pol, t] = result(IDet[row] - KDet[row], label='DetSignal')
                monSignal180[w, pol, t] = result(IMon[row] - KMon[row], label='MonSignal')
                row += 1
    signal = detSignal / monSignal
    signal180 = detSignal180 / monSignal180
    # Plot the data
    if Plot:
        row = 0
        n = NTheta * NPhi + NTheta - 2  # number of measurements at each wavelength and polarisation
        for i in range(0, 2 * NWavelengths):
            fig, axes = plt.subplots(1, 4, figsize=(12, 3), constrained_layout=True)
            fig.suptitle('Sample measurements check, wavelength=' + str(AllData[row, 0]) + ' nm, polarisation=' + str(
                AllData[row, 5]))
            axes[0].plot((detSignal / np.cos(np.radians(AllData[:, 4])))[row:row + n].x, label='Detector')
            axes[0].set_title('Detector signal/cos(theta)')
            axes[0].set_xlabel('Measurement number')
            axes[0].set_ylabel('Detector signal/cos(theta) (V)')
            axes[1].plot(monSignal[row:row + n].x, label='Monitor')
            axes[1].set_title('Monitor signal')
            axes[1].set_xlabel('Measurement number')
            axes[1].set_ylabel('Monitor signal (V)')
            axes[2].plot(detSignal[row:row + n].u / detSignal[row:row + n].x, label='Detector')
            axes[2].set_title('Detector signal to noise')
            axes[2].set_xlabel('Measurement number')
            axes[2].set_ylabel('u(signal)/Signal')
            axes[3].plot(monSignal[row:row + n].u / monSignal[row:row + n].x, label='Monitor')
            axes[3].set_title('Monitor Signal to Noise')
            axes[3].set_xlabel('Measurement number')
            axes[3].set_ylabel('u(signal)/Signal')
            row += n
    return [signal, signal180, detSignal, detSignal180, monSignal, monSignal180]

def CalculatePhi(Signal,Signal180,RefSignal):
    """
    Calculates the flux ratio from the reference data and the measurements. Uses the array of all the data to determine
    which wavelength and polarisation to use from the reference data (the polarisation index should be 0 for s polarised
    and 1 for p polarised, the wavelength index should be 0 for the smallest wavelength and increase as the wavelength
    increases). Takes into account the gain change (using the global variable 'GainDifference') and the associated
    error. Returns an uncertain array with all the flux ratios.
    :param Signal:array of the signal
    :param Signal180:array of the signal (for spectralon test)
    :param RefSignal:array of reference signal
    :return:array of the signal normalised by the reference signal
    """
    EGainChangeSample=ureal(0,0,999,label='Gain change sample')
    EGainChangeRef=ureal(0,0,999,label='Gain change ref')
    gainChangeSample=GainDifference-EGainChangeSample
    gainChangeRef=1-EGainChangeRef
    g=result(gainChangeRef/gainChangeSample,label='GainChange')
    flux=CreateUArray(NWavelengths,NTheta,NPhi)
    flux180=CreateUArray(NWavelengths,NTheta-2,1)
    for pol in range(0,2):
        for w in range(0,NWavelengths):
            for t in range(0,NTheta):
                for p in range(0,NPhi):
                    flux[w,pol,t,p]=g*Signal[w,pol,t,p]/RefSignal[w,pol]
            for t in range(0,NTheta-2):
                flux180[w,pol,t]=g*Signal180[w,pol,t]/RefSignal[w,pol]
    return [flux,flux180]

def ApplyRotations(AllData, Aperture17=False):
    """
    Applies the rotations to calculate the values of theta and phi.
    :param AllData:array with all the data in
    :param Aperture17:Boolean
    :return:
    """
    nPoints = len(AllData)
    LAll = la.uarray([ureal(0, 0) for i in range(0, nPoints)])
    tdAll = la.uarray([ureal(0, 0) for i in range(0, nPoints)])
    # Initialise arrays to store the random errors
    EAccuracyU = la.uarray([ureal(0, 0) for i in range(0, nPoints)])
    EAccuracyV = la.uarray([ureal(0, 0) for i in range(0, nPoints)])
    EAccuracyW = la.uarray([ureal(0, 0) for i in range(0, nPoints)])
    EAccuracyD = la.uarray([ureal(0, 0) for i in range(0, nPoints)])
    EResolutionU = la.uarray([ureal(0, 0) for i in range(0, nPoints)])
    EResolutionV = la.uarray([ureal(0, 0) for i in range(0, nPoints)])
    EResolutionW = la.uarray([ureal(0, 0) for i in range(0, nPoints)])
    EResolutionD = la.uarray([ureal(0, 0) for i in range(0, nPoints)])
    brdfParameters = la.uarray(
        [[0, 0, ureal(0, 0), ureal(0, 0), ureal(0, 0), ureal(0, 0), ureal(0, 0), ureal(0, 0)] for i in
         range(0, nPoints)])
    brdf = la.uarray([ureal(0, 0) for i in range(0, nPoints)])
    # Initialise angle positions and flags
    UOld = -999
    VOld = -999
    WOld = -999
    DOld = -999
    # Find angle uncertainties for each measurement
    for i in range(0, nPoints):
        # Extract the stage and slew ring angles
        [u, v, w, d] = AllData[i, 1:5]
        # Convert angles to radians
        u = np.radians(u)
        v = np.radians(v)
        w = np.radians(w)
        d = np.radians(d)
        # Check which angles moved, and add appropriate errors to angles
        # Generate random errors for each axis
        [EAccuracyU, EResolutionU] = GenerateRandomErrors(u, UOld, EAccuracyU, EResolutionU, uEAccuracyU, uEResolutionU,
                                                          'Pitch', i)
        [EAccuracyV, EResolutionV] = GenerateRandomErrors(v, VOld, EAccuracyV, EResolutionV, uEAccuracyV, uEResolutionV,
                                                          'Yaw', i)
        [EAccuracyW, EResolutionW] = GenerateRandomErrors(w, WOld, EAccuracyW, EResolutionW, uEAccuracyW, uEResolutionW,
                                                          'Roll', i)
        [EAccuracyD, EResolutionD] = GenerateRandomErrors(d, DOld, EAccuracyD, EResolutionD, uEAccuracyD, uEResolutionD,
                                                          'Detector', i)
        # Add errors to angles
        u = u - EAccuracyU[i] - EResolutionU[i] - EZeroU
        v = v - EAccuracyV[i] - EResolutionV[i] - EZeroV
        w = w - EAccuracyW[i] - EResolutionW[i] - EZeroW
        d = d - EAccuracyD[i] - EResolutionD[i] - EZeroD
        # Apply rotations to basis vectors (i0,j0,k0 are the unit vectors in lab space, i1,j1,k1 are the rotated vectors)
        i0 = la.uarray([[1, 0, 0]]).T
        j0 = la.uarray([[0, 1, 0]]).T
        k0 = la.uarray([[0, 0, 1]]).T
        i1 = RotateStages(u, v, w, i0)
        j1 = RotateStages(u, v, w, j0)
        k1 = RotateStages(u, v, w, k0)
        # Rotate detector
        if Aperture17:
            L1 = RotateDetector(u, v, w, d, la.uarray([[0, 0, l17]]).T)
        else:
            L1 = RotateDetector(u, v, w, d, la.uarray([[0, 0, l]]).T)
        # Calculate true length
        L = sqrt(la.dot(L1.T, L1))[0][0]
        # Normalise L1 to get unit vector for calculating thetas and phis
        LHat = L1 / L
        # Calculate thetas and phis
        [ti, phii, td, pd] = CalculateThetaPhi(i0, j0, k0, i1, j1, k1, LHat)
        LAll[i] = L
        tdAll[i] = td
    # Put into the right format
    length = CreateUArray(NWavelengths, NTheta, NPhi)
    length180 = CreateUArray(NWavelengths, NTheta - 2, 1)
    thetaD = CreateUArray(NWavelengths, NTheta, NPhi)
    thetaD180 = CreateUArray(NWavelengths, NTheta - 2, 1)
    row = 0
    for pol in range(0, 2):
        for w in range(0, NWavelengths):
            for t in range(0, NTheta):
                for p in range(0, NPhi):
                    length[w, pol, t, p] = LAll[row]
                    thetaD[w, pol, t, p] = tdAll[row]
                    row += 1
            for t in range(0, NTheta - 2):
                length180[w, pol, t] = LAll[row]
                thetaD180[w, pol, t] = tdAll[row]
                row += 1
    return [length, length180, thetaD, thetaD180]

def CalculateBRDF(L,Flux,ThetaD,Aperture17=False):
    """
    Calculates BRDF
    :param L:
    :param Flux:
    :param ThetaD:
    :param Aperture17:
    :return:
    """
    if Aperture17:
        omega=result((np.pi*M17**2)/(4*L**2),label='SolidAngle')
    else:
        omega=result((np.pi*M**2)/(4*L**2),label='SolidAngle')
    brdf=Flux*np.pi/(omega*cos(ThetaD))
    return brdf

def ReadVFData(Source,Aperture17=False):
    """
    Read in view factor data
    :param Source:
    :param Aperture17:
    :return:
    """
    if Source=='LDLS':
        if Aperture17:
            vf=np.loadtxt(r'I:\MSL\Private\Temperature\Software Archive\Ellie\Detector Model\VF Calculations\VF 12 October Data 17 mm LDLS Rectangular Right Way Up.txt')
        else:
            vf=np.loadtxt(r'I:\MSL\Private\Temperature\Software Archive\Ellie\Detector Model\VF Calculations\VF 12 October Data 30 mm LDLS Rectangular Right Way Up.txt')
        vfData=np.zeros((7,17,3))
        row=0
        for w in range(0,7):
            for t in range(0,17):
                vfData[w,t,0]=np.radians(abs(vf[row,0]))
                vfData[w,t,1]=vf[row,1]
                vfData[w,t,2]=vf[row,3]
                row+=1
    else:
        if Aperture17:
            vf=np.loadtxt(r'I:\MSL\Private\Temperature\Software Archive\Ellie\Detector Model\VF Calculations\VF 19 October Data 17 mm Supercontinuum Rectangular Right Way Up.txt')
        else:
            vf=np.loadtxt(r'I:\MSL\Private\Temperature\Software Archive\Ellie\Detector Model\VF Calculations\VF 19 October Data 30 mm Supercontinuum Rectangular Right Way Up.txt')
        vfData=np.zeros((9,17,3))
        row=0
        for w in range(0,9):
            for t in range(0,17):
                vfData[w,t,0]=np.radians(abs(vf[row,0]))
                vfData[w,t,1]=vf[row,1]
                vfData[w,t,2]=vf[row,3]
                row+=1
    vfData=vfData[:,vfData[0,:,0].argsort(),:]
    return vfData

def CalculateBRDFViewFactor(Flux,ThetaD,Source,Aperture17=False):
    """
    Calculate BRDF using the vf (instead of solid angle)
    :param Flux:
    :param ThetaD:
    :param Source:
    :param Aperture17:
    :return:
    """
    vfData=ReadVFData(Source,Aperture17)
    vf=CreateUArray(NWavelengths,NTheta,NPhi)
    for w in range(0,NWavelengths):
        for p in range(0,NPhi):
            for t in range(0,NTheta):
                vf[w,0,t,p]=ureal(vfData[w,t+1,1],0,label='View Factor s, theta='+str(t))
                vf[w,1,t,p]=ureal(vfData[w,t+1,2],0,label='View Factor p, theta='+str(t))
    brdf=Flux/vf
    return brdf

def SortData(Array,SortPhi=False,Sort180=False,Backwards=False):
    """
    Sort the data into a big multidimensional matrix, with the measurements ordered by theta and phi
    :param Array:
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
                        Array[w,pol,t,:]=Array[w,pol,t,:][phiInd1]
                    else:
                        Array[w,pol,t,:]=Array[w,pol,t,:][phiInd2]
    for pol in range(0,2):
        for w in range(0,NWavelengths):
            Array[w,pol,:,:]=Array[w,pol,:,:][thetaInd,:]
    return Array

def AveragePhi(BRDF):
    """
    Average the BRDF by phi
    :param BRDF:
    :return:
    """
    AvgPhi=la.uarray([la.uarray([la.uarray([ureal(0,0) for i in range(0,2)]) for j in range(0,NTheta)]) for k in range(0,NWavelengths)])
    for w in range(0,NWavelengths):
        for t in range(0,NTheta):
            for pol in range(0,2):
                AvgPhi[w,t,pol]=sum(BRDF[w,pol,t,:])/NPhi
    return AvgPhi

def AveragePol(AvgPhi):
    """
    Average the two polarisations
    :param AvgPhi:
    :return:
    """
    AvgBRDF=la.uarray([la.uarray([ureal(0,0) for i in range(0,NTheta)]) for j in range(0,NWavelengths)])
    for w in range(0,NWavelengths):
        for t in range(0,NTheta):
            AvgBRDF[w,t]=sum(AvgPhi[w,t,:])/2
    return AvgBRDF

def CalculateRF(AverageBRDF,integrationMethod='Lagrange'):
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
        if integrationMethod=='Lagrange':
            RF[w]=IntegrateLagrangeCubic(tdAll,brdfCurrent)
        elif integrationMethod=='Simpson':
            RF[w]=SimpsonNonuniform(tdAll,brdfCurrent)
    return RF

def PlotFluxRatio(Flux,Source):
    """
    Plot the flux ratio by phi
    :param Flux:
    :param Source:
    :return:
    """
    if Source=='LDLS':
        Wavelengths=WavelengthsL
    else:
        Wavelengths=WavelengthsS
    for w in range(0,NWavelengths):
        fig,axes=plt.subplots(1,2,figsize=(12,5),constrained_layout=True)
        fig.suptitle('Flux ratio by phi')
        for t in range(0,NTheta):
            axes[0].set_title('Wavelength='+str(Wavelengths[w])+' nm, s polarised')
            axes[0].plot(PhiAll,Flux[w,0,t,:].x/Flux[w,0,t,0].x,label=str(ThetaAll[t]))
            axes[0].set_xlabel('Phi (degrees)')
            axes[0].set_ylabel('Flux ratio')
            axes[1].set_title('Wavelength='+str(Wavelengths[w])+' nm, p polarised')
            axes[1].plot(PhiAll,Flux[w,1,t,:].x/Flux[w,1,t,0].x,label=str(ThetaAll[t]))
            axes[1].set_xlabel('Phi (degrees)')
            axes[1].set_ylabel('Flux ratio')
            axes[0].legend()

def PlotBRDF(AvgBRDF,Source):
    # Plot BRDF averaged over phi against theta
    if Source=='LDLS':
        Wavelengths=WavelengthsL
    else:
        Wavelengths=WavelengthsS
    fig,axes=plt.subplots(1,2,figsize=(12,5),constrained_layout=True)
    fig.suptitle('BRDF against theta')
    for w in range(0,NWavelengths):
        axes[0].set_title('s polarised')
        axes[0].plot(ThetaAll,AvgBRDF[w,:,0].x,label=str(Wavelengths[w]))
        axes[0].set_xlabel('Theta (degrees)')
        axes[0].set_ylabel('BRDF')
        axes[1].set_title('p polarised')
        axes[1].plot(ThetaAll,AvgBRDF[w,:,1].x,label=str(Wavelengths[w]))
        axes[1].set_xlabel('Theta (degrees)')
        axes[1].set_ylabel('BRDF')
        axes[0].legend()

def PlotSpectralonTest(Flux,Flux180,Source):
    # Plot spectralon test results
    if Source=='LDLS':
        Wavelengths=WavelengthsL
    else:
        Wavelengths=WavelengthsS
    fig,axes=plt.subplots(1,2,figsize=(12,5),constrained_layout=True)
    fig.suptitle('Spectralon test')
    for w in range(1,NWavelengths):
        # The spectralon test measurements on the positive side are at phi=180, and those on the negative side are at phi=0
        # so for the theta measured on the positive side (5,15,...,75), we want to divide the first phi value, and for those
        # on the negative side (10,20,...,80) we want to divide the spectralon test signal by the fifth phi value (phi=180)
        spectralonPlot=np.zeros((NTheta-2,2))
        for t in range(0,NTheta-2):
            if t%2:
                # If t isn't divisible by 2, then theta is 15,25,..,75
                spectralonPlot[t,0]=Flux[w,0,t+1,0].x/Flux180[w,0,t,0].x
                spectralonPlot[t,1]=Flux[w,1,t+1,0].x/Flux180[w,1,t,0].x
            else:
                # If t is divisible by 2, then theta is 10,20,...,80
                spectralonPlot[t,0]=Flux180[w,0,t,0].x/Flux[w,0,t+1,4].x
                spectralonPlot[t,1]=Flux180[w,1,t,0].x/Flux[w,1,t+1,4].x
        axes[0].set_title('s polarised')
        axes[0].plot(ThetaAll[1:NTheta-1],spectralonPlot[:,0],label=str(Wavelengths[w]))
        axes[0].set_xlabel('Theta (degrees)')
        axes[0].set_ylabel('Positive side/Negative side')
        axes[1].set_title('p polarised')
        axes[1].plot(ThetaAll[1:NTheta-1],spectralonPlot[:,1],label=str(Wavelengths[w]))
        axes[1].set_xlabel('Theta (degrees)')
        axes[1].set_ylabel('Positive side/Negative side')
        axes[0].legend()

def ApplySpectralonTestCorrection(Flux,Flux180):
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

def GenerateRandomErrors(Angle,OldAngle,EAcc,ERes,uEAcc,uERes,Axis,i,j=None):
    """
    Generates the random accuracy and resolution errors if the axis moves, otherwise sets the random errors to be the same
    as the previous value.
    """
    if j is None:
        if Angle!=OldAngle:
            # If the axis moves
            EAcc[i]=ureal(0,tb.distribution['gaussian'](uEAcc),label=Axis+', Accuracy = '+str(math.degrees(Angle)))
            ERes[i]=ureal(0,tb.distribution['uniform'](uERes),label=Axis+', Resolution = '+str(math.degrees(Angle)))
        else:
            # If the axis does not move
            EAcc[i]=EAcc[i-1]
            ERes[i]=ERes[i-1]
    else:
        if Angle!=OldAngle:
            # If the axis moves
            EAcc[j,i]=ureal(0,tb.distribution['gaussian'](uEAcc),label=Axis+', Accuracy = '+str(math.degrees(Angle)))
            ERes[j,i]=ureal(0,tb.distribution['uniform'](uERes),label=Axis+', Resolution = '+str(math.degrees(Angle)))
        else:
            if i!=0:
                EAcc[j,i]=EAcc[j,i-1]
                ERes[j,i]=ERes[j,i-1]
            else:
                EAcc[i]=EAcc[j-1,3]
                ERes[i]=ERes[j,i-1]
    return [EAcc,ERes]

def ToThetaPhi(U,V,W,D):
    """
    Converts from pitch, yaw, roll, and detection angle into thetas and phis.
    """
    if cos(V)*cos(U)>=1:
        ti=acos(cos(V)*cos(U)-0.0000000001)
    elif cos(V)*cos(U)<=-1:
        ti=acos(cos(V)*cos(U)+0.0000000001)
    else:
        ti=acos(cos(V)*cos(U))
    if sin(D)*cos(U)*sin(V) + cos(D)*cos(U)*cos(V) >= 1:
        td=acos(0.9999999999)
    else:
        td=acos(sin(D)*cos(U)*sin(V) + cos(D)*cos(U)*cos(V))
    if abs(U)<0.00001 and abs(V)<0.00001:
        phii=0
    else:
        phii=atan2(sin(U)*cos(V),-sin(V))-W
    pd=atan2(sin(D)*(sin(U)*sin(V)*cos(W)-cos(V)*sin(W))+cos(D)*(sin(V)*sin(W)+sin(U)*cos(V)*cos(W)),
            sin(D)*(cos(V)*cos(W)+sin(U)*sin(V)*sin(W))+cos(D)*(sin(U)*cos(V)*sin(W)-sin(V)*cos(W)))
    return [ti,phii,td,pd]

def ToUVWD(ti,phii,td,pd):
    """
    Converts from thetas and phis to pitch, yaw, roll and detection angle.
    """
    if cos(ti)*cos(td)+sin(ti)*sin(td)*cos(pd-phii)>=1:
        D=acos(cos(ti)*cos(td)+sin(ti)*sin(td)*cos(pd-phii)-0.0000001)
    elif cos(ti)*cos(td)+sin(ti)*sin(td)*cos(pd-phii)<=-1:
        D=acos(cos(ti)*cos(td)+sin(ti)*sin(td)*cos(pd-phii)+0.0000001)
    else:
        D=acos(cos(ti)*cos(td)+sin(ti)*sin(td)*cos(pd-phii))
    if (-sin(ti)*sin(td)*sin(pd-phii))/sin(D)>=1:
        U=asin((-sin(ti)*sin(td)*sin(pd-phii))/sin(D)-0.0000001)
    elif (-sin(ti)*sin(td)*sin(pd-phii))/sin(D)<=-1:
        U=asin((-sin(ti)*sin(td)*sin(pd-phii))/sin(D)+0.0000001)
    else:
        U=asin((-sin(ti)*sin(td)*sin(pd-phii))/sin(D))
    V=atan((cos(td)-cos(ti)*cos(D))/(cos(ti)*sin(D)))
    if abs(U)<0.00001 and abs(V)<0.00001:
        W=-pd
    else:
        W=atan2(sin(U)*cos(V),-sin(V))-phii
    return [U,V,W,D]

def RotateVector(u,v,w,a):
    """
    Apply rotation matrices to vector a, given angles u,v,w
    """
    Rp=la.uarray([[cos(u)+(TPx**2*(1-cos(u))),
                TPx*TPy*(1-cos(u))-TPz*sin(u),
                TPx*TPz*(1-cos(u))+TPy*sin(u)],
               [TPy*TPx*(1-cos(u))+TPz*sin(u),
                cos(u)+(TPy**2*(1-cos(u))),
                TPy*TPz*(1-cos(u))-TPx*sin(u)],
               [TPz*TPx*(1-cos(u))-TPy*sin(u),
               TPz*TPy*(1-cos(u))+TPx*sin(u),
               cos(u)+(TPz**2*(1-cos(u)))]])
    Ry=la.uarray([[cos(v)+(TYx**2*(1-cos(v))),
                TYx*TYy*(1-cos(v))-TYz*sin(v),
                TYx*TYz*(1-cos(v))+TYy*sin(v)],
               [TYy*TYx*(1-cos(v))+TYz*sin(v),
                cos(v)+(TYy**2*(1-cos(v))),
                TYy*TYz*(1-cos(v))-TYx*sin(v)],
               [TYz*TYx*(1-cos(v))-TYy*sin(v),
               TYz*TYy*(1-cos(v))+TYx*sin(v),
               cos(v)+(TYz**2*(1-cos(v)))]])
    Rr=la.uarray([[cos(w)+(TRx**2*(1-cos(w))),
                TRx*TRy*(1-cos(w))-TRz*sin(w),
                TRx*TRz*(1-cos(w))+TRy*sin(w)],
               [TRy*TRx*(1-cos(w))+TRz*sin(w),
                cos(w)+(TRy**2*(1-cos(w))),
                TRy*TRz*(1-cos(w))-TRx*sin(w)],
               [TRz*TRx*(1-cos(w))-TRy*sin(w),
               TRz*TRy*(1-cos(w))+TRx*sin(w),
               cos(w)+(TRz**2*(1-cos(w)))]])
    a0=DeltaY+la.matmul(Ry,(DeltaP+la.matmul(Rp,(DeltaR+la.matmul(Rr,(a-DeltaR))-DeltaP))-DeltaY))
    return a0

def RotateStages(u,v,w,a):
    """
    Apply the rotation matrices to the vector, a, given rotation angles u,v,w,d
    """
    # Rotate origin
    o=la.uarray([[0,0,0]]).T
    o0=RotateVector(u,v,w,o)

    # Apply rotation to vector
    a0=RotateVector(u,v,w,a)-o0
    return a0

def ZOffset(u,v,w):
    """
    Calculate the Z offset when stages are rotated by angles u,v,w
    """
    # Rotate surface normal
    k=la.uarray([[0,0,1]]).T
    k1=RotateStages(u,v,w,k)

    # Rotate origin
    o=la.uarray([[0,0,0]]).T
    o1=RotateVector(u,v,w,o)

    # Calculate Z offset
    Z=la.dot(k1.T,o1)[0,0]/k1[2,0]
    return Z

def RotateDetector(u,v,w,d,L):
    """
    Apply rotation around detector axis to L. Rotation stages set at angles u,v,w.
    """
    Rd=la.uarray([[cos(d)+(TDx**2*(1-cos(d))),
                TDx*TDy*(1-cos(d))-TDz*sin(d),
                TDx*TDz*(1-cos(d))+TDy*sin(d)],
               [TDy*TDx*(1-cos(d))+TDz*sin(d),
                cos(d)+(TRy**2*(1-cos(d))),
                TDy*TDz*(1-cos(d))-TDx*sin(d)],
               [TDz*TDx*(1-cos(d))-TDy*sin(d),
               TDz*TDy*(1-cos(d))+TDx*sin(d),
               cos(d)+(TDz**2*(1-cos(d)))]])

    # Find Z offset
    Z=ZOffset(u,v,w)
    L0=DeltaD+la.matmul(Rd,(L-DeltaD))-Z
    return L0

def CalculateThetaPhi(i,j,k,i1,j1,k1,L1):
    """
    Calculate the true theta and phi angles given the rotated unit vectors
    """
    if la.dot(k.T,k1)>=1:
        ti=acos(la.dot(k.T,k1)-0.00001)[0][0]
    elif la.dot(k.T,k1)<=-1:
        ti=acos(la.dot(k.T,k1)+0.00001)[0][0]
    else:
        ti=acos(la.dot(k.T,k1))[0][0]
    if la.dot(L1.T,k1)>=1:
        td=acos(la.dot(L1.T,k1)-0.00001)[0][0]
    elif la.dot(L1.T,k1)<=-1:
        td=acos(la.dot(L1.T,k1)+0.00001)[0][0]
    else:
        td=acos(la.dot(L1.T,k1))[0][0]
    phii=atan2(la.dot(k.T,j1),la.dot(k.T,i1))[0][0]
    pd=atan2(la.dot(L1.T,j1),la.dot(L1.T,i1))[0][0]
    return[ti,phii,td,pd]

def ApplyAllFunctions(Directory,Source,SRef,PRef,SData,PData=None,BothRef=False,Aperture17=False):
    """
    Applies all the functions to calculate RF
    """
    if PData:
        [sRef,pRef,allData]=ReadData(Directory,Source,SRef,PRef,SData,PData,BothRef)
    else:
        [sRef,pRef,allData]=ReadData(Directory,Source,SRef,PRef,SData,PData,BothRef)
    refSignal=CalculateRefSignal(sRef,pRef)
    [signal,signal180,detSignal,detSignal180,monSignal,monSignal180]=CalculateSignal(allData)
    [length,length180,thetaD,thetaD180]=ApplyRotations(allData,Aperture17)
    signal=SortData(signal,SortPhi=True)
    detSignal=SortData(detSignal,SortPhi=True)
    monSignal=SortData(monSignal,SortPhi=True)
    thetaD=SortData(thetaD,SortPhi=True)
    length=SortData(length,SortPhi=True)
    signal180=SortData(signal180,Sort180=True)
    detSignal180=SortData(detSignal180,Sort180=True)
    monSignal180=SortData(monSignal180,Sort180=True)
    length180=SortData(length180,Sort180=True)
    thetaD180=SortData(thetaD180,Sort180=True)
    [flux,flux180]=CalculatePhi(signal,signal180,refSignal)
    PlotSpectralonTest(flux,flux180,Source)
    brdf=CalculateBRDF(length,flux,thetaD,Aperture17)
    brdf180=CalculateBRDF(length180,flux180,thetaD180,Aperture17)
    avgBRDFPhi=AveragePhi(brdf)
    avgBRDF=AveragePol(avgBRDFPhi)
    avgThetaPhi=AveragePhi(thetaD)
    avgTheta=AveragePol(avgThetaPhi)
    PlotBRDF(avgBRDFPhi,Source)
    BRDFData=la.uarray([la.uarray([la.uarray([ureal(0,0),ureal(0,0)])for i in range(0,NTheta)])for j in range(0,NWavelengths)])
    BRDFData[:,:,0]=avgBRDF
    BRDFData[:,:,1]=avgTheta
    RFLagrange=CalculateRF(BRDFData,integrationMethod='Lagrange')
    [correctedflux,correctedflux180]=ApplySpectralonTestCorrection(flux,flux180)
    correctedBrdf=CalculateBRDF(length,correctedflux,thetaD,Aperture17)
    correctedAvgBRDFPhi=AveragePhi(correctedBrdf)
    correctedAvgBRDF=AveragePol(correctedAvgBRDFPhi)
    PlotBRDF(correctedAvgBRDFPhi,Source)
    correctedBRDFData=la.uarray([la.uarray([la.uarray([ureal(0,0),ureal(0,0)])for i in range(0,NTheta)])for j in range(0,NWavelengths)])
    correctedBRDFData[:,:,0]=correctedAvgBRDF
    correctedBRDFData[:,:,1]=avgTheta
    correctedRFLagrange=CalculateRF(correctedBRDFData,integrationMethod='Lagrange')
    vfBRDF=CalculateBRDFViewFactor(flux,thetaD,Source,Aperture17)
    vfAvgBRDFPhi=AveragePhi(vfBRDF)
    vfAvgBRDF=AveragePol(vfAvgBRDFPhi)
    PlotBRDF(vfAvgBRDFPhi,Source)
    vfBRDFData=la.uarray([la.uarray([la.uarray([ureal(0,0),ureal(0,0)])for i in range(0,NTheta)])for j in range(0,NWavelengths)])
    vfBRDFData[:,:,0]=vfAvgBRDF
    vfBRDFData[:,:,1]=avgTheta
    vfRFLagrange=CalculateRF(vfBRDFData,integrationMethod='Lagrange')
    return [RFLagrange,correctedRFLagrange,vfRFLagrange]
