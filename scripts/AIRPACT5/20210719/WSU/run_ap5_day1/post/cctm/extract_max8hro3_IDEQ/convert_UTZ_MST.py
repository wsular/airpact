#%%
import pandas as pd
import sys

#%% Read in sample data
INFILE  = sys.argv[1]
OUTFILE  = sys.argv[2]
#df_UTC = pd.read_csv('/Users/vonw/work/software/airpact/IDEQ/pm25.dat', sep='|', parse_dates={'Time': ['_MM/DD/YY_UTZ', '_HH:MM_UTZ']}, index_col='Time')
df_UTC = pd.read_csv(INFILE, sep='|', parse_dates={'Time': ['_MM/DD/YY_UTZ', '_HH:MM_UTZ']}, index_col='Time')
#print("dates read in: ",df_UTC)

#%% Convert Pandas dataframe index to UTC
df_UTC = df_UTC.tz_localize('UTC')
#print("dates as UTC dataframe: ", df_UTC)

#%% Create a new dataframe with index in MST.
df_MST = df_UTC.tz_convert('MST')
#print("dates as MST: ", df_MST)
#print(df_MST)
fout = open(OUTFILE,'w+')
#df_MST.to_csv(OUTFILE)
df_MST.to_csv(fout)

#print(" End of python script for time conversion")

exit()

