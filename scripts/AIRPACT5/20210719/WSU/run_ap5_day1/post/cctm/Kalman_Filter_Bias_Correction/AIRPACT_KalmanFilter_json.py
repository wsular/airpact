# 4 Day Kalman Filter for AIRPACT
# Written by Nicole A. June and put into AIRPACT5 by Joe Vaughan July 2020.

# Import Packages
import numpy as np
import pandas as pd
from statsmodels.tsa.statespace.kalman_filter import KalmanFilter
from scipy.interpolate import griddata
import datetime
from netCDF4 import Dataset
import os
import json
import pickle

# Current Date Information
date = pd.to_datetime('today').strftime('%Y%m%d')
year = pd.to_datetime('today').year
yesterday = pd.datetime.strftime(pd.datetime.now() - datetime.timedelta(1), '%Y%m%d')
time_select = pd.to_datetime('today').strftime('%Y-%m-%d')
time_select = str(time_select)+' 08:00:00'

# Read in the Data
url = 'http://download.aeolus.wsu.edu:3838/pm25_past7days/tmp/all_sites_pm25avg.csv'
data = pd.read_csv(url,dtype={'AQSID':str})
data.AQSID = data.AQSID.apply(lambda x: '0'*(9 - len(x))+x)
nc_file = '/data/lar/projects/airpact5/AIRRUN/'+str(year)+'/'+str(date)+'00/POST/CCTM/PM25_L01_24hr_'+str(yesterday)+'.ncf'
mod_grid = Dataset(nc_file)
mod_vals = mod_grid.variables['RollingA24_PM25'][1,0,:,:]

grid_data_file = '/data/lar/projects/airpact5/AIRRUN/'+str(year)+'/'+str(date)+'00/MCIP37/GRIDCRO2D'
grid_data = Dataset(grid_data_file)
LAT = grid_data.variables['LAT'][0,0,:,0]
LON = grid_data.variables['LON'][0,0,0,:]

# Output File Names
#datedir = '/data/lar/projects/KFBC/AIRRUN/'+str(year)+'/'+str(date)+'00'
datedir = '/data/lar/projects/airpact5/AIRRUN/'+str(year)+'/'+str(date)+'00'
try:
	os.mkdir(datedir)
except FileExistsError:
	pass
outdir = '/data/lar/projects/airpact5/AIRRUN/'+str(year)+'/'+str(date)+'00/POST/CCTM'
imagedir = '/data/lar/projects/airpact5/AIRRUN/'+str(year)+'/'+str(date)+'00/IMAGES/KFBC'
#try:
#	os.mkdir(outdir)   this dir should exist, JKV
#except FileExistsError:
#	 pass
try:
	os.mkdir(imagedir)
except FileExistsError:
	pass
filename = outdir+'/kf_data_'+str(date)+'.csv'
KFBC_csv = outdir+'/KFBC_24hr_avg_'+str(date)+'.csv'
ncfilename = outdir+'/PM25_24hr_BiasCorrected_'+str(date)+'00.ncf'
jsonfilename = outdir+'/KFBC_24hr_LinKriged_'+str(date)+'00.json'
txt1 = imagedir+'/KFBC_PM25_CubicInt_'+str(date)+'00.txt'
f1 = open(txt1,'w')
f1.write("Bias-Corrected 24-hour PM2.5: Kalman Filter bias, cubic spline interpolated, applied to correct forecast PM2.5")
f1.close()
txt2 = imagedir+'/KFBC_PM25_GausKrig_'+str(date)+'00.txt'
f2 = open(txt2,'w')
f2.write("Bias-Corrected 24-hour PM2.5: Kalman Filter bias, Gaussian Kriging interpolated, applied to correct forecast PM2.5")
txt3 = imagedir+'/KFBC_PM25_LinKrig_'+str(date)+'00.txt'
f3 = open(txt3,'w')
f3.write("Bias-Corrected 24-hour PM2.5: Kalman Filter bias, Linear Kriging interpolated, applied to correct forecast PM2.5")

# Organize the Data by Site to Run Kalman Filter
data_id = dict(tuple(data.groupby('AQSID'))) 
aqsids = list(data_id.keys()) 

# Run the Kalman Filter
kf_data = {}
for aqsid in aqsids:
	data_site = pd.DataFrame(data_id[aqsid]).reset_index(drop=True)
	mod = pd.DataFrame(data_site['PM2.5_mod']).reset_index(drop=True)
	obs = pd.DataFrame(data_site['PM2.5_obs']).reset_index(drop=True)
	err = pd.DataFrame(data_site['PM2.5_mod']-data_site['PM2.5_obs']).reset_index(drop=True)
	lenk = len(obs)
	tindex = np.arange(lenk)
	sigma_s = np.nanvar(obs)
	sigma_o = np.nanvar(mod)
	kf = KalmanFilter(1,1)
	kf.obs_cov = np.array([sigma_o])
	kf.state_cov = np.array([sigma_s])
	kf.design = np.array([1.0])
	kf.transition = np.array([1.0])
	kf.selection = np.array([1.0])
	kf.initialize_known(np.array([0.0]), np.array([[sigma_s]])) 
	y = np.array(err)
	kf.bind(y.copy())
	r = kf.filter()          #Implementing the Kalman Filter
	filtered_state = r.filtered_state[0]     
	kalgaink = r.kalman_gain
	kalgaink = kalgaink.reshape([lenk,1])
	kfk = pd.DataFrame(filtered_state)      #The filtered state for the observation site k
	kfk = kfk.astype('float')
	kfk[kfk == 0] = np.nan
	kfk = pd.DataFrame(kfk)
	kfka = np.array(kfk)        
	kfka = np.resize(kfk,[lenk,1])
	kf_bias = pd.DataFrame(kfka).reset_index(drop=True)
	kfk1 = mod-kfka
	kfk1_df1 = pd.DataFrame(index=tindex)
	kfk1_df1['kf'] = kfk1
	kfk1 = [0 if i < 0 else i for i in kfk1_df1.kf]
	kfk1_df = pd.DataFrame(index=tindex)
	kfk1_df['DateTime'] = data_site['DateTime']
	kfk1_df['mod'] = mod
	kfk1_df['obs'] = obs
	kfk1_df['kf'] = kfk1
	kfk1_df['kf_bias'] = kf_bias
	kfk_df = kfk1_df[lenk-72:lenk]
	kf_data[aqsid] = kfk_df
kf_data_df = pd.concat(kf_data)
kf_data_df = pd.DataFrame(kf_data_df).reset_index()
kf_data_df.columns = ['AQSID','index','DateTime','mod','obs','kf','kf_bias']
kf_data_df.to_csv(filename)

# Join the Latitude Longitude data to the Kalman Filter Data
location_filepath = '/data/lar/projects/airpact5/AIRRUN/'+str(year)+'/'+str(date)+'00/POST/CCTM/aqsid.csv'
site_loc = pd.read_csv(location_filepath) 
kf_data_df = pd.merge(site_loc, kf_data_df, on='AQSID', how='inner')
kf_data_df = pd.DataFrame(kf_data_df).reset_index(drop=True)

# Model Domain
latN = 51.0
latS = 39.0
lonE = -108.75
lonW = -127.0

# Interpolation Method 1: interpolates bias corrected PM2.5 Values
from pykrige.ok import OrdinaryKriging
kf_dict = dict(tuple(kf_data_df.groupby('DateTime')))
time_data = pd.DataFrame(kf_dict[time_select])
time_csv = time_data[['AQSID','DateTime','kf']]
time_csv.columns = ['AQSID','DATE','KFBC_Value']
time_csv['DATE'] = pd.to_datetime(time_csv['DATE']).apply(lambda x:x.strftime('%m/%d/%y'))
time_csv.to_csv(KFBC_csv)

numcols, numrows = 285, 258
xi = np.linspace(lonW, lonE, numcols)
yi = np.linspace(latS, latN, numrows)
xi, yi = np.meshgrid(LON+360,LAT)
data_na = time_data.dropna(subset=['kf_bias'])
kf = data_na.kf
kfb = data_na.kf_bias
lato = data_na.Latitude
lono = data_na.Longitude+360
OK = OrdinaryKriging(lono, lato, kfb, variogram_model='gaussian',verbose=False, enable_plotting=False,coordinates_type='geographic')
kfb_interp1, ss = OK.execute('grid', LON+360, LAT,backend='loop',n_closest_points=10)
kf_gauskrig = mod_vals-kfb_interp1

# Interpolation Method 2: interpolates kalman filter bias and subtracts from model grid
kf_dict = dict(tuple(kf_data_df.groupby('DateTime')))
time_data = pd.DataFrame(kf_dict[time_select])
numcols, numrows = 285, 258
xi, yi = np.meshgrid(LON,LAT)
data_na = time_data.dropna(subset=['kf_bias'])
kfb = data_na.kf_bias
lato = data_na.Latitude
lono = data_na.Longitude
kfb_interp = griddata((lono,lato),kfb,(xi,yi),method='cubic')
kf_interp2 = mod_vals-kfb_interp
kf_cubic = np.where(np.isnan(kf_interp2),mod_vals,kf_interp2)

# Interpolation Method 3: Uses Linear Kriging
kf_dict = dict(tuple(kf_data_df.groupby('DateTime')))
time_data = pd.DataFrame(kf_dict[time_select])
numcols, numrows = 285, 258
xi = np.linspace(lonW, lonE, numcols)
yi = np.linspace(latS, latN, numrows)
xi, yi = np.meshgrid(LON+360,LAT)
data_na = time_data.dropna(subset=['kf'])
kf = data_na.kf
kfb = data_na.kf_bias
lato = data_na.Latitude
lono = data_na.Longitude+360
OK = OrdinaryKriging(lono, lato, kfb, variogram_model='linear',verbose=False, enable_plotting=False,coordinates_type='geographic')
kfb_interp3, ss = OK.execute('grid', LON+360, LAT,backend='loop',n_closest_points=10)
kf_linkrig = mod_vals-kfb_interp3

# export kf_linkrig as json file
#fp = open(jsonfilename)
#open(jsonfilename, 'w') as outfile:
#    json.dump(kr_linkrig, outfile)

#with open(jsonfilename, 'w') as outfile:  # Use outfile to refer to the file object
#	json.dump(kf_linkrig, outfile)

# serialize object containing linkrig results
#pkf_linkrig = pickle.dumps(kf_linkrig, protocol=None, *, fix_imports=True, buffer_callback=None)
#pkf_linkrig = pickle.dumps(kf_linkrig, protocol=None, fix_imports=True, buffer_callback=None)
pkf_linkrig = pickle.dumps(kf_linkrig, protocol=None, fix_imports=True)

dir(pkf_linkrig)

# Write serialized object to json file
#with open(jsonfilename, 'w') as outfile:
 #   json.dump(pkf_linkrig, outfile)

# Write both to a netcdf file
m3_file = Dataset('/home/airpact5/AIRRUN/for_KFBC/KFBC_PM25_24hr_template.ncf')

biascorrected_nc = Dataset(ncfilename,mode='w',format='NETCDF3_CLASSIC')
# copy attributes
for name in m3_file.ncattrs():
    biascorrected_nc.setncattr(name, mod_grid.getncattr(name))
# copy dimensions
for name, dimension in m3_file.dimensions.items():
    biascorrected_nc.createDimension(name,len(dimension))
# copy variables
for name,variable in m3_file.variables.items():
	biascorrected_nc.createVariable(name, variable.datatype, variable.dimensions)
	d_type = variable.datatype
	dimen = variable.dimensions

biascorrected_nc['KFBC_PM25_LinKri'][:] = kf_linkrig
biascorrected_nc['KFBC_PM25_GausKr'][:] = kf_gauskrig
biascorrected_nc['KFBC_PM25_CubicI'][:] = kf_cubic
biascorrected_nc.close()
mod_grid.close()
m3_file.close()


