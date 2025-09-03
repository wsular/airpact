"""
This Python script obtains the latest ML forecasts for ozone and PM2.5 from aeolus.wsu.edu, adds geographic information (Latitude and Longitude), then saves these data files to a folder used by the WSU LAR GeoServer.

Von P. Walden, Washington State University
30 January 2023
"""
import pandas as pd
import geopandas as gpd

import subprocess

# ....rsync with aeolus to get most recent ML forecasts
subprocess.call("rsync --update --include './' --include '*.csv' --exclude '*' -raz -e ssh airpact5@aeolus.wsu.edu:/data/lar/projects/airpact5/ML/ /mnt/AIRNAS1/ML", shell=True)

vars = ['O3', 'PM']

for var in vars:
    # ....Determine the latest ML forecast file
    outstr = subprocess.check_output(['ls -Art /mnt/AIRNAS1/ML/ML_' + var + '_forecasts* | tail -n 1'], shell=True)
    fn = outstr.decode()[:-1]
    
    print('Processing ML forecast for ' + var + ' using latest forecast: ' + fn)
    
    # ....Read the file
    ml = pd.read_csv(fn, names=['SiteID', 'Date', var])
    ml['SiteID'] = (ml.SiteID).astype(str)
    
    # ....Read in recent list of AQS sites by first parsing date and time from fn
    yyyymmdd = fn.split('/')[-1].split('_')[-2]
    yyyy = yyyymmdd[0:4]
    aqs = pd.read_csv('/mnt/AIRNAS1/airpact/AIRRUN/' + yyyy + '/' + yyyymmdd + '00/POST/CCTM/aqsid.csv', skiprows=2, names=['SiteID', 'Latitude', 'Longitude', 'SiteName'])
    aqs = aqs.iloc[0:245]    # Eliminates SiteIDs that can't be converted to integers...
    aqs['SiteID'] = (aqs.SiteID).astype(str)
    
    ml_GIS = pd.merge(ml, aqs, on='SiteID')

    # ....Create a shapefile
    gdf = gpd.GeoDataFrame(ml_GIS, geometry=gpd.points_from_xy(x=ml_GIS.Longitude, y=ml_GIS.Latitude), crs='epsg:4326')
    gdf[var] = gdf[var].astype(float)
    
    # ....Save data to GIS folder used by GeoServer
    gdf.to_file('/usr/share/geoserver/data_dir/workspaces/ml1/machineLearning/WSU_PNW_ML_' + var + '.shp', driver='ESRI Shapefile')

