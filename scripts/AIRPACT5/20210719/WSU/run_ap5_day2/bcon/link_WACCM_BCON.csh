#!/bin/csh -f

# example of using this script:
# 
#   > ./run_mozart42bcon.csh 20151113
#
#   takes ~2 minutes to run
#
#  2020-10-13	 Joseph Vaughan 	Revised to link to WACCM derived BCON of DAY1 run.
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
     set previousdayyear = `echo $previousday | cut -c1-4`
     set pYEAR  = `echo $previousday | cut -c1-4`
     echo PREVIOUSDAYYEAR $previousdayyear 
     echo PREVIOUSDAY $previousday 
   endif

# "pre"conditions --need to set during test ----------------------------

   if ( ! $?PBS_O_WORKDIR  ) set PBS_O_WORKDIR = ~airpact5/AIRHOME/run_ap5_day2
   if ( ! $?AIRHOME        ) set AIRHOME = ~airpact5/AIRHOME
   		#if ( ! $?AIRRUN ) then
      set AIRROOT1 = /data/lar/projects/airpact5/AIRRUN/$previousdayyear/${previousday}00
      set AIRROOT = /data/lar/projects/airpact5/AIRRUNDAY2
      set AIRRUN  = $AIRROOT/$YEAR
   		#endif
   if ( ! $?AIROUT         ) set AIROUT = $AIRRUN/${currentday}00
   if ( ! $?AIRLOGDIR      ) set AIRLOGDIR = $AIROUT/LOGS

# directories and files ------------------------------------------------
  mkdir -p ${AIRLOGDIR}/bcon
  set srcdir       = $AIRROOT1/BCON/output
  set srcfile      = bcon_cb05_${previousday}.ncf
  set outdir       = $AIROUT/BCON/output; mkdir -p $outdir
  set outfile      = bcon_cb05_${currentday}.ncf
  ls -lt $srcdir/$srcfile
# link WACCM BCON file -----------------------------------

  cd $outdir
  if ( -e $srcdir/$srcfile ) then
     echo "*** Linking DAY1 WACCM BCON file for DAY2 ***" 
     echo "*** Linking DAY1 WACCM BCON file for DAY2 ***"  >&! $AIRLOGDIR/bcon/link_WACCM-BCON.log
     ln -sf $srcdir/$srcfile $outdir/$outfile
     ls -lt $outdir/$outfile >> $AIRLOGDIR/bcon/link_WACCM-BCON.log
     ls -lt $outdir/$outfile
     exit ( 0 )
  else
     echo "*** Failed to find WACCM BCON to link from --  Use MOZART-4 monthly profile. ***" \
	>&! $AIRLOGDIR/bcon/link_MOZART4_2015-BCON.log
     ln -sf /data/lar/projects/airpact5/input/bcon4cmaq/bcon_from_mozart4_2015${MONTH}.ncf $outdir/$outfile
     ls -lt $outdir/$outfile >> $AIRLOGDIR/bcon/link_MOZART4_2015-BCON.log
     exit ( 0 )
  endif

  echo " finished in $0" 
  exit(0)
