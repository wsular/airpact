#!/bin/sh
#
# RCS file, release, date & time of last delta, author, state, [and locker]
# $Header: /home/schung/models/CMAQ4.7.1/models/TOOLS/src/sitecmp/run_improve.sh,v 1.1.1.1 2010/01/07 18:35:50 sjr Exp $ 
#
# what(1) key, module and SID; SCCS file; date and time of last delta:
# %W% %P% %G% %U%
#
# script for running the site compare program on Unix
#  comparing the CMAQ model run I2a dataset with IMPROVE dataset
#
#  ./run_sitecmp.sh 1997 6


#> check arguments -----------------------------------------------------
   if [[ $# -eq 2 ]] ; then
      year=$1
      month=$2
   else
       echo " incorect number of arguments; usage example:"
       echo $0 1997 6
       exit 2
   fi

#> date stuff ----------------------------------------------------------
   if [[ $month -lt 10 ]]; then
      amonth="0$month"
   else
      amonth=$month
   fi
   # previous month
     if [[ $month -gt 1 ]]; then
        monthp1=$(($month - 1 ))
        yearp1=$year
        if [[ $monthp1 -lt 10 ]]; then
             amonthp1="0$monthp1"
        else
            amonthp1=$monthp1
        fi
     else
        monthp1=12  
        amonthp1="12"
        yearp1=$(( $year - 1 ))
     fi

     echo $yearp1 $amonthp1
     echo $year $amonth
   # determine if it is a leap year
     if [[ $year%400 -eq 0 ]]; then 
        IFLEAP=Y
     elif [[ $year%100 -eq 0 ]]; then 
        IFLEAP=N
     elif [[ $year%4 -eq 0 ]]; then
        IFLEAP=Y 
     else
        IFLEAP=N
     fi
   # determine number of days in each month
     if [[ $IFLEAP == "Y" ]]; then
        days_in_month=( 31 29 31 30 31 30 31 31 30 31 30 31 );
     else
        days_in_month=( 31 28 31 30 31 30 31 31 30 31 30 31 );
     fi
   # determine day of the year for the 1st and last day of the month
     startday=${days_in_month[@]:${monthp1}-1:1}
     endday=${days_in_month[@]:${month}-1:1}
     echo previous month last day is $startday and current month last day is $endday
     DOYstring=`juldate $monthp1 $startday $yearp1 | cut -d',' -f 2 | cut -d ' ' -f 2`
     DOY1=`echo $DOYstring | cut -c5-7`
     echo $DOY1
     DOYstring=`juldate $month $endday $year | cut -d',' -f 2 | cut -d ' ' -f 2`
     DOY2=`echo $DOYstring | cut -c5-7`
     echo $DOY2

#> location/path -------------------------------------------------------
     datadir=/home/airpact5/AIRHOME/run_ap5_day1/speciation 
   # program location
     BASE=$datadir/sitecmp

     EXECUTION_ID=sitecmpV1.0; export EXECUTION_ID
     EXEC=/home/airpact5/AIRHOME/build/sitecmp/bld/${EXECUTION_ID}.exe
   # input
     indir1=/data/lar/projects/airpact5/saved/${yearp1}/${amonthp1}/speciation/CCTM
     indir2=/data/lar/projects/airpact5/saved/${year}/${amonth}/speciation/CCTM

     # ioapi input files containing VNAMES (max of 10)
       M3_FILE_1=${indir1}/speciated_pm25_${yearp1}${amonthp1}.ncf;  export M3_FILE_1
       M3_FILE_2=${indir2}/speciated_pm25_${year}${amonth}.ncf;  export M3_FILE_2
     # SITE FILE containing site-id, longitude, latitude (tab?? delimited)
     #  for IMPROVE, columns should be, with "#," in the beginning of the header line :
     #     #,siteid,lon,lat
      SITE_FILE=/home/airpact5/AIRHOME/run_ap5_day1/speciation/improve_csn_sites4sitecmp.csv; export SITE_FILE
     # : input table (exported file from Excel) 
     #   containing site-id, time-period, and data fields
     # note: for IMPROVE the file should have the following column names (among other things)
     #           site_code
     #           obs_date

     IN_TABLE=${datadir}/improve_csn_data_${year}.csv; export IN_TABLE
   # output
     outroot=/data/lar/projects/airpact5/saved/${year}/IMAGES
     outdir=$outroot/speciation;  mkdir -p $outdir 
     #  output table (tab delimited text file importable to Excel)
        OUT_TABLE=${outdir}/sitecmp_improve_csn_${year}${amonth}.csv; export OUT_TABLE
   # log
     logdir=$outroot/logs; mkdir -p $logdir
     logfile=$logdir/sitecmp_improve_csn_${year}${amonth}.log

#> site compare set up -------------------------------------------------
   # Set TABLE TYPE
     TABLE_TYPE=IMPROVE;   export TABLE_TYPE
   # Specify the variable names used in your observation inputs
   # and model output files for each of the species you are analyzing below.
   #
   # variable format:
   #    Obs_expression, Obs_units, [Mod_expression], [Mod_unit], [Variable_name]
   #
   # The expression is in the form:
   #       [factor1]*Obs_name1 [+][-] [factor2]*Obs_name2 ...
   #
   # If you do not need one of the species listed, comment out the first column.
 
   # AEROSOL Variables (1-10)  - compute average over time

     AERO_1="Organic_Carbon,ugC/m3,AOCT,,PM_OC";   export AERO_1   # Organic Carbon
     AERO_2="Elemental_Carbon,ug/m3,AECT,,PM_EC";  export AERO_2   # Elemental Carbon
     AERO_3="PM25_mass,ug/m3,PM25_TOT,,PM25";      export AERO_3   # PM2.5
     AERO_4="Nitrate,ug/m3,ANO3T,,PM_NO3";         export AERO_4   # Nitrate
     AERO_5="Sulfate,ug/m3,ASO4T,,PM_SO4";         export AERO_5   # Sulfate
     AERO_6="Ammonium,ug/m3,ANH4T,,PM_NH4";        export AERO_6  #Ammonium

   # define time window
     START_DATE=${yearp1}${DOY1};  export START_DATE
     START_TIME=0;               export START_TIME
     END_DATE=${year}${DOY2};  export END_DATE
     END_TIME=230000;            export END_TIME
   # adjust for daylight savings 
     APPLY_DLS=N; export APPLY_DLS 
   # define string to indicate missing data
     MISSING='-999'; export MISSING
   # Projection sphere type (use type #19 to match CMAQ)
     IOAPI_ISPH=19; export IOAPI_ISPH

#############################################################
#  Output files
#############################################################


 ${EXEC} > $logfile

 echo output file = ${OUT_TABLE}
 echo log file = ${logfile}
 tail ${logfile}

 echo "Now removing any lines with data from last day of previous month"
 sed -i "/${amonthp1}\/${startday}\/${yearp1}/d" ${OUT_TABLE}
