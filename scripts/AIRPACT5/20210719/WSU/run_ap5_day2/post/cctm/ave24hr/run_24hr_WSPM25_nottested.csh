#!/bin/tcsh -f

# example of using this script:
#
#  <prompt> ./run_24hr_WSPM25.csh 20160223 
#
#    where 20160223 denotes forecast start time of 8 GMT on May 1, 2012
#
#   Serena H. Chung 2016-02-23
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
   if ( ! $?PBS_O_WORKDIR ) set PBS_O_WORKDIR = $AIRHOME/run
   if ( ! $?AIRRUN ) then
      set AIRRUN  = /data//lar/projects/airpact5/AIRRUN/$YEAR
   endif
   if ( ! $?AIROUT )        set AIROUT        = $AIRRUN/${1}00
   if ( ! $?AIRLOGDIR )     set AIRLOGDIR     = $AIROUT/LOGS

#> get necessary files and path defined --------------------------------

   setenv YESTERDAY    $AIRROOT/$previousdayyear/${previousday}00/POST/CCTM/combined_${previousday}.ncf
   setenv TODAY        $AIROUT/POST/CCTM/combined_${currentday}.ncf
   setenv OUTFILE      $AIROUT/POST/CCTM/WSPM25_L01_24hr_${previousday}.ncf
   if ( -e $OUTFILE ) rm -f $OUTFILE

#> other program parameters --------------------------------------------
   setenv PROMPTFLAG N
   setenv IOAPI_LOG_WRITE FALSE
   setenv NHRS 24  # number of hours to average over
   setenv VNAMEIN  WSPM25
   setenv VNAMEOUT Avg${NHRS}_$VNAMEIN
   setenv PRGDIR $prgdir
   set prgdir  = ~airpact5/AIRHOME/build/rolling_avg
   set prgexe = rolling_avg.x


#> run the program to do 24-hr averaging -------------------------------
   $prgdir/$prgexe >&! $AIRLOGDIR/post/log03b_post_ave24hr_wspm25.txt

exit(0)
