#!/bin/csh -fV

# example of using this script:
# 
#   > ./run_mozart42bcon.csh 20151113
#
#   takes ~2 minutes to run
#
#  2015-11-13    Serena H. Chung      initial version
#  2017-08-05    Joe Vaughan   Added --no-check-certificate on wget for mozart4 data

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
     set previousdayyear = `echo $previousday | cut -c1-4`
   endif

# "pre"conditions --need to set during test ----------------------------

   if ( ! $?PBS_O_WORKDIR  ) set PBS_O_WORKDIR = ~airpact5/AIRHOME/run_ap5_day1
   if ( ! $?AIRHOME        ) set AIRHOME = ~airpact5/AIRHOME
   if ( ! $?AIRRUN ) then
      set AIRROOT = /data/lar/projects/airpact5/AIRRUN
      set AIRRUN  = $AIRROOT/$YEAR
   endif
   if ( ! $?AIROUT         ) set AIROUT = $AIRRUN/${currentday}00
   if ( ! $?AIRLOGDIR      ) set AIRLOGDIR = $AIROUT/LOGS
   if ( ! $?MCIPDIR        ) then
     if ( -e $AIROUT/MCIP/METCRO2D ) then
        set MCIPDIR   = $AIROUT/MCIP37
     else
        set MCIPDIR   = /data/lar/projects/airpact5/AIRRUN/$YEAR/${currentday}00/MCIP37
     endif
   endif
   if ( ! $?BCONDIR        ) set BCONDIR   = $AIROUT/BCON


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
  set indir       = $BCONDIR/input; mkdir -p $indir
  set inputfile   = ${mz4fileroot}_${currentday}.nc
  set outdir      = $BCONDIR/output; mkdir -p $outdir
  set intermfile  = bcon_mz4_${currentday}.ncf
  set outputfile  = bcon_cb05_${currentday}.ncf

# download MOZART-4 file if necessary ----------------------------------

  cd $indir
  # the required should have been created by a crontab job; if not, do it here
  if ( ! -e $inputfile ) then
     if ( -e ${mz4file}.gz ) then
        gunzip ${mz4file}.gz
     else if ( ! -e $mz4file ) then
        echo "download MOZART-4 file"
        echo "wget -N -nv --no-check-certificate http://www.acom.ucar.edu/acresp/AMADEUS/mz4_output/chemfcst/${mz4file}"
        wget -N -nv --no-check-certificate http://www.acom.ucar.edu/acresp/AMADEUS/mz4_output/chemfcst/${mz4file}
     endif
     if ( -e $mz4file ) then
        echo 'remove variable CO_ORIG_VMR from MOZART-4 file'
        ncks -x -v CO_ORIG_VMR_inst $mz4file $inputfile
        gzip $mz4file
     else # missing today's file, use yesterday's file
        set inputfileprevious = $AIRROOT/${previousdayyear}/${previousday}00/BCON/input/${mz4fileroot}_${previousday}_8z_f65.nc 
        echo "use MOZART-4 file from previous day for BCON" $inputfileprevious
        if ( -e $inputfileprevious ) then
           cp $inputfileprevious $inputfile
        else if ( -e ${inputfileprevious}.gz ) then
           gunzip ${inputfileprevious}.gz
           cp $inputfileprevious $inputfile
        else
	   echo "***   error no previous day's file for MOZART-4 "
           echo "--->> use monthly profile "
	   ln -sf /data/lar/projects/airpact5/input/bcon4cmaq/bcon_from_mozart4_2015${MONTH}.ncf $outdir/$outputfile
  	   echo ' finished in run_mozart42bcon.csh with link to /data/lar/projects/airpact5/input/bcon4cmaq/bcon_from_mozart4_2015${MONTH}.ncf' 
	   exit (0)	   
        endif
     endif
  else
      echo "necessary MOZART-4 file already exists"
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
  ncdump -h $outdir/$intermfile >&! $wrkdir/log01_imfile.txt
  cp $outdir/$intermfile $wrkdir/${intermfile}_01
  set exitstat = $status
  if ( $exitstat ) then
     echo "*** error in running mozart2cmaqBC"
     echo "*** unable to create boundary condition file"
     exit ( $exitstat )
  endif

# convert units --------------------------------------------------------
  cd $wrkdir
  setenv PROGNAME mozart2cmaqBC
  setenv PROMPTFLAG N
  setenv INFILE  $outdir/$intermfile
    # ( Note: INFILE is both input and output file in this step)
  echo "  " `date` 
  cp $INFILE $wrkdir/pre_CalcAeroMass_mz4.ncf
  echo "    starting CalcAeroMass_mz4"
  ${prgdir}/CalcAeroMass_mz4 >&! $AIRLOGDIR/bcon/log02_CalcAeroMass_mz4.txt
  ncdump -h $outdir/$intermfile >&! $wrkdir/log02_imfile.txt
  cp $INFILE $wrkdir/post_CalcAeroMass_mz4.ncf
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
  ncdump -h $outdir/$intermfile >&! $wrkdir/log03_imfile.txt
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
