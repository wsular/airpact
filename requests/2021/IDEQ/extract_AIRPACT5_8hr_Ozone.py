#%%
import numpy as np
import xarray as xr
import pandas as pd

import hvplot.pandas

#%%
def find_WRF_indices(lat, lon):
    # Read latitude and longitude from file into numpy arrays
    # Renamed findWRFpixel from original function, naive_fast, written by Vikram Ravi.
    dist_sq = (lats-lat)**2 + (lons-lon)**2
    minindex_flattened = dist_sq.argmin()  # 1D index of min element
    iy_min, ix_min = np.unravel_index(minindex_flattened, lats.shape)

    return int(iy_min),int(ix_min)

# ....Loads the latitudes and longitudes for the AIRPACT data.
grid = xr.open_dataset('/mnt/data/vonw/airpact5/AIRRUN/2020/2020010200/MCIP37/GRIDCRO2D')
lats = np.reshape(grid.LAT.values,(258,285))
lons = np.reshape(grid.LON.values,(258,285))


#%%
###################################### POCATELLO ######################################
# Create necessary dates for analysis.
city = 'Pocatello'
#year = '2020'
#days = 366
year = '2021'
days = 365

dates = pd.date_range(year, periods=days, freq='D')
#dates = pd.date_range('2021', periods=365, freq='D')

# Create tuple of indices to loop over; NW, NE, SW, SE
#pocatello = (42.916401,-112.515800) # 160050004   ,42.916401,-112.515800,Pocatello STP
pocatello = (42.876701,-112.460297)  # 160050015   ,42.876701,-112.460297 Pocatello Garrett and Gould

po_ilat, po_ilon = find_WRF_indices(pocatello[0], pocatello[1])

# Indices for NW pixel, NE pixel, SW pixel, SE pixel; note that the SW pixel contains the AQS site
ilats = [po_ilat+1, po_ilat+1, po_ilat,   po_ilat]
ilons = [po_ilon-1, po_ilon,   po_ilon-1, po_ilon]


#%%
# Create an empty Pandas dataframe
df = pd.DataFrame(columns=['Rolling_8hr_O3_NW',
                           'Rolling_8hr_O3_NE',
                           'Rolling_8hr_O3_SW',
                           'Rolling_8hr_O3_SE'])

for date in dates:
    print('Processing ozone data files for ' + date.strftime('%Y%m%d'))
    localdir  = '/mnt/data/vonw/airpact5/AIRRUN/' + date.strftime('%Y') + '/' + date.strftime('%Y%m%d00') + '/POST' + '/CCTM/'
    try:
        o3 = xr.open_dataset(localdir + 'O3_L01_08hr_' + (date + pd.Timedelta(-1, unit='d')).strftime('%Y%m%d') + '.ncf')
    except:
        print('Ozone data is missing for this day...')
        continue

    # Append pandas dataframe with ozone data.
    times = [pd.to_datetime(date + pd.Timedelta(t, unit='H')).tz_localize('UTC').tz_convert('US/Mountain') for t in o3.TSTEP.values]
    nw = o3.RollingA8_O3.sel(ROW=ilats[0], COL=ilons[0]).values.flatten()
    ne = o3.RollingA8_O3.sel(ROW=ilats[1], COL=ilons[1]).values.flatten()
    sw = o3.RollingA8_O3.sel(ROW=ilats[2], COL=ilons[2]).values.flatten()
    se = o3.RollingA8_O3.sel(ROW=ilats[3], COL=ilons[3]).values.flatten()
    df = pd.concat([df, pd.DataFrame({'Rolling_8hr_O3_NW': nw,
                                      'Rolling_8hr_O3_NE': ne,
                                      'Rolling_8hr_O3_SW': sw,
                                      'Rolling_8hr_O3_SE': se,
                                      }, index=times)])

df.index.name = 'Datetime'

#%%
df.Rolling_8hr_O3_NW.hvplot() * df.Rolling_8hr_O3_NE.hvplot() * df.Rolling_8hr_O3_SW.hvplot() * df.Rolling_8hr_O3_SE.hvplot()

#%%
df.to_csv('/mnt/data/vonw/airpact5/AIRRUN/' + year + '/' + year + '_' + city + '_' + 'Roll8O3_MST.csv')

#%%
# Determine daily maximum values
dfmx = df.resample('D').max()
dfmx.to_csv('/mnt/data/vonw/airpact5/AIRRUN/' + year + '/' + year + '_' + city + '_' + 'Max8O3_MST.csv')

#%%
###################################### IDAHO FALLS ######################################
# Create necessary dates for analysis.
city = 'IdahoFalls'
#year = '2020'
#days = 366
year = '2021'
days = 365

dates = pd.date_range(year, periods=days, freq='D')
#dates = pd.date_range('2021', periods=365, freq='D')

# Create tuple of indices to loop over; NW, NE, SW, SE
idahofalls = (43.468300,-112.053101) # 160190011   ,43.468300,-112.053101,Idaho Falls / Penford

po_ilat, po_ilon = find_WRF_indices(idahofalls[0], idahofalls[1])

# Indices for NW pixel, NE pixel, SW pixel, SE pixel; note that the SW pixel contains the AQS site
ilats = [po_ilat+1, po_ilat+1, po_ilat,   po_ilat]
ilons = [po_ilon-1, po_ilon,   po_ilon-1, po_ilon]


#%%
# Create an empty Pandas dataframe
df = pd.DataFrame(columns=['Rolling_8hr_O3_NW',
                           'Rolling_8hr_O3_NE',
                           'Rolling_8hr_O3_SW',
                           'Rolling_8hr_O3_SE'])

for date in dates:
    print('Processing ozone data files for ' + date.strftime('%Y%m%d'))
    localdir  = '/mnt/data/vonw/airpact5/AIRRUN/' + date.strftime('%Y') + '/' + date.strftime('%Y%m%d00') + '/POST' + '/CCTM/'
    try:
        o3 = xr.open_dataset(localdir + 'O3_L01_08hr_' + (date + pd.Timedelta(-1, unit='d')).strftime('%Y%m%d') + '.ncf')
    except:
        print('Ozone data is missing for this day...')
        continue

    # Append pandas dataframe with ozone data.
    times = [pd.to_datetime(date + pd.Timedelta(t, unit='H')).tz_localize('UTC').tz_convert('US/Mountain') for t in o3.TSTEP.values]
    nw = o3.RollingA8_O3.sel(ROW=ilats[0], COL=ilons[0]).values.flatten()
    ne = o3.RollingA8_O3.sel(ROW=ilats[1], COL=ilons[1]).values.flatten()
    sw = o3.RollingA8_O3.sel(ROW=ilats[2], COL=ilons[2]).values.flatten()
    se = o3.RollingA8_O3.sel(ROW=ilats[3], COL=ilons[3]).values.flatten()
    df = pd.concat([df, pd.DataFrame({'Rolling_8hr_O3_NW': nw,
                                      'Rolling_8hr_O3_NE': ne,
                                      'Rolling_8hr_O3_SW': sw,
                                      'Rolling_8hr_O3_SE': se,
                                      }, index=times)])

df.index.name = 'Datetime'

#%%
df.Rolling_8hr_O3_NW.hvplot() * df.Rolling_8hr_O3_NE.hvplot() * df.Rolling_8hr_O3_SW.hvplot() * df.Rolling_8hr_O3_SE.hvplot()

#%%
df.to_csv('/mnt/data/vonw/airpact5/AIRRUN/' + year + '/' + year + '_' + city + '_' + 'Roll8O3_MST.csv')

#%%
# Determine daily maximum values
dfmx = df.resample('D').max()
dfmx.to_csv('/mnt/data/vonw/airpact5/AIRRUN/' + year + '/' + year + '_' + city + '_' + 'Max8O3_MST.csv')

#%%
