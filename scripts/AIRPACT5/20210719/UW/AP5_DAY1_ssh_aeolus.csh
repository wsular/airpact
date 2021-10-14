#!/bin/csh -fX

echo Running $0 for argument $1
date

set TRUE = 0
set FALSE = 1

set RUN_MASTER_AP5 = $TRUE 

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

if ( $RUN_MASTER_AP5 == $TRUE ) then
  setenv STATUS 1
  set count = 0
  while ( $STATUS != 0 )
        # ssh to run AP5 on aeolus.
        ssh -xn airpact5\@aeolus.wsu.edu "~/AIRHOME/run_ap5_day1/master4all.csh ${SRTYR}${SRTMN}${SRTDT} >& ~/AIRHOME/run_ap5_day1/master4all_${SRTYR}${SRTMN}${SRTDT}.log & "
        if ( $status == 0 ) then
           echo "*** success on ssh in AP5_ssh_aeolus.csh on aeolus ***"
           setenv STATUS 0
#          02/09/21 JKV added mail & text message
           set users = 'jvaughan@wsu.edu 5093369756@txt.att.net v.walden@wsu.edu'
           echo "Status on $0 is 0" | mail -s "$0 DAY1 status is 0" $users
           echo Status on mail call is $status
        endif
        set count = `expr $count + 1`
        echo "ssh to aeolus for AP5 Iteration: $count STATUS: $STATUS"
  end
endif

exit(0)
