#print(" Python code for converting hourly to 24-hr avg PM2.5, prepartory to converting to AQI values. JKV " )
#print(" Input file format is based on AIRPACT v6.dat, but has been grepped for PM2.5 pefore passed in,")
#print(" for the WRF-Sfire AIRPACT result processing -- CMAQ results part ")
#print(" Header (not present in files) for input data is: DateTime,AQSID,O3_mod,PM2.5_mod,O3_obs,PM2.5_obs ")
#print(" sitecol = 3, datecol = 1, timecol = 2, speciescol = 4, modelcol =5, datimecol =0")

# FORMAT OF WRF_SFIRE *_v6.dat files:
#MM/DD/YY UTZ | HH:MM UTZ | SITEID | SPECIES | PPB or ug/m3
#08/17/15 | 08:00 |000100060|CO| 284.0
#08/17/15 | 08:00 |000100060|NO|   0.0
#08/17/15 | 08:00 |000100060|NO2|   1.8
#08/17/15 | 08:00 |000100060|NOX|   1.8
#08/17/15 | 08:00 |000100060|OZONE|  53.0
#08/17/15 | 08:00 |000100060|PM10|  11.3
#08/17/15 | 08:00 |000100060|PM2.5|  11.2
#08/17/15 | 08:00 |000100060|SO2|   0.6
#08/17/15 | 08:00 |000100060|WSPM2.5|   0.0

#print(" THIS CODE ONLY AVERAGES THE PM2.5_obs values, from hr 08 thru hr 07. and writes them in same format as hr 08")

# Note from Jen Hinds on dealing with missing values:
#  For PM2.5:
#  24-hr averages require 18 values
#  PM2.5_obs_avg <- rollapply(PM2.5_obs, width=24, mean, fill=NA, partial=18, align='left')
#  
#  For Ozone:
#  8-hr averages require 6 values
#  O3_obs_avg <- rollapply(O3_obs, width=8, mean, fill=NA, partial=6, align='left')

import csv
import sys
import aqi

# setting for Obs for hr avg PM2.5 file
datimecol = 0
datecol = 1
timecol = 2
sitecol = 3
modo3col = 0
modpm25col = 5
obso3col   = 0
obspm25col = 0

infile  = sys.argv[1]
outfile  = sys.argv[2]

print('INFILE is: ', infile )
print('OUTFILE is: ', outfile )

fout = open(outfile,'w+')

with open(infile) as csv_file:
    csv_reader = csv.reader(csv_file, delimiter='|')
#   Initialize before first loop
    loop_count = 0
    line_count = 0
    indate   = "null"
    intime   = "null"
    insite     = "null"
#    inmodo3   = 0.0
#    missing_inmodo3 = 0
    inmodpm25 = 0.0
    missing_inmodpm25 = 0
    for row in csv_reader:
        print(f'Values read in:  {", ".join(row)}')
        indate = row[datecol-1]
        intime = row[timecol-1]
        if line_count == 0:
             savedate = indate
             savetime = intime
        insite = row[sitecol-1]

#        if row[modo3col-1] != '':
#             inmodo3 = inmodo3 + float(row[modo3col-1])
#        else:
#             missing_inmodo3 += 1 

        if row[modpm25col-1] != '':
             inmodpm25 = inmodpm25 + float(row[modpm25col-1])
        else:
             missing_inmodpm25 += 1 

#        if row[obso3col-1] != '':
#             inobso3 = inobso3 + float(row[obso3col-1])
#        else:
#             missing_inobso3 += 1 

#        if row[obspm25col-1] != '':
#             inobspm25 = inobspm25 + float(row[obspm25col-1])
#        else:
#             missing_inobspm25 += 1 

#        print (f'\tREADIN OR SUM: ',indatime, insite, inmodo3, inmodpm25, inobso3, inobspm25 )
        if line_count == 23:
                
#             if missing_inmodo3 <= 6:
#                outmodo3 =   inmodo3/(24.0-float(missing_inmodo3))
#             else:
#                outmodo3 = float('nan')
                
             if missing_inmodpm25 <= 6:
                outmodpm25 = inmodpm25/(24.0-float(missing_inmodpm25))
             else:
                outmodpm25 = float('nan')

#             if missing_inobso3 <= 6:
#                outobso3 = inobso3/(24.0-float(missing_inobso3))
#             else:
#                outobso3 = float('nan')
#
#             if missing_inobspm25 <= 6:
#                outobspm25 = inobspm25/(24.0-float(missing_inobspm25))
#             else:
#                outobspm25 = float('nan')

#             print (f'\tAVG24: ',savedatime, insite, outmodo3, outmodpm25, outobso3, outobspm25 )
#             print ('AVG24: ',savedatime,',',insite,',',outmodo3,',',outmodpm25,',',outobso3,',',outobspm25 )
#             print (savedatime,',',insite,',',outmodo3,',',outmodpm25,',',outobso3,',',outobspm25,'\n')
             lineout="{},{},{},{:.1f}\n".format(savedate,savetime,insite,outmodpm25)
             fout.write(lineout)
             print (savedate,',',savetime,',',insite,',',outmodpm25)
#             inmodo3   = 0.0
#             missing_inmodo3 = 0
             inmodpm25 = 0.0
             missing_inmodpm25 = 0
#             inobso3   = 0.0
#             missimng_inobso3   = 0
#             inobspm25 = 0.0
#             missing_inobspm25 = 0
             line_count = 0
             loop_count += 1
        else:
             line_count += 1 
fout.close()
print(f'Processed ', line_count,' lines and ',loop_count,'loops.')
print(f' END OF PYTHON CODE.')
