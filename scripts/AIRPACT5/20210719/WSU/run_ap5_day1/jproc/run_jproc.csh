#!/bin/csh -f
#
# example of using this script:
# 
#   > ./run_jproc.csh 20151117
#
#   takes ~2 minutes to run
#
#  2015-11-17    Serena H. Chung      initial version



# check argument & set date strings  -----------------------------------

  if ( $1 > 20000101 ) then     
     set YEAR  = `echo $1 | cut -c1-4`
     set MONTH = `echo $1 | cut -c5-6`
     set DAY   = `echo $1 | cut -c7-8`
     set currentday  = $1
     set nextday     = `date -d "$currentday +1 days" '+%Y%m%d'`
     set previousday = `date -d "$currentday -1 days" '+%Y%m%d'`
     set twodaysago  = `date -d "$currentday -2 days" '+%Y%m%d'`
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
        echo Error on finding $AIROUT/MCIP37
        set MCIPDIR   = /data/lar/projects/airpact5/AIRRUN/${YEAR}/${currentday}00/MCIP37
     endif
   endif

# determine day of the year -------------------------------------------

  set DOYstring = `juldate $MONTH $DAY $YEAR | cut -d',' -f 2`
  set DOY       = `echo $DOYstring | cut -c5-7`
  set YEARDOY   = $YEAR$DOY

  set nYEAR  = `echo $nextday | cut -c1-4`
  set nMONTH = `echo $nextday | cut -c5-6`
  set nDAY   = `echo $nextday | cut -c7-8`
  set nDOYstring = `juldate $nMONTH $nDAY $nYEAR | cut -d',' -f 2`
  set nDOY       = `echo $nDOYstring | cut -c5-7`
  set nYEARDOY   = $nYEAR$nDOY

   # the parameters for this run - produces one file per day -------------
     set STDATE   = $YEARDOY   # the beginning day for this run
     set ENDATE   = $nYEARDOY  # the ending day

# initialize exit status ----------------------------------------------
  set exitstat = 0

# set input and output directories and files --------------------------

  # input data directories and file names
    setenv M3DATA1 /data/lar/larinput/download/CMAQ/CMAQ5.0/CMAQv5.0/data
    if ( ! -e $M3DATA1 ) then
       echo "   $M3DATA1 path does not exist"
       exit 1
    endif
    set CSQYpath   = $M3DATA1/raw/phot  # CSQY input data
    set PROFpath   = $M3DATA1/raw/phot  # PROF input data
    set ETpath     = $M3DATA1/raw/phot  # ET input data
    set TOMSpath   = $M3DATA1/raw/phot  # TOMS input data

    set ETfile    = ETirradiance.dat
    set PROFfile  = PROFILES.dat
    set O2ABSfile = O2_JPL06-2
    set O3ABSfile = O3O1D_JPL06-2
    set TOMSfile  = not_available

  # setenv for input files
    setenv ET        $ETpath/$ETfile
    setenv PROFILES  $PROFpath/$PROFfile
    setenv TOMS      $TOMSpath/$TOMSfile
    setenv O2ABS     $CSQYpath/$O2ABSfile
    setenv O3ABS     $CSQYpath/$O3ABSfile
    setenv CSQY      $CSQYpath

  # output directory and file name
    set OUTDIR = $AIROUT/JPROC
    mkdir -p ${OUTDIR}

  # program path
    set APPL     = cb05tucl_ae6_aq
    set CFG      = cb05tucl_ae6_aq
    set EXEC     = JPROC_${CFG}_Linux2_x86_64pgi 
    set PROGDIR  = $AIRHOME/build/CMAQ5.0.2/jproc
    set BLD      = ${PROGDIR}/BLD_$APPL
    cd $PROGDIR; date; set timestamp; #cat $BLD/cfg.${CFG}; echo " "; set echo

# check input files ---------------------------------------------------

  # check ET input file
    if (! ( -e $ET ) ) then
       echo " $ET not found "
       exit
    endif
  # check profile input file
    if (! ( -e $PROFILES ) ) then
       echo " $PROFILES not found "
       exit
    endif
  # check TOMS input file
    setenv JPROC_TOMSEXIST  N  # Assume TOMS data file does not exist for this run
    if ( -e $TOMS ) then
       setenv JPROC_TOMSEXIST  Y
    endif
  # check O2 absorption input file
    if (! ( -e $O2ABS ) ) then
       echo " $O2ABS not found "
       exit
    endif
  # check O3 absorption input file
    if (! ( -e $O3ABS ) ) then
       echo " $O3ABS not found "
       exit
    endif

# executable call -----------------------------------------------------
  @ Date = $STDATE
  while ( $Date <= $ENDATE )         # loop thru all the days to run
     setenv JPROC_STDATE $Date
     echo "   running for $Date ..."
     set JVfile = JTABLE_${Date}     # daily output file name
     setenv JVALUES $OUTDIR/$JVfile
     if ( -e $JVALUES ) rm $JVALUES  # remove existing output file
     # executable call:
       mkdir -p ${AIRLOGDIR}/jproc
       $BLD/$EXEC >&! ${AIRLOGDIR}/jproc/log_jproc_${Date}.txt
     # check status
       if ( $exitstat ) then
          echo "*** error in $BLD/$EXEC"
          tail -4 $AIRLOGDIR/jproc/log_jproc_${Date}.txt       
          exit ( $exitstat )
       endif
     @ Date++
   end

# exiting -------------------------------------------------------------
  echo ' finished in run_jproc.csh'
  exit() 

