#!/bin/csh -fX
#
# example of using this script:
# 
#   > ./run_site_extract_airpact_v9.csh 20160223
#
#  2018-04-16    Joe Vaughan  updated to call updated v6 script for extract_AIRNow:
#   	1) to get fresh AIRNow sites daily, 
#   	2) to call v6 executable extracting (CO, NO, NO2, NOX, O3, PM2.5, PM10, SO2, WSPM2.5) and include header w/ units.
#  2019-09-24    Joe Vaughan  updated to use sites file found by day1 post processing.
#  2020-01-13    Joe Vaughan corrects error truncation of 12-character siteIDs to 9 characters, 
#     drop WSPM25, varies formats, and compresses all spaces from final file..
#     1) Recognize and create edit control file to expand 9-character siteIDs to 12-character versions.
#     2) Use sed to apply edits to create new aqsites file.
#     3) Call v9 version of extraction program.
#     4) strip out spaces from output file.#  
#

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

#> check environment variable ------------------------------------------

   if ( ! $?AIRHOME )       set AIRHOME       = ~airpact5/AIRHOME
   if ( ! $?PBS_O_WORKDIR ) set PBS_O_WORKDIR = $AIRHOME/run_ap5_day2
   if ( ! $?AIRRUN ) then
      set AIRRUN  = /data/lar/projects/airpact5/AIRRUNDAY2/$YEAR
   endif
   if ( ! $?AIROUT )        set AIROUT        = $AIRRUN/${1}00
   if ( ! $?AIRLOGDIR )     set AIRLOGDIR     = $AIROUT/LOGS
   if ( ! $?mciproot )      set mciproot      = $AIRRUN
   if ( ! $?MCIPDIR )       set MCIPDIR       = $mciproot/${1}00/MCIP37
   set BASE = ${PBS_O_WORKDIR}/post/cctm/extract_AIRNow
   set pYEAR  = `echo $previousday | cut -c1-4`

    # specifying the spheroids to be used
      setenv IOAPI_ISPH 19
  #> get necesary files defined
     setenv GRIDCRO2D  $MCIPDIR/GRIDCRO2D
     setenv INFILE     $AIROUT/POST/CCTM/combined_${currentday}.ncf 

   if ( -e $INFILE ) then
     echo process $INFILE in original location 
   else
     echo No INFILE $INFILE found so exiting
     exit(1)
   endif

#> run the extraction script -------------------------------------------
   mkdir -p $AIROUT/POST/CCTM 
   cd $AIROUT/POST/CCTM

# Instead of using wget, use the aqsid.csv file in use for the day1 run.
   ln -f /data/lar/projects/airpact5/AIRRUN/$pYEAR/${previousday}00/POST/CCTM/aqsid.csv aqsid.csv
   if ( -e aqsid.csv ) then
     echo process aqsid.csv as found in day1 location 
   else
     echo No aqsid.csv FILE found so exiting
     exit(1)
   endif
   ls -lt aqsid.csv

#  Next section:
#  2020-01-13    Joe Vaughan  updated to correct error that truncates 12-character siteIDs to 9 characters.
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
#
#   	3) Call v9 version of extraction program.
~airpact5/AIRHOME/build/extract_AIRNow/site_extract_v9.x   >&! $AIRLOGDIR/post/log04_post_xtr4airnow.txt 
echo Status on site_extract_v9.x is $status

#	4) get rid of spaces in output file
	cat AIRNowSites_${1}_v9.dat | sed -e 's/ //g' >! noSpaces.dat
	mv -f noSpaces.dat AIRNowSites_${1}_v9.dat
	ls -lt AIRNowSites_${1}_v9.dat

echo Status $status
exit(0)
