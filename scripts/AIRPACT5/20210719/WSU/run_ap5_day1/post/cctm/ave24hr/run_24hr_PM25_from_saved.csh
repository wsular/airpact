#!/bin/tcsh -f

# example of using this script:
#
#  <prompt> ./run_24hr_PM25_from_saved.csh 20120702 
#
#    where 20120702 denotes forecast start time of 8 GMT on May 1, 2012
#
#   Joe Vaughan     2012-05
#   Serena H. Chung 2015-10-22 updated for AIRPACT5
#

#> initialize exit status ----------------------------------------------
   set exitstat = 0

#> check argument  -----------------------------------------------------

   if ( $#argv == 1 ) then
      set currentday = $1
      set YEAR  = `echo $1 | cut -c1-4`
      set MONTH = `echo $1 | cut -c5-6`
      set DAY   = `echo $1 | cut -c7-8`
   else
      echo 'invalid argument. '
      echo "usage $0 <yyyymmdd>"
      set exitstat = 1
      exit ( $exitstat )
   endif
   set prevday = `date -d "$currentday -1 days" '+%Y%m%d'`
   set prevdayyear = `echo $prevday | cut -c1-4`
   set prevdaymon  = `echo $prevday | cut -c5-6`

#> for testing only --------------------------------------------------

   if ( ! $?AIRHOME )       set AIRHOME       = ~airpact5/AIRHOME
   if ( ! $?PBS_O_WORKDIR ) set PBS_O_WORKDIR = $AIRHOME/run
   if ( ! $?SAVED  )        set SAVED   = /data/lar/projects/airpact5/saved/$YEAR
   if ( ! $?SAVEDm1  )      set SAVEDm1 = /data/lar/projects/airpact5/saved/$prevdayyear 
   if ( ! $?AIRRUN )        set AIRRUN  = /data/lar/projects/airpact5/AIRRUN/$YEAR
   if ( ! $?AIROUT )        set AIROUT  =    $AIRRUN/${1}00
   if ( ! -e $AIROUT/POST/CCTM )      mkdir -p $AIROUT/POST/CCTM
   if ( ! $?AIRLOGDIR )     set AIRLOGDIR     = $AIROUT/LOGS
   if ( ! -e $AIRLOGDIR )      mkdir -p $AIRLOGDIR/post
   
#> get necessary files and path defined ------------------------------__

   setenv YESTERDAY    $SAVEDm1/$prevdaymon/aconc/combined_${prevday}.ncf
   setenv TODAY        $SAVED/$MONTH/aconc/combined_${currentday}.ncf
   setenv ROLLING24HR  $AIROUT/POST/CCTM/PM25_L01_24hr_${prevday}.ncf
   if ( -e $ROLLING24HR ) rm -f $ROLLING24HR

#> run the program to do 24-hr averaging -------------------------------
   setenv PROMPTFLAG N
   setenv IOAPI_LOG_WRITE FALSE
   $AIRHOME/build/ave24hr/RollingAvg_PM25.x >&! $AIRLOGDIR/post/log03_post_ave24hr.txt

exit(0)

