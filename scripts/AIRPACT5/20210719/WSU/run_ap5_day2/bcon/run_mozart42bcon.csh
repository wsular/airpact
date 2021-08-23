#!/bin/csh -f

# example of using this script:
# 
#   > ./run_mozart42bcon.csh 20151113
#
#   takes ~2 minutes to run
#
#  2015-11-13    Serena H. Chung      initial version

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

# link MOZART-4 file if necessary --------------------------------------

  cd $indir
  if ( -e $AIRROOT1/$pYEAR/${previousday}00/BCON/input/$inputfile ) then
     ln -sf $AIRROOT1/$pYEAR/${previousday}00/BCON/input/$inputfile .
  else
     echo "***   MOZART-4 files"
     echo "--->> use monthly profile "
     ln -sf /data/lar/projects/airpact5/input/bcon4cmaq/bcon_from_mozart4_2015${MONTH}.ncf $outdir/$outputfile
     exit ( 0 )
  endif

# convert MOZART-4 output file to CMAQ BCON-formatted file -------------
  cd $wrkdir
  setenv PROGNAME mozart2cmaqBC
  setenv PROMPTFLAG N
  setenv INFILE     $indir/$inputfile
  setenv METCRO3D   $MCIPDIR/METCRO3D
  setenv OUTFILE    $outdir/$intermfile
  echo "  " `date` 
  echo "    starting mozart2cmaqBC" 
  ${prgdir}/mozart2cmaqBC >&! $AIRLOGDIR/bcon/log01_mozart2cmaqBC.txt
  set exitstat = $status
  if ( $exitstat ) then
     echo "*** error in running mozart2cmaqBC"
     echo "*** unable to create day-specific boundary condition file"
     echo "--->> use monthly profile "
     ln -sf /data/lar/projects/airpact5/input/bcon4cmaq/bcon_from_mozart4_2015${MONTH}.ncf $outdir/$outputfile
     exit ( 0 )
  endif
  unlink $indir/inputfile

# convert units --------------------------------------------------------
  cd $wrkdir
  setenv PROGNAME mozart2cmaqBC
  setenv PROMPTFLAG N
  setenv INFILE  $outdir/$intermfile
    # ( Note: INFILE is both input and output file in this step)
  echo "  " `date` 
  echo "    starting CalcAeroMass_mz4"
  ${prgdir}/CalcAeroMass_mz4 >&! $AIRLOGDIR/bcon/log02_CalcAeroMass_mz4.txt
  set exitstat = $status
  if ( $exitstat ) then
     echo "*** error in running CalcAeroMass_mz4"
     echo "*** unable to create boundary condition file"
     exit ( $exitstat )
  endif

# mechanism conversion -------------------------------------------------
  cd $wrkdir
  setenv PROGNAME mozart2cmaqBC
  setenv PROMPTFLAG N
  setenv INFILE  $outdir/$intermfile
  setenv OUTFILE $outdir/$outputfile
  echo "  " `date` 
  echo "    starting MechConv_mz4"
  ${prgdir}/MechConv_mz4 >&! $AIRLOGDIR/bcon/log03_MechConv_mz4.txt 
  set exitstat = $status
  if ( $exitstat ) then
     echo "*** error in running MechConv_mz4"
     echo "*** unable to create boundary condition file"
     exit ( $exitstat )
  endif

# remove intermediate file ---------------------------------------------
  /bin/rm -f $outdir/$intermfile

  echo ' finished in run_mozart42bcon.csh' 
  exit(0)
