#!/bin/csh -fX

# example of using this script:
# 
#   > ./run_sum2daily_dep.csh 20151201
#
#
#  2015-12-01    Serena H. Chung      initial version

# initialize exit status -----------------------------------------------
  set exitstat = 0

# check argument & set date strings  -----------------------------------

  if ( $1 > 20000101 ) then     
     set YEAR  = `echo $1 | cut -c1-4`
     set MONTH = `echo $1 | cut -c5-6`
     set DAY   = `echo $1 | cut -c7-8`
     set currentday  = $1
     set previousday = `date -d "$currentday -1 days" '+%Y%m%d'`
     set twodaysago  = `date -d "$currentday -2 days" '+%Y%m%d'`
  else # if no command-line input, use system time
     set today     = `perl -e 'printf "%d\n", (gmtime(time()))[3]'` #today local time 
     set thismonth = `perl -e 'printf "%d\n", (gmtime(time()))[4]+1'`#format month (January = 0)
     set thisyear  = `perl -e 'printf "%d\n", (gmtime(time()))[5]+1900'`#format year
     set YEAR = $thisyear
     if ( $thismonth < 10 ) set thismonth = 0${thismonth}
     if ( $today < 10 ) set today = 0${today}
     set currentday = ${thisyear}${thismonth}${today}
  endif


# "pre"conditions --need to set during test ----------------------------

   if ( ! $?AIRHOME        ) set AIRHOME = ~airpact5/AIRHOME
   if ( ! $?AIRRUN ) then
      set AIRRUN  = /data/lar/projects/airpact5/AIRRUN/$YEAR
   endif
   if ( ! $?AIROUT         ) set AIROUT = $AIRRUN/${currentday}00
   if ( ! $?AIRLOGDIR      ) set AIRLOGDIR = $AIROUT/LOGS
   if ( ! $?MCIPDIR        ) set MCIPDIR   = /data/lar/projects/airpact5/AIRRUN/$YEAR/${currentday}00/MCIP37
   if ( ! $?BCONDIR        ) set BCONDIR   = $AIROUT/BCON
   if ( ! $?PBS_O_WORKDIR  ) set PBS_O_WORKDIR = ~airpact5/AIRHOME/run_ap5_day1
   if ( ! $?AIRSAVE        ) set AIRSAVE = /data/lar/projects/airpact5/saved/$YEAR

# fortran program ------------------------------------------------------
  set prgdir = ~/AIRHOME/build//sum_ntime
  set prgexe = sum_ntime.x
  setenv NTSTEP2SUM 24
  setenv UNITS kg/hectare/day
  setenv VDESC "daily sum values"
#
  set savedir = $AIRSAVE/${MONTH}/deposition
  if ( ! -d $savedir ) mkdir -p $savedir
  set wrkdir = $PBS_O_WORKDIR/post/cctm/deposition
  foreach type ( DRYDEP WETDEP1 )
     setenv  INFILE $AIROUT/CCTM/${type}_${currentday}.ncf
     setenv OUTFILE $savedir/${type}_dailysum_${currentday}.ncf
     if ( -e $INFILE ) then
        if ( -e $OUTFILE ) /bin/rm -f $OUTFILE
        set logfile = $AIRLOGDIR/post/log05_sum2daily_${type}.txt
        $prgdir/$prgexe >&! $logfile
        echo "  checking" $logfile
        set tmp_str1 = `tail -4 $logfile`
        set tmp_str2 = `echo "$tmp_str1[1-6]"`
        if ( `echo $tmp_str2` == `echo "--->> Normal Completion of program sum_ntime"` ) then
           echo "  ok; " #removing $INFILE"
          #/bin/rm -f $INFILE
        else
           echo "      error running sum_by_time"
           echo `tail -4 $logfile`
           echo $tmp_str2
           exit(1)
        endif
     else
        echo $INFILE "does not exist; cannot run sum_by_time"
        exit(1)
     endif        
  end #type
