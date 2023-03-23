# Copy of initialise errors for checking uncertainties in alignment. Can change these values

from GTC import *
import numpy as np

# Axis displacement errors (mm)
DeltaPy=ureal(0,tb.distribution['gaussian'](0.1),df=5,label="E Delta Py")
DeltaPz=ureal(0,tb.distribution['gaussian'](0.1),df=5,label="E Delta Pz")
DeltaYx=ureal(0,tb.distribution['gaussian'](0.1),df=5,label="E Delta Yx")
DeltaYz=ureal(0,tb.distribution['gaussian'](0.1),df=5,label="E Delta Yz")
DeltaRx=ureal(0,tb.distribution['gaussian'](0.1),df=5,label="E Delta Rx")
DeltaRy=ureal(0,tb.distribution['gaussian'](0.1),df=5,label="E Delta Ry")
DeltaDx=ureal(0,tb.distribution['gaussian'](0.1),df=5,label="E Delta Dx")
DeltaDz=ureal(0.14,tb.distribution['gaussian'](0.1),df=5,label="E Delta Dz")

DeltaP=la.uarray([[0,DeltaPy,DeltaPz]]).T
DeltaY=la.uarray([[DeltaYx,0,DeltaYz]]).T
DeltaR=la.uarray([[DeltaRx,DeltaRy,0]]).T
DeltaD=la.uarray([[DeltaDx,0,DeltaDz]]).T

# Angular offset errors (radians)
TPy=ureal(0,tb.distribution['uniform'](0.002),label="E TPy")
TPz=ureal(0,tb.distribution['uniform'](0.002),label="E TPz")
TYx=ureal(0,tb.distribution['uniform'](0.0003),label="E TYx")
TYz=ureal(0,tb.distribution['uniform'](0.0003),label="E TYz")
TRx=ureal(0,tb.distribution['uniform'](0.0011),label="E TRx")
TRy=ureal(0,tb.distribution['uniform'](0.00076),label="E TRy")
TDx=ureal(0,tb.distribution['uniform'](0.00078),label="E TDx")
TDz=ureal(0,tb.distribution['uniform'](0.0006),label="E TDz")

# Normalise the axis displacement vectors(relative) - Tpx, Tyy, Trz, Tdy are all 0 with no uncertainty
TPx=1
TYy=1
TRz=1
TDy=1

TP=la.uarray([[TPx,TPy,TPz]]).T
TY=la.uarray([[TYx,TYy,TYz]]).T
TR=la.uarray([[TRx,TRy,TRz]]).T
TD=la.uarray([[TDx,TDy,TDz]]).T

TP=TP/(sqrt(TPx**2+TPy**2+TPz**2))
TY=TY/(sqrt(TYx**2+TYy**2+TYz**2))
TR=TR/(sqrt(TRx**2+TRy**2+TRz**2))
TD=TD/(sqrt(TDx**2+TDy**2+TDz**2))

# Angle errors (degrees, converted to radians)
EAccuracyU=ureal(0,math.radians(0.024),label="Pitch accuracy")
EResolutionU=ureal(0,math.radians(0.0002),label="Pitch resolution")
EZeroU=ureal(0,tb.distribution['gaussian'](math.radians(0.1)),df=50,label="Pitch axis zero")

EAccuracyV=ureal(0,math.radians(0.1),label="Yaw accuracy")
EResolutionV=ureal(0,math.radians(0.00016),label="Yaw resolution")
EZeroV=ureal(0,tb.distribution['gaussian'](math.radians(0.1)),df=50,label="Yaw axis zero")

EAccuracyW=ureal(0,math.radians(0.067),label="Roll accuracy")
EResolutionW=ureal(0,math.radians(0.0043),label="Roll resolution")

EAccuracyD=ureal(0,math.radians(0.029),label="Detector accuracy")
EResolutionD=ureal(0,math.radians(0.00003),label="Detector resolution")
EZeroD=ureal(0,tb.distribution['gaussian'](math.radians(0.1)),df=50,label="Detector axis zero")
EDetectorHeight=ureal(0,tb.distribution['gaussian'](0.5),df=50,label="Detector height")

# # Angle errors (degrees, converted to radians)
# EAccuracyU=ureal(0,math.radians(0.0065),label="Pitch accuracy")
# EResolutionU=ureal(0,math.radians(0.0002),label="Pitch resolution")
# EZeroU=ureal(0,tb.distribution['gaussian'](math.radians(0.05)),df=50,label="Pitch axis zero")
#
# EAccuracyV=ureal(0,math.radians(0.018),label="Yaw accuracy")
# EResolutionV=ureal(0,math.radians(0.00016),label="Yaw resolution")
# EZeroV=ureal(0,tb.distribution['gaussian'](math.radians(0.1)),df=50,label="Yaw axis zero")
#
# EAccuracyW=ureal(0,math.radians(0.055),label="Roll accuracy")
# EResolutionW=ureal(0,math.radians(0.0043),label="Roll resolution")
#
# EAccuracyD=ureal(0,math.radians(0.029),label="Detector accuracy")
# EResolutionD=ureal(0,math.radians(0.00003),label="Detector resolution")
# EZeroD=ureal(0,tb.distribution['gaussian'](math.radians(0.1)),df=50,label="Detector axis zero")
# EDetectorHeight=ureal(0,tb.distribution['gaussian'](0.5),df=50,label="Detector height")

# Length (mm)
LengthRod=ureal(499.965,tb.distribution['gaussian'](0.008/4.3),df=4,label="Length rod calibration")
ApertureDepth=ureal(3.4775,tb.distribution['gaussian'](0.0059),df=7,label="Aperture depth")
ELSetting=ureal(0,tb.distribution['gaussian'](0.1),df=50,label="Length setting")
Length=LengthRod-ApertureDepth-ELSetting


# Initialise functions
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
    L0=DeltaD+la.matmul(Rd,(L-DeltaD))-np.array([[0,0,Z]]).T
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