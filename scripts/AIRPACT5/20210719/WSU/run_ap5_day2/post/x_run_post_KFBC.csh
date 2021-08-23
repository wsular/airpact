#!/bin/csh -fX


# example of using this script:
# 
#   ./run_post.csh <YYYYMMDD of DAY2>
#
#   takes ~15 minutes to run
#

# initialize exit status -----------------------------------------------
  set exitstat = 0

# check argument & set date strings  -----------------------------------

  if ( $1 > 20000101 ) then     
     set currentday  = $1
     set YEAR  = `echo $currentday | cut -c1-4`
     set MONTH = `echo $currentday | cut -c5-6`
     set DAY   = `echo $currentday | cut -c7-8`
     set previousday = `date -d "$currentday -1 days" '+%Y%m%d'`
     set twodaysago  = `date -d "$currentday -2 days" '+%Y%m%d'`
   endif

# "pre"conditions --need to set during test ----------------------------

   if ( ! $?AIRHOME        ) set AIRHOME = ~airpact5/AIRHOME
   if ( ! $?AIRRUN ) then
      set AIRRUN  = /data/lar/projects/airpact5/AIRRUNDAY2/$YEAR
   endif
   if ( ! $?AIROUT         ) set AIROUT = $AIRRUN/${currentday}00
   if ( ! $?AIRLOGDIR      ) set AIRLOGDIR = $AIROUT/LOGS
   if ( ! $?MCIPDIR        ) set MCIPDIR   = $AIROUT/MCIP37
   if ( ! $?PBS_O_WORKDIR  ) set PBS_O_WORKDIR = ~airpact5/AIRHOME/run_ap5_day2


# switches -------------------------------------------------------------
  set RUN_COMBINE    = N
  set RUN_08O3       = N
  set RUN_24PM25     = N
  set RUN_AIRNow     = N
  set RUN_AOD        = N #shc added 2016-05-05
  set RUN_KFBC       = Y #JKV added 2020-08-10

# ----------------------------------------------------------------------

#    set BASE = ${PBS_O_WORKDIR}/post
  set BASE = ~/AIRHOME/run_ap5_day2/post 
  echo BASE is $BASE
  if ( ! -d $AIRLOGDIR/post ) mkdir -p $AIRLOGDIR/post

  if (  $RUN_COMBINE == 'Y' ) then
     echo Running $BASE/cctm/combine/run_combine_v2.csh $currentday
     $BASE/cctm/combine/run_combine_v2.csh $currentday
  endif #RUN_COMBINE

  if (  $RUN_08O3 == 'Y' ) then
     echo Running $BASE/cctm/ave08hr/run_08hr_O3.csh $currentday
     $BASE/cctm/ave08hr/run_08hr_O3.csh $currentday
  endif #RUN_08O3

  if (  $RUN_24PM25 == 'Y' ) then
     echo Running $BASE/cctm/ave24hr/run_24hr_PM25.csh $currentday
     $BASE/cctm/ave24hr/run_24hr_PM25.csh $currentday
  endif #RUN_24PM25

  if (  $RUN_AIRNow == 'Y' ) then
     echo Running $BASE/cctm/extract_AIRNow/run_site_extract_airpact_v9.csh for $currentday
     $BASE/cctm/extract_AIRNow/run_site_extract_airpact_v9.csh $currentday
  endif #RUN_AIRNow

  if (  $RUN_AOD == 'Y' ) then
     echo Running $BASE/cctm/aod/run_aod.csh $currentday
     $BASE/cctm/aod/run_aod.csh $currentday
  endif #RUN_AOD

  if (  $RUN_KFBC == 'Y' ) then
     echo BASE in KFBC call is $BASE
     echo Running $BASE/cctm/KFBC/run_KFBC_PM2.5.csh  $currentday
     $BASE/cctm/KFBC/run_KFBC_PM2.5.csh  $currentday >&! $AIRLOGDIR/post/run_KFBC_PM2.5.log
  endif #RUN_KFBC 

  echo ' finished in run_post.csh' 
