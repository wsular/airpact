#!/bin/csh -f
#
# example of using this script:
# 
#   > ./run_extract_day-avg_PM25_HealthDemand.csh YYYYMMDD
#
#       This script extracts the target day's average PM2.5 for use in the Health Demand App/Webpage.
#       The 24-hr average for the day YYYYMMDD is the 00 hh labeled running 24-hr average.
#       JKV September 2017 

#> check argument & set date strings -----------------------------------

   if ( $1 > 20000100 ) then     
      set currentday = $1
      set YEAR  = `echo $currentday | cut -c1-4`
      set MONTH = `echo $currentday | cut -c5-6`
      set DAY   = `echo $currentday | cut -c7-8`
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
   if ( ! $?PBS_O_WORKDIR ) set PBS_O_WORKDIR = $AIRHOME/run_fastscratch
   if ( ! $?AIRRUN ) then
      set AIRRUN  = /data/lar/projects/airpact5/AIRRUN/$YEAR
   endif
   if ( ! $?AIROUT )        set AIROUT        = $AIRRUN/${1}00
   if ( ! $?AIRLOGDIR )     set AIRLOGDIR     = $AIROUT/LOGS
   if ( ! $?mciproot )      set mciproot      = /data/lar/projects/airpact5/AIRRUN/$YEAR
   if ( ! $?MCIPDIR )       set MCIPDIR       = $mciproot/${1}00/MCIP37

     set EXEC = ~/AIRHOME/build/json_exports/Export_PM2.5-24hr.exe

#    # specifying the spheroids to be used
#      setenv IOAPI_ISPH 19
#  #> get necesary files defined
#     setenv GRIDCRO2D  $MCIPDIR/GRIDCRO2D
#	need day before date
#
     set previousday = `date -d "$currentday -1 days" '+%Y%m%d'`
     setenv PM25_24hr    $AIROUT/POST/CCTM/PM25_L01_24hr_${previousday}.ncf 

#> run the extraction script -------------------------------------------
     cd $AIROUT/POST/CCTM 
     $EXEC >&! $AIRLOGDIR/post/log04d_post_xtrPM25_json.txt

#rename JSON file
     mv -f PM25.json PM25_24hr_${currentday}.json

# #> clean up ------------------------------------------------------------

exit(0)
