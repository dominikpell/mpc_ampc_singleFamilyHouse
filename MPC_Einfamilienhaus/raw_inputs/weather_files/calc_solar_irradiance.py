# -*- coding: utf-8 -*-
"""
Created on Fri Aug  2 09:25:22 2019

@author: she

from: https://teheesen.net/python-skripte-zur-berechnung-der-sonneneinstrahlung-in-die-geneigte-ebene/
"""

import datetime
import math
import calendar
import numpy as np
import pandas as pd
from datetime import datetime

def calc_tilted_irradiance(timestamp, timezone, location, orientation, A, E_hor):
        
    """ 
    Calculaction of the direct, diffuse and reflected irradiance in the tilted module plane with the isotropic sky diffuse model
    
    
    Parameters
    ----------   
    timestamp : list of [actual date as str, timezone offset as numeric]
        actual date is a string "YYYY-mm-dd HH:MM:SS"
        timezone offset is the offset from UTC (for Germany +1 in winter and +2 in summer)
    location : list with [longitude as numeric, latitude as numeric]
        longitude of the location of the PV system in degree (0° is Greenwich, positive values to the east)
        latitude of the location of the PV system in degree (-90° south pole, 0° is equator and +90° north pole)
    orientation : list with [azimuth angle as numeric, inclination angle as numeric]
        azimuth angle (horizontal orientation) of the PV system (0° north, 90° east, 180° south, 270° west)
        inclination angle of the PV system (0° is horizontally mounted, 90° is vertically mounted)
    A : Albedo as numeric
        Reflection factor of the ground: Default value is 0.2. Larger values show a higher reflection value
    E_hor : list with [direct horizontal irradiance as numeric, diffuse horizontal irradiance as numeric]
        direct horizontal irradiance per square meter
        diffuse horizontal irradiance per square meter
        
    Returns
    -------
    titled irradiance : tuple
        Direct irradiance in tilted module plane in Wh per squaremeter : numeric
        Diffuse irradiance in tilted module plane in Wh per squaremeter : numeric
        Reflected irradiance in tilted module plane in Wh per squaremeter : numeric
    """
    
    actual_date = timestamp
    
    L = math.radians(location[0])
    phi = math.radians(location[1])
    
    module_azimuth_angle = math.radians(orientation[0])
    module_elevation_angle = math.radians(orientation[1])
    
    E_dir_hor = E_hor[0]
    E_diff_hor = E_hor[1]
    E_G_hor = E_dir_hor + E_diff_hor

    # Plausibility checks
    error = 0
    if ( (timezone<-12) or (timezone>12) ):
        print ("Timezone has wrong value. Timezone must be betwenn -12 and +12.")
        error+=1
        
    if ( (location[0]<-180) or (location[0]>180) ):
        print ("Longitude has wrong value. Longitude must be between -180° and +180°.")
        error+=1
    
    if ( (location[1]<-90) or (location[1]>90) ):
        print ("Latitude has wrong value. Latitude must be between -90° and +90°.")
        error+=1
    
    if ( (orientation[0]<0) or (orientation[0]>360) ):
        print ("Module orientation has wrong value. Orientation must be between 0° and 360°. Southern orientation is 180°")
        error+=1
        
    if ( (orientation[1]<0) or (orientation[1]>90) ):
        print ("Modul inclination has wrong value. Inclination must be between 0° and +90°. 0° is horizontal.")
        error+=1
    
    if ( (A<0) or (A>1) ):
        print ("Albedo has wrong value. Albedo must be between 0 and 1. Default value is A=0.2")
        error+=1
        
    for i in range(len(E_hor[0])):
        if ( E_hor[0][i]<0 ):
            print ("Direct horizontal irradiance has negative value. Direct horizontal irradiance must be positive.")
            error+=1
    for i in range(len(E_hor[1])):
        if ( E_hor[0][i]<0 ):
            print ("Diffuse horizontal irradiance has negative value. Diffuse horizontal irradiance must be positive.")
            error+=1
        
    if (error > 0):
        raise SystemExit("Script aborted.")
        
    
    actual_date_formated = actual_date.to_pydatetime()
    first_day = datetime(actual_date_formated[0].year, 1, 1, 0, 0, 0)
    
    number_of_days = 365
    if (calendar.isleap(actual_date_formated[0].year)):
        number_of_days = 366
        
    n = ((actual_date_formated[0]-first_day).days)+1
    j = 360*n/number_of_days

    declination_angle = math.radians( 0.3948 - 23.2559*math.cos( math.radians(j+9.1) ) - 0.3915*math.cos( math.radians(2*j+5.4) ) - 0.1764*math.cos( math.radians(3*j+26) ) )

    teq = ( 0.0066 + 7.3525*math.cos( math.radians(j+85.9) ) + 9.9359*math.cos( math.radians(2*j+108.9) ) + 0.3387*math.cos( math.radians(3*j+105.2) ) )


    local_time = actual_date.to_pydatetime()

    mean_local_time = local_time - datetime.timedelta(hours=timezone) + 4*datetime.timedelta(minutes=math.degrees(L))

    true_local_time = mean_local_time + datetime.timedelta(minutes=teq)

    hour_angle = math.radians(15*(12-(true_local_time.hour+true_local_time.minute/60+true_local_time.second/3600)))

    sun_elevation_angle = math.asin( math.cos(hour_angle)*math.cos(phi)*math.cos(declination_angle) + math.sin(phi)*math.sin(declination_angle) )
    
    if (true_local_time.hour <= 12):
        sun_azimuth_angle = math.pi - math.acos( (math.sin(sun_elevation_angle)*math.sin(phi)-math.sin(declination_angle))/(math.cos(sun_elevation_angle)*math.cos(phi)) )
    else:
        sun_azimuth_angle = math.pi + math.acos( (math.sin(sun_elevation_angle)*math.sin(phi)-math.sin(declination_angle))/(math.cos(sun_elevation_angle)*math.cos(phi)) )
    
    solar_angle_of_incidence = math.acos( -math.cos(sun_elevation_angle)*math.sin(module_elevation_angle)*math.cos(sun_azimuth_angle-(module_azimuth_angle-math.pi))+math.sin(sun_elevation_angle)*math.cos(module_elevation_angle) )
       
    E_dir_tilted = np.maximum(E_dir_hor * math.cos(solar_angle_of_incidence),0)
        
    E_diff_tilted = E_diff_hor * 1/2 * (1 + math.cos(module_elevation_angle)) 

    E_refl_tilted = E_G_hor * A * 1/2 * (1 - math.cos(module_elevation_angle))
        
    return E_dir_tilted, E_diff_tilted, E_refl_tilted


if __name__ == "__main__":
    timestamp = pd.date_range(start='1/1/2020', end='1/08/2021', freq='H')
    #timezone offset is the offset from UTC (for Germany +1 in winter and +2 in summer)
    timezone = 1
    #set location [longitude as numeric, latitude as numeric]
    location = [52.520008, 13.404954]
    #set orientation = [azimuth angle as numeric, inclination angle as numeric]
    #azimuth angle (horizontal orientation) of the PV system (0° north, 90° east, 180° south, 270° west) #inclination angle of the PV system (0° is horizontally mounted, 90° is vertically mounted)
    orientation= [180, 35] 
    A = 0.2
    E_hor = {}
    E_hor[0] = np.loadtxt("D:\\git\\fubic\\raw_inputs\\weather_files\\Berlin_E_dir.csv")
    E_hor[1] = np.loadtxt("D:\\git\\fubic\\raw_inputs\\weather_files\\Berlin_E_diff.csv")
    
    solar_irradiance = calc_tilted_irradiance(timestamp, timezone, location, orientation, A, E_hor)