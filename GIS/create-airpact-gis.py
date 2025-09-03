#%%
def create_AIRPACT_GIS(date, variables):
    '''Function to convert AIRPACT GIF images to GeoTIFFS
    
    Derived from Examples 1 and 5 of:
        https://gdal.org/drivers/raster/gpkg.html
        

    Written by: Von P. Walden, Washington State University
    Date:       8 August 2022
    '''

    from datetime import timedelta
    from glob import glob
    from subprocess import call
    
    # ....Open the geoserver
    #from geo.Geoserver import Geoserver
    #geo = Geoserver('http://localhost:8080/geoserver', username='admin', password='geoserver')
    workspace   = 'airpact'
    geopackage  = date.strftime('%Y%m%d')
    
    # ....Important directories
    yyyy       = date.strftime('%Y')
    yyyymmddhh = date.strftime('%Y%m%d%H')
    directory  = '/mnt/AIRNAS1/airpact/AIRRUN/' + yyyy + '/' + yyyymmddhh + '/IMAGES/'
    if not os.path.exists(directory + '/gis/'):
        os.mkdir(directory + '/gis/')
    
    for variable in variables:
        
        # ....Create a workspace for each variable
        #workspace = date.strftime('%Y%m%d') + '_' + variable
        #geo.create_workspace(workspace)
        
        # ....Determines list of filenames to convert
        gifs = glob(directory + 'aconc/hourly/gif/airpact5_' + variable + '*.gif')
        gifs.sort()

        for gif in gifs:
            fn = gif.split('/')[-1]
            HH = int(fn.split('.')[0][-2:])
            time = date + timedelta(hours=HH)
            print('Processing: ', fn)
            gif2geotiff = 'gdal_translate -of GTiff -gcp 40.5778 725.437 -125.128 40.1728 -gcp 769.549 750.564 -111.374 39.81 -gcp 862.547 43.5673 -109.617 49.2912 -gcp 0.530624 8.33774 -125.889 49.7214 ' + gif + ' ' + directory + 'gis/' + fn + ' -mo TIFFTAG_DATETIME="' + time.strftime('%Y-%m-%d %H:%M:%S') + '"'
            call(gif2geotiff, shell=True)
            project_geotiff = 'gdalwarp -r near -order 1 -co COMPRESS=None  -t_srs EPSG:4326 ' + directory + 'gis/' + fn + ' ' + directory + 'gis/' + fn + '.tif'
            call(project_geotiff, shell=True)
            
            # ....Create a layer coverage on the geoserver
            #geo.create_coveragestore(layer_name=fn.split('.')[0], path=directory + 'gis/' + fn + '.tif', workspace=workspace)
            
            # ....Create geopackage and append geoTIFFS
            if(HH==0):
                create_geopackage = 'gdal_translate -of GPKG ' + directory + 'gis/' + fn + '.tif ' + geopackage + '_' + variable + '.gpkg -co RASTER_TABLE=hr' + str(HH).zfill(2)
                call(create_geopackage, shell=True)
            else:
                append_geopackage = 'gdal_translate -of GPKG ' + directory + 'gis/' + fn + '.tif ' + geopackage + '_' + variable + '.gpkg -co RASTER_TABLE=hr' + str(HH).zfill(2) + ' -co APPEND_SUBDATASET=YES'
                call(append_geopackage, shell=True)
                
            call(['rm ' + directory + 'gis/' + fn], shell=True )
            call(['rm ' + directory + 'gis/' + fn + '.tif'], shell=True )
            
    return

#%%
import os
from datetime import datetime

# ....List of variables
possible_hourly_variables_to_choose_from = ['ANO3', 'AOD', 'AOMIJ', 'CO', 'HCHO', 'ISOPRENE', 'NH3', 'NOx', 'O3', 'PM25', 'SO2', 'VOCs', 'WSPM25']
variables = ['O3', 'PM25']

# ....Create the GIS images for desired day
#desired_day = datetime(2024,8,14)
#create_AIRPACT_GIS(desired_day, variables)

today = datetime.now().date()
create_AIRPACT_GIS(today, variables)

#%%
