#!/bin/tcsh -fX

# example of using this script:
#
#  <prompt> ./run_24hr_PM25.csh 20120702 
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
   set previousday = `date -d "$currentday -1 days" '+%Y%m%d'`
   set previousdayyear = `echo $previousday | cut -c1-4`

#> for testing only --------------------------------------------------

   if ( ! $?AIRHOME )       set AIRHOME       = ~airpact5/AIRHOME
   if ( ! $?PBS_O_WORKDIR ) set PBS_O_WORKDIR = $AIRHOME/run_ap5_day2
   if ( ! $?AIRRUN ) then
      set AIRROOT1 = /data/lar/projects/airpact5/AIRRUN
      set AIRRUN   = /data/lar/projects/airpact5/AIRRUNDAY2/$YEAR
   endif
   if ( ! $?AIROUT )        set AIROUT        = $AIRRUN/${1}00
   if ( ! $?AIRLOGDIR )     set AIRLOGDIR     = $AIROUT/LOGS

#> get necessary files and path defined ------------------------------__

   setenv YESTERDAY    $AIRROOT1/$previousdayyear/${previousday}00/POST/CCTM/combined_${previousday}.ncf
   echo YESTERDAY $YESTERDAY
   ls -lt $YESTERDAY
   setenv TODAY        $AIROUT/POST/CCTM/combined_${currentday}.ncf
   echo TODAY $TODAY
   ls -lt $TODAY
   setenv ROLLING24HR  $AIROUT/POST/CCTM/PM25_L01_24hr_${previousday}.ncf
   if ( -e $ROLLING24HR ) rm -f $ROLLING24HR

#> wait on necessary input file, added by JKV 111317
   if ( -e $AIRLOGDIR/wait_run_24hr_PM25.log  ) rm  -f $AIRLOGDIR/wait_run_24hr_PM25.log
   ~/bin/wait_for_tstep_in_ncf.csh $YESTERDAY 24 >&! $AIRLOGDIR/wait_run_24hr_PM25.log
   ~/bin/wait_for_tstep_in_ncf.csh $TODAY 24 >> $AIRLOGDIR/wait_run_24hr_PM25.log
        
#> run the program to do 24-hr averaging -------------------------------
   setenv PROMPTFLAG N
   setenv IOAPI_LOG_WRITE FALSE
   $AIRHOME/build/ave24hr/RollingAvg_PM25.x >&! $AIRLOGDIR/post/log03_post_ave24hr.txt

exit(0)

