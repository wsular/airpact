#!/usr/bin/env csh
##!/bin/csh -fX
#
# example of using this script:
# 
#   > ./run_site_extract_airpact_v10.csh 20160223
#
#  2020-09-23    Joe Vaughan  updated to call updated v10 python code by Von Walden for extraction.
#       and to correct output formatting limitation in FORTRAN-compiled version (v9). 
#
#  2020-01-05    Joe Vaughan corrects error truncation of 12-character siteIDs to 9 characters, 
#  	drop WSPM25, varies formats, and compresses all spaces from final file..
#   	1) Recognize and create edit control file to expand 9-character siteIDs to 12-character versions.
#   	2) Use sed to apply edits to create new aqsites file.
#   	3) Call v9 version of extraction program.
#   	4) strip out spaces from output file.

#> check argument & set date strings -----------------------------------

   if ( $1 > 20000100 ) then     
      set currentday = $1
      set YEAR  = `echo $currentday | cut -c1-4`
      set MONTH = `echo $currentday | cut -c5-6`
      set DAY   = `echo $currentday | cut -c7-8`
      set previousday = `date -d "$currentday -1 days" '+%Y%m%d'`
   else
      echo 'invalid argument. '
      echo "usage $0 <yyyymmdd>"
      set exitstat = 1
       exit ( $exitstat )
   endif

  #> initialize exit status
     set exitstat = 0

# module load commands:
module load gcc/7.3.0
module load python/3.7.1/gcc/7.3.0
#module load geos/3.7.0/gcc/7.3.0
#module load proj/5.2.0/gcc/7.3.0

which python3
whereis python3

#
#> check environment variable ------------------------------------------

   if ( ! $?AIRHOME )       set AIRHOME       = ~airpact5/AIRHOME
   if ( ! $?PBS_O_WORKDIR ) set PBS_O_WORKDIR = $AIRHOME/run_ap5_day1
   if ( ! $?AIRRUN )        set AIRRUN  = /data/lar/projects/airpact5/AIRRUN
   if ( ! $?AIROUT )        set AIROUT        = $AIRRUN/$YEAR/${1}00
   if ( ! $?AIRLOGDIR )     set AIRLOGDIR     = $AIROUT/LOGS
   if ( ! $?MCIPDIR )       set MCIPDIR       = $AIROUT/MCIP37
   set BASE = ~airpact5/AIRHOME/run_ap5_day1/post/cctm/extract_AIRNow_IDEQ
   echo BASE $BASE 

    # specifying the spheroids to be used
      setenv IOAPI_ISPH 19
  #> get necesary files defined
     setenv GRIDCRO2D  $MCIPDIR/GRIDCRO2D
     setenv OUTFILE    $AIROUT/POST/CCTM/IDEQ_Sites_${currentday}_v10.dat
     setenv INFILE     $AIROUT/POST/CCTM/O3_L01_08hr_${previousday}.ncf 
   if ( ! -e $INFILE ) then
	echo $INFILE is not found.  Exit.
        exit(9)
   endif


#> run the extraction script -------------------------------------------
   cd $AIROUT/POST/CCTM

 	setenv NEWAQSID  $BASE/AQSID_IDEQ.csv 

#   	3) Call v10 version of extraction program.
	echo GRIDCRO2D $GRIDCRO2D 
	echo INFILE    $INFILE
	echo OUTFILE    $OUTFILE
	echo NEWAQSID  $NEWAQSID  
	ls -lt  $BASE/site_extract_max8hrO3.py 
        touch $AIRLOGDIR/post/log04_post_xtr4airnow_IDEQ.txt 
	# do I need the argument for the py code?
	echo "python3 ${BASE}/site_extract_max8hrO3.py $previousday  >&! $AIRLOGDIR/post/log04_post_xtr4airnow_IDEQ.txt"
	python3 ${BASE}/site_extract_max8hrO3.py $previousday  >&! $AIRLOGDIR/post/log04_post_xtr4airnow_IDEQ.txt
	set pystatus = $status
	if ( $pystatus == 0 ) then
	   echo Status after python script is  $pystatus
	   echo Report completion to log file
	   echo "--->> Normal Completion of program site_extract" >> $AIRLOGDIR/post/log04_post_xtr4airnow_IDEQ.txt
	   echo " status on echo to $AIRLOGDIR/post/log04_post_xtr4airnow_IDEQ.txt is $status"
	   echo "Successful end" >> $AIRLOGDIR/post/log04_post_xtr4airnow_IDEQ.txt
	   echo "Date and time:", `date` >> $AIRLOGDIR/post/log04_post_xtr4airnow_IDEQ.txt
	   echo " " >> $AIRLOGDIR/post/log04_post_xtr4airnow_IDEQ.txt
        else
	   echo Python ended with bad status of $pystatus
	   set exitstat = $pystatus
	endif
 
#	4) get rid of spaces in output file
	cat IDEQ_Sites_${currentday}_v10.dat | sed -e 's/ //g' >! noSpaces.dat
	echo status on sed for noSpaces is $status
	mv -f noSpaces.dat IDEQ_Sites_${currentday}_v10.dat
	ls -lt  IDEQ_Sites_${currentday}_v10.dat
	echo Current Directory is $cwd
	
echo Status on ending $0 is  $exitstat
exit($exitstat)
