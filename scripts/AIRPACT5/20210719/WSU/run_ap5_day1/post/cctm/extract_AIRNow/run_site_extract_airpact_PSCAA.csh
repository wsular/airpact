#!/bin/csh -f
#
# example of using this script:
# 
#   > ./run_site_extract_airpact_PSCAA.csh 20160223
# JUSR GETTING COL AND ROW FOR LAT/LONG  47.6062 and 122.3321
#
# based on updated v7 (sci. not. output) script for extract_AIRNow:
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
   if ( ! $?PBS_O_WORKDIR ) set PBS_O_WORKDIR = $AIRHOME/run_ap5_day1
   if ( ! $?AIRRUN )        set AIRRUN  = /data/lar/projects/airpact5/AIRRUN
   if ( ! $?AIROUT )        set AIROUT        = $AIRRUN/$YEAR/${1}00
   if ( ! $?AIRLOGDIR )     set AIRLOGDIR     = $AIROUT/LOGS
#   if ( ! $?mciproot )      set mciproot      = $AIROUT/MCIP37 
   if ( ! $?MCIPDIR )       set MCIPDIR       = $AIROUT/MCIP37
   set BASE = ${PBS_O_WORKDIR}/post/cctm/extract_AIRNow

    # specifying the spheroids to be used
      setenv IOAPI_ISPH 19
  #> get necesary files defined
     setenv GRIDCRO2D  $MCIPDIR/GRIDCRO2D
     setenv INFILE     $AIROUT/POST/CCTM/combined_${currentday}.ncf 

#> run the extraction script -------------------------------------------
   mkdir -p $AIROUT/POST/CCTM 
   cd $AIROUT/POST/CCTM

## Implements wget for daily sites list.  JKV 022318  but ask for previous day, as current will nto be available yet.
#   wget -N -nv --no-check-certificate http://lar.wsu.edu/airpact/airnow_sites/aqsid${previousday}.sv
#   if ( -e aqsid${previousday}.csv ) then
#	ln -f aqsid${previousday}.csv aqsid.csv
#	ls -lt aqsid.csv
#	echo Using newly acquired airnow sites file 
#   else
#	echo WGET FAILED for aqsid${previousday}.csv  
#	cp -f $BASE/aqsid.csv aqsid.csv
#   endif

 cp -f $BASE/PSCAA_site.csv aqsid.csv
~airpact5/AIRHOME/build/extract_AIRNow/site_extract_v7.x   >&! $AIRLOGDIR/post/log04_post_xtr4airnow.txt 

# #> clean up ------------------------------------------------------------
#    /bin/rm -f $AIROUT/POST/CCTM/AIRNow_sites.txt

exit(0)