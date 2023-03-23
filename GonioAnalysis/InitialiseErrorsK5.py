from GTC import *

# Software Version = v1.1

# Beam displacement errors (mm)
SBeamDisplacementX=ureal(0,tb.distribution['gaussian'](0.5),label="Beam displacement, s pol")
SBeamDisplacementY=ureal(0,tb.distribution['gaussian'](0.5),label="Beam displacement, s pol")
PBeamDisplacementX=ureal(0,tb.distribution['gaussian'](0.5),label="Beam displacement, p pol")
PBeamDisplacementY=ureal(0,tb.distribution['gaussian'](0.5),label="Beam displacement, p pol")

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

TP=TP/(sqrt(1+TPy**2+TPz**2))
TY=TY/(sqrt(1+TYx**2+TYz**2))
TR=TR/(sqrt(1+TRx**2+TRy**2))
TD=TD/(sqrt(1+TDx**2+TDz**2))

# Angle errors (degrees, converted to radians)
uEAccuracyU=math.radians(0.0065)
dfAccuracyU=7
uEResolutionU=math.radians(0.0002)
EZeroU=ureal(math.radians(0),tb.distribution['gaussian'](math.radians(0.05)),df=50,label="Pitch axis zero")

uEAccuracyV=math.radians(0.018)
dfAccuracyV=6
uEResolutionV=math.radians(0.00016)
EZeroV=ureal(math.radians(0),tb.distribution['gaussian'](math.radians(0.05)),df=50,label="Yaw axis zero")

uEAccuracyW=math.radians(0.055)
dfAccuracyW=11
uEResolutionW=math.radians(0.0043)
EZeroW=ureal(math.radians(0),tb.distribution['gaussian'](math.radians(0.2)),df=50,label="Roll axis zero")

uEAccuracyD=math.radians(0.029)
dfAccuracyD=11
uEResolutionD=math.radians(0.00003)
EZeroD1=ureal(math.radians(0),tb.distribution['gaussian'](math.radians(0.1)),df=50,label="Detector axis zero")
EZeroD2=ureal(0,tb.distribution['gaussian'](math.radians(0.1)),df=50,label="Detector axis zero")
EZeroD3=ureal(0,tb.distribution['gaussian'](math.radians(0.1)),df=50,label="Detector axis zero")
EZeroD4=ureal(0,tb.distribution['gaussian'](math.radians(0.1)),df=50,label="Detector axis zero")

# Dark current
# DetectorDark7=ureal(-5e-06,5e-06,df=inf,label="Detector dark gain = 7") # detector dark for K5 references
DetectorDark7=ureal(2e-06,2e-06,df=55,label="Detector dark gain = 7") # detector dark for S7 references
DetectorDark9=ureal(0.00002,0.00001,df=inf,label="Detector dark, gain 9")
# DetectorDark8=ureal(0.000002,0.000002,df=inf,label="Detector dark, gain 8")
# DetectorDark8=ureal(0.000003,0.000003,df=inf,label="Detector dark, gain 8")
# DetectorDark8=ureal(4.4e-6,2.1e-6,df=24,label="Detector dark, gain 8")
DetectorDark8=ureal(2.9e-6,1.7e-6,df=inf,label="Detector dark, gain 8")
DetectorDarkSphere=ureal(-0.00016,0.00002,df=inf,label="Sphere detector dark")
# MonitorDark=ureal(-0.00012,2e-5,df=inf,label="Monitor dark")
MonitorDarkK52=ureal(-5.5e-5,2e-5,df=inf,label="Monitor dark")
MonitorDarkK53=ureal(-8.5e-5,2e-5,df=inf,label="Monitor dark")
MonitorDarkK54=ureal(-3.4e-5,2e-5,df=inf,label="Monitor dark")
# MonitorDark=ureal(-0.000254,0.000057,df=22,label="Monitor dark")
MonitorDark=ureal(-9.5e-6,8.5e-7,df=inf,label="Monitor dark")
MonitorDarkMay2021=ureal(-6.5e-7,6e-7,df=inf,label="Monitor dark (May 2021)")

# Uncertainties and degrees of freedom in dark current for S7
uDetectorDark8=2e-6
dfDetectorDark8=50
uMonitorDark1=2e-4
dfMonitorDark1=21
uMonitorDark2=5e-6
dfMonitorDark2=24

# MonitorDark=ureal(-0.000009,0.000057,df=22,label="Monitor dark") # for BTDF
# DetectorDark8=ureal(3e-6,2e-6,df=24,label="Detector dark, gain 8") # for BTDF

# Polariser position
# UPolariserPositionS=0.00042
# UPolariserPositionP=0.0021

# Values for BxDiff BRDF
UPolariserPositionS=0.0002
UPolariserPositionP=0.0006


# Gain errors
EGainChange=ureal(0.009997250111094555,tb.distribution['gaussian'](5.765087725266612e-06),df=64.56760106622126,label='Gain ratio 7/9, Electrical 2018')
EGainChange79=ureal(0.00999741,tb.distribution['gaussian'](0.00000018),df=25,label='Gain ratio 7/9, Photometry 2018')
EGainChange78=ureal(0.1004302,tb.distribution['gaussian'](0.0000017),df=23.9,label='Gain ratio 7/8, Photometry 2018')

# Correction Errors
EDetectorModel=ureal(0,tb.distribution['gaussian'](0.0006),df=10,label='Detector uniformity model')
EViewFactor=ureal(0,0.00000002,df=10,label='View factor quantised beam')
# uNoSample=0.0003 # for K5
uNoSample=0.00015 # for S7
dfNoSample=50
EStrayLight1=0.998966
uStrayLight1=0.000048
EUStrayLight=ureal(0,0.0003,df=12,label='Stray light correction') # applying uncertainty as fully correlated
EStrayLight2m=0.0000090
EStrayLight2c=0.0057
uStrayLight2=0.00042
ENoSampleBTDF=ureal(0,1.5e-6,label='No sample, BxDiff BTDF') # Absolute uncertainty for no sample
EInterpolation=ureal(0,0.0010,df=53,label='Interpolation error')
EInterpolationMSL5=ureal(0,0.0020,df=53,label='Interpolation error')
uRefRatioSuperK=0.002 # Relative uncertainty in reference ratio, superK
uRefRatioLDLS=0.0005 # Relative uncertainty in reference ratio, LDLS
uRefRatio360=0.003 # Relative uncertainty in reference ratio, 360 nm

# Homing uncertainties
UPitchSampleHoming=math.radians(0.3)
UYawSampleHoming=math.radians(0.1)
dfSampleHoming=19

# Beam imaging data (mm)
EBeamData=ureal(0,tb.distribution['gaussian'](0.5),df=10,label='Beam imaging data')

# Wavelength (nm)
# For K5
# uWavelengthLDLS=0.063
# uWavelengthSuperK=0.16
# dfWavelengthLDLS=40
# dfWavelengthSuperK=7

# For S7
uWavelengthLDLS=0.18
dfWavelengthLDLS=68
uWavelengthSuperK=0.33
dfWavelengthSuperK=47

# Length (mm)
LengthRod=ureal(499.965,tb.distribution['gaussian'](0.008/4.3),df=2,label="Length rod calibration")
ApertureDepth=ureal(3.4775,tb.distribution['gaussian'](0.0059),df=7,label="Aperture depth")
ApertureDepthSphere=ureal(3.445,tb.distribution['gaussian'](0.0090),df=11,label="Aperture depth")
ApertureDepth17=ureal(3.4763,tb.distribution['gaussian'](0.0053),df=7,label="Aperture depth")
ApertureDepth08=ureal(3.544,tb.distribution['gaussian'](0.0065),df=6,label="Aperture depth")
ApertureDepth04=ureal(3.5863,tb.distribution['gaussian'](0.0074),df=7,label="Aperture depth")
EApertureDepthResolution=ureal(0,tb.distribution['uniform'](0.01/2),df=inf,label="Aperture depth gauge resolution")
EApertureDepthFeed=ureal(0,tb.distribution['gaussian'](0.002/2),df=50,label="Aperture depth gauge feed error")
EApertureDepthZero=ureal(0,tb.distribution['gaussian'](0.001/2),df=50,label="Aperture depth gauge zero error")
EApertureDepthFlatness=ureal(0,tb.distribution['gaussian'](0.0002/2),df=50,label="Aperture depth gauge flatness")
EApertureDepthParallelism=ureal(0,tb.distribution['gaussian'](0.001/2),df=50,label="Aperture depth gauge parallelism")
EApertureDepth=result(EApertureDepthResolution+EApertureDepthFeed+EApertureDepthZero+EApertureDepthFlatness+EApertureDepthParallelism)
ELSetting1=ureal(0,tb.distribution['gaussian'](0.1),df=50,label="Length setting")
ELSetting2=ureal(0,tb.distribution['gaussian'](0.1),df=50,label="Length setting")
ELSetting3=ureal(0,tb.distribution['gaussian'](0.1),df=50,label="Length setting")
ELSetting4=ureal(0,tb.distribution['gaussian'](0.1),df=50,label="Length setting")
ELSetting=ureal(0,tb.distribution['gaussian'](0.1),df=50,label="Length setting")

# Detector height (mm)
EDetectorHeight1=ureal(0,tb.distribution['gaussian'](0.5),df=50,label="Detector height")
EDetectorHeight2=ureal(0,tb.distribution['gaussian'](0.5),df=50,label="Detector height")
EDetectorHeight3=ureal(0,tb.distribution['gaussian'](0.5),df=50,label="Detector height")
EDetectorHeight4=ureal(0,tb.distribution['gaussian'](0.5),df=50,label="Detector height")
EDetectorHeight5=ureal(0,tb.distribution['gaussian'](0.5),df=50,label="Detector height")

# Aperture diameter (mm)
M30=2*ureal(15.3209,tb.distribution['gaussian'](0.0022/2),df=47,label="Aperture radius")
# M30=2*ureal(15.3209,tb.distribution['gaussian'](0.0011),df=50,label="Aperture radius") # Updated value
M17=2*ureal(8.7705,tb.distribution['gaussian'](0.0014/2),df=63,label="Aperture radius")
M4=2*ureal(2.1645,0.0019/2,df=35,label="Aperture radius")
M8=2*ureal(4.3372,0.0024/2,df=35,label="Aperture radius")

# Correction files
VFDataDirectory=r'G:\Shared drives\MSL - Photometry & Radiometry\STANDARDS\GonioSpectrometry\K5 Comparison 2020\Corrections\VF Calculations\\'
VFSensitivityCoefficients17='VF Beam Data Sensitivity Coefficients 17 mm.txt'
VFSensitivityCoefficients30='VF Beam Data Sensitivity Coefficients 30 mm.txt'
VFDataFileLDLS17='Updated VF Data LDLS 17 mm.txt'
VFDataFileLDLS30='Updated VF Data LDLS 30 mm.txt'
VFDataFileSuperK17='Updated VF Data Supercontinuum 17 mm.txt'
VFDataFileSuperK30='Updated VF Data Supercontinuum 30 mm.txt'
VFDataFileNoBeamImaging=r'G:\Shared drives\MSL - Photometry & Radiometry\STANDARDS\GonioSpectrometry\S7 2022\Corrections\View factor corrections.txt'

# NoSampleSuperK=r'G:\Shared drives\MSL - Photometry & Radiometry\STANDARDS\GonioSpectrometry\K5 Comparison 2020\Measurements\No sample\No Sample Correction Supercontinuum.txt'
# NoSampleSuperK=r'G:\Shared drives\MSL - Photometry & Radiometry\STANDARDS\GonioSpectrometry\K5 Comparison 2020\Measurements\No sample\No Sample reflectance Correction Supercontinuum.txt' # K5
NoSampleSuperK=r'G:\Shared drives\MSL - Photometry & Radiometry\STANDARDS\GonioSpectrometry\S7 2022\Corrections\No sample diffR correction S7.txt' # S7

# DetUniformityDirectory=r'G:\Shared drives\MSL - Photometry & Radiometry\STANDARDS\GonioSpectrometry\K5 Comparison 2020\Corrections\Detector Non-Uniformity Calculations\\' # for K5
# DetUSensitivityCoefficientsLDLS='LDLS Detector Uniformity Beam Imaging Error.txt'
# DetUSensitivityCoefficientsSuperK='Supercontinuum Detector Uniformity Beam Imaging Error.txt'
# DetUDataFileLDLS17='LDLS Diffuse 12 October Data 17 mm.txt'
# DetUDataFileLDLS30='LDLS Diffuse 12 October Data 30 mm.txt'
# DetUDataFileSuperK17='Supercontinuum Diffuse 19 October Data 17 mm.txt'
# DetUDataFileSuperK30='Supercontinuum Diffuse 19 October Data 30 mm.txt'
# DetUDataFile2022_17='2022 Calculations, 17 mm aperture, using measured data.txt'
# DetUDataFile2022_30='2022 Calculations, 30 mm aperture, using measured data.txt'

DetUniformityDirectory=r'G:\Shared drives\MSL - Photometry & Radiometry\STANDARDS\GonioSpectrometry\S7 2022\Corrections\\' # for S7
DetUDataFile2022_30='Detector correction.txt'

# Sample sensitivity coefficient files
SampleSensitivityCoefficientDir=r'G:\Shared drives\MSL - Photometry & Radiometry\STANDARDS\GonioSpectrometry\K5 Comparison 2020\Sensitivity Coefficients\\'
S7SampleSensitivityCoefficientDir=r'G:\Shared drives\MSL - Photometry & Radiometry\STANDARDS\GonioSpectrometry\S7 2022\Sensitivity coefficients\\'

# Wavelength
WavelengthSensitivityU=0.005 # set uncertainty for wavelength sensitivity coefficient for wavelengths above 440 nm.
WavelengthSensitivityDF=5 # set df for wavelength sensitivity coefficient for wavelengths above 440 nm.
T13WavelengthSensitivityCoefficients='T13 Wavelength Sensitivity Coefficients.txt'
P15WavelengthSensitivityCoefficients='P15 Wavelength Sensitivity Coefficients2.txt'
PTB41WavelengthSensitivityCoefficients='PTB41 Wavelength Sensitivity Coefficients.txt'
Grey40WavelengthSensitivityCoefficients='MSL 40% Grey Wavelength Sensitivity Coefficients.txt'
Grey5WavelengthSensitivityCoefficients='MSL 5% Grey Wavelength Sensitivity Coefficients.txt'
S6IIWavelengthSensitivityCoefficients='S6-II Wavelength Sensitivity Coefficients.txt'
S6IIIWavelengthSensitivityCoefficients='S6-III Wavelength Sensitivity Coefficients.txt'

# Theta d
T13ThetaDSensitivityCoefficients='T13 Theta_d Sensitivity Coefficients.txt'
P15ThetaDSensitivityCoefficients='P15 Theta_d Sensitivity Coefficients.txt'
PTB41ThetaDSensitivityCoefficients='PTB41 Theta_d Sensitivity Coefficients.txt'
Grey40ThetaDSensitivityCoefficients='MSL 40% Grey Theta_d Sensitivity Coefficients.txt'
Grey5ThetaDSensitivityCoefficients='MSL 5% Grey Theta_d Sensitivity Coefficients.txt'
S6IIThetaDSensitivityCoefficients='S6-II Theta_d Sensitivity Coefficients.txt'
S6IIIThetaDSensitivityCoefficients='S6-III Theta_d Sensitivity Coefficients.txt'

# Theta i
T13ThetaISensitivityCoefficients='T13 Theta_i Yaw Sensitivity Coefficient.txt'
P15ThetaISensitivityCoefficients='P15 Theta_i Yaw Sensitivity Coefficient.txt'
PTB41ThetaISensitivityCoefficients='PTB41 Theta_i Yaw Sensitivity Coefficient.txt'
Grey40ThetaISensitivityCoefficients='MSL 40% Grey Theta_i Yaw Sensitivity Coefficient.txt'
Grey5ThetaISensitivityCoefficients='MSL 5% Grey Theta_i Yaw Sensitivity Coefficient.txt'
S6IIThetaISensitivityCoefficients='S6-II Theta_i Yaw Sensitivity Coefficient.txt'
S6IIIThetaISensitivityCoefficients='S6-III Theta_i Yaw Sensitivity Coefficient.txt'

#Interpolation errors
InterpolationCorrectionFile=r'G:\Shared drives\MSL - Photometry & Radiometry\STANDARDS\GonioSpectrometry\S7 2022\Corrections\Interpolation error.txt'