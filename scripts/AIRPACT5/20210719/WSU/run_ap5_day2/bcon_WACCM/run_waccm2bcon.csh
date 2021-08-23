#!/bin/csh -f

# example of using this script:
# 
#   > ./run_waccm2bcon.csh 20151113
#
#   takes ~2 minutes to run
#
#  2015-11-13    Serena H. Chung      initial version
#  2018-11-01    Joseph K. Vaughan   new version creates link to day1 BCON from WACCM file

# initialize exit status -----------------------------------------------
  set exitstat = 0

# check argument & set date strings  -----------------------------------

  if ( $1 > 20000101 ) then     
     set YEAR  = `echo $1 | cut -c1-4`
     set MONTH = `echo $1 | cut -c5-6`
     set DAY   = `echo $1 | cut -c7-8`
     set currentday  = $YEAR$MONTH$DAY
     set nextday = `date -d "$currentday +1 days" '+%Y%m%d'`
     set previousday = `date -d "$currentday -1 days" '+%Y%m%d'`
     set twodaysago  = `date -d "$currentday -2 days" '+%Y%m%d'`
     set previousdayyear = `echo $previousday | cut -c1-4`
     set pYEAR  = `echo $previousday | cut -c1-4`
   endif

# "pre"conditions --need to set during test ----------------------------

   if ( ! $?PBS_O_WORKDIR  ) set PBS_O_WORKDIR = ~airpact5/AIRHOME/run_ap5_day2
   if ( ! $?AIRHOME        ) set AIRHOME = ~airpact5/AIRHOME
   if ( ! $?AIRRUN ) then
      set AIRROOT1 = /data/lar/projects/airpact5/AIRRUN
      set AIRROOT = /data/lar/projects/airpact5/AIRRUNDAY2
      set AIRRUN  = $AIRROOT/$YEAR
   endif
   if ( ! $?AIROUT         ) set AIROUT = $AIRRUN/${currentday}00
   if ( ! $?AIRLOGDIR      ) set AIRLOGDIR = $AIROUT/LOGS
   if ( ! $?MCIPDIR        ) then
      set MCIPDIR   = /data/lar/projects/airpact5/AIRRUNDAY2/$YEAR/${currentday}00/MCIP37
   else 
      echo MCIPDIR is $MCIPDIR
   endif

   if ( ! -e $MCIPDIR/METCRO3D ) then
      echo ${MCIPDIR}"/METCRO3D  file does not exit; existing run_mozart42bcon.csh"
      exit(1)
   endif

# directories and files ------------------------------------------------
  set prgdir  =  ~airpact5/AIRHOME/build/MOZART4_bcon/cb05
  set wrkdir = ${PBS_O_WORKDIR}/bcon
  mkdir -p ${AIRLOGDIR}/bcon
  set mz4fileroot = mz4geos_nwus_1h
  set mz4file     = ${mz4fileroot}_${currentday}_8z_f65.nc
  set indir       = $AIROUT/BCON/input; mkdir -p $indir
  set inputfile   = ${mz4fileroot}_${previousday}.nc
  set outdir      = $AIROUT/BCON/output; mkdir -p $outdir
  set intermfile  = bcon_mz4_${currentday}.ncf
  set outputfile  = bcon_cb05_${currentday}.ncf
  set poutputfile  = bcon_cb05_${previousday}.ncf

# link WACCM-derived BCON file from previous day, if available ---------

  cd $outdir
  if ( -e $outputfile ) rm -f $outputfile
  if ( -e $AIRROOT1/$pYEAR/${previousday}00/BCON/output/${poutputfile} ) then
     ln -sf $AIRROOT1/$pYEAR/${previousday}00/BCON/output/${poutputfile} $outputfile
     echo "--->> linked to AIRRUN day1 WACCM- bcon file "
  else
     # else link MOZART-4 file if necessary --------------------------------------
     echo "***   MOZART-4 files"
     echo "--->> use monthly profile "
     ln -sf /data/lar/projects/airpact5/input/bcon4cmaq/bcon_from_mozart4_2015${MONTH}.ncf $outdir/$outputfile
     exit ( 0 )
  endif

  echo "   finished in $0"
  exit(0)
