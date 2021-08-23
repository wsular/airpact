#!/bin/csh -f
#   This script is meant to run monthly (14th day) for the current year
#   Due to the 3 month time lag on data availability, this script will not run current year for January-March
#
#   ./run_sitecmp_graphics_thisyear_noarg.csh
#> ---------------------------------
   set BASE = /home/airpact5/AIRHOME/run_ap5_day1/speciation

#----------------------------- Current Year Process ------------------------------------------------------------#
#> get date info   ------------------------------------------------------

 set month = `perl -e 'printf "%d\n", (gmtime(time()))[4]+1'`
 set year  = `perl -e 'printf "%d\n", (gmtime(time()))[5]+1900'`
 echo "attempting to run Rscript for " $year $month

   set IMAGES = /data/lar/projects/airpact5/saved/${year}/IMAGES/speciation
   mkdir -p ${IMAGES}

if ( $month > 3 ) then #this script will not run current year for January-March
#> First download the speciation data
   cd ${BASE}
   Rscript speciation_download.R ${year}
   ls -alh ${BASE}/improve_csn_data_${year}.csv
   echo "Current Year Speciation Observations Download Complete"

   if ( ! -e ${BASE}/improve_csn_data_${year}.csv ) then
      echo "No Speciation Observations Available from Download, Stopping"
      exit(0)
   endif

 #> date stuff ----------------------------------------------------------
   set amonth = $month
   if ( $month < 10 ) set amonth = 0$month
   set lastmonthtouse = `perl -e 'printf "%d\n", (gmtime(time() - 7776000))[4]+1'` #3 months ago = 90 days   

#> run site compare code to generate model / observation comparison tables for each month in question

    @ miq = 1
    while ( $miq <= $lastmonthtouse )
        set amiq = $miq
        if ( $amiq < 10 ) set amiq = 0$miq
        #> set input and output directories and files --------------------------
        set outdir  = /data/lar/projects/airpact5/saved/$year/speciation/CCTM; mkdir -p ${outdir}
        set logdir  = /data/lar/projects/airpact5/saved/$year/speciation/LOGS; mkdir -p ${logdir}
        echo "${BASE}/run_sitecmp.sh ${year} ${miq} > ${logdir}/sitecmp_${year}${amiq}.log"
        ${BASE}/run_sitecmp.sh ${year} ${miq} > ${logdir}/sitecmp_${year}${amiq}.log
        #> copy over the output table to the working directory
        cp ${outdir}/sitecmp_improve_csn_${year}${amiq}.csv ${BASE}/
        @ miq +=1
    end
    ls -alh ${BASE}/sitecmp_improve_csn*

#> run R script to generate graphics for the entire year
    cd ${BASE}
    echo "Rscript speciation_graphics.R > ${BASE}/sitecmp_graphics_${year}.log"
    Rscript speciation_graphics.R > ${BASE}/sitecmp_graphics_${year}.log
    mkdir -p ${IMAGES}
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
    echo "Current Year Speciation Graphics Completed"

endif

exit
