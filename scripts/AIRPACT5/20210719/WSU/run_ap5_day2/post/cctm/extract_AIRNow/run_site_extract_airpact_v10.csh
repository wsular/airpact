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
#  2020-10-09    Joe Vaughan updated to use v10 extraction with python code by Von Walden.

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
   if ( ! $?PBS_O_WORKDIR ) set PBS_O_WORKDIR = $AIRHOME/run_ap5_day2
   if ( ! $?AIRRUN )        set AIRRUN  = /data/lar/projects/airpact5/AIRRUNDAY2
   if ( ! $?AIROUT )        set AIROUT        = $AIRRUN/$YEAR/${1}00
   if ( ! $?AIRLOGDIR )     set AIRLOGDIR     = $AIROUT/LOGS
   if ( ! $?MCIPDIR )       set MCIPDIR       = $AIROUT/MCIP37
   set BASE = ${PBS_O_WORKDIR}/post/cctm/extract_AIRNow
   echo BASE $BASE 

    # specifying the spheroids to be used
      setenv IOAPI_ISPH 19
  #> get necesary files defined
     setenv GRIDCRO2D  $MCIPDIR/GRIDCRO2D
     setenv OUTFILE    $AIROUT/POST/CCTM/AIRNowSites_${currentday}_v10.dat
     setenv INFILE     $AIROUT/POST/CCTM/combined_${currentday}.ncf 
   if ( -e $INFILE ) then
	echo process $INFILE in original location 
   else
	echo $INFILE not found and not DAY2 POST/CCTM files are not saved.  Exit.
#	setenv INFILE /data/lar/projects/airpact5/saved/${YEAR}/${MONTH}/aconc/combined_${currentday}.ncf
#	mkdir -p $AIRLOGDIR/post
#	if ( -e $INFILE )  then
#		echo Using $INFILE
#	else
#		echo $INFILE not found
#		exit(1)
#	endif
   endif


#> run the extraction script -------------------------------------------
#   mkdir -p $AIROUT/POST/CCTM 
   cd $AIROUT/POST/CCTM

# Implements wget for daily sites list.  JKV 022318  but ask for previous day, as current will not be available yet.
   wget -N -nv --no-check-certificate http://lar.wsu.edu/airpact/airnow_sites/aqsid${previousday}.csv
   touch aqsid${previousday}.csv # to get correct time of wget of file.
   ls -lt aqsid${previousday}.csv
   set csv_len = `wc -l aqsid${previousday}.csv | cut -f1 -d' ' `

#    Decide if new file has enough sites or shoud we use the backup.
#   if ( -e aqsid${previousday}.csv ) then
   if ( ${csv_len} > 200 ) then
	ln -f aqsid${previousday}.csv aqsid.csv
	echo Using newly acquired airnow sites file 
   else
	echo WGET FAILED for aqsid${previousday}.csv  
	cp -f $BASE/aqsid_BACKUP.csv aqsid.csv
   endif

   ls -lt aqsid.csv

#  Next section:
#  2020-01-05    Joe Vaughan  updated to correct error that truncates 12-character siteIDs to 9 characters.
#   	1) Recognize and create edit control file to expand 9-character siteIDs to 12-character versions.
#		1.1) get list of all siteids, IDs only, by parsing file using cat and cut.
#		1.2) then for IDs of length 9 characters, write an edit command to sed.txt control file.
	cat aqsid.csv | sed -e '1,2d' | cut -f1 -d',' >! onlyIDs.csv
	if ( -f sed.txt) rm -f sed.txt
	touch sed.txt
foreach ID ( `cat onlyIDs.csv` )
set IDlen = `echo $ID | wc -c`
echo $ID $IDlen
if ( $IDlen == 10 ) then
set IDofLen9 = `echo $ID | cut -c 1-9 `
#echo IDofLen9 $IDofLen9
echo "s/$IDofLen9/$IDofLen9   /" >> sed.txt
#else
# echo IDlen not equal to 10
endif
end

#   	2) Use sed to apply edits to create new aqsites file.
	cat aqsid.csv | sed -f sed.txt >! newaqsid.csv
 	setenv NEWAQSID $cwd/newaqsid.csv
#
#   	3) Call v9 version of extraction program.
# ~airpact5/AIRHOME/build/extract_AIRNow/site_extract_v9.x   >&! $AIRLOGDIR/post/log04_post_xtr4airnow.txt 

#   	3) Call v10 version of extraction program.
	echo GRIDCRO2D $GRIDCRO2D 
	echo INFILE    $INFILE
	echo OUTFILE    $OUTFILE
	echo NEWAQSID  $NEWAQSID  
	ls -lt  $BASE/site_extract_v10.py 
        touch $AIRLOGDIR/post/log04_post_xtr4airnow.txt 
	echo "python3 ~/AIRHOME/run_ap5_day1/post/cctm/extract_AIRNow/site_extract_v10.py $previousday  >&! $AIRLOGDIR/post/log04_post_xtr4airnow.txt"
	python3 ~/AIRHOME/run_ap5_day1/post/cctm/extract_AIRNow/site_extract_v10.py $previousday  >&! $AIRLOGDIR/post/log04_post_xtr4airnow.txt
	set pystatus = $status
	if ( $pystatus == 0 ) then
	   echo Status after python script is  $pystatus
	   echo Report completion to log file
	   echo "--->> Normal Completion of program site_extract" >> $AIRLOGDIR/post/log04_post_xtr4airnow.txt
	   echo " status on echo to $AIRLOGDIR/post/log04_post_xtr4airnow.txt is $status"
	   echo "Successful end" >> $AIRLOGDIR/post/log04_post_xtr4airnow.txt
	   echo "Date and time:", `date` >> $AIRLOGDIR/post/log04_post_xtr4airnow.txt
	   echo " " >> $AIRLOGDIR/post/log04_post_xtr4airnow.txt
        else
	   echo Python ended with bad status of $pystatus
	   set exitstat = $pystatus
	endif
 
#	4) get rid of spaces in output file
	cat AIRNowSites_${currentday}_v10.dat | sed -e 's/ //g' >! noSpaces.dat
	echo status on sed for noSpaces is $status
	mv -f noSpaces.dat AIRNowSites_${currentday}_v10.dat
	ls -lt  AIRNowSites_${1}_v10.dat
	echo Current Directory is $cwd
	
echo Status on ending $0 is  $exitstat
exit($exitstat)
