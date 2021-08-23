#%%
import numpy  as np
import pandas as pd
import xarray as xr
import sys
import os

# Tested by JKV for col & row locaton by lat, lon.
# provided these AQSID inputs:
# AQSID,Latitude,Longitude,long_name
# File aqsid20210322.csv produced by Jen Hinds and Joe Vaughan, 03/22/2021
# 000000001   ,40.176800,-125.125700,South West Corner Cell
# 000000002   ,49.718200,-125.884900,North West Corner Cell
# 000000003   ,49.279400,-109.616900,North East Corner Cell
# 000000004   ,39.807600,-111.374700,South East Corner Cell
# representing the lat&lon displayed by Google Maps interface of AIRPACT5 web display when
# cursor is put over the cornermost grid line intersections.  
# There are 1-285 W to E and 1-258 S to N, gridlines.
# The col and row values returned are:
#  LAT:  40.1768  LON:  -125.1257  ROW:  0  COL:  0
#  LAT:  49.7182  LON:  -125.8849  ROW:  257  COL:  0
#  LAT:  49.2794  LON:  -109.6169  ROW:  257  COL:  284
#  LAT:  39.8076  LON:  -111.3747  ROW:  0  COL:  284
#  and given that python indexes from 0 by default, these seem to correctly represent the
#  corner locations.

#%%
def extractMonitoringSiteData(filedate, variables):

    yyyymmdd = str(filedate.year) + str(filedate.month).zfill(2) + str(filedate.day).zfill(2)

    # ....Define function to determine indices to data values
    def find_WRF_pixel(lat, lon):
        # Read latitude and longitude from file into numpy arrays
        # Renamed findWRFpixel from original function, naive_fast, written by Vikram Ravi.

        # ....Loads the latitudes and longitudes for the AIRPACT data.
        grid = xr.open_dataset(gfile)
        lats = np.reshape(grid.LAT.values,(258,285))
        lons = np.reshape(grid.LON.values,(258,285))

        dist_sq = (lats-lat)**2 + (lons-lon)**2
        minindex_flattened = dist_sq.argmin()  # 1D index of min element
        iy_min, ix_min = np.unravel_index(minindex_flattened, lats.shape)

        return int(iy_min),int(ix_min)
    
    # ....Create necessary filenames for the lat/lon grid, data and AQS sites
    # grid
    #gfn = '../GRIDCRO2D'
    # data

    #Get all necessary file names from env variables.  JKV
    gfile = os.environ.get('GRIDCRO2D')
    print(" GRIDCRO2D is : ", gfile)
    infile = os.environ.get('INFILE')
    print(" INFILE is : ", infile)
    outfile = os.environ.get('OUTFILE')
    print(" OUTFILE is : ", outfile)
    # AQS_sites
#%%    sfn = '/data/lar/projects/airpact5/AIRRUN/' + str(date.year) + '/' + yyyymmdd + '00/POST/CCTM/aqsid.csv'
    aqsid = os.environ.get('NEWAQSID')
    print(" AQSID is: ", aqsid )

#    dfn = '/data/lar/projects/airpact5/saved/' + str(filedate.year) + '/' + str(filedate.month).zfill(2) + '/aconc/combined_' + yyyymmdd + '.ncf'
#
#    #dfn = '/Users/vonw/data/airpact/combined_' + yyyymmdd + '.ncf'
#    # AQS_sites
#    sfn = '/data/lar/projects/airpact5/AIRRUN/' + str(filedate.year) + '/' + yyyymmdd + '00/POST/CCTM/aqsid.csv'
#    #sfn = '/Users/vonw/data/airpact/aqsid.csv'
#
    # ....Open necessary files
#    aconc = xr.open_dataset(dfn)
    aconc = xr.open_dataset(infile)
#    aqs_sites = pd.read_csv(sfn, header=[0], skiprows=[1])
    aqs_sites = pd.read_csv(aqsid, header=[0], skiprows=[1])
    
    # ....Extract the forecasted date and time
    base_time = pd.to_datetime(str(aconc.SDATE) + ' ' + str(aconc.STIME).zfill(6), format='%Y%j %H%M%S')
    times     = [base_time + pd.to_timedelta(time, unit='h') for time in aconc.TSTEP.values]
    
    # ....Extract data for set of variables
#    fp = open('AIRNowSites_' + yyyymmdd + '_v10.dat', mode='w')
    fp = open(outfile, mode='w')
    fp.write('_MM/DD/YY_UTZ' + '|' + '_HH:MM_UTZ' + '|' +  '_SITEID' + '|' +  '_SPECIES' + '|' +  '_PPB_or_ug/m3' + '\n')
    # for time in times:
    for tindex, time in enumerate(times):
        for site in aqs_sites.iterrows():
            siteID = site[1][0] # to get full strings, not truncated.  [-7:].zfill(9)
            lat    = site[1][1]
            lon    = site[1][2]
            r,c    = find_WRF_pixel(lat, lon)
            print(" LAT: ",lat," LON: ",lon," ROW: ",r," COL: ",c)
            for variable in variables:
                # ....Handles special cases for species
                if variable == 'O3':
                    species = 'OZONE'
                elif variable == 'PMIJ':
                    species = 'PM2.5'
                else:
                    species = variable
#fp.write(str(time.month).zfill(2) + '/' + str(time.day).zfill(2) + '/' + str(time.year)[2:4] + '|' + str(time.hour).zfill(2)  + ':' + str(time.minute).zfill(2) + '|' + siteID  + '|' + species  + '|' + f'{aconc[variable][0,0,r,c].item():.4f}' + '\n')
                # print(f'TYPE for siteID ', type(siteID) )
                # print(f'TYPE for species ', type(species) )
                fp.write(str(time.month).zfill(2) + '/' + str(time.day).zfill(2) + '/' + str(time.year)[2:4] + '|' + str(time.hour).zfill(2)  + ':' + str(time.minute).zfill(2) + '|' + str(siteID)  + '|' + species  + '|' + f'{aconc[variable][tindex,0,r,c].item():.4f}' + '\n')
    
    fp.close()
#%%
###################################################################
filedate = pd.to_datetime(sys.argv[1])
variables = ['RollingA8_O3']
print("Running $sys.argv[0] by VW with File ID by JKV")
extractMonitoringSiteData(filedate, variables)
