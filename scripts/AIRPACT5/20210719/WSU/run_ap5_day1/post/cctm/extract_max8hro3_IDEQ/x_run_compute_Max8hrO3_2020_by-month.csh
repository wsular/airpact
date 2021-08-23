#!/bin/tcsh -fX

# example of using this script:
# run_compute_Max8hrO3_2020_by-month.csh YYYYMM 
#  runs: 
# 	run_site_extract_Roll8hrO3.csh
# 	X   run_site_daily_max8hr03.csh
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

#foreach YYYYMMDD ( `ls -1 $AIRRUN | cut -c1-8 | sort -u | grep ${YEAR}${MONTH} | head -1 ` )
   foreach YYYYMMDD ( `ls -1 $AIRRUN | cut -c1-8 | sort -u | grep ${YEAR}${MONTH} ` )
	echo Process $YYYYMMDD

	echo run_site_daily_max8hr03.csh $YYYYMMDD  >&! ${YYYYMMDD}.log
 	run_site_daily_max8hr03.csh $YYYYMMDD >&! run_site_daily_max8hr03_${YYYYMMDD}.log 
	echo Status for run_site_daily_max8hr03 $YYYYMMDD is $status

end

exit(0)

