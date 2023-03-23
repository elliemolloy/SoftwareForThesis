# Code to save BRDF data in json format
import sigfig
import json

def brdfJson(Sample,BRDF,FileName):
    brdf={}
    brdf["metadata"]={}
    brdf["metadata"]["schema"]=r"https://bird-project.github.io/BRDF_JSON_schema_docs/"
    brdf["metadata"]["id"]=r"https://raw.githubusercontent.com/BiRD-project/BiRD_view/master/BRDF_JSON_schema/brdf_json_schema_v1.0.json"
    brdf["metadata"]["type"]="BRDF"
    brdf["metadata"]["timestamp"]="2022-04-11"
    brdf["metadata"]["provenance"]={}
    brdf["metadata"]["provenance"]["organization"]="MSL"
    brdf["metadata"]["provenance"]["location"]={}
    brdf["metadata"]["provenance"]["location"]["country"]="New Zealand"
    brdf["metadata"]["provenance"]["location"]["city"]="Lower Hutt"
    brdf["metadata"]["provenance"]["location"]["street"]="Gracefield Road"
    brdf["metadata"]["provenance"]["location"]["building_nr"]="69"
    brdf["metadata"]["provenance"]["location"]["postal_code"]="5010"
    brdf["metadata"]["provenance"]["email"]="annette.koo@measurement.govt.nz"
    brdf["metadata"]["provenance"]["contact_person"]="Annette Koo"
    brdf["metadata"]["description"]="MSL measurement results for BxDiff BRDF comparison."
    brdf["metadata"]["method"]="measurement"
    brdf["metadata"]["instrumentation"]={}
    brdf["metadata"]["instrumentation"]["name"]="MSL goniospectrophotometer"
    brdf["metadata"]["instrumentation"]["illumination_system"]={}
    brdf["metadata"]["instrumentation"]["illumination_system"]["name"]="Remote supercontinuum"
    brdf["metadata"]["instrumentation"]["illumination_system"]["source"]={}
    brdf["metadata"]["instrumentation"]["illumination_system"]["source"]["name"]="supercontinuum"
    brdf["metadata"]["instrumentation"]["illumination_system"]["source"]["type"]="laser"
    brdf["metadata"]["instrumentation"]["illumination_system"]["source"]["power"]={}
    brdf["metadata"]["instrumentation"]["illumination_system"]["source"]["power"]["value"]=5.5
    brdf["metadata"]["instrumentation"]["illumination_system"]["source"]["power"]["unit"]="W"
    brdf["metadata"]["instrumentation"]["illumination_system"]["source"]["wl_range"]={}
    brdf["metadata"]["instrumentation"]["illumination_system"]["source"]["wl_range"]["min_value"]=440
    brdf["metadata"]["instrumentation"]["illumination_system"]["source"]["wl_range"]["max_value"]=1600
    brdf["metadata"]["instrumentation"]["illumination_system"]["source"]["wl_range"]["unit"]="nm"
    brdf["metadata"]["instrumentation"]["illumination_system"]["beam"]={}
    brdf["metadata"]["instrumentation"]["illumination_system"]["beam"]["shape"]="circular"
    brdf["metadata"]["instrumentation"]["illumination_system"]["beam"]["dimensions"]={}
    brdf["metadata"]["instrumentation"]["illumination_system"]["beam"]["dimensions"]["radius"]={}
    brdf["metadata"]["instrumentation"]["illumination_system"]["beam"]["dimensions"]["radius"]["value"]=5
    brdf["metadata"]["instrumentation"]["illumination_system"]["beam"]["dimensions"]["radius"]["unit"]="mm"
    brdf["metadata"]["instrumentation"]["detection_system"]={}
    brdf["metadata"]["instrumentation"]["detection_system"]["name"]="MSL gonio detector"
    brdf["metadata"]["instrumentation"]["detection_system"]["sensors"]=[{}]
    brdf["metadata"]["instrumentation"]["detection_system"]["sensors"][0]["name"]="silicon diode"
    brdf["metadata"]["instrumentation"]["detection_system"]["sensors"][0]["spectral_response_range"]={}
    brdf["metadata"]["instrumentation"]["detection_system"]["sensors"][0]["spectral_response_range"]["min_value"]=300
    brdf["metadata"]["instrumentation"]["detection_system"]["sensors"][0]["spectral_response_range"]["max_value"]=1000
    brdf["metadata"]["instrumentation"]["detection_system"]["sensors"][0]["spectral_response_range"]["unit"]="nm"
    brdf["metadata"]["instrumentation"]["detection_system"]["aperture"]={}
    brdf["metadata"]["instrumentation"]["detection_system"]["aperture"]["name"]="detector aperture (Gonio 30.6 mm)"
    brdf["metadata"]["instrumentation"]["detection_system"]["aperture"]["shape"]="circular"
    brdf["metadata"]["instrumentation"]["detection_system"]["aperture"]["dimensions"]={}
    brdf["metadata"]["instrumentation"]["detection_system"]["aperture"]["dimensions"]["radius"]={}
    brdf["metadata"]["instrumentation"]["detection_system"]["aperture"]["dimensions"]["radius"]["value"]=15.32090
    brdf["metadata"]["instrumentation"]["detection_system"]["aperture"]["dimensions"]["radius"]["unit"]="mm"
    brdf["metadata"]["instrumentation"]["detection_system"]["aperture"]["dimensions"]["radius"]["uncertainty"]=0.00098
    brdf["metadata"]["instrumentation"]["detection_system"]["aperture"]["dimensions"]["radius"]["uncertainty_unit"]="mm"
    brdf["metadata"]["instrumentation"]["detection_system"]["solid_angle"]={}
    brdf["metadata"]["instrumentation"]["detection_system"]["solid_angle"]["value"]=0.00095225
    brdf["metadata"]["instrumentation"]["detection_system"]["solid_angle"]["unit"]="sr"
    brdf["metadata"]["instrumentation"]["detection_system"]["solid_angle"]["uncertainty"]=4.0E-7
    brdf["metadata"]["instrumentation"]["detection_system"]["solid_angle"]["uncertainty_unit"]="sr"
    brdf["metadata"]["software"]="NA"
    brdf["metadata"]["environment"]={}
    brdf["metadata"]["environment"]["temperature"]={}
    brdf["metadata"]["environment"]["temperature"]["value"]=21.9
    brdf["metadata"]["environment"]["temperature"]["unit"]="°C"
    brdf["metadata"]["environment"]["temperature"]["uncertainty"]=0.3
    brdf["metadata"]["environment"]["temperature"]["uncertainty_unit"]="°C"
    brdf["metadata"]["environment"]["relative_humidity"]={}
    brdf["metadata"]["environment"]["relative_humidity"]["value"]=56.7
    brdf["metadata"]["environment"]["relative_humidity"]["unit"]="%"
    brdf["metadata"]["environment"]["relative_humidity"]["uncertainty"]=5.5
    brdf["metadata"]["environment"]["relative_humidity"]["uncertainty_unit"]="%"

    brdf["metadata"]["sample"]={}
    brdf["metadata"]["sample"]["name"]=Sample
    brdf["metadata"]["sample"]["type"]="diffuse reflectance sample"
    brdf["metadata"]["sample"]["shape"]="square"
    brdf["metadata"]["sample"]["dimensions"]={}
    brdf["metadata"]["sample"]["dimensions"]["length"]={}
    brdf["metadata"]["sample"]["dimensions"]["length"]["unit"]="mm"
    brdf["metadata"]["sample"]["dimensions"]["width"]={}
    brdf["metadata"]["sample"]["dimensions"]["width"]["unit"]="mm"

    if Sample=="SN 5A":
        brdf["metadata"]["sample"]["dimensions"]["length"]["value"]=225
        brdf["metadata"]["sample"]["dimensions"]["width"]["value"]=225
    else:
        brdf["metadata"]["sample"]["dimensions"]["length"]["value"]=225
        brdf["metadata"]["sample"]["dimensions"]["width"]["value"]=225
    brdf["metadata"]["sample"]["zero_azimuth_location"]="according to the marking on the back of the sample"

    brdf["data"]={}
    brdf["data"]["theta_i"]={}
    brdf["data"]["theta_i"]["unit"]="°"
    brdf["data"]["theta_i"]["values"]=[45,0,45,45,45]
    brdf["data"]["phi_i"]={}
    brdf["data"]["phi_i"]["unit"]="°"
    brdf["data"]["phi_i"]["values"]=[0,0,0,0,0]
    brdf["data"]["theta_r"]={}
    brdf["data"]["theta_r"]["unit"]="°"
    brdf["data"]["theta_r"]["values"]=[0,45,45,50.1,60]
    brdf["data"]["phi_r"]={}
    brdf["data"]["phi_r"]["unit"]="°"
    brdf["data"]["phi_r"]["values"]=[0,180,90,146.6,180]
    brdf["data"]["BRDF"]={}
    brdf["data"]["BRDF"]["unit"]="1/sr"
    brdf["data"]["BRDF"]["uncertainty"]={}
    brdf["data"]["BRDF"]["uncertainty"]["unit"]="1/sr"
    brdf["data"]["wavelength_i"]={}
    brdf["data"]["wavelength_i"]["unit"]="nm"
    brdf["data"]["wavelength_i"]["values"]=[550,550,550,550,550]
    brdf["data"]["wavelength_r"]={}
    brdf["data"]["wavelength_r"]["unit"]="nm"
    brdf["data"]["wavelength_r"]["values"]=[550,550,550,550,550]
    brdf["data"]["polarization_i"]={}
    brdf["data"]["polarization_i"]["notation"]="sp"
    brdf["data"]["polarization_i"]["values"]=["u","u","u","u","u"]
    brdf["data"]["polarization_r"]={}
    brdf["data"]["polarization_r"]["notation"]="sp"
    brdf["data"]["polarization_r"]["values"]=["u","u","u","u","u"]

    brdfValues=[]
    uBRDF=[]
    df=[]
    for i in range(0,5):
        uBRDF.append(sigfig.round(BRDF[i].u,sigfigs=2))
        nPlaces=len(str(uBRDF[i]).split(".")[1])
        brdfValues.append(round(BRDF[i].x,nPlaces))
        df.append(sigfig.round(BRDF[i].df,sigfigs=2))

    brdf["data"]["BRDF"]["value"]=brdfValues
    brdf["data"]["BRDF"]["uncertainty"]["value"]=uBRDF
    brdf["data"]["BRDF"]["comments"]={}
    brdf["data"]["BRDF"]["comments"]["degrees_of_freedom"]=df

    with open(FileName,'w') as f:
        json.dump(brdf,f,indent=2)

    return brdf