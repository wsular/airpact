#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Sep  8 20:40:07 2020

@author: Von P. Walden 
         Washington State University
Modified: Joe Vaughan, LAR/WSU, Sept 15, 2020
"""

import numpy as np
import xarray as xr

#%%
# ....Edit these filenames for the netCDF date file and the appropriate GRIDCRO2D
fn_grid = '/data/lar/projects/airpact5/AIRRUN/2020/2020091500/MCIP37/GRIDCRO2D'
fn_data = '/data/lar/projects/airpact5/AIRRUN/2020/2020091500/POST/CCTM/PM25_24hr_BiasCorrected_2020091500.ncf'

# ....Load Kalman-Filtered PM2.5 data from AIRPACT5.
data = xr.open_dataset(fn_data)

# ....Loads the latitudes and longitudes for the AIRPACT data.
grid = xr.open_dataset(fn_grid)
lats = np.reshape(grid.LAT.values,(258,285))
lons = np.reshape(grid.LON.values,(258,285))
r = data.NROWS
c = data.NCOLS

#%%
# ....Create a new xarray object with latitude and longitude as coordiates.
ds = xr.Dataset({
                    'PM2.5_KFBC_LinearKriging': (['lon', 'lat'], data.KFBC_PM25_LinKri.values.reshape(r,c).T),
                    'PM2.5_KFBC_GaussianKriging': (['lon', 'lat'], data.KFBC_PM25_GausKr.values.reshape(r,c).T),
                    'PM2.5_KFBC_CubicInterpolation': (['lon', 'lat'], data.KFBC_PM25_CubicI.values.reshape(r,c).T)
                },
                coords={
                    'latitude':  (['lon', 'lat'], lats.T),
                    'longitude': (['lon', 'lat'], lons.T),                    
                })

# ....Copy attributes from original netCDF file.
for attr in data.attrs: ds.attrs[attr] = data.attrs[attr]

#%%
# ....Save xarray object as a new netCDF file.
ds.to_netcdf(fn_data.split('.')[0] + '_new.' + fn_data.split('.')[-1])

#%%
# ....Plot the results.
import matplotlib.pyplot as plt
plt.figure()
ds['PM2.5_KFBC_LinearKriging'].plot(x='longitude', y='latitude', vmin=0, vmax=100)
plt.figure()
ds['PM2.5_KFBC_GaussianKriging'].plot(x='longitude', y='latitude', vmin=0, vmax=100)
plt.figure()
ds['PM2.5_KFBC_CubicInterpolation'].plot(x='longitude', y='latitude', vmin=0, vmax=100)
