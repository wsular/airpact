#%%
import numpy as np

#%%
def addCoordsToACONC(date):
    from datetime import datetime, timedelta
    import xarray as xr

    yyyy       = date.strftime('%Y')
    yyyymmdd   = date.strftime('%Y%m%d')
    yyyymmddhh = date.strftime('%Y%m%d'+'00')
    aconc = xr.open_dataset('/mnt/AIRNAS1/airpact/AIRRUN/' + yyyy + '/' + yyyymmddhh + '/CCTM/ACONC_' + yyyymmdd + '.ncf', engine='netcdf4')
    gridcro2d = xr.open_dataset('/mnt/AIRNAS1/airpact/AIRRUN/' + yyyy + '/' + yyyymmddhh + '/MCIP37/GRIDCRO2D', engine='netcdf4')
    metcro3d = xr.open_dataset('/mnt/AIRNAS1/airpact/AIRRUN/' + yyyy + '/' + yyyymmddhh + '/MCIP37/METCRO3D', engine='netcdf4')

    # ....Assign coordinates to aconc file
    times = [date + timedelta(hours=int(hour)) for hour in aconc.TSTEP.values]
    ds = aconc.copy()
    ds = ds.drop('TFLAG')
    ds = ds.assign_coords({'time': (["TSTEP"], times),
                         'pressure': (["TSTEP","LAY","ROW","COL"], metcro3d.PRES[:-1].values),
                         'latitude': (["ROW","COL"], gridcro2d.LAT[0,0].values),
                         'longitude': (["ROW","COL"], gridcro2d.LON[0,0].values)})

    return ds

#%%
def find_WRF_pixel(latvar,lonvar,lat0,lon0):
    # Read latitude and longitude from file into numpy arrays
    # Renamed findWRFpixel from original function, naive_fast, written by Vikram Ravi.
    latvals = latvar[:]
    lonvals = lonvar[:]
    dist_sq = (latvals-lat0)**2 + (lonvals-lon0)**2
    minindex_flattened = dist_sq.argmin()  # 1D index of min element
    iy_min, ix_min = np.unravel_index(minindex_flattened, latvals.shape)

    return int(iy_min),int(ix_min)

#%%
def findACONCindex(time, pressure, lat, lon):
    # ....Find time
    it         = np.where(aconc.time == np.datetime64(date))[0][0]
    # ....Find nearest gridcell
    ilat, ilon = find_WRF_pixel(aconc.latitude, aconc.longitude, lat, lon)
    # ....Find nearest pressure level
    dP = aconc.pressure[it, :, ilat, ilon].values
    ipr = np.where(np.abs(dP) == np.abs(dP).min())[0][0]

    return it, ipr, ilat, ilon
    
#%%
from datetime import datetime
date = datetime(2022,8,9,10)
aconc = addCoordsToACONC(date)
it, ipr, ilat, ilon = findACONCindex(date, 70000, 46.7, -117.2)

#%%
# ....Print some contaminant values
print('O3  = ', aconc.O3[it,ipr,ilat,ilon].values)
print('NO2 = ', aconc.NO2[it,ipr,ilat,ilon].values)
