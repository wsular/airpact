#!/usr/bin/env csh
##!/bin/csh -fX
#
# example of using this script:
# 
#   > ./run_site_daily_max8hr03.csh 
#
#  2021-04-10    Joe Vaughan: created for calculating daily max8hrO3 per site for entire year of days.
#
# Input data will look like:

#> check argument & set date strings -----------------------------------

# module load commands:
module load gcc/7.3.0
module load python/3.8.8/gcc/7.3.0

which python3
whereis python3

#
#> check environment variable ------------------------------------------

   set BASE = ~airpact5/AIRHOME/run_ap5_day1/post/cctm/extract_max8hro3_IDEQ
   echo BASE $BASE 
   cd $BASE

   foreach infile ( 2020_Id_Falls_NE_Roll8O3_MST.csv \
                    2020_Id_Falls_NW_Roll8O3_MST.csv \
                    2020_Id_Falls_SE_Roll8O3_MST.csv \
                    2020_Id_Falls_SW_Roll8O3_MST.csv \
                    2020_Pocatello_NE_Roll8O3_MST.csv \
                    2020_Pocatello_NW_Roll8O3_MST.csv \
                    2020_Pocatello_SE_Roll8O3_MST.csv \
                    2020_Pocatello_SW_Roll8O3_MST.csv )

                    set INFILE = ~/AIRRUN/2020/$infile
                    echo INFILE is $INFILE
                    if ( ! -e $INFILE ) then
                        echo $INFILE is not found.  Exit.
                        exit(9)
                    endif
                    set OUTFILE = `echo $INFILE | sed -e 's/Roll8O3/Max8O3/'`
                    echo OUTFILE is $OUTFILE 
                    head -1 $INFILE >! $OUTFILE
                    ls -lt  $BASE/daily_max8hrO3.py 
                    echo python3 $BASE/daily_max8hrO3.py $INFILE $OUTFILE 
                    python3 $BASE/daily_max8hrO3.py $INFILE $OUTFILE >&! $BASE/daily_max8O3.log
                    set pystat = $status
                    sleep 2
		    if ( $pystat == 0 ) then
                       echo Status after python call is $pystat
                    else 
                       echo Bad status on python 
                       exit($pystat)
                    endif
     end 
exit($pystat)
