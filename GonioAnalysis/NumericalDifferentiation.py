import numpy as np


def CalculateDerivative(Data):
    # Calculate dy/dx at each point by fitting a quadratic through the point plus the two either side and analytically
    # differentiating the quadratic. At the end points, use a linear approximation for first and last points.
    N=Data.shape[0]
    dydx=np.zeros((N,2))
    dydx[:,0]=Data[:,0]
    for i in range(1,N-1):
        [x0,x1,x2]=Data[i-1:i+2,0]
        [y0,y1,y2]=Data[i-1:i+2,1]
        a0=y0/((x0-x1)*(x0-x2))
        a1=y1/((x1-x0)*(x1-x2))
        a2=y2/((x2-x0)*(x2-x1))
        dydx[i,1]=a0*(x1-x2)+a1*(2*x1-x0-x2)+a2*(x1-x0)
    dydx[0,1]=(Data[1,1]-Data[0,1])/(Data[1,0]-Data[0,0])
    dydx[N-1,1]=(Data[N-1,1]-Data[N-2,1])/(Data[N-1,0]-Data[N-2,0])
    return dydx
