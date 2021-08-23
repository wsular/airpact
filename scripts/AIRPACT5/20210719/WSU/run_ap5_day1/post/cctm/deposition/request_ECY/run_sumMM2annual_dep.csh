#!/bin/csh -f

# example of using this script:
# 
#   > ./run_sumMM2annual_dep.csh 
#
#
#  2017-08-04    Tsengel Nergui      initial version

# initialize exit status -----------------------------------------------
  set exitstat = 0

# fortran program ------------------------------------------------------
  set prgdir = ~/AIRHOME/build/sum_files
  set prgexe = sum_files.x
  setenv UNITS kg/hectare/year
  setenv VDESC "annual sum values"

# directory
  set indir = /data/lar/projects/airpact5/saved/2016
  set outdir = $cwd

# loop over deposition type
     setenv NFILE 12
    #echo $NFILE
     set run_status = 0
        setenv INFILE01 $indir/02/deposition/NSdep_monthlysum_201602.ncf
        setenv INFILE02 $indir/02/deposition/NSdep_monthlysum_201602.ncf

        setenv INFILE03 $indir/03/deposition/NSdep_monthlysum_201603.ncf
        setenv INFILE04 $indir/03/deposition/NSdep_monthlysum_201603.ncf

        setenv INFILE05 $indir/05/deposition/NSdep_monthlysum_201605.ncf
        setenv INFILE06 $indir/06/deposition/NSdep_monthlysum_201606.ncf
        setenv INFILE07 $indir/07/deposition/NSdep_monthlysum_201607.ncf
        setenv INFILE08 $indir/08/deposition/NSdep_monthlysum_201608.ncf
        setenv INFILE09 $indir/09/deposition/NSdep_monthlysum_201609.ncf
        setenv INFILE10 $indir/10/deposition/NSdep_monthlysum_201610.ncf
        setenv INFILE11 $indir/11/deposition/NSdep_monthlysum_201611.ncf
        setenv INFILE12 $indir/12/deposition/NSdep_monthlysum_201612.ncf
     

setenv OUTFILE  $outdir/NSdep_annualsum_2016.ncf
     set logfile = $cwd/log_sum_files_2016.txt
     $prgdir/$prgexe >&! $logfile
     echo "checking logfile" $logfile
     set tmp_str1 = `tail -4 $logfile`
     set tmp_str2 = `echo "$tmp_str1[1-6]"`
     if ( `echo $tmp_str2` == `echo "--->> Normal Completion of program sum_files"` ) then
        echo "  ok"
     else
        echo "      error running sum_files"
        echo `tail -4 $logfile`
        echo $tmp_str2
        set run_status = 1
        exit($run_status)
     endif


exit($run_status)
