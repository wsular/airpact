#!/bin/csh -f


# example of using this script:
# 
#   > ./run_post.csh 20151202
#
#   takes ~15 minutes to run
#
#  2015-11-23    Serena H. Chung      initial version

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
  set RUN_COMBINE    = Y
  set RUN_08O3       = Y
  set RUN_24PM25     = Y
  set RUN_AIRNow     = Y
  set RUN_AOD        = Y #shc added 2016-05-05

# ----------------------------------------------------------------------

  set BASE = ${PBS_O_WORKDIR}/post

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
     echo Running $BASE/cctm/extract_AIRNow/run_site_extract_airpact_v10.csh for $currentday
     $BASE/cctm/extract_AIRNow/run_site_extract_airpact_v10.csh $currentday
  endif #RUN_AIRNow

  if (  $RUN_AOD == 'Y' ) then
     echo Running $BASE/cctm/aod/run_aod.csh $currentday
     $BASE/cctm/aod/run_aod.csh $currentday
  endif #RUN_AOD

  echo ' finished in run_post.csh' 
