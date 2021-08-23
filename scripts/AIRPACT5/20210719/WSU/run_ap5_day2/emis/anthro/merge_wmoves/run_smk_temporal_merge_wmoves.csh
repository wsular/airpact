#!/bin/csh -f

#> exampe of using this script
#   
#   #   ./run_smk_temporal_merge_wmoves.csh 20120429 24
#
#   #   where 20120429 denotes forecaststart time of 8 GMT on April 29, 2012
#   #               24 denotes 24 hours of forecast
#
#   # called from ../run_emis_anthro.csh
#
#  Precondition(s):
#
#     setenv AIRHOME
#     setenv AIRLOGDIR
#
#
#  2013-10-08 Serena H. Chung  created to merge non-mobile anthropogenic sources with
#                              MOVES

   if ( ! $?PBS_O_WORKDIR ) then
      setenv PBS_O_WORKDIR ~airpact5/AIRHOME/run_ap5_day2
   endif
#> switches

   # run sectors and sources
     setenv RUN_AREA     N
     setenv RUN_MOVES    N
     setenv RUN_NROAD    N
     setenv RUN_POINT    N

   # run Merge and Clean
     setenv RUN_MERGE    Y
     setenv RUN_CLEANUP  N #not implemented, so always set to N for now

#> initialize exit status
   set exitstat = 0

#> Check command line argument
   if ( $#argv == 2 ) then
     set SRTYR = `echo $1 | cut -c1-4`
     set SRTMN = `echo $1 | cut -c5-6`
     set SRTDT = `echo $1 | cut -c7-8`
     set NHR   = $2
   else
     echo 'invalid argument. '
     echo "usage $0 yyyymmddhh nhrs"
     set exitstat = 1
     exit ( $exitstat )
   endif

   if ( ! $?AIRRUN ) then
      set AIRRUN  = /data//lar/projects/airpact5/AIRRUN/$SRTYR
   endif
   if ( ! $?AIROUT         ) setenv AIROUT $AIRRUN/${SRTYR}${SRTMN}${SRTDT}00
   if ( ! $?AIRLOGDIR      ) setenv AIRLOGDIR $AIROUT/LOGS
   if ( ! $?MCIPDIR        ) setenv MCIPDIR   $AIROUT/MCIP

  #> Other dates/time environment variables
     set DOYstring = `juldate $SRTMN $SRTDT $SRTYR | cut -d',' -f 2`
     set DOY       = `echo $DOYstring | cut -c5-7`
     setenv CJDATE $SRTYR$DOY
     setenv STIME 080000
     setenv RNLEN ${NHR}0000

#> setup directory and file location

   setenv SMK_SUBSYS  $SMK_HOME/subsys                               # SMOKE subsystem dir
   setenv SMKROOT     $SMK_SUBSYS/smoke                              # System root dir
   setenv SMOKE_EXE   Linux2_x86_64pg
   setenv SMK_BIN     ${SMKROOT}/${SMOKE_EXE}

   setenv IOAPI_GRIDNAME_1   'AIRPACT_04km'  # set grid name
   setenv EBASE    ${PBS_O_WORKDIR}/emis/anthro/merge_wmoves

   setenv BIN     $SMK_BIN
   setenv ARBASE  $SMK_HOME/intermediate/nonpoint_nonroad-other  
   setenv PTBASE  $SMK_HOME/intermediate/point
   setenv MBBASE  $SMK_HOME/intermediate/moves
   setenv NRBASE  $SMK_HOME/intermediate/nonroad

   setenv SMKDAT  $SMK_HOME/data
   setenv GE_DAT  $SMKDAT/ge_dat

   source $EBASE/set_env.csh $1
   source $EBASE/set_dir.csh
   set exitstat = $status
   if ( $exitstat ) then
      echo "*** Error in set_dir.csh ***"
      exit ( $exitstat )
   endif

### Begin process

 # merge
   echo 'merging'
      echo ' '
      echo '**************************************************'
      echo 'merging all anthropogenic emissions (with MOVES for mobile emissions)'
      echo ' '
      time $EBASE/mrg_emis_anthro_wmoves.csh >&! $AIRLOGDIR/emis/anthro/log03b_emis_anthro_merge_wmoves_$G_STDATE.txt
      set exitstat = $status
      if ( $exitstat ) then
         echo "*** error in mrg_emis_anthro.csh ***"
         exit ( $exitstat )
      endif
   endif # RUN_MERGE

 # clean up
   if ( $RUN_CLEANUP == 'Y' ) then
      echo ' '
      echo '**************************************************'
      echo 'Delete intermediate emission files in directory: '
      echo " $INTDIR "
      echo ' '
      time $EBASE/cleanup_emis_anthro.csh >&! $AIRLOGDIR/emis/anthro/log03c_emis_anthro_cleanup_$G_STDATE.txt
      set exitstat = $status
      if ( $exitstat ) then
         echo "*** error in cleanup.csh ***"
         exit ( $exitstat )
      endif
   endif # RUN_CLEANUP


## run complete ##
   echo "SMOKE for anthropogenic emissions processing complete (with MOVES)" 
   echo `date`
   exit ( $exitstat )
