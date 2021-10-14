#!/bin/csh -fX
# AP5_mcip5.1_37_DAY1.csh calls MCIP and rsync for DAY1  JKV 04/06/21 update to rsync use.

#  As of 4/6//21 Updating from scp to rsync, from rainier to Aeolus.
#  As of 2/11/21 our ability to ssh and scp, from rainier to Aeolus, was interupted by WSU's requirement 
#  for use of the globalprotect VPN.  After that VPN turned out to be dificult to set up successfully, 
#  WSU simply placed the rainier system on a 'whitelist'.

echo Running $0 for argument $1
date

set TRUE = 0
set FALSE = 1

setenv RUN_MCIP       $TRUE 
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

# AIRPACT locations
set HOME      = /home/rainier_empact
set AIRRUN    = $HOME/airpact5/AIRRUN5
set AIRHOME   = $HOME/airpact5/AIRHOME 
set DONE      = $HOME/airpact5/AIRHOME/DONE 
set MCIP      = $HOME/airpact5/AIRHOME/mcip 
set AIRDATA   = $AIRHOME/DATA

# set_env.csh sets CASE GridName CoordName TOOLS LOGDIR SDATE EDATE ETIME
#                  ENDYR ENDMN ENDDT NXDATE NXTIME NXNDYR NXNDMN NXNDDT
#
setenv RNLEN 240000
setenv STIME 080000 

source $AIRHOME/RUN/set_env_4km.csh
set exitstat = $status
 if ( $exitstat ) then
    echo "*** Error in set_env.csh ***"
    exit ( $exitstat )
 endif

set RUNROOT = $AIRRUN/$1 
set PRVROOT = $AIRRUN/$PGDATE
setenv RUNROOT $RUNROOT
echo RUNROOT is $RUNROOT 
set LOGDIR = $RUNROOT/LOGS
setenv LOGDIR $LOGDIR 

if ( ${RUN_MCIP} == $TRUE ) then

     mkdir -p $RUNROOT
     mkdir -p $LOGDIR
     echo   LOGDIR is $LOGDIR
     echo "CLEAN OUT $DONE/MCIPDAY1"
     rm -f $DONE/MCIPDAY1 	
     echo Now run MCIP5.1 for AIRPACT-5
     date
     $MCIP/mcip5.1_AP5_37_DAY1.csh $1 >&! ${LOGDIR}/mcip5.1_AP5_37_DAY1.log
     set mcip_status = $status 
     echo Status on mcip5.1_AP5_37_DAY1.csh is $mcip_status
#    02/09/21 JKV added mail & text message
     set users = 'jvaughan@wsu.edu 5093369756@txt.att.net v.walden@wsu.edu '
     echo "Status on mcip5.1_AP5_37_DAY1.csh is $mcip_status" | mail -s "MCIP DAY1 status is $mcip_status" $users
     echo Status on mail call is $status
     echo "mcip5.1_AP5_37_DAY1.csh $mcip_status" >! $DONE/MCIPDAY1 	

endif

if ( ${RUN_RSYNC_AEOLUS} == $TRUE ) then
     echo And now run the rsync to move 4km MCIP results to aeolus. 
     echo Added test on status and conditional ssh and removes.    
     date
     $MCIP/rsync_MCIP5.1_37_DAY1.csh $1 >&! $LOGDIR/rsync_MCIP5.1_37_DAY1.log 
     set rsync_stat = $status
#    02/09/21 JKV added mail & text message
     set users = 'jvaughan@wsu.edu 5093369756@txt.att.net v.walden@wsu.edu '
     echo "Status on rsync_MCIP5.1_37_DAY1.csh is $rsync_stat" | mail -s "RSYNC DAY1 status is $rsync_stat" $users
     echo Status on second mail call is $status

    if ( $rsync_stat == 0 ) then
        echo Good status on rsync_MCIP5.1_37_DAY1.csh so delete previous days MCIP37
        rm -fR $PRVROOT/MCIP37  # modified to remove previous day 032613  JKV
    else
        echo Bad status on rsync_MCIP5.1_37_DAY1.csh
        echo Do not delete the MCIP37 files.
    endif
    date
endif

exit(0)
