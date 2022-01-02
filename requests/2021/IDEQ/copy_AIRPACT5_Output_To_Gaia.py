#%%
import os
import pandas as pd
import pysftp

#%%
# Create necessary directories on gaia.
dates = pd.date_range('2020', periods=366, freq='D')

#%%
# Make all the necessary data directories on gaia.
for date in dates:
    os.mkdir('/mnt/data/vonw/airpact5/AIRRUN/' + date.strftime('%Y') + '/' + date.strftime('%Y%m%d00'))
    os.mkdir('/mnt/data/vonw/airpact5/AIRRUN/' + date.strftime('%Y') + '/' + date.strftime('%Y%m%d00') + '/POST')
    os.mkdir('/mnt/data/vonw/airpact5/AIRRUN/' + date.strftime('%Y') + '/' + date.strftime('%Y%m%d00') + '/POST' + '/CCTM')

#%%
# Open an SFTP session to aeolus.wsu.edu
# !! IMPORTANT: ENTER THE DESIRED USERNAME AND PASSWORD !!
USERNAME = 'vonw'
PASSWORD = '...'
sftp = pysftp.Connection('aeolus.wsu.edu', username=USERNAME, password=PASSWORD)

#%%
for date in dates[0:167]:
    print('Copying data files for ' + date.strftime('%Y%m%d'))
    localdir  = '/mnt/data/vonw/airpact5/AIRRUN/' + date.strftime('%Y') + '/' + date.strftime('%Y%m%d00') + '/POST' + '/CCTM'
    remotedir = '/data/lar/projects/airpact5/AIRRUN/' + date.strftime('%Y') + '/' + date.strftime('%Y%m%d00') + '/POST' + '/CCTM/'
    # Navigate to desired local directory
    os.chdir(localdir)
    # Obtain a list of remote files to copy
    try:
        fns = sftp.listdir(remotedir)
    except:
        print('   Missing data...')
        continue
    # Copy each file using SFTP
    for fn in fns:
        sftp.get(remotedir + fn)

#%%
sftp.close()

#%%
