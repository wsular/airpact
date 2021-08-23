#!/bin/csh -f
#
# example of using this script:
# 
#   > ./run_site_extract_airpact_v3.csh 20160223
#
#       This scripts extract hourly O3, PM2.5, WSPMPM.25 tracer results 
#       from CMAQ AirNOW sites.
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
   if ( ! $?PBS_O_WORKDIR ) set PBS_O_WORKDIR = $AIRHOME/run
   if ( ! $?AIRRUN )        set AIRRUN  = /data/lar/projects/airpact5/AIRRUNDAY2/$YEAR
   if ( ! $?AIROUT )        set AIROUT        = $AIRRUN/${1}00
   if ( ! $?AIRLOGDIR )     set AIRLOGDIR     = $AIROUT/LOGS
   if ( ! $?mciproot )      set mciproot      = /data/airpact4/AIRRUN     # find MCIP in airpact4 location
   if ( ! $?MCIPDIR )       set MCIPDIR       = $mciproot/${1}00/MCIP
   set BASE = ${PBS_O_WORKDIR}/post/cctm/extract_AIRNow

    # specifying the spheroids to be used
      setenv IOAPI_ISPH 19
  #> get necesary files defined
     setenv GRIDCRO2D  $MCIPDIR/GRIDCRO2D
     setenv O3FILE     $AIROUT/POST/CCTM/combined_${currentday}.ncf 
     setenv PM25FILE   $AIROUT/POST/CCTM/combined_${currentday}.ncf 
     setenv WSPM25FILE $AIROUT/POST/CCTM/combined_${currentday}.ncf 

#> run the extraction script -------------------------------------------
   mkdir -p $AIROUT/POST/CCTM 
   cd $AIROUT/POST/CCTM
#   cp $BASE/aqsid.csv $AIROUT/POST/CCTM
    set lines = `wc -l $BASE/aqsid.csv | cut -f1 -d' ' `
    set bodylines = `expr $lines - 2`  ; echo Body-Lines is $bodylines

    head -2  $BASE/aqsid.csv >! aqsid_head.txt
    cat aqsid_head.txt

    tail -$bodylines  $BASE/aqsid.csv >! aqsid_body.txt
    cut -c1-32 aqsid_body.txt >! aqsid_body_one.txt 
    cut -c33-  aqsid_body.txt | sed -f ~/AIRHOME/build/extract_AIRNow/aqsid.sed >! aqsid_body_two.txt
    paste -d' ' aqsid_body_one.txt aqsid_body_two.txt >! aqsid_body_three.txt 
    cat aqsid_head.txt aqsid_body_three.txt >! aqsid.csv

   ~airpact5/AIRHOME/build/extract_AIRNow/site_extract_v3.x   >&! $AIRLOGDIR/post/log04b_post_xtr4airnow_elev.txt

#> clean up ------------------------------------------------------------
#   /bin/rm -f $AIROUT/POST/CCTM/AIRNow_sites.txt

exit(0)
