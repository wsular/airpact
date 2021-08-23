#!/usr/bin/env csh

# example of using this script:
# convert_UTZ_MST.csh YYYYMM
#  runs:
#       convert_UTZ_MST.py
#
#   Joe Vaughan     2021-04-07 for doing timezone conversion from UTZ to MT for IDEQ (Pocatello and Twin Falls)

# module load commands:
module load gcc/7.3.0
module load python/3.8.8/gcc/7.3.0

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
   set BASE   = ~/AIRHOME/run_ap5_day1/post/cctm/extract_max8hro3_IDEQ
   cd $BASE

#foreach YYYYMMDD ( `ls -1 $AIRRUN | cut -c1-8 | sort -u | grep ${YEAR}${MONTH} | head -1 ` )
foreach YYYYMMDD ( `ls -1 $AIRRUN | cut -c1-8 | sort -u | grep ${YEAR}${MONTH} ` )
   
    echo In $0 foreach loop processing for date $YYYYMMDD 

    setenv INFILE $AIRRUN/${YYYYMMDD}00/POST/CCTM/IDEQ_Sites_${YYYYMMDD}_v10.dat
    echo INFILE is $INFILE
    wc -l $INFILE

    setenv OUTFILE $AIRRUN/${YYYYMMDD}00/POST/CCTM/IDEQ_Sites_${YYYYMMDD}_Roll8hrO3_MST.dat
    rm -f OUTTEMP
    setenv OUTTEMP ./OUTTEMP

    head -1 $INFILE >! INFILE.hdr
    #  
    python3 convert_UTZ_MST.py $INFILE $OUTTEMP
    echo Status for convert_UTZ_MST.py is $status 
    
    cat INFILE.hdr | sed -e 's/UTZ/MST/g' >! OUTTEMP.hdr
    grep RollingA8_O3 OUTTEMP >! OUTTEMP-7.body
    cat  OUTTEMP-7.body | sed -e 's/-07:00//' |tr -s ' ' '|' | sed -e 's/,/|/g' >! OUTTEMP.body
    cat  OUTTEMP.hdr OUTTEMP.body >! ${OUTFILE}
    echo OUTFILE is $OUTFILE
    wc -l OUTTEMP* $OUTFILE
    head ${OUTFILE} 
    echo Done with foreach loop processing for date $YYYYMMDD = = = = = = = = 
end # on foreach

exit(0)

