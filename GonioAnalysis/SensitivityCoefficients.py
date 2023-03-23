import math
import numpy
#%matplotlib inline
import matplotlib.pyplot as plt
import xlrd
import xlwt
from GTC import *

def ImportData(file):

    data = numpy.loadtxt(file, skiprows = 31, delimiter = ",",usecols = (2,7,8,9,10,15,16,17,18,19,20,21,22,23,24))
    N = numpy.shape(data)[0]
    detector_dark = ureal(numpy.mean(data[:,8]),numpy.std(data[:,9]))
    monitor_dark = ureal(numpy.mean(data[:,12]),numpy.std(data[:,13]))
    dmratio = numpy.array([(ureal(data[i,6],data[i,7])-detector_dark)/((ureal(data[i,10],data[i,11])-monitor_dark)) for i in range(0,N)])
    wavelength = data[:,0]
    polarisation = data[:,5]
    theta_i = data[:,1]
    theta_d = data[:,3]
    return (dmratio)

def WavelengthSensitivity(dataset):

    Ntheta = 15
    Nwave = 14
    Npts = 5
    Row = 0
    wavedata_v = la.uarray(
        [[[[ureal(0.0, 0.0) for j in range(0, 5)] for i in range(0, 4)] for theta in range(0, Ntheta)] for wave in
         range(0, Nwave)])
    wavedata_h = la.uarray(
        [[[[ureal(0.0, 0.0) for j in range(0, 5)] for i in range(0, 4)] for theta in range(0, Ntheta)] for wave in
         range(0, Nwave)])

    for wave in range(0, Nwave):
        for theta in range(0, Ntheta):
            wavedata_v[wave, theta, :, :] = numpy.array(
                [wavelength[Row:Row + 5], theta_d[Row:Row + 5], theta_i[Row:Row + 5],
                 dmratio[Row:Row + 5] / dmratio[Row + 2]])
            Row = Row + 5

    for wave in range(0, Nwave):
        for theta in range(0, Ntheta):
            wavedata_h[wave, theta, :, :] = numpy.array(
                [wavelength[Row:Row + 5], theta_d[Row:Row + 5], theta_i[Row:Row + 5],
                 dmratio[Row:Row + 5] / dmratio[Row + 2]])
            Row = Row + 5

    fig, axes = plt.subplots(int(math.ceil((Nwave) / 4.)), 4, figsize=(12, 3 * int(math.ceil((Nwave + 1) / 4.))))

    for wave in range(0, Nwave):
        for theta in range(0, Ntheta):
            axes[wave // 4, wave % 4].plot(wavedata_v[wave, theta, 0, :], wavedata_v[wave, theta, 3, :].x,
                                           label=str(round(wavedata_v[wave, theta, 1, 1])))
            axes[wave // 4, wave % 4].plot(wavedata_h[wave, theta, 0, :], wavedata_h[wave, theta, 3, :].x, '--',
                                           label=str(round(wavedata_h[wave, theta, 1, 1])))
            # print (str(round((wavedata[wave,theta,1,1]))))
            axes[wave // 4, wave % 4].set_xlabel('Wavelength (nm)')
            axes[wave // 4, wave % 4].set_title("%d" % wavedata[wave, theta, 0, 2], fontsize=20, color="blue")

    # axes[wave//4,wave%4].legend()
    fig.tight_layout();
    plt.show()

    return('hello')

if __name__ == "__main__":
    file = "I:\MSL\Private\Photometry & Radiometry\STANDARDS\GonioSpectrometry\K5 Comparison 2020\Sensitivity Coefficients\BSDF_000230a.csv"
    print(ImportData(file))