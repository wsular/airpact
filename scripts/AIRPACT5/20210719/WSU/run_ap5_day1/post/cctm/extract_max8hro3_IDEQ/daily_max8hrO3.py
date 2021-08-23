#%%
import numpy  as np
import pandas as pd
import xarray as xr
import sys
import csv
import os

# Reads from year of hourly rolling 8hr-avg O3 values groups of 24 records and writes max for day (MST day) to outfile

infile  = sys.argv[1]
outfile  = sys.argv[2]
print('INFILE is: ', infile )
print('OUTFILE is: ', outfile )

# Input data will look like:
'''
MM/DD/YY_MST|_HH:MM_MST|_SITEID|_SPECIES|_PPB_or_ug/m3
2020-01-01|00:00:00|Pocatello_SE|RollingA8_O3|46.6325
2020-01-01|01:00:00|Pocatello_SE|RollingA8_O3|46.5805
2020-01-01|02:00:00|Pocatello_SE|RollingA8_O3|46.5924
2020-01-01|03:00:00|Pocatello_SE|RollingA8_O3|46.4411
2020-01-01|04:00:00|Pocatello_SE|RollingA8_O3|46.023
2020-01-01|05:00:00|Pocatello_SE|RollingA8_O3|45.9773
2020-01-01|06:00:00|Pocatello_SE|RollingA8_O3|46.3565
2020-01-01|07:00:00|Pocatello_SE|RollingA8_O3|47.0402
2020-01-01|08:00:00|Pocatello_SE|RollingA8_O3|47.755
2020-01-01|09:00:00|Pocatello_SE|RollingA8_O3|48.4101
2020-01-01|10:00:00|Pocatello_SE|RollingA8_O3|48.9597
2020-01-01|11:00:00|Pocatello_SE|RollingA8_O3|49.5081
2020-01-01|12:00:00|Pocatello_SE|RollingA8_O3|50.0745
2020-01-01|13:00:00|Pocatello_SE|RollingA8_O3|50.1885
2020-01-01|14:00:00|Pocatello_SE|RollingA8_O3|49.9172
2020-01-01|15:00:00|Pocatello_SE|RollingA8_O3|49.4109
2020-01-01|16:00:00|Pocatello_SE|RollingA8_O3|48.9084
2020-01-01|17:00:00|Pocatello_SE|RollingA8_O3|48.4613
2020-01-01|18:00:00|Pocatello_SE|RollingA8_O3|48.056
2020-01-01|19:00:00|Pocatello_SE|RollingA8_O3|47.6101
2020-01-01|20:00:00|Pocatello_SE|RollingA8_O3|47.1399
2020-01-01|21:00:00|Pocatello_SE|RollingA8_O3|46.7413
2020-01-01|22:00:00|Pocatello_SE|RollingA8_O3|46.3317
2020-01-01|23:00:00|Pocatello_SE|RollingA8_O3|45.9919 
'''
fout = open(outfile,'w+')

with open(infile) as csv_file:
    csv_reader = csv.reader(csv_file, delimiter='|')
    max8O3 = float(0.0)
    print("Type max8O3: ", type(max8O3), max8O3 )
    row_count = 0
    loop_count = 0
    for row in csv_reader:
        if row_count == 0:
            print(f'HEADER Values read in:  {", ".join(row)}')
            loop_count = -1
        else:
#            print(f'Values read in:  {", ".join(row)}')
            indate = str(row[0])
            intime = str(row[1])
            insite = str(row[2])
            inspecies = str(row[3])
            inozone8hr=  float(row[4])
            if inozone8hr > max8O3:
                 max8O3 = inozone8hr
                 maxdate = indate
                 maxtime = intime
                 maxsite = insite
                 maxspecies = inspecies
                 print("Max set to ",max8O3)
        row_count += 1
        loop_count += 1
        if loop_count == 24:
            print("End of day at indate-intime: ",indate,"-",intime," at loop_count: ",loop_count)
            lineout="{},{},{},{:.1f}\n".format(maxdate, maxtime, maxsite, max8O3)
            #print(" Max 8hr O3 is ", maxdate, maxtime, max8O3)
            fout.write(lineout)
            loop_count = 0
            max8O3 = float(0.0)
            
print("EOF at row_count: ",row_count," at row_count: ",loop_count)

#write last day max
lineout="{},{},{},{:.1f}\n".format(maxdate, maxtime, maxsite, max8O3)
fout.write(lineout)
fout.close()

print(" End of python script for 8hr max O3")

exit()
