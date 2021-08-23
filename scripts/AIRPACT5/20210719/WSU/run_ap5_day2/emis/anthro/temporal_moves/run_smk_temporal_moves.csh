#!/bin/csh -f

#> Exampe of using this script
#   
#    run_smk_temporal_moves.csh 20130403 24
#
#      where 20130403 denotes forecaststart time of 8 GMT on Nov 5, 2010
#                  24 denotes 64 hours of forecast
#
#   called from ../run_emis_anthro.csh
#
#   set up some environment variables before calling ./smk_mb_move.csh
#
#   created April 2013
#   Serena H. Chung
#
#
# ----------------------------------------------------------------------

#> switches

   setenv RUN_MOVES   Y

#> initialize exit status
   set exitstat = 0

#> check command line argument

   if ( $#argv == 2 ) then
     set SRTYR = `echo $1 | cut -c1-4`
     set SRTMN = `echo $1 | cut -c5-6`
     set SRTDT = `echo $1 | cut -c7-8`
     set NHR   = $2 # not used as of 04/30/2013
     setenv ESDATE $1
   else
     echo 'invalid argument. '
     echo "Usage $0 yyyymmdd nhrs"
     set exitstat = 1
     exit ( $exitstat )
   endif

#> set up when not running from parent script, e.g., when testing

   if ( ! $?PBS_O_WORKDIR )  setenv PBS_O_WORKDIR   ~airpact5/AIRHOME/run_ap5_day2
   if ( ! $?AIRRUN ) then
      set AIRRUN  = /data//lar/projects/airpact5/AIRRUN/$SRTYR
   endif
   if ( ! $?AIROUT         ) setenv AIROUT    $AIRRUN/${SRTYR}${SRTMN}${SRTDT}00
   if ( ! $?AIRLOGDIR      ) setenv AIRLOGDIR $AIROUT/LOGS
   if ( ! $?MCIPDIR        ) setenv MCIPDIR   $AIROUT/MCIP


#> other dates/time environment variables
   set DOYstring = `juldate $SRTMN $SRTDT $SRTYR | cut -d',' -f 2`
   set DOY       = `echo $DOYstring | cut -c5-7`
   setenv CJDATE $SRTYR$DOY
   setenv STTIME 080000
   setenv RNLEN ${NHR}0000
   setenv STDATE $CJDATE          # starting date in Julian
   setenv EPI_NDAY 1
   @ eday = $STDATE + $EPI_NDAY   # this won't work for end of the year
   setenv ENDATE $eday
   setenv ENDTIME 80000


#> setup directory and file location

   setenv SMK_HOME    ~airpact5/models/SMOKEv3.5.1
   setenv SMK_SUBSYS  $SMK_HOME/subsys                               # SMOKE subsystem dir
   setenv SMKROOT     $SMK_SUBSYS/smoke                              # System root dir
   setenv SMOKE_EXE   Linux2_x86_64pg                                # vikram 7/6/15
   setenv SMK_BIN     ${SMKROOT}/${SMOKE_EXE}
   setenv BIN         $SMK_BIN
   setenv SCRIPTS     $SMKROOT/scripts

   setenv IOAPI_GRIDNAME_1   'AIRPACT_04km'  # set grid name
   setenv IOAPI_ISPH     19                    # specifies spheroid type associated with grid
   setenv EBASE          ${PBS_O_WORKDIR}/emis/anthro/temporal_moves

   setenv MBBASE      $SMK_HOME/intermediate/moves
   setenv SMKDAT      $SMK_HOME/data
   setenv GE_DAT      $SMKDAT/ge_dat
   setenv COSTCY      $GE_DAT/costcy_v8.txt    # country/state/county info             # vikram 7/6/2015
   setenv HOLIDAYS    $GE_DAT/holidays_2005_2019.txt # holidays for day change
   setenv MCODES      $GE_DAT/mcodes.txt                         # mobile codes to build internal SCC 
   setenv MCXREF      $GE_DAT/mcref_moves_nw.txt                 # ref county cross-reference
   setenv MFMREF      $GE_DAT/fuelmonth_nw.txt                   # ref county fuel-month
   setenv MGREF       $GE_DAT/amgref_4km_2014_moves.txt  # Mobile gridding x-ref  # vikram 7/14/2015
   setenv MTPRO       $GE_DAT/mtpro_AP5_final.txt                   # Temporal profiles
   setenv MTREF       $GE_DAT/mtref_AP5_final.txt             # Mobile temporal x-ref
   setenv SRGDESC     $GE_DAT/srgdesc_4km_airpact5_moves.txt      # surrogate descriptions  
   setenv SRGPRO_PATH $GE_DAT/SRGPRO/                    # surrogate files path      # vikram 7/6/2015
   setenv SCCDESC     $GE_DAT/scc_desc_030804.txt  # SCC descriptions
   setenv ORISDESC    $GE_DAT/oris_info.txt        # ORIS ID descriptions
   setenv MACTDESC    $GE_DAT/mact_desc.txt        # MACT descriptions
   setenv NAICSDESC   $GE_DAT/naics_desc.txt       # NAICS descriptions

   setenv GRIDDESC $GE_DAT/GRIDDESC                  # Grid descriptions.
   setenv GRID     AIRPACT_04km     # Gridding root for naming
   setenv SMK_DEFAULT_TZONE 8

   setenv SPC          cmaq_cb05_soa     # Speciation type
  
   source $EBASE/set_env.csh $1
   source $EBASE/set_dir.csh
   setenv LOGS $LOGDIR
   set exitstat = $status
   if ( $exitstat ) then
      echo "*** error in set_dir.csh ***"
      exit ( $exitsmktat )
   endif
   setenv SMKOUT $EIROOT
 
   setenv MET_CRO_2D  $METDIR/METCRO2D
   setenv MET_CRO_3D  $METDIR/METCRO3D
   setenv M_OUT       $EIROOT/moves
   setenv METDAT      $M_OUT/met             # smoke met files
   if ( ! -d $METDAT) mkdir -p $METDAT
   setenv METLIST     $METDAT/metlist4moves.lst
   setenv INVDIR      $SMK_HOME/emissions/moves
   setenv INVTABLE    $GE_DAT/invtable_hapcap_cb05soa.txt    # vikram 7/6/15
   setenv INTERMED    $SMK_HOME/intermediate
   setenv NONTEMPORAL $SMK_HOME

 # mobile Sources
   if ( $RUN_MOVES == 'Y' ) then
      echo ' '
      echo '**************************************************'
      echo 'mobile source emission with MOVES'
      echo ' '
      time $EBASE/smk_mb_moves.csh $1 $2
      set exitstat = $status
      if ( $exitstat ) then
         echo "*** error in smk_mb_moves.csh ***"
         exit ( $exitstat )
      endif
   endif # RUN_MOVES

## run complete ##
   echo "SMOKE for mobile emission using MOVES"
   echo `date`
   exit ( $exitstat )
