#!/bin/csh -f

# example of using this script:
# 
#   > ./run_combine4monthly_dep.csh 2016 05
#
#
#  2016-06-20    Serena H. Chung      initial version

# initialize exit status -----------------------------------------------
  set exitstat = 0

# check argument & set date strings  -----------------------------------
  if ( $#argv == 2 ) then     
    set YEAR  = $1
    set MONTH = $2
  endif

# "pre"conditions --need to set during test ----------------------------

   if ( ! $?AIRHOME        ) set AIRHOME = ~airpact5/AIRHOME
   if ( ! $?AIRRUN ) then
      set AIRRUN  = /data/lar/projects/airpact5/AIRRUN/$YEAR
      set AIRSAVE = /data/lar/projects/airpact5/saved/$YEAR
   endif
   if ( ! $?PBS_O_WORKDIR  ) set PBS_O_WORKDIR = ~airpact5/AIRHOME/run_ap5_day1

# fortran program ------------------------------------------------------
  set prgdir = ~airpact5/AIRHOME/build/combine/bld
  set prgexe = combine.exe

# files and directories ------------------------------------------------
  set  indir = $AIRSAVE/${MONTH}/deposition
  set outdir = $indir
  setenv SPECIES_DEF ~airpact5/AIRHOME/run_ap5_day1/post/cctm/deposition/spec_def_NSdep.txt
  setenv INFILE1   $indir/DRYDEP_monthlysum_$YEAR$MONTH.ncf
  setenv INFILE2   $indir/WETDEP1_monthlysum_$YEAR$MONTH.ncf
  setenv OUTFILE  $outdir/NSdep_monthlysum_$YEAR$MONTH.ncf

  if ( ! -e $INFILE1 ) then 
     echo $INFILE1 not found  
     exit(1)          
  else if ( ! -e $INFILE2 ) then 
     echo $INFILE2 not found  
     exit(1)          
  endif
  if ( -e $OUTFILE ) /bin/rm -f $OUTFILE

# running COMBINE ------------------------------------------------------
  setenv IOAPI_LOG_WRITE FALSE
  setenv GENSPEC FALSE
  set logfile = $AIRRUN/deposition/logs/log_combine_files_$YEAR$MONTH.txt
  mkdir -p $AIRRUN/deposition/logs
  $prgdir/$prgexe >&! $logfile

# checking log file ----------------------------------------------------
  echo "checking" $logfile
  set tmp_str1 = `tail -4 $logfile`
  set tmp_str2 = `echo "$tmp_str1[1-6]"`
  if ( `echo $tmp_str2` == `echo "--->> Normal Completion of program COMBINE"` ) then
     set tmp = `grep -i error $logfile`
     if ( $#tmp == 0 ) then
         echo "  ok; created" $OUTFILE
     else
         echo "  error in" $logfile
         echo $tmp
         set run_status = 1
         exit($run_status)
     endif
  else
     echo "      error running combine"
     echo `tail -4 $logfile`
     echo $tmp_str2
     set run_status = 1
     exit($run_status)
  endif

exit()
