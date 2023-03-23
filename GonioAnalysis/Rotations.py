import numpy as np
from GonioAnalysis.ReadingData import *

"""
Functions in this file:
    ApplyRotations(NWavelengths,NTheta,NPhi,AllData,Aperture=30,Data180=False,SphereDet=False,BxDiffBRDF=False,RollZero=0)
    GenerateRandomErrors(Angle,OldAngle,EAcc,ERes,uEAcc,uERes,Axis,i,j=None)
    ToThetaPhi(U,V,W,D)
    ToUVWD(ti,phii,td,pd)
    RotateVector(u,v,w,a)
    RotateStages(u,v,w,a)
    ZOffset(u,v,w)
    RotateDetector(u,v,w,d,L)
    CalculateThetaPhi(i,j,k,i1,j1,k1,L1)
"""


def ApplyRotations(NWavelengths,NTheta,NPhi,AllData,Aperture=30,Data180=False,SphereDet=False,BxDiffBRDF=False,
                   RollZero=0,ReturnUVWD=False,PitchSampleHoming=0,YawSampleHoming=0):
    """
    Applies the rotations to calculate the values of theta and phi.
    :param AllData:array with all the data in
    :param Aperture17:Boolean
    :param Data180:Boolean says if data measured 180 degrees opposite is included (for spectralon test)
    :return:
    """
    # Select aperture depth
    if Aperture==30:
        apertureDepth=ApertureDepth
    elif Aperture==17:
        apertureDepth=ApertureDepth17
    elif Aperture==8:
        apertureDepth=ApertureDepth08
    elif Aperture==4:
        apertureDepth=ApertureDepth04
    else:
        apertureDepth=0

    nPoints=len(AllData)
    LAll=la.uarray([ureal(0,0) for i in range(0,nPoints)])
    tdAll=la.uarray([ureal(0,0) for i in range(0,nPoints)])
    tiAll=la.uarray([ureal(0,0) for i in range(0,nPoints)])
    phiiAll=la.zeros(nPoints)
    pdAll=la.zeros(nPoints)

    if ReturnUVWD:
        uAll=la.zeros(nPoints)
        vAll=la.zeros(nPoints)
        wAll=la.zeros(nPoints)
        dAll=la.zeros(nPoints)

    # Initialise arrays to store the random errors
    EAccuracyU=la.uarray([ureal(0,0) for i in range(0,nPoints)])
    EAccuracyV=la.uarray([ureal(0,0) for i in range(0,nPoints)])
    EAccuracyW=la.uarray([ureal(0,0) for i in range(0,nPoints)])
    EAccuracyD=la.uarray([ureal(0,0) for i in range(0,nPoints)])
    EResolutionU=la.uarray([ureal(0,0) for i in range(0,nPoints)])
    EResolutionV=la.uarray([ureal(0,0) for i in range(0,nPoints)])
    EResolutionW=la.uarray([ureal(0,0) for i in range(0,nPoints)])
    EResolutionD=la.uarray([ureal(0,0) for i in range(0,nPoints)])

    # Initialise angle positions and flags
    UOld=-999
    VOld=-999
    WOld=-999
    DOld=-999

    # Find angle uncertainties for each measurement
    for i in range(0, nPoints):
        # Extract the stage and slew ring angles
        [u,v,w,d]=AllData[i,1:5]

        # Convert angles to radians
        u=np.radians(u)
        v=np.radians(v)
        w=np.radians(w)
        d=np.radians(d)

        # Find polarisation of data point
        pol=AllData[i,5]
        if pol==0:
            polarisation='s'
        else:
            polarisation='p'

        # Check which angles moved, and add appropriate errors to angles
        # Generate random errors for each axis
        [EAccuracyU,EResolutionU]=GenerateRandomErrors(u,UOld,EAccuracyU,EResolutionU,uEAccuracyU,uEResolutionU,dfAccuracyU,'Pitch',i)
        [EAccuracyV,EResolutionV]=GenerateRandomErrors(v,VOld,EAccuracyV,EResolutionV,uEAccuracyV,uEResolutionV,dfAccuracyV,'Yaw',i)
        [EAccuracyW,EResolutionW]=GenerateRandomErrors(w,WOld,EAccuracyW,EResolutionW,uEAccuracyW,uEResolutionW,dfAccuracyW,'Roll',i)
        [EAccuracyD,EResolutionD]=GenerateRandomErrors(d,DOld,EAccuracyD,EResolutionD,uEAccuracyD,uEResolutionD,dfAccuracyD,'Detector',i)

        # Add errors to angles
        u=u-EAccuracyU[i]-EResolutionU[i]-EZeroU-PitchSampleHoming
        v=v-EAccuracyV[i]-EResolutionV[i]-EZeroV-YawSampleHoming
        w=w-EAccuracyW[i]-EResolutionW[i]-RollZero

        # Pick the right zero position error for the detector
        if AllData[i,-1]<44088:
            d=d-EAccuracyD[i]-EResolutionD[i]-EZeroD1
        elif AllData[i,-1]<44105:
            d=d-EAccuracyD[i]-EResolutionD[i]-EZeroD2
        elif AllData[i,-1]<44259:
            d=d-EAccuracyD[i]-EResolutionD[i]-EZeroD3
        else:
            d=d-EAccuracyD[i]-EResolutionD[i]-EZeroD4

        if ReturnUVWD:
            uAll[i]=u
            vAll[i]=v
            wAll[i]=w
            dAll[i]=d

        # Apply rotations to basis vectors (i0,j0,k0 are the unit vectors in lab space, i1,j1,k1 are the rotated vectors)
        i0=la.uarray([[1,0,0]]).T
        j0=la.uarray([[0,1,0]]).T
        k0=la.uarray([[0,0,1]]).T
        i1=RotateStages(u,v,w,i0,polarisation)
        j1=RotateStages(u,v,w,j0,polarisation)
        k1=RotateStages(u,v,w,k0,polarisation)

        # Set the length with the right length setting error
        if SphereDet:
            l=result(LengthRod-ApertureDepthSphere-ELSetting4-EApertureDepth)
        else:
            if AllData[i,-1]<44054:
                l=result(LengthRod-apertureDepth-ELSetting1-EApertureDepth)
            elif AllData[i,-1]<44104:
                l=result(LengthRod-apertureDepth-ELSetting2-EApertureDepth)
            elif AllData[i,-1]<44260:
                l=result(LengthRod-apertureDepth-ELSetting3-EApertureDepth)
            else:
                l=result(LengthRod-apertureDepth-ELSetting4-EApertureDepth)

        # Pick the appropriate detector height error, then rotate detector
        if AllData[i,-1]<44074:
            EDetectorHeight=EDetectorHeight1
        elif AllData[i,-1]<44088:
            EDetectorHeight=EDetectorHeight2
        elif AllData[i,-1]<44104:
            EDetectorHeight=EDetectorHeight3
        elif AllData[i,-1]<44259:
            EDetectorHeight=EDetectorHeight4
        else:
            EDetectorHeight=EDetectorHeight5

        L1=RotateDetector(u,v,w,d,la.uarray([[0,EDetectorHeight,l]]).T,polarisation)

        # Calculate true length
        L=sqrt(la.dot(L1.T,L1))[0][0]

        # Normalise L1 to get unit vector for calculating thetas and phis
        LHat=L1/L

        # Calculate thetas and phis
        [ti,phii,td,pd]=CalculateThetaPhi(i0,j0,k0,i1,j1,k1,LHat)
        LAll[i]=L
        tdAll[i]=td
        tiAll[i]=ti
        phiiAll[i]=phii
        if pd<-0.1:
            pdAll[i]=pd+2*np.pi
        else:
            pdAll[i]=pd

    # Put into the right format
    length=CreateUArray(NWavelengths,NTheta,NPhi)
    thetaD=CreateUArray(NWavelengths,NTheta,NPhi)
    thetaI=CreateUArray(NWavelengths,NTheta,NPhi)
    phiI=CreateUArray(NWavelengths,NTheta,NPhi)
    phiD=CreateUArray(NWavelengths,NTheta,NPhi)

    if ReturnUVWD:
        u2=CreateUArray(NWavelengths,NTheta,NPhi)
        v2=CreateUArray(NWavelengths,NTheta,NPhi)
        w2=CreateUArray(NWavelengths,NTheta,NPhi)
        d2=CreateUArray(NWavelengths,NTheta,NPhi)

    if Data180:
        length180=CreateUArray(NWavelengths,NTheta-2,1)
        thetaD180=CreateUArray(NWavelengths,NTheta-2,1)
    row=0
    for pol in range(0,2):
        for w in range(0,NWavelengths):
            for t in range(0,NTheta):
                for p in range(0,NPhi):
                    length[w,pol,t,p]=LAll[row]
                    thetaD[w,pol,t,p]=tdAll[row]
                    thetaI[w,pol,t,p]=tiAll[row]
                    phiI[w,pol,t,p]=phiiAll[row]
                    phiD[w,pol,t,p]=pdAll[row]
                    if ReturnUVWD:
                        u2[w,pol,t,p]=uAll[row]
                        v2[w,pol,t,p]=vAll[row]
                        w2[w,pol,t,p]=wAll[row]
                        d2[w,pol,t,p]=dAll[row]
                    row+=1
            if Data180:
                for t in range(0,NTheta-2):
                    length180[w,pol,t]=LAll[row]
                    thetaD180[w,pol,t]=tdAll[row]
                    row+=1
    if BxDiffBRDF:
        toReturn=[length,thetaD,thetaI,phiI,phiD]
    elif ReturnUVWD:
        toReturn=[length,thetaD,phiD,u2,v2,w2,d2]
    else:
        if Data180:
            toReturn=[length,length180,thetaD,thetaD180,thetaI]
        else:
            toReturn=[length,thetaD,thetaI]
    return toReturn


def GenerateRandomErrors(Angle,OldAngle,EAcc,ERes,uEAcc,uERes,DFAcc,Axis,i,j=None):
    """
    Generates the random accuracy and resolution errors if the axis moves, otherwise sets the random errors to be the same
    as the previous value.
    """
    if j is None:
        if Angle!=OldAngle:
            # If the axis moves
            EAcc[i]=ureal(0,tb.distribution['gaussian'](uEAcc),df=DFAcc,label=Axis+', Accuracy = '+str(math.degrees(Angle)))
            ERes[i]=ureal(0,tb.distribution['uniform'](uERes),label=Axis+', Resolution = '+str(math.degrees(Angle)))
        else:
            # If the axis does not move
            EAcc[i]=EAcc[i-1]
            ERes[i]=ERes[i-1]
    else:
        if Angle!=OldAngle:
            # If the axis moves
            EAcc[j,i]=ureal(0,tb.distribution['gaussian'](uEAcc),df=DFAcc,label=Axis+', Accuracy = '+str(math.degrees(Angle)))
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


def RotateVector(u,v,w,a,Polarisation):
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
    if Polarisation=='s':
        DeltaPDisplaced=DeltaP+la.uarray([[0,SBeamDisplacementY,0]]).T
        DeltaYDisplaced=DeltaY+la.uarray([[SBeamDisplacementX,0,0]]).T
        DeltaRDisplaced=DeltaR+la.uarray([[SBeamDisplacementX,SBeamDisplacementY,0]]).T
    else:
        DeltaPDisplaced=DeltaP+la.uarray([[0,PBeamDisplacementY,0]]).T
        DeltaYDisplaced=DeltaY+la.uarray([[PBeamDisplacementX,0,0]]).T
        DeltaRDisplaced=DeltaR+la.uarray([[PBeamDisplacementX,PBeamDisplacementY,0]]).T
    a0=DeltaYDisplaced+la.matmul(Ry,(DeltaPDisplaced+la.matmul(Rp,(DeltaRDisplaced+la.matmul(Rr,(a-DeltaRDisplaced))-
                                                                   DeltaPDisplaced))-DeltaYDisplaced))
    return a0


def RotateStages(u,v,w,a,Polarisation):
    """
    Apply the rotation matrices to the vector, a, given rotation angles u,v,w,d
    """
    # Rotate origin
    o=la.uarray([[0,0,0]]).T
    o0=RotateVector(u,v,w,o,Polarisation)

    # Apply rotation to vector
    a0=RotateVector(u,v,w,a,Polarisation)-o0
    return a0


def ZOffset(u,v,w,Polarisation):
    """
    Calculate the Z offset when stages are rotated by angles u,v,w
    """
    # Rotate surface normal
    k=la.uarray([[0,0,1]]).T
    k1=RotateStages(u,v,w,k,Polarisation)

    # Rotate origin
    o=la.uarray([[0,0,0]]).T
    o1=RotateVector(u,v,w,o,Polarisation)

    # Calculate Z offset
    Z=la.dot(k1.T,o1)[0,0]/k1[2,0]
    return Z


def RotateDetector(u,v,w,d,L,Polarisation):
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
    Z=ZOffset(u,v,w,Polarisation)
    if Polarisation=='s':
        EBeamDisplacement=la.uarray([[SBeamDisplacementX,0,0]]).T
    else:
        EBeamDisplacement=la.uarray([[PBeamDisplacementX,0,0]]).T
    DeltaDDisplaced=DeltaD+EBeamDisplacement
    L0=DeltaDDisplaced+la.matmul(Rd,(L-DeltaDDisplaced))-np.array([[0,0,Z]]).T
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


