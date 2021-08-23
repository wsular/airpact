#!/bin/csh -fX
#
# example of using this script:
# 
#   > ./run_site_extract_airpact_v6.csh 20160223
#
#  2018-04-16    Joe Vaughan  updated to call updated v6 script for extract_AIRNow:
#   	1) to get fresh AIRNow sites daily, 
#   	2) to call v6 executable extracting (CO, NO, NO2, NOX, O3, PM2.5, PM10, SO2, WSPM2.5) and include header w/ units.
#  2019-09-24    Joe Vaughan  updated to sue sites fiel found by day1 post processing.
#

#> check argument & set date strings -----------------------------------

   if ( $1 > 20000100 ) then     
      set currentday = $1
      set YEAR  = `echo $currentday | cut -c1-4`
      set MONTH = `echo $currentday | cut -c5-6`
      set DAY   = `echo $currentday | cut -c7-8`
      set previousday = `date -d "$currentday -1 days" '+%Y%m%d'`
   else
      echo 'invalid argument. '
      echo "usage $0 <yyyymmdd>"
      set exitstat = 1
       exit ( $exitstat )
   endif

  #> initialize exit status
     set exitstat = 0

#> check environment variable ------------------------------------------

   if ( ! $?AIRHOME )       set AIRHOME       = ~airpact5/AIRHOME
   if ( ! $?PBS_O_WORKDIR ) set PBS_O_WORKDIR = $AIRHOME/run_ap5_day2
   if ( ! $?AIRRUN ) then
      set AIRRUN  = /data/lar/projects/airpact5/AIRRUNDAY2/$YEAR
   endif
   if ( ! $?AIROUT )        set AIROUT        = $AIRRUN/${1}00
   if ( ! $?AIRLOGDIR )     set AIRLOGDIR     = $AIROUT/LOGS
   if ( ! $?mciproot )      set mciproot      = $AIRRUN
   if ( ! $?MCIPDIR )       set MCIPDIR       = $mciproot/${1}00/MCIP37
   set BASE = ${PBS_O_WORKDIR}/post/cctm/extract_AIRNow
   set pYEAR  = `echo $previousday | cut -c1-4`

    # specifying the spheroids to be used
      setenv IOAPI_ISPH 19
  #> get necesary files defined
     setenv GRIDCRO2D  $MCIPDIR/GRIDCRO2D
     setenv INFILE     $AIROUT/POST/CCTM/combined_${currentday}.ncf 

#> run the extraction script -------------------------------------------
   mkdir -p $AIROUT/POST/CCTM 
   cd $AIROUT/POST/CCTM

#jkv# Implements wget for daily sites list.  JKV 022318  but ask for previous day, as current will nto be available yet.
#jkv   wget -N -nv --no-check-certificate http://lar.wsu.edu/airpact/airnow_sites/aqsid${previousday}.csv
#jkv   if ( -e aqsid${previousday}.csv ) then
#jkv	ln -f aqsid${previousday}.csv aqsid.csv
#jkv	ls -lt aqsid.csv
#jkv	echo Using newly acquired airnow sites file 
#jkv   else
#jkv	echo WGET FAILED for aqsid${previousday}.csv  
#jkv	cp -f $BASE/aqsid.csv aqsid.csv
#jkv   endif

# Instead of using wget, use the aqsid.csv file in use for the day1 run.
   ln -f /data/lar/projects/airpact5/AIRRUN/$pYEAR/${previousday}00/POST/CCTM/aqsid.csv aqsid.csv
   ls -lt aqsid.csv
   echo Using newly acquired day1 run sites file 

~airpact5/AIRHOME/build/extract_AIRNow/site_extract_v6.x   >&! $AIRLOGDIR/post/log04_post_xtr4airnow.txt 

# #> clean up ------------------------------------------------------------
#    /bin/rm -f $AIROUT/POST/CCTM/AIRNow_sites.txt

exit(0)
