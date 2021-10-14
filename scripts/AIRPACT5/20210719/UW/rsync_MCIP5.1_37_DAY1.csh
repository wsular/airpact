#!/bin/csh -f

# rsync_MCIP5.1_37_DAY1.csh 02/19/20 Joe Vaughan 
# Changed /data/lar/projects/airpact5/AIRRUN to /data/lar/projects/airpact5/AIRRUN  JKV 010518 

echo Running $0 for argument $1
date

set TRUE = 0
set FALSE = 1

setenv RUN_RSYNC_AEOLUS $TRUE

#check argument
if ( $#argv == 1 ) then
   setenv SRTYR `echo $1 | cut -c1-4`
   setenv SRTMN `echo $1 | cut -c5-6`
   setenv SRTDT `echo $1 | cut -c7-8`
   setenv SRTHR `echo $1 | cut -c9-10`
else
   echo 'Invalid argument. '
   echo "Usage $0 <yyyymmddhh>"
   set exitstat = 1
   exit ( $exitstat )
endif

# AIRPACT-5 locations on rainier
set HOME      = /home/rainier_empact
set AIRRUN    = $HOME/airpact5/AIRRUN5
set AIRHOME   = $HOME/airpact5/AIRHOME 
set AIRDATA   = $AIRHOME/DATA
set RUNROOT   = $AIRRUN/$1 
set LOGDIR    = $RUNROOT/LOGS
echo RUNROOT is $RUNROOT 
setenv LOGDIR $LOGDIR 

# AIRPACT-5 locations on aeolus 
set TARGETSYS = airpact5@aeolus.wsu.edu
set TARGETDIR = /data/lar/projects/airpact5/AIRRUN/$SRTYR/$1

if ( ${RUN_RSYNC_AEOLUS} == $TRUE ) then
    echo rsync 4-km MCIP37 results to aeolus
    date

# check source directory and list file in source directory
  if ( ! -d $RUNROOT/MCIP37 ) then
     echo "Error: $RUNROOT/MCIP37 directory does not exist."
     set exitstat = 1
     exit ( $exitstat )
  endif

echo "TARGET directory is ${TARGETSYS}:${TARGETDIR}"

## create necessary date directory on aeolus under airpact5
  setenv STATUS 1
  set count = 0
  while ( $STATUS != 0  && $count < 100 )
        ssh -v  ${TARGETSYS} mkdir -v -p $TARGETDIR
        if ( $status == 0 ) then
#           echo "*** success on ssh for mkdir on aeolus ***"
           setenv STATUS 0
        endif
	set count = `expr $count + 1`
        echo STATUS for mkdir iteration $count is $STATUS
	date
  end

cd $RUNROOT
   setenv STATUS 1
   set count = 0
     while ( $STATUS != 0  && $count < 100 )
         rsync -rzvh MCIP37 ${TARGETSYS}:$TARGETDIR
         if ( $status == 0 ) then
            setenv STATUS 0
         endif
	 set count = `expr $count + 1`
         echo STATUS for rsync on MCIP37 iteration $count is $STATUS
	 date
     end

exit($status)
