#!/bin/csh -f


#> Exampe of using this script
#   
#   #   run_emis_anthro_nontemporal.csh 20150507 24
#
#
#  Precondition(s):
#
#     setenv AIRHOME
#     setenv AIRLOGDIR
#     setenv RUN_EMIS_ANTHRO
#
#


    setenv SMK_HOME        ~airpact5/models/SMOKEv3.5.1
    setenv AIRLOGDIR       $SMK_HOME/intermediate #All logs for non-temporal go into the static intermediate folder

#> Switches
   set RUN_SMK_NONTEMPORAL       = Y #All non-MOVES sources
   set RUN_SMK_NONTEMPORAL_MOVES = N #MOVES sources

#> Initialize exit status
   set exitstat = 0

#> Check command line argument
   if ( $#argv == 2 ) then
     set SRTYR = `echo $1 | cut -c1-4`
     set SRTMN = `echo $1 | cut -c5-6`
     set SRTDT = `echo $1 | cut -c7-8`
     set NHR   = $2
   else
     echo 'Invalid argument. '
     echo "Usage $0 yyyymmdd nhrs"
     set exitstat = 1
     exit ( $exitstat )
   endif

#> some prerequisites

   if ( ! $?PBS_O_WORKDIR) setenv PBS_O_WORKDIR   ~airpact5/AIRHOME/run_ap5_day2

   if ( ! $?AIRRUN ) then
      set AIRRUN  = /data//lar/projects/airpact5/AIRRUN/$SRTYR
   endif
   setenv AIROUT       $AIRRUN/${1}00

   if ( ! $?MCIPDIR )  setenv MCIPDIR   $AIROUT/MCIP

#> run SMOKE for anthropogenic emissions (non-MOVES)
   # non-temporal (i.e., time-independent) scripts
     if ( $RUN_SMK_NONTEMPORAL == 'Y'  ) then
       echo ' '
       echo '**************************************************'
       echo "run time-independent SMOKE scripts"
       ${PBS_O_WORKDIR}/emis/anthro/non_temporal/run_smk_nontemporal.csh >&! $AIRLOGDIR/emis_anthro_smk_nontemporal.log
       set exitstat = $status
       if ( $exitstat ) then
           echo "*** error in run_smk_nontemporal.csh"
           exit ( $exitstat )
       endif
       echo 'END script:' `date`; echo ' '
     endif # RUN_SMK_NONTEMPORAL

#> run SMOKE for anthropogenic emissions (MOVES)
   # non-temporal (i.e., time-independent) scripts
     if ( $RUN_SMK_NONTEMPORAL_MOVES == 'Y'  ) then
       echo ' '
       echo '**************************************************'
       echo "run time-independent SMOKE scripts"
       ${PBS_O_WORKDIR}/emis/anthro/non_temporal_moves/run_smk_nontemporal_moves.csh >&! $AIRLOGDIR/emis_anthro_smk_nontemporal_moves.log
       set exitstat = $status
       if ( $exitstat ) then
           echo "*** error in run_smk_nontemporal_moves.csh"
           exit ( $exitstat )
       endif
       echo 'END script:' `date`; echo ' '
     endif # RUN_SMK_NONTEMPORAL_MOVES

echo 'end run_emis_anthro_nontemporal.csh script:' `date`; echo ' '
