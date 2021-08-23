#!/usr/bin/env csh
##!/bin/csh -fX
#
# example of using this script:
# 
#   > ./per_site_catenation_Roll8hr03_for_year.csh YYYY
#
#  2021-04-08    Joe Vaughan: for catenating the Rolling8hrO3 per site for a year.
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

#> for each site catenate the associated files for Roll8O3 in sorted order.
     ls -1  $AIROUT/${YEAR}*/POST/CCTM/IDEQ_Sites_${YEAR}*_Roll8hrO3_MST.dat |  sort  >! ${YEAR}_Roll8hr_MST.lst

     foreach ssite ( ` cat $SITES ` ) 
	echo Process SITE: $ssite
#       get all occurances of site into a sorted file 
	setenv YEAR_SITE_ROLL8O3_file $AIROUT/${YEAR}_${ssite}_Roll8O3_MST.csv
        echo Output YEAR_SITE_ROLL8O3_file is $YEAR_SITE_ROLL8O3_file
        rm -f $YEAR_SITE_ROLL8O3_file
        cp -f OUTTEMP.hdr $YEAR_SITE_ROLL8O3_file
        foreach ffile ( `cat ${YEAR}_Roll8hr_MST.lst` ) #   loop over a list of the Roll8hrO3_MST files
            grep $ssite $ffile | grep $YEAR >> $YEAR_SITE_ROLL8O3_file
            wc -l $YEAR_SITE_ROLL8O3_file
            ls -1 $YEAR_SITE_ROLL8O3_file
        end
     end # on ssite

        ls -lt $AIROUT/${YEAR}_*_Roll8O3_MST.csv
     
echo Status on ending $0 is  $exitstat

exit($exitstat)
