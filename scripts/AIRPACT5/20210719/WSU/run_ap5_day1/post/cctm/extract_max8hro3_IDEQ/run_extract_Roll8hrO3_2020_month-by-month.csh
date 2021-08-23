#!/bin/tcsh -fX

# example of using this script:
# run_2020_month-by-month.csh YYYYMM 
#  runs: 
# 	run_site_extract_Roll8hrO3.csh
# 		 YYYYMM 
#
#   Joe Vaughan     2012-05 Modified to extract ave08O3 for sites for IDEQ (Pocatello and Twin Falls)
#


#> initialize exit status ----------------------------------------------
   set exitstat = 0

#> check argument  -----------------------------------------------------

   if ( $#argv == 1 ) then
      set YEAR  = `echo $1 | cut -c1-4`
      set MONTH = `echo $1 | cut -c5-6`
   else
      echo 'invalid argument. '
      echo "usage $0 <yyyymm>"
      set exitstat = 1
      exit ( $exitstat )
   endif

echo Running $0 for $YEAR $MONTH
#  
   set AIRRUN = ~/AIRRUN/$YEAR/

#   ls -1 $AIRRUN
 
# build list of dates to run
#   ls -1 $AIRRUN | cut -c1-10 | sort -u | grep ${YEAR}${MONTH}
#
   foreach YYYYMMDD ( `ls -1 $AIRRUN | cut -c1-8 | sort -u | grep ${YEAR}${MONTH} ` )
#foreach YYYYMMDD ( `ls -1 $AIRRUN | cut -c1-8 | sort -u | grep ${YEAR}${MONTH} | head -1 ` )
	echo Process $YYYYMMDD

	echo run_site_extract_Roll8hrO3.csh $YYYYMMDD  
 	run_site_extract_Roll8hrO3.csh $YYYYMMDD >&! run_site_extract_Roll8hrO3_${YYYYMMDD}.log
	echo Status for run_site_extract_Roll8hrO3 $YYYYMMDD is $status

   end

exit(0)

