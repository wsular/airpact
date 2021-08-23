#!/bin/csh -f

setenv basedir ~airpact5/AIRHOME/run_ap5_day2/post/cctm/KFBC
cd $basedir

# get the date to run for
  if ( $#argv == 1 ) then
     set currentday = $1
     set YYYY  = `echo $currentday | cut -c1-4`
     set YYYYMMDD  = `echo $currentday | cut -c1-8`
     echo Running $0 for $YYYYMMDD from command line argument
  else # if no command-line input, use CURRENTRUN.txt
     echo Missing command-line input.  Exiting.
     exit(1) 
  endif

# set up sed edit file 
cat >! sed.txt << EOF
s|YYYYMMDD|$YYYYMMDD|g
s|YYYY|$YYYY|g
EOF

#build the qsub file for the reqested KFBC run
cat qsub4run_ncl_KFBC_PM25.template | sed -f sed.txt >! qsub4run_ncl_KFBC_PM25_$YYYYMMDD.csh

#submit the qsub script for the reqested KFBC run
qsub -V qsub4run_ncl_KFBC_PM25_$YYYYMMDD.csh
echo Status on qsub subimssion of qsub4run_ncl_KFBC_PM25_$YYYYMMDD.csh is $status

exit(0)


