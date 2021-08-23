#!/bin/csh -f

# example of using this script:
# 
#   > ./run_sum2monthly_dep.csh 2015 01
#
#
#  2015-12-01    Serena H. Chung      initial version

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
      set DATASAVE = /data/lar/projects/airpact5/saved/$YEAR #JKV Sept 1, 2017
# fortran program ------------------------------------------------------
  set prgdir = ~/AIRHOME/build/sum_files
  set prgexe = sum_files.x
  setenv UNITS kg/hectare/month
  setenv VDESC "monthly sum values"

# directory
  set indir = $AIRSAVE/${MONTH}/deposition
  set datasave = $DATASAVE/${MONTH}/deposition #JKV Sept 1, 2017
  set outdir = $indir

# make symbolic links for any dauily depositon for month already moved to /data at $DATASAVE JKV Sept 1, 2017
  ln -s $datasave/*ncf $indir

# loop over deposition type
  foreach type ( DRYDEP WETDEP1 )
     setenv NFILE `cal $MONTH $YEAR  |tr -s " " "\n"|tail -1`     # number of files is the number of days
    #echo $NFILE
     set run_status = 0
     @ iday = 1
     while ( $iday <= $NFILE )
        set DAY = $iday
        if ( $iday < 10 ) set DAY = 0$iday
        setenv INFILE${DAY} $indir/${type}_dailysum_${YEAR}${MONTH}${DAY}.ncf
        set tmp1 = INFILE${DAY}
        set tmp2 = `eval echo \$$tmp1`
        if ( ! -e $tmp2 ) then
            echo $tmp2 "does not exit"
            set run_status = 1
            exit($run_status)
        endif
        @ iday ++
     end # iday
     setenv OUTFILE  $outdir/${type}_monthlysum_$YEAR$MONTH.ncf
     mkdir -p $AIRRUN/deposition/logs
     set logfile = $AIRRUN/deposition/logs/log_sum_files_${type}_$YEAR$MONTH.txt
     $prgdir/$prgexe >&! $logfile
     echo "checking logfile" $logfile
     set tmp_str1 = `tail -4 $logfile`
     set tmp_str2 = `echo "$tmp_str1[1-6]"`
     if ( `echo $tmp_str2` == `echo "--->> Normal Completion of program sum_files"` ) then
        echo "  ok"
        rm -f $indir/${type}_dailysum_[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9].ncf
       #/bin/rm -f $logfile
     else
        echo "      error running sum_files"
        echo `tail -4 $logfile`
        echo $tmp_str2
        set run_status = 1
        exit($run_status)
     endif
  end #type


exit($run_status)
