#!/bin/csh -f
#
# example of using this script:
# 
#   > ./run_site_extract_airpact.csh 20120702
#
#       This scripts extract hourly O3 and PM2.5 results from CMAQ air 
#       AirNOW sites.
#

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
   if ( ! $?PBS_O_WORKDIR ) set PBS_O_WORKDIR = $AIRHOME/run_ap5_day1
   if ( ! $?AIRRUN ) then
      set AIRRUN  = /data/lar/projects/airpact5/saved/$YEAR/$MONTH
   endif
   if ( ! $?AIROUT )        set AIROUT        = $AIRRUN/aconc
   if ( ! $?AIRLOGDIR )     set AIRLOGDIR     = $AIROUT
   if ( ! $?mciproot )      set mciproot      = /data/lar/projects/airpact5/AIRRUN/$YEAR     # find MCIP in airpact4 location
   if ( ! $?MCIPDIR )       set MCIPDIR       = $mciproot/${1}00/MCIP37
   set BASE = ${PBS_O_WORKDIR}/post/cctm/extract_AIRNow

    # specifying the spheroids to be used
      setenv IOAPI_ISPH 19
  #> get necesary files defined
     setenv GRIDCRO2D  $MCIPDIR/GRIDCRO2D
     setenv O3FILE     $AIROUT/combined_${currentday}.ncf 
     setenv PM25FILE   $AIROUT/combined_${currentday}.ncf 

#> run the extraction script -------------------------------------------

   cp $BASE/aqsid_TCOPS.csv $AIROUT/aqsid.csv
   cd $AIROUT
   ~airpact5/AIRHOME/build/extract_AIRNow/site_extract.x   >&! $AIRLOGDIR/post_xtr4TCOPS_$YEAR$MONTH$DAY.log


exit(0)
