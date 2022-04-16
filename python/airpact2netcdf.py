#%%
from datetime import datetime, timedelta
import numpy as np
import xarray as xr
#import rioxarray

#%% Reads in data
# ....Read in CCTM data
d = '/Users/vonw/data/airpact5/'
datestr = '20220411'

#%%
def airpact2netcdf(d, datestr):
    # ....Open files in subdirectories
    grid   = xr.open_dataset(d+datestr+'00/MCIP37/GRIDCRO2D')
    met    = xr.open_dataset(d+datestr+'00/MCIP37/METCRO2D')
    bcon   = xr.open_dataset(d+datestr+'00/BCON/output/bcon_cb05_'+datestr+'.ncf')
    cctm   = xr.open_dataset(d+datestr+'00/CCTM/CONC_'+datestr+'.ncf')
    drydep = xr.open_dataset(d+datestr+'00/CCTM/DRYDEP_'+datestr+'.ncf')
    wetdep = xr.open_dataset(d+datestr+'00/CCTM/WETDEP1_'+datestr+'.ncf')

    # ....Convert WRF date and time to datetime
    sdate = datetime.strptime(cctm.SDATE.astype(str), '%Y%j')
    hh    = int(cctm.STIME.astype(str).rjust(6)[0:2])
    mm    = int(cctm.STIME.astype(str).rjust(6)[2:4])
    ss    = int(cctm.STIME.astype(str).rjust(6)[4:6])
    hrs   = hh + (mm*60) + (ss*3600)
    times = [sdate+timedelta(hours=hrs+int(tstep)) for tstep in cctm.TSTEP.values] 

    # ....Read in WRF grid
    lats = np.reshape(grid.LAT.values,(258,285))
    lons = np.reshape(grid.LON.values,(258,285))

    # ....Creates a new xarray dataset (with dimensions and coordinates!!) using variables
    data = xr.Dataset({ 'T2m':   (['time', 'y', 'x'], met.TEMP2[:,0,:,:].data),
                        'wspd':  (['time', 'y', 'x'], met.WSPD10[:,0,:,:].data),
                        'wdir':  (['time', 'y', 'x'], met.WDIR10[:,0,:,:].data),
                        'ozone': (['time', 'y', 'x'], cctm.O3[:,0,:,:].data)},
                        coords={
                            'time': times, 
                            'latitude': (['y', 'x'], lats), 
                            'longitude': (['y', 'x'], lons)
                        }
                    )
    
    # ....Save data to a netCDF file
    data.to_netcdf('airpactGIS_'+datestr+'.nc')
    return

#%%
