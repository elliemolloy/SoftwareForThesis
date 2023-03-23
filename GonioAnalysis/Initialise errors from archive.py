from GTC import *

# Read archived files of uncertain numbers to initialise errors
LengthDirectory=r'G:\Shared drives\MSL - Photometry & Radiometry\QUAL\P&R Standards Files\Length\\'

f=open(LengthDirectory+'Length_1192_2020 (gonio apertures).json','r')
a=pr.loads_json(f.read())
f.close()
M17=2*a['gonio17']
M30=2*a['gonio30']

f=open(LengthDirectory+'Length 1182_2020 (gonio length rod).json','r')
a=pr.loads_json(f.read())
f.close()
LengthRod=a['gonioLengthRod']

f=open(LengthDirectory+'Metrology Calibration Services 1894503, Depth Micrometer 902887.json','r')
a=pr.loads_json(f.read())
f.close()
EApertureDepthResolution=a['resolution']
EApertureDepthFeed=a['feed']
EApertureDepthZero=a['zero']
EApertureDepthFlatness=a['flatness']
EApertureDepthParallelism=a['parallelism']
EApertureDepth=result(EApertureDepthResolution+EApertureDepthFeed+EApertureDepthZero+EApertureDepthFlatness+EApertureDepthParallelism)