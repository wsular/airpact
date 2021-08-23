#!/bin/tcsh -fX

# example of using this script:
# run_2020_month-by-month.csh runs run_site_extract_max8hrO3.csh for argument YYYYMM 
#
#  <prompt> ./ 20120702 
#
#    where 20120702 denotes forecast start time of 8 GMT on Jul 1, 2012
#
#   Joe Vaughan     2012-05
#   Serena H. Chung 2012-05-10  
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
echo Process $YYYYMMDD
echo run_site_extract_max8hrO3.csh $YYYYMMDD  
run_site_extract_max8hrO3.csh $YYYYMMDD  >&! ${YYYYMMDD}.log
echo Status for $YYYYMMDD is $status
end

exit(0)

