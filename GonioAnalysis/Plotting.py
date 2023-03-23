import numpy as np
import matplotlib.pyplot as plt

"""
Functions in this file:
    PlotSpectralonTest(Flux,Flux180,Source)
    PlotBRDF(AvgBRDF,Source)
    PlotFluxRatio(Flux,Source)
"""


def PlotSpectralonTest(NWavelengths,NTheta,Flux,Flux180,Source):
    # Plot spectralon test results
    thetaAll=np.arange(5,81,5)
    if Source=='LDLS':
        Wavelengths=[360,380,400,420,440,460,480]
    else:
        Wavelengths=[460,480,530,580,630,680,730,780,830]
    fig,axes=plt.subplots(1,2,figsize=(12,5),constrained_layout=True)
    fig.suptitle('Spectralon test')
    for w in range(1,NWavelengths):
        # The spectralon test measurements on the positive side are at phi=180, and those on the negative side are at phi=0
        # so for the theta measured on the positive side (5,15,...,75), we want to divide the first phi value, and for those
        # on the negative side (10,20,...,80) we want to divide the spectralon test signal by the fifth phi value (phi=180)
        spectralonPlot=np.zeros((NTheta-2,2))
        for t in range(0,NTheta-2):
            if t%2==0:
                # If t%2==0, then theta is 10,20,...,80
                spectralonPlot[t,0]=Flux[w,0,t+1,0].x/Flux180[w,0,t,0].x
                spectralonPlot[t,1]=Flux[w,1,t+1,0].x/Flux180[w,1,t,0].x
            else:
                # Else, theta is 15,25,..,75
                spectralonPlot[t,0]=Flux180[w,0,t,0].x/Flux[w,0,t+1,4].x
                spectralonPlot[t,1]=Flux180[w,1,t,0].x/Flux[w,1,t+1,4].x
        axes[0].set_title('s polarised')
        axes[0].plot(thetaAll[1:NTheta-1],spectralonPlot[:,0],label=str(Wavelengths[w]))
        axes[0].set_xlabel('Theta (degrees)')
        axes[0].set_ylabel('Positive side/Negative side')
        axes[1].set_title('p polarised')
        axes[1].plot(thetaAll[1:NTheta-1],spectralonPlot[:,1],label=str(Wavelengths[w]))
        axes[1].set_xlabel('Theta (degrees)')
        axes[1].set_ylabel('Positive side/Negative side')
        axes[0].legend()


def PlotBRDF(NWavelengths,AvgBRDF,Source):
    # Plot BRDF averaged over phi against theta
    thetaAll = np.arange(5, 81, 5)
    if Source=='LDLS':
        Wavelengths=[360,380,400,420,440,460,480]
    else:
        Wavelengths=[460,480,530,580,630,680,730,780,830]
    fig,axes=plt.subplots(1,2,figsize=(12,5),constrained_layout=True)
    fig.suptitle('BRDF against theta')
    for w in range(0,NWavelengths):
        axes[0].set_title('s polarised')
        axes[0].plot(thetaAll,AvgBRDF[w,:,0].x,label=str(Wavelengths[w]))
        axes[0].set_xlabel('Theta (degrees)')
        axes[0].set_ylabel('BRDF')
        axes[1].set_title('p polarised')
        axes[1].plot(thetaAll,AvgBRDF[w,:,1].x,label=str(Wavelengths[w]))
        axes[1].set_xlabel('Theta (degrees)')
        axes[1].set_ylabel('BRDF')
        axes[0].legend()


def PlotFluxRatio(NWavelengths,NTheta,Flux,Source):
    """
    Plot the flux ratio by phi
    :param Flux:
    :param Source:
    :return:
    """
    thetaAll=np.arange(5,81,5)
    phiAll=np.arange(0,360,45)
    if Source=='LDLS':
        Wavelengths=[360,380,400,420,440,460,480]
    else:
        Wavelengths=[460,480,530,580,630,680,730,780,830]
    for w in range(0,NWavelengths):
        fig,axes=plt.subplots(1,2,figsize=(12,5),constrained_layout=True)
        fig.suptitle('Flux ratio by phi')
        for t in range(0,NTheta):
            axes[0].set_title('Wavelength='+str(Wavelengths[w])+' nm, s polarised')
            axes[0].plot(phiAll,Flux[w,0,t,:].x/Flux[w,0,t,0].x,label=str(thetaAll[t]))
            axes[0].set_xlabel('Phi (degrees)')
            axes[0].set_ylabel('Flux ratio')
            axes[1].set_title('Wavelength='+str(Wavelengths[w])+' nm, p polarised')
            axes[1].plot(phiAll,Flux[w,1,t,:].x/Flux[w,1,t,0].x,label=str(thetaAll[t]))
            axes[1].set_xlabel('Phi (degrees)')
            axes[1].set_ylabel('Flux ratio')
            axes[0].legend()


