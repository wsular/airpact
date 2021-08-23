#!/bin/csh -f
#
# RCS file, release, date & time of last delta, author, state, [and locker]
# $Header: /home/schung/models/CMAQ4.7.1/models/TOOLS/src/combine/combine.sh,v 1.1.1.1 2010/01/07 18:35:50 sjr Exp $ 
#
# what(1) key, module and SID; SCCS file; date and time of last delta:
# %W% %P% %G% %U%
#
#  example script for running the combine program on Unix
#
#  generates a new concentration file from output from the CMAQ model run
#

#   ./run_combine_daily_speciation_noarg.csh

#> location of the combine program ---------------------------------
source /home/airpact5/.tcshrc

   set BASE = /home/airpact5/AIRHOME/build/combineV3/bld
   set EXEC = ${BASE}/combineV3.0.exe

#> get date info for last month (20 days ago)  ------------------------------------------------------

 set month = `perl -e 'printf "%d\n", (gmtime(time() - 1728000))[4]+1'`#1728000 seconds equals 20 days back
 set year  = `perl -e 'printf "%d\n", (gmtime(time() - 1728000))[5]+1900'`#1728000 seconds equals 20 days back

 #> date stuff ----------------------------------------------------------
   set amonth = $month
   if ( $month < 10 ) set amonth = 0$month
   # determine if it is a leap year
     if ( ${year} % 400 == 0 ) then 
        set IFLEAP = Y
     else if ( ${year} % 100 == 0 ) then 
        set IFLEAP = N
     else if ( ${year} % 4 == 0 ) then
        set IFLEAP = Y 
     else
        set IFLEAP = N
     endif
   # determine number of days in each month
     if ( IFLEAP == 'Y' ) then
        set days_in_month = ( 31 29 31 30 31 30 31 31 30 31 30 31 )
     else
        set days_in_month = ( 31 28 31 30 31 30 31 31 30 31 30 31 )
     endif
    
#> set input and output directories and files --------------------------

    set outdir  = /data/lar/projects/airpact5/saved/$year/$amonth/speciation/CCTM; mkdir -p ${outdir}
    set logdir  = /data/lar/projects/airpact5/saved/$year/$amonth/speciation/LOGS; mkdir -p ${logdir}
    setenv OUTFILE $outdir/speciated_pm25_${year}${amonth}.ncf
   # define name of species definition file,  one that is mostly aerosol
    setenv SPECIES_DEF /home/airpact5/AIRHOME/run_ap5_day1/speciation/spec_def_aero.conc
    echo attempting to create $OUTFILE
    @ day = 1
    while ( $day <= $days_in_month[$month] ) 
       set aday = $day
       if ( $day < 10) set aday = 0$day
       set DOYstring = `juldate $month $day $year | cut -d',' -f 2`
#       set DOYstring = `juldate $month $day $year | cut -d',' -f 2 | cut -d ' ' -f 2`
       set DOY       = `echo $DOYstring | cut -c5-7`
       set indir  = /data/lar/projects/airpact5/saved/${year}/${amonth}/aconc
       echo `date` ": run combine" $year $month $day 
       setenv INFILE1 $indir/combined_${year}${amonth}${aday}.ncf
       echo attempting to use $INFILE1
       if ( ! -e $INFILE1 ) then 
          echo $INFILE1 not found  
          exit(1)          
       endif
       ${EXEC}
       @ day ++
    end # while day

echo "...." $OUTFILE "created"
