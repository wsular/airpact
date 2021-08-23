#!/bin/csh -f

# Serena H. Chung
# 2016-04-29

#   ./run_combine_3d.csh 20160429

#> location of the combine program ---------------------------------
   set prgdir = ~airpact5/AIRHOME/build/combine/bld
   set exec = combine.exe

#> initialize exit status ----------------------------------------------
   set exitstat = 0

#> check argument & set date strings  ----------------------------------

   if ( $#argv == 1 ) then
      set currentday = $1
      set YEAR  = `echo $1 | cut -c1-4`
      set MONTH = `echo $1 | cut -c5-6`
      set DAY   = `echo $1 | cut -c7-8`
   else
      echo 'invalid argument. '
      echo "usage $0 <yyyymmdd>"
      set exitstat = 1
      exit ( $exitstat )
   endif


#> during testing 

   if ( ! $?PBS_O_WORKDIR ) then
      set PBS_O_WORKDIR = ~airpact5/AIRHOME/run_ap5_day1
      set AIROUT = /data/lar/projects/airpact5/AIRRUN/${YEAR}/${currentday}00
      set AIRSAVE = /data/lar/projects/airpact5/saved/$YEAR
   endif
    
#> directory set-up ----------------------------------------------------

   set BASE    = $PBS_O_WORKDIR/post/cctm/combine
   set  INDIR  = $AIROUT/CCTM
   set OUTDIR  = $AIROUT/POST/CCTM
   if ( ! -d $OUTDIR ) mkdir -p $OUTDIR

   setenv SPECIES_DEF ~airpact5/AIRHOME/run_ap5_day1/post/cctm/combine/spec_def_conc_3d.txt
   setenv INFILE1 $AIROUT/CCTM/ACONC_${currentday}.ncf
   setenv OUTFILE $OUTDIR/combined3d_${currentday}.ncf
   if ( ! -e $INFILE1 ) then 
      echo $INFILE1 not found  
      exit(1)          
   endif
   if ( -e $OUTFILE ) /bin/rm -f $OUTFILE

  #echo attempting to create $OUTFILE
   setenv IOAPI_LOG_WRITE FALSE
   set logfile = $AIROUT/LOGS/post/log01b_post_combine.txt
   $prgdir/${exec} >&! $logfile

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

