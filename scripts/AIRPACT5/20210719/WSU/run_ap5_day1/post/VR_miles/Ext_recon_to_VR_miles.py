#%% Imports
import sys
import xarray as xr

#%% Conversions and Constants
miles_per_km = 0.621371
print("Miles per kilometer:",miles_per_km)

K = 3.9
print( "Koschmieder Coefficient:", K)

print( "SECTION 1 COMPLETED SET UP ")

# # SECTION 2 fake in command line inputs

print ("SECTION 2 DATE READ AND INTERPRETED ")

YYYYMMDD = sys.argv[1]
print ("DATE READ FROM sys.argv[1]:", YYYYMMDD)

#%%
y     = str(YYYYMMDD)[0:4]
m     = str(YYYYMMDD)[4:6]
d     = str(YYYYMMDD)[6:8]
print (" YEAR: ", y)
print (" MONTH: ", m)
print (" DAY:  ", d)

#%% file locations: AIRPACT5 AEROVIS derived EXT_recon file
print ("SECTION 3 READ IN AND CHECK AEORVIS EXT_Recon ")

runroot = "/data/lar/projects/airpact5/AIRRUN/{y}/{y}{m}{d}00".format(m=m, y=y, d=d)
cctm_dir = runroot + "/CCTM/"
cctm_aerovis_file =  cctm_dir + "AEROVIS" + "_{y}{m}{d}.ncf".format(m=m, y=y, d=d)

#%%
aerovis = xr.open_dataset(cctm_aerovis_file)

#%% Create new variables for Visibility Range (VR)
aerovis['VR_km']   = K / aerovis['EXT_Recon']
aerovis['VR_miles'] = aerovis['VR_km'] * miles_per_km

#%% Output to a new netCDF file
aerovis[['VR_km', 'VR_miles']].to_netcdf(cctm_dir + 'VR_miles' + "_{y}{m}{d}.ncf".format(m=m, y=y, d=d), format='NETCDF3_CLASSIC')

