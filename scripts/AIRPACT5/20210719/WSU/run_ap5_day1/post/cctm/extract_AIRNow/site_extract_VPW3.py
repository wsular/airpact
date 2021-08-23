#%%
import numpy  as np
import pandas as pd
import xarray as xr
import sys

#%%
def extractMonitoringSiteData(filedate, variables):

    yyyymmdd = str(filedate.year) + str(filedate.month).zfill(2) + str(filedate.day).zfill(2)

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
    dfn = '/data/lar/projects/airpact5/saved/' + str(filedate.year) + '/' + str(filedate.month).zfill(2) + '/aconc/combined_' + yyyymmdd + '.ncf'
    #dfn = '/Users/vonw/data/airpact/combined_' + yyyymmdd + '.ncf'
    # AQS_sites
    sfn = '/data/lar/projects/airpact5/AIRRUN/' + str(filedate.year) + '/' + yyyymmdd + '00/POST/CCTM/aqsid.csv'
    #sfn = '/Users/vonw/data/airpact/aqsid.csv'

    # ....Open necessary files
    aconc = xr.open_dataset(dfn)
    aqs_sites = pd.read_csv(sfn, header=[0], skiprows=[1])
    
    # ....Extract the forecasted date and time
    base_time = pd.to_datetime(str(aconc.SDATE) + ' ' + str(aconc.STIME).zfill(6), format='%Y%j %H%M%S')
    times     = [base_time + pd.to_timedelta(time, unit='h') for time in aconc.TSTEP.values]
    
    # ....Extract data for set of variables
    fp = open('AIRNowSites_' + yyyymmdd + '_v10.dat', mode='w')
    fp.write('_MM/DD/YY_UTZ' + '|' + '_HH:MM_UTZ' + '|' +  '_SITEID' + '|' +  '_SPECIES' + '|' +  '_PPB_or_ug/m3' + '\n')
    for tindex, time in enumerate(times):
        for site in aqs_sites.iterrows():
            siteID = site[1][0]
            lat    = site[1][1]
            lon    = site[1][2]
            r,c    = find_WRF_pixel(lat, lon)
            for variable in variables:
                # ....Handles special cases for species
                if variable == 'O3':
                    species = 'OZONE'
                elif variable == 'PMIJ':
                    species = 'PM2.5'
                else:
                    species = variable
                fp.write(str(time.month).zfill(2) + '/' + str(time.day).zfill(2) + '/' + str(time.year)[2:4] + '|' + str(time.hour).zfill(2)  + ':' + str(time.minute).zfill(2) + '|' + siteID  + '|' + species  + '|' + f'{aconc[variable][tindex,0,r,c].item():.4f}' + '\n')
    
    fp.close()
#%%
###################################################################
#filedate = pd.to_datetime(sys.argv[1])
filedate = pd.to_datetime('2020-09-23')
variables = ['CO', 'NO', 'NO2', 'NOX', 'O3', 'PM10', 'PMIJ', 'SO2']

extractMonitoringSiteData(filedate, variables)
