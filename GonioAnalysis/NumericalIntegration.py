import numpy as np
from GTC import *

def SimpsonNonuniform(x,f):
    """
    Simpson rule for irregularly spaced data.
        Parameters
        ----------
        x : list or np.array of floats
                Samplingdef TrapeziumRule(XData,YData):
    n=len(XData)
    integral=0.5*(XData[-1]*YData[-1]-XData[0]*YData[0])
    for i in range(1,n-1):
        integral+=0.5*(XData[i+1]*YData[i]-XData[i]*YData[i+1])
    return integral points for the function values
        f : list or np.array of floats
                Function values at the sampling points
        Returns
        -------
        float : approximation for the integral
    """
    N=len(x)-1
    h=np.diff(x)
    result=0.0
    for i in range(1,N,2):
        hph=h[i]+h[i-1]
        result+=f[i]*(h[i]**3+h[i-1]**3+3.*h[i]*h[i-1]*hph)/(6*h[i]*h[i-1])
        result+=f[i-1]*(2.*h[i-1]**3-h[i]**3+3.*h[i]*h[i-1]**2)/(6*h[i-1]*hph)
        result+=f[i+1]*(2.*h[i]**3-h[i-1]**3+3.*h[i-1]*h[i]**2)/(6*h[i]*hph)
    if (N+1)%2==0:
        result+=f[N]*(2*h[N-1]**2+3.*h[N-2]*h[N-1])/(6*(h[N-2]+h[N-1]))
        result+=f[N-1]*(h[N-1]**2+3*h[N-1]*h[N-2])/(6*h[N-2])
        result-=f[N-2]*h[N-1]**3/(6*h[N-2]*(h[N-2]+h[N-1]))
    return result

def CalculateIntegralLagrange(xsub,ysub,a):
    i1=ysub[0]*(a**4/4-(xsub[1]+xsub[2]+xsub[3])*a**3/3+(xsub[1]*xsub[2]+xsub[1]*xsub[3]+xsub[2]*xsub[3])*a**2/2-
                xsub[1]*xsub[2]*xsub[3]*a)/((xsub[0]-xsub[1])*(xsub[0]-xsub[2])*(xsub[0]-xsub[3]))
    i2=ysub[1]*(a**4/4-(xsub[0]+xsub[2]+xsub[3])*a**3/3+(xsub[0]*xsub[2]+xsub[0]*xsub[3]+xsub[2]*xsub[3])*a**2/2-
                xsub[0]*xsub[2]*xsub[3]*a)/((xsub[1]-xsub[0])*(xsub[1]-xsub[2])*(xsub[1]-xsub[3]))
    i3=ysub[2]*(a**4/4-(xsub[0]+xsub[1]+xsub[3])*a**3/3+(xsub[0]*xsub[1]+xsub[0]*xsub[3]+xsub[1]*xsub[3])*a**2/2-
                xsub[0]*xsub[1]*xsub[3]*a)/((xsub[2]-xsub[0])*(xsub[2]-xsub[1])*(xsub[2]-xsub[3]))
    i4=ysub[3]*(a**4/4-(xsub[0]+xsub[1]+xsub[2])*a**3/3+(xsub[0]*xsub[1]+xsub[0]*xsub[2]+xsub[1]*xsub[2])*a**2/2-
                xsub[0]*xsub[1]*xsub[2]*a)/((xsub[3]-xsub[0])*(xsub[3]-xsub[1])*(xsub[3]-xsub[2]))
    integral=i1+i2+i3+i4
    return integral

def DefiniteIntegralLagrange(xsub,ysub,x1,x2):
    integral1=CalculateIntegralLagrange(xsub,ysub,x1)
    integral2=CalculateIntegralLagrange(xsub,ysub,x2)
    integral=integral2-integral1
    return integral

def IntegrateLagrangeCubic(XData,YData):
    N=np.shape(XData)[0]
    integral=DefiniteIntegralLagrange(XData[0:4],YData[0:4],XData[0],XData[2])
    for i in range(3,N-2):
        xsub=XData[i-2:i+2]
        ysub=YData[i-2:i+2]
        integral+=DefiniteIntegralLagrange(xsub,ysub,XData[i-1],XData[i])
    integral+=DefiniteIntegralLagrange(XData[N-4:N],YData[N-4:N],XData[N-3],XData[N-1])
    return integral

def TrapeziumRule(XData,YData):
    n=len(XData)
    integral=0.5*(XData[-1]*YData[-1]-XData[0]*YData[0])
    for i in range(1,n-1):
        integral+=0.5*(XData[i+1]*YData[i]-XData[i]*YData[i+1])
    return integral