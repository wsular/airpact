#!/bin/csh -fX

# Example of using this script:
# 
#   > plot_south_bcon_PM25_w.csh 20120501 
#
#    where 20101104 denotes forecast start time of 8 GMT on Nov 5, 2010
#
# Sept 2018: With adoption of code processing WACCM files to BCON input file for CMAQ in AIRPACT5, the BCON time steps have changed.
# Previous versions of BCON processing either: 
# (ending Jan 2018) used daily MOZART4 results and provided hourly BCON time steps to CMAQ, and those time steps 
# matched those of the MCIP meteorology, with 25 hourly steps in the file, providing for interpolation to intermediate times.
# (or since Jan 2018) used old monthly average MOZART4 results providing only a single hour each day.
#
# As of Sept 2018, BCON will soon be being generated from WACCM files with data every 6 hours.
# The WACCM data deosn't start at, or contain, the hour matching UTZ 08 which is the starting hour for MCIP and CMAQ.
# The BCON from WACCM will instead contain hour 06 UTZ and every six hours thereafter for a total of ten timesteps.
# CMAQ will interpolate for BCON needed bewteen the available time steps of the BCON file.
# 
# Following these Sept 2018 changes, these BCON plotting codes are being changed to plot only every 6 hours, 
# beginning with hour 06 UTZ, fora total of ten time steps, thus covering both DAY1 and DAY2 CMAQ runs.
#
# Farren Herron-Thorpe   2013-04-26
# Joe Vaughan           2013-10-17
# Joe Vaughan           2016-12-28 Modified for testing in AIRPACT5
# Joe Vaughan           2018-09-06 Modified for BCON from WACCM for AIRPACT5

# Old comments:
# This C shell script creates hourly gif files of plots of the PM25 on the 
# southern boundary (based on AIRPACT-5 MOZART BCON files) 
# For each hour, the script 1) creates an NCL script, 2) runs the NCL script
# to create the figure in postcript format, and 3) converts the postscript file to a gif file.

#> check argument & set date strings  ----------------------------------

echo $0 $1

   if ( $#argv == 1 ) then
      setenv YEAR `echo $1 | cut -c1-4`
      setenv MONTH `echo $1 | cut -c5-6`
      setenv DAY `echo $1 | cut -c7-8`
   else
      echo 'Invalid argument. '
      echo "Usage $0 <yyyymmdd>"
      set exitstat = 1
      exit ( $exitstat )
   endif

  #> determine date
   set yyyymmdd = ${YEAR}${MONTH}${DAY}
     set YEARMMDD = $yyyymmdd

set prevday = `date -d "$yyyymmdd -1 days" '+%Y%m%d'`
     echo PREVDAY $prevday

set nextday = `date -d "$yyyymmdd +1 days" '+%Y%m%d'`
     echo NEXTDAY $nextday

set nextnextday = `date -d "$yyyymmdd +2 days" '+%Y%m%d'`
     echo NEXTNEXTDAY $nextnextday


#> during testing 
   if ( ! $?PBS_O_WORKDIR ) then
    set PBS_O_WORKDIR = ~airpact5/AIRHOME/run_ap5_day1
    set AIROUT = /data/lar/projects/airpact5/AIRRUN/$YEAR/${1}00
    set MCIPDIR = /data/lar/projects/airpact5/AIRRUN/$YEAR/${1}00/MCIP37
   endif

#> initialize exit status ----------------------------------------------
   set exitstat = 0

#> directory set-up ----------------------------------------------------

   set indir      = $AIROUT
   set mcip       = $MCIPDIR
   set NCLSCRIPTS = ${PBS_O_WORKDIR}/plot
   set PSDIR      = $indir/IMAGES/bcon/ps
   mkdir -p $PSDIR

# > create and run ncl script hour by hour ----------------------------

foreach ihour ( 0   1   2   3   4   5   6   7   8   9  )

echo Starting for hour $ihour

# utz_hh       06  12  18  00  06  12  18  00  06  12   
# utz_date      D   D   D  D+1 D+1 D+1 D+1 D+2 D+2 D+2
# pst_hh       22  04  10  16  22  04  10  16  22  04   
# pst_date     D-1  D   D   D   D  D+1 D+1 D+1 D+1 D+2  
#
       if ( $ihour < 10 ) then
          set ahour = 0$ihour
       else
          set ahour = $ihour
       endif

       if ( $ihour == 0 ) then
		set utz_hh = 06
		set utz_date = $yyyymmdd
			set pst_hh = 22
			set pst_date = $prevday
	else if ( $ihour == 1 ) then
		set utz_hh = 12
		set utz_date = $yyyymmdd
			set pst_hh = 04
			set pst_date = ${YEAR}${MONTH}${DAY}
	else if ( $ihour == 2 ) then
		set utz_hh = 18
		set utz_date = $yyyymmdd
			set pst_hh = 10
			set pst_date = ${YEAR}${MONTH}${DAY}
	else if ( $ihour == 3 ) then
		set utz_hh = 00
		set utz_date = $yyyymmdd
			set pst_hh = 16
			set pst_date = ${YEAR}${MONTH}${DAY}
	else if ( $ihour == 4 ) then
		set utz_hh = 06
		set utz_date = $yyyymmdd
			set pst_hh = 22
			set pst_date = ${YEAR}${MONTH}${DAY}
	else if ( $ihour == 5 ) then
		set utz_hh = 12
		set utz_date = $yyyymmdd
			set pst_hh = 04
			set pst_date = $nextday
	else if ( $ihour == 6 ) then
		set utz_hh = 18
		set utz_date = $yyyymmdd
			set pst_hh = 10
			set pst_date = $nextday 
	else if ( $ihour == 7 ) then
		set utz_hh = 00
		set utz_date = $yyyymmdd
			set pst_hh = 16
			set pst_date = $nextday
	else if ( $ihour == 8 ) then
		set utz_hh = 06
		set utz_date = $yyyymmdd
			set pst_hh = 22
			set pst_date = $nextday
	else if ( $ihour == 9 ) then
		set utz_hh = 12
		set utz_date = $yyyymmdd
			set pst_hh = 06
			set pst_date = $nextnextday
	else if ( $ihour >= 10 ) then
		echo SOMEHOW WE GOT TO HOUR 10.  CHECK RESULTS...
		exit(1)
	endif 
		

echo " ihour = " $ihour
setenv ihour $ihour
echo " ahour " $ahour 
echo "UTZ: " utz_date utz_hh
echo "PST: " pst_date pst_hh

setenv ahour $ahour
