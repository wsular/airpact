#!/bin/tcsh -f

# example of using this script:
#
#  <prompt> ./run_08hr_O3.csh 20120702 
#
#    where 20120702 denotes forecast start time of 8 GMT on Jul 1, 2012
#
#   Joe Vaughan     2012-05
#   Serena H. Chung 2012-05-10  
#   Joe Vaughan     2012-05 Modified to run from saved combine files.
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
   set previousday = `date -d "$currentday -1 days" '+%Y%m%d'`
   set PYEAR = `echo $previousday | cut -c1-4`
   set PMONTH  = `echo $previousday | cut -c5-6`
   set PDAY  = `echo $previousday | cut -c7-8`

#> for testing only --------------------------------------------------

   if ( ! $?AIRHOME )       set AIRHOME       = ~airpact5/AIRHOME
   if ( ! $?PBS_O_WORKDIR ) set PBS_O_WORKDIR = $AIRHOME/run_ap5_day1
   if ( ! $?AIRRUN ) set AIRRUN  = /data/lar/projects/airpact5/AIRRUN/$YEAR
   if ( ! $?AIROUT )  set AIROUT        = $AIRRUN/${1}00
   if ( ! -d $AIROUT/$currentday/POST/CCTM)  mkdir -p $AIROUT  
   if ( ! $?AIRLOGDIR )   set AIRLOGDIR     = $AIROUT/LOGS
   if ( ! -d $AIRLOGDIR ) mkdir -p $AIRLOGDIR/post
   if ( ! $?SAVED )     set SAVED = /data/lar/projects/airpact5/saved

#> get necessary files and path defined ------------------------------

   setenv YESTERDAY   $SAVED/$PYEAR/$PMONTH/aconc/combined_${previousday}.ncf
   setenv TODAY       $SAVED/$YEAR/$MONTH/aconc/combined_${currentday}.ncf
   setenv ROLLING8HR  $AIROUT/POST/CCTM/O3_L01_08hr_${previousday}.ncf
   if ( -e $ROLLING8HR ) rm -f   $ROLLING8HR

#> run the program to do 8-hr averaging --------------------------------
   setenv PROMPTFLAG N
   setenv IOAPI_LOG_WRITE FALSE
   $AIRHOME/build/ave08hr/RollingAvg_O3.x >&! $AIRLOGDIR/post/log02_post_ave08hr.txt

exit(0)

