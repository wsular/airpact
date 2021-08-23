#!/bin/csh -f

# example of using this script:
# 
#   > ./run_icon_ideal.csh 20151123
#
#   takes ~2 minutes to run
#
#  2015-11-23    Serena H. Chung      initial version

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
  else
     echo 'invalid argument. '
     echo "usage $0 <yyyymmdd>"
     set exitstat = 1
     exit ( $exitstat )
   endif

# "pre"conditions --need to set during test ----------------------------

   if ( ! $?PBS_O_WORKDIR  ) set PBS_O_WORKDIR = ~airpact5/AIRHOME/run_ap5_day1
   if ( ! $?AIRHOME        ) set AIRHOME = ~airpact5/AIRHOME
   if ( ! $?AIRRUN ) then
      set AIRRUN  = /data/lar/projects/airpact5/AIRRUN/$YEAR
   endif
   if ( ! $?AIROUT         ) set AIROUT = $AIRRUN/${currentday}00
   if ( ! $?AIRLOGDIR      ) set AIRLOGDIR = $AIROUT/LOGS
   if ( ! $?MCIPDIR        ) then
     if ( -e $AIROUT/MCIP37/METCRO2D ) then
        set MCIPDIR   = $AIROUT/MCIP37
     else
        set MCIPDIR   = /data/airpact4/AIRRUN/${currentday}00/MCIP37
     endif
   endif

   if ( ! -e $MCIPDIR/METCRO3D ) then
      echo "METCRO3D file does not exit; existing $0"
      exit(1)
   endif

# set input and output directories and files --------------------------

  # horizontal grid defn; check GRIDDESC file for GRID_NAME options
    setenv GRIDDESC $MCIPDIR/GRIDDESC
    setenv GRID_NAME AIRPACT_04km
    setenv IOAPI_ISPH 19
  # vertical layer defn
    setenv LAYER_FILE $MCIPDIR/METCRO3D
  # output directory and file name
    set OUTDIR = $AIROUT/ICON
    mkdir -p ${OUTDIR}
    setenv INIT_CONC_1    $OUTDIR/ICON_AIRPACT_04km_${currentday}.ncf
  # program path
    set APPL     = cb05tucl_ae6_aq_ideal
    set CFG      = cb05tucl_ae6_aq
    set MECH     = cb05tucl_ae6_aq
    set EXEC     = ICON_${CFG}_Linux2_x86_64pgi
    setenv NPCOL_NPROW "1 1"
    set PROGDIR  = $AIRHOME/build/CMAQ5.0.2/icon/
    set BLD      = ${PROGDIR}/BLD_$APPL
    cd $BLD; date; set timestamp; cat $BLD/cfg.${CFG}; echo " "; set echo
  # raw data for ideal initialization
    setenv IC_PROFILE      $BLD/ic_profile_CB05.dat
  # misc
    setenv IOAPI_OFFSET_64 NO
    setenv EXECUTION_ID $EXEC
    setenv IOAPI_LOG_WRITE F
  # species defn
    setenv gc_matrix_nml ${BLD}/GC_$MECH.nml
    setenv ae_matrix_nml ${BLD}/AE_$MECH.nml
    setenv nr_matrix_nml ${BLD}/NR_$MECH.nml
    setenv tr_matrix_nml ${BLD}/Species_Table_TR_0.nml
 
# executable call -----------------------------------------------------
  /usr/bin/time $BLD/$EXEC >&! ${AIRLOGDIR}/log_icon_ideal.txt

# exiting -------------------------------------------------------------
  if ( $exitstat ) then
     echo "*** error in $BLD/$EXEC"
     exit ( $exitstat )
  endif
  echo ' finished in run_icon_ideal.csh'
  exit() 

