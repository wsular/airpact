#!/bin/csh -f

# example of using this script:
# 
#   > ./run_wrapper4megan2.10.csh 20151122 20160217
#
#   takes ~40 minutes to run
#
#  2015-11-18    Serena H. Chung      initial version

# initialize exit status -----------------------------------------------
  set exitstat = 0

# check argument & set date strings  -----------------------------------

  if ( $2 > 20000101 ) then     
     set epiday = $1
     set YEAR  = `echo $2 | cut -c1-4`
     set MONTH = `echo $2 | cut -c5-6`
     set DAY   = `echo $2 | cut -c7-8`
     set currentday  = $YEAR$MONTH$DAY
     set previousday = `date -d "$currentday -1 days" '+%Y%m%d'`
     set twodaysago  = `date -d "$currentday -2 days" '+%Y%m%d'`
   endif

# "pre"conditions --need to set during test ----------------------------

   if ( ! $?AIRHOME        ) setenv AIRHOME   ~airpact5/AIRHOME
   if ( ! $?AIRRUN ) then
      set AIRROOT = /data/lar/projects/airpact5/AIRRUNDAY2
      set AIRRUN  = $AIRROOT/$YEAR
   endif
   if ( ! $?AIROUT         ) setenv AIROUT    $AIRRUN/${currentday}00
   if ( ! $?AIRLOGDIR      ) setenv AIRLOGDIR $AIROUT/LOGS
   if ( ! $?MCIPROOT       ) setenv MCIPROOT  /data/lar/projects/airpact5/AIRRUNDAY2/$YEAR
   if ( ! $?MCIPDIR        ) setenv MCIPDIR   $AIROUT/MCIP37
   if ( ! $?PBS_O_WORKDIR  ) setenv PBS_O_WORKDIR  ~airpact5/AIRHOME/run_ap5_day2

# ----------------------------------------------------------------------
   set logdir = $AIRLOGDIR/emis/megan2.10
   if ( ! -d $logdir ) mkdir -p $logdir
   $PBS_O_WORKDIR/emis/megan2.10/run_met2mgn.csh  $epiday     $currentday >&! $logdir/log01_met2mgn.txt
   $PBS_O_WORKDIR/emis/megan2.10/run_emproc.csh   $currentday             >&! $logdir/log02_emproc.txt
   $PBS_O_WORKDIR/emis/megan2.10/run_mgn2mech.csh $currentday             >&! $logdir/log03_mgn2mech.txt
