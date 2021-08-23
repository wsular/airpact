#!/usr/bin/env csh
##!/bin/csh -fX
#
# example of using this script:
# 
#   > ./per_site_catenation_max8hr03_for_year.csh YYYY
#
#  2021-03-25    Joe Vaughan: for catenating the max8hro3 per site for a year.
#> check argument & set date strings -----------------------------------

   if ( $1 > 2000 ) then     
      set YEAR = $1
   else
      echo 'invalid argument. '
      echo "usage $0 <yyyy>"
      set exitstat = 1
       exit ( $exitstat )
   endif

  #> initialize exit status
     set exitstat = 0

#
#> check environment variable ------------------------------------------

   set BASE = ~airpact5/AIRHOME/run_ap5_day1/post/cctm/extract_max8hro3_IDEQ
   echo BASE $BASE 
   cd $BASE
   if ( ! $?AIRHOME )       set AIRHOME       = ~airpact5/AIRHOME
   if ( ! $?PBS_O_WORKDIR ) set PBS_O_WORKDIR = $AIRHOME/run_ap5_day1
   if ( ! $?AIRRUN )        set AIRRUN  = /data/lar/projects/airpact5/AIRRUN
   if ( ! $?AIROUT )        set AIROUT        = $AIRRUN/$YEAR
   if ( ! $?AIRLOGDIR )     set AIRLOGDIR     = $BASE

  #> get necesary files defined
     setenv SITES     $BASE/SITELIST_IDEQ.txt 
     echo SITES     $SITES

#> for each site catenate the associated files for max8O3 in sorted order.


     foreach ssite ( ` cat $SITES ` ) 
	echo Process SITE: $ssite
	setenv YEAR_SITE_MAX8O3_file $AIROUT/${YEAR}_${ssite}_max8O3.csv
        echo Output YEAR_SITE_MAX8O3_file is $YEAR_SITE_MAX8O3_file
        touch $YEAR_SITE_MAX8O3_file
#       get a list of all the files needed for this site
	ls -1 $AIROUT/${YEAR}*00/POST/CCTM/IDEQ_${ssite}_${YEAR}*_max8O3.csv | sort >! flist.txt
        cat `cat flist.txt` | sed 's/20,/2020,/' >&! $YEAR_SITE_MAX8O3_file  
        ls -lt $YEAR_SITE_MAX8O3_file
        end

echo Status on ending $0 is  $exitstat
exit($exitstat)
