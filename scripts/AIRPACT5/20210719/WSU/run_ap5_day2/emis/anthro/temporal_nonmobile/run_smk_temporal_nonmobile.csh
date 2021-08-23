#!/bin/csh -f

#> Exampe of using this script
#   
#   #   run_smk_temporal_nomobile.csh 20101105 64
#
#   #   where 2010110508 denotes forecaststart time of 8 GMT on Nov 5, 2010
#   #               64 denotes 64 hours of forecast
#
#   # called from ../run_emis_anthro.csh
#
#  Precondition(s):
#
#     setenv AIRHOME
#     setenv AIRLOGDIR
#
#
#
#
#  2013-04-23 Serena H. Chung  created to run only nonmobile sources
#

#> Switches

   # run sectors and sources
     setenv RUN_POINT    Y
     setenv RUN_NROAD    Y
     setenv RUN_AREA     Y


#> Initialize exit status
   set exitstat = 0

#> check command line argument
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

#> set up when not running from parent script, e.g., when testing

   if ( ! $?PBS_O_WORKDIR ) then
      setenv PBS_O_WORKDIR ~airpact5/AIRHOME/run_ap5_day2
      setenv PBS_JOBID noidnumber
      setenv RUN_SMKREPORT N    
   endif
   if ( ! $?AIRRUN ) then
      set AIRRUN  = /data//lar/projects/airpact5/AIRRUN/$SRTYR
   endif
   if ( ! $?AIROUT         ) setenv AIROUT    $AIRRUN/${SRTYR}${SRTMN}${SRTDT}00
   if ( ! $?AIRLOGDIR      ) setenv AIRLOGDIR $AIROUT/LOGS
   if ( ! $?MCIPDIR        ) setenv MCIPDIR   $AIROUT/MCIP37

  #> other dates/time environment variables
     set DOYstring = `juldate $SRTMN $SRTDT $SRTYR | cut -d',' -f 2`
     set DOY       = `echo $DOYstring | cut -c5-7`
     setenv CJDATE $SRTYR$DOY
     setenv STIME 080000
     setenv RNLEN ${NHR}0000

  #>
     setenv IOAPI_ISPH     19

#> Setup directory and file location

   setenv SMK_HOME    ~airpact5/models/SMOKEv3.5.1 
   setenv SMK_SUBSYS  $SMK_HOME/subsys                               # SMOKE subsystem dir
   setenv SMKROOT     $SMK_SUBSYS/smoke                              # System root dir
   setenv SMOKE_EXE   Linux2_x86_64pg 
   setenv SMK_BIN     ${SMKROOT}/${SMOKE_EXE}
   setenv ESCEN       2014nw  # added by JKV 061815 as a test for problem of undefined AGT file set -- no difference?

   setenv IOAPI_GRIDNAME_1   'AIRPACT_04km'  # set grid name
   setenv EBASE    ${PBS_O_WORKDIR}/emis/anthro/temporal_nonmobile

   setenv BIN     $SMK_BIN
   setenv ARBASE  $SMK_HOME/intermediate/nonpoint_nonroad-other
   setenv PTBASE  $SMK_HOME/intermediate/point
   setenv MBBASE  $SMK_HOME/intermediate/onroad
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

 # area sources
   echo 'processing area'
   if ( $RUN_AREA == 'Y' ) then
      echo ' '
      echo '**************************************************'
      echo 'AREA source emission'
      echo ' '
      time $EBASE/smk_ar.csh
      set exitstat = $status
      if ( $exitstat ) then
         echo "*** Error in smk_ar.csh ***"
         exit ( $exitstat )
      endif
   endif # RUN_AREA

 # non-road sources
   echo 'processing nonroad'
   if ( $RUN_NROAD == 'Y' ) then
      echo ' '
      echo '**************************************************'
      echo 'Non-road source emission'
      echo ' '
      time $EBASE/smk_nr.csh
      set exitstat = $status
      if ( $exitstat ) then
         echo "*** error in smk_nr.csh ***"
         exit ( $exitstat )
      endif
   endif # RUN_NROAD

 # Point Sources
   echo 'processing point'
   if ( $RUN_POINT == 'Y' ) then
      echo ' '
      echo '**************************************************'
      echo 'Point source emission'
      echo ' '
      time $EBASE/smk_pt_3d.csh #shc changed to "3d" on 2016-04-23
      set exitstat = $status
      if ( $exitstat ) then
         echo "*** error in smk_pt.csh ***"
         exit ( $exitstat )
      endif
   endif # RUN_POINT


## run complete ##
   echo "SMOKE for anthropogenic area and point source emissions processing complete"
   echo `date`
   exit ( $exitstat )
