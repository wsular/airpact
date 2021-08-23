#%%
import numpy  as np
import pandas as pd
import xarray as xr
import sys

#%%
def extractMonitoringSiteData(date, variables):

    yyyymmdd = str(date.year) + str(date.month).zfill(2) + str(date.day).zfill(2)

    # ....Define function to determine indices to data values
    def find_WRF_pixel(lat, lon):
        # Read latitude and longitude from file into numpy arrays
        # Renamed findWRFpixel from original function, naive_fast, written by Vikram Ravi.

        # ....Loads the latitudes and longitudes for the AIRPACT data.
        grid = xr.open_dataset(gfn)
        lats = np.reshape(grid.LAT.values,(258,285))
        lons = np.reshape(grid.LON.values,(258,285))

        dist_sq = (lats-lat)**2 + (lons-lon)**2
        minindex_flattened = dist_sq.argmin()  # 1D index of min element
        iy_min, ix_min = np.unravel_index(minindex_flattened, lats.shape)

        return int(iy_min),int(ix_min)
    
    # ....Create necessary filenames for the lat/lon grid, data and AQS sites
    # grid
    gfn = '../GRIDCRO2D'
    # data
    dfn = '/data/lar/projects/airpact5/saved/' + str(date.year) + '/' + str(date.month).zfill(2) + '/aconc/combined_' + yyyymmdd + '.ncf'
    #dfn = 'combined_' + yyyymmdd + '.ncf'
    # AQS_sites
    sfn = '/data/lar/projects/airpact5/AIRRUN/' + str(date.year) + '/' + yyyymmdd + '00/POST/CCTM/aqsid.csv'
    #sfn = 'aqsid.csv'

    # ....Open necessary files
    aconc = xr.open_dataset(dfn)
    aqs_sites = pd.read_csv(sfn, header=[0], skiprows=[1])

    # ....Extract data for set of variables
    data = pd.DataFrame(columns=['_MM/DD/YY_UTZ', '_HH:MM_UTZ', '_SITEID', '_SPECIES', '_PPB_or_ug/m3'])
    for site in aqs_sites.iterrows():
        for variable in variables:
            time = str(aconc.STIME).zfill(6)
            siteID = site[1][0]
            lat    = site[1][1]
            lon    = site[1][2]
            r,c    = find_WRF_pixel(lat, lon)
            # ....Handles special cases for species
            if variable == 'O3':
                species = 'OZONE'
            elif variable == 'PMIJ':
                species = 'PM2.5'
            else:
                species = variable
            
            # ....Append row to dataframe
            df = pd.DataFrame({'_MM/DD/YY_UTZ': [str(date.month).zfill(2) + '/' + str(date.day).zfill(2) + '/' + str(date.year)[2:4]],
                               '_HH:MM_UTZ'   : [time[0:2] + ':' + time[2:4]],
                               '_SITEID'      : [siteID],
                               '_SPECIES'     : [species],
                              '_PPB_or_ug/m3' : [aconc[variable][0,0,r,c].item()]})

            data = pd.concat([df, data], ignore_index=True)
    data.to_csv('AIRNowSites_' + yyyymmdd + '_v10.dat', sep='|', index=False)

#%%
###################################################################
date = pd.to_datetime(sys.argv[1])
variables = ['CO', 'NO', 'NO2', 'NOX', 'O3', 'PM10', 'PMIJ', 'SO2']

extractMonitoringSiteData(date, variables)
