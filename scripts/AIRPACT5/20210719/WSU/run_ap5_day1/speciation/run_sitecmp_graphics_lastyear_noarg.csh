#!/bin/csh -f
#   This script is meant to run monthly (13th day) for the previous year
#  
#   ./run_sitecmp_graphics_latyear_noarg.csh
#> ---------------------------------
   set BASE = /home/airpact5/AIRHOME/run_ap5_day1/speciation

#----------------------------- Previous Year Process ------------------------------------------------------------#
#> get date info (365 days ago)  ------------------------------------------------------

 set month = `perl -e 'printf "%d\n", (gmtime(time() - 31536000))[4]+1'`#31536000 seconds equals 365 days back
 set year  = `perl -e 'printf "%d\n", (gmtime(time() - 31536000))[5]+1900'`#31536000 seconds equals 365 days back
 echo "attempting to run Rscript for " $year $month

   set IMAGES = /data/lar/projects/airpact5/saved/${year}/IMAGES/speciation
   mkdir -p ${IMAGES}

#> First download the speciation data
   cd ${BASE}
   Rscript speciation_download.R ${year}
   ls -alh ${BASE}/improve_csn_data_${year}.csv
   echo "Previous Year Speciation Observations Download Complete"

#> date stuff ----------------------------------------------------------
   set amonth = $month
   if ( $month < 10 ) set amonth = 0$month
   set lastmonth = 12
   if ( $month == 1 ) set lastmonth = 10 #No need to run Nov/Dec if current month is Jan
   if ( $month == 2 ) set lastmonth = 11 #No need to run Dec if current month is Feb

#> run site compare code to generate model / observation comparison tables for each month in question

   @ miq = 1
   while ( $miq <= $lastmonth )
       set amiq = $miq
       if ( $amiq < 10 ) set amiq = 0$miq
       #> set input and output directories and files --------------------------
       set outdir  = /data/lar/projects/airpact5/saved/$year/speciation; mkdir -p ${outdir}
       set logdir  = /data/lar/projects/airpact5/saved/$year/speciation; mkdir -p ${logdir}
       echo "${BASE}/run_sitecmp.sh ${year} ${miq} > ${logdir}/sitecmp_${year}${amiq}.log"
       ${BASE}/run_sitecmp.sh ${year} ${miq} > ${logdir}/sitecmp_${year}${amiq}.log
       #> copy over the output table to the working directory
       cp ${outdir}/sitecmp_improve_csn_${year}${amiq}.csv ${BASE}/
       @ miq +=1
   end
   ls -alh ${BASE}/sitecmp_improve_csn*

#> run R script to generate graphics for the entire year
    cd ${BASE}
    echo "Rscript speciation_graphics.R > ${BASE}/logs/sitecmp_graphics_${year}.log"
    Rscript speciation_graphics.R > ${BASE}/logs/sitecmp_graphics_${year}.log

    cp ${BASE}/*.png ${IMAGES}/
    cp ${BASE}/sitecmp_improve_csn_${year}*.csv ${IMAGES}/
    cp ${BASE}/improve_csn_data_${year}.csv ${IMAGES}/
    cp ${BASE}/*${year}_stats.csv ${IMAGES}/
    cp ${BASE}/*${year}.log ${IMAGES}/
    rm -f ${BASE}/*.png
    rm -f ${BASE}/sitecmp_improve_csn_${year}*.csv
    rm -f ${BASE}/improve_csn_data_${year}.csv
    rm -f ${BASE}/*${year}_stats.csv
    rm -f ${BASE}/*${year}.log
    echo ${IMAGES}
    ls -alh ${IMAGES}
    echo "Previous Year Speciation Graphics Completed"

exit
