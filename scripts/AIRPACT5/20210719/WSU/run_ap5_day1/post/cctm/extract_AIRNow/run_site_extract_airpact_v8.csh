#!/bin/csh -fX
#
# example of using this script:
# 
#   > ./run_site_extract_airpact_v8.csh 20160223
#
#  2018-04-16    Joe Vaughan  updated to call updated v8 script for extract_AIRNow:
#   	1) to get fresh AIRNow sites daily, 
#   	2) to call v6 executable extracting (CO, NO, NO2, NOX, O3, PM2.5, PM10, SO2, WSPM2.5) and include header w/ units.
#  2020-01-05    Joe Vaughan  updated to correct error that truncates 12-character siteIDs to 9 characters.
#   	1) Recognize and create edit control file to expand 9-character siteIDs to 12-character versions.
#   	2) Use sed to apply edits to create new aqsites file.
#   	3) Call v8 version of extraction program.

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
   if ( ! $?PBS_O_WORKDIR ) set PBS_O_WORKDIR = $AIRHOME/run_ap5_day1
   if ( ! $?AIRRUN )        set AIRRUN  = /data/lar/projects/airpact5/AIRRUN
   if ( ! $?AIROUT )        set AIROUT        = $AIRRUN/$YEAR/${1}00
   if ( ! $?AIRLOGDIR )     set AIRLOGDIR     = $AIROUT/LOGS
   if ( ! $?MCIPDIR )       set MCIPDIR       = $AIROUT/MCIP37
   set BASE = ${PBS_O_WORKDIR}/post/cctm/extract_AIRNow

    # specifying the spheroids to be used
      setenv IOAPI_ISPH 19
  #> get necesary files defined
     setenv GRIDCRO2D  $MCIPDIR/GRIDCRO2D
     setenv INFILE     $AIROUT/POST/CCTM/combined_${currentday}.ncf 

#> run the extraction script -------------------------------------------
   mkdir -p $AIROUT/POST/CCTM 
   cd $AIROUT/POST/CCTM

# Implements wget for daily sites list.  JKV 022318  but ask for previous day, as current will not be available yet.
   wget -N -nv --no-check-certificate http://lar.wsu.edu/airpact/airnow_sites/aqsid${previousday}.csv
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
echo IDofLen9 $IDofLen9
echo "s/$IDofLen9/$IDofLen9   /" >> sed.txt
else
echo IDlen not equal to 10
endif
end

#   	2) Use sed to apply edits to create new aqsites file.
	cat aqsid.csv | sed -f sed.txt >! newaqsid.csv
#
#   	3) Call v8 version of extraction program.
~airpact5/AIRHOME/build/extract_AIRNow/site_extract_v8.x   >&! $AIRLOGDIR/post/ite_extract_v8.log
#~airpact5/AIRHOME/build/extract_AIRNow/site_extract_v8.x   >&! $AIRLOGDIR/post/log04_post_xtr4airnow.txt 

# #> clean up ------------------------------------------------------------
#    /bin/rm -f $AIROUT/POST/CCTM/AIRNow_sites.txt

exit(0)
