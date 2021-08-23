#!/usr/bin/env csh

# module load commands:
module load gcc/7.3.0
module load python/3.8.8/gcc/7.3.0

setenv INFILE $cwd/test_UTZ.dat
setenv OUTFILE $cwd/test_MST.out
#head $INFILE
head -1 $INFILE >! ${INFILE}.hdr
#  
      python3 convert_UTZ_MST.py $INFILE >&! $OUTFILE
      echo Status for convert_UTZ_MST.py is $status 

cat ${INFILE}.hdr | sed -e 's/UTZ/MST/g' >! ${OUTFILE}.hdr
grep RollingA8_O3 $OUTFILE >! ${OUTFILE}-7.body
cat  ${OUTFILE}-7.body | sed -e 's/-07:00//' |tr -s ' ' '|' >! ${OUTFILE}.body
cat ${OUTFILE}.hdr ${OUTFILE}.body >! ${OUTFILE}.MST

exit(0)

