#!/bin/csh -f


# exampe of using this script
#   
#   #   run_emis_anthro.csh 20130423 24
#

# initialize exit status -----------------------------------------------
  set exitstat = 0

# check argument & set date strings  -----------------------------------

  if ( $1 > 20000101 ) then     
     set YEAR  = `echo $1 | cut -c1-4`
     set MONTH = `echo $1 | cut -c5-6`
     set DAY   = `echo $1 | cut -c7-8`
     set currentday  = $YEAR$MONTH$DAY
     set previousday = `date -d "$currentday -1 days" '+%Y%m%d'`
     set twodaysago  = `date -d "$currentday -2 days" '+%Y%m%d'`
     set NHR   = $2
  else
     echo 'invalid argument. '
     echo "usage $0 yyyymmdd nhrs"
     set exitstat = 1
     exit ( $exitstat )
   endif

# "pre"conditions --need to set during test ----------------------------

   if ( ! $?AIRHOME        ) setenv AIRHOME   ~airpact5/AIRHOME

   if ( ! $?AIRRUN ) then
      set AIRRUN  = /data/lar/projects/airpact5/AIRRUNDAY2/$YEAR
   endif

   if ( ! $?AIROUT         ) setenv AIROUT    $AIRRUN/${currentday}00
   if ( ! $?AIRLOGDIR      ) setenv AIRLOGDIR $AIROUT/LOGS
   if ( ! $?MCIPROOT       ) setenv MCIPROOT  /data/airpact4/AIRRUN
   if ( ! $?MCIPDIR        ) setenv MCIPDIR   $MCIPROOT/${currentday}00/MCIP37
   if ( ! $?PBS_O_WORKDIR  ) setenv PBS_O_WORKDIR  ~airpact5/AIRHOME/run_ap5_day2


# switches -------------------------------------------------------------
  set RUN_SMK_NONTEMPORAL    = N  # this is run only once and thus should be set to N for all daily operation
  set RUN_SMK_TEMPORAL       = Y
  setenv RUN_SMKREPORT N
  setenv IOAPI_LOG_WRITE FALSE

# run SMOKE for anthropogenic emissions --------------------------------
  set logdir = $AIRLOGDIR/emis/anthro
  if ( ! -d $logdir ) mkdir -p $logdir

  # non-temporal (i.e., time-independent) scripts
    if ( $RUN_SMK_NONTEMPORAL == 'Y'  ) then
       echo ' '
       echo '**************************************************'
       echo "run time-independent SMOKE scripts"
       ${PBS_O_WORKDIR}/emis/anthro/non_temporal/run_smk_nontemporal.csh >&! $logdir/log00_emis_anthro_smk_nontemporal.txt
       set exitstat = $status
       if ( $exitstat ) then
           echo "*** error in run_smk_nontemporal.csh"
           exit ( $exitstat )
       endif
       echo 'END script:' `date`; echo ' '
    endif # RUN_SMK_NONTEMPORAL

   # time-dependent SMOKE scripts
     if ( $RUN_SMK_TEMPORAL == 'Y'  ) then
        echo ' '
        echo '**************************************************'
        echo "run SMOKE scripts for anthropogenic emissions - nonmobile"
#        ${PBS_O_WORKDIR}/emis/anthro/temporal_nonmobile/run_smk_temporal_nonmobile.csh $1 $2  >&! $logdir/log01_emis_anthro_smk_temporal_nonmobile.txt
        ${PBS_O_WORKDIR}/emis/anthro/temporal_nonmobile/run_smk_temporal_nonmobile_update.csh $1 $2  >&! $logdir/log01_emis_anthro_smk_temporal_nonmobile.txt
        set exitstat = $status
        if ( $exitstat ) then
           echo "*** error in run_smk_temporal_nonmobile.csh"
           exit ( $exitstat )
        endif

        echo "run SMOKE scripts for anthropogenic emissions - MOVES"
        ${PBS_O_WORKDIR}/emis/anthro/temporal_moves/run_smk_temporal_moves.csh $1 $2 >>&! $logdir/log02_emis_anthro_smk_temporal_moves.txt
        if ( $exitstat ) then
           echo "*** error in run_smk_temporal_moves.csh"
           exit ( $exitstat )
        endif

        echo "run SMOKE scripts for anthropogenic emissions - merge nonmobile and MOVES emissions"
        ${PBS_O_WORKDIR}/emis/anthro/merge_wmoves/run_smk_temporal_merge_wmoves.csh $1 $2 >>&! $logdir/log03_emis_anthro_smk_temporal_merge_wmoves.txt
        if ( $exitstat ) then
          echo "*** error in /run_smk_temporal_merge_wmoves.csh"
          exit ( $exitstat )
        endif
     endif # RUN_SMK_TEMPORAL      


echo 'end run_emis_anthro.csh script:' `date`; echo ' '


