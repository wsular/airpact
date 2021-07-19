#!/bin/csh -f

#
#  usage examples:
#   
#       ./master4all.csh 
#       ./master4all,csh 20151123
#       ./master4all,csh 20160323 319664
# 
#    If no input argument is provivded, the script will get the system
#    date (in GMT).  If an input argument(s) is (are) provided, it is 
#    assumed that the first argument is simulation date in YYYYMMDD 
#    format.  The second argument is optional; it is the job id number
#    of the job that needs to be finished before the run(s) here can 
#    start.
#    This script delays starting until 10:30
#    Fire processing is submitted by submit_fireemis.csh, and is set to start at 23:45 (11:45 PM).. 

# ----------------------------------------------------------------------


  source ~airpact5/.tcshrc              # needed when running from crontab
                                             # crontab starts in bash
  setenv basedir  ~airpact5/AIRHOME/run_ap5_day1
  cd $basedir

  rm -f qsub4*csh

# delete any old txt file for DAY1 POSTCCTM Job ID. JKV 011420
  if ( -e $basedir/POSTCCTM_JobID.txt ) then
	echo remove old txt file for DAY1 POSTCCTM Job ID.
	rm -f $basedir/POSTCCTM_JobID.txt
  endif

# obsolete   source set_AIRPACT_fire_season.csh #JKV 091317
# switchess ------------------------------------------------------------
  # all switches should be "Y" for daily operation
    set RUN_PRECCTM         = Y # JPROC, BCON, and anthropogenic emission
    set RUN_MEGAN_PARALLEL  = Y # added 2016-04-30
    set RUN_FIS_BSP_FIRES   = Y # added 2020-09-03
    set RUN_EMIS_FIRE_ORL   = Y # added 2016-04-30
    set RUN_EMIS_MERGE      = Y # added 2016-04-30
    set RUN_PLOT_BCON       = Y
    set RUN_PLOT_NONCCTM    = Y
    set RUN_CCTM            = Y
    set RUN_POSTCCTM        = Y
    set RUN_PLOT_CCTM       = Y
    set RUN_CLEANUP         = Y

# get date info --------------------------------------------------------

  if ( $#argv == 1 || $#argv == 2) then
     set currentday = $1
     set thisyear  = `echo $currentday | cut -c1-4`
     set thismonth = `echo $currentday | cut -c5-6`
     set today     = `echo $currentday | cut -c7-8`
     if ( $#argv == 2 ) setenv runid0 $2
#    It is assumed that if a jobid is passed as argument $2 then it will be applied to one or more of 
#       these first three processes: PRECCTM, FIS_BSP and MEGAN_PARALLEL.  JKV 090420
  else # if no command-line input, use system time in GMT
     set today     = `perl -e 'printf "%d\n", (gmtime(time()))[3]'` #today local time 
     set thismonth = `perl -e 'printf "%d\n", (gmtime(time()))[4]+1'`#format month (January = 0)
     set thisyear  = `perl -e 'printf "%d\n", (gmtime(time()))[5]+1900'`#format year
     if ( $thismonth < 10 ) set thismonth = 0${thismonth}
     if ( $today < 10 ) set today = 0${today}
     set currentday = ${thisyear}${thismonth}${today}
  endif

# Delay submission if necessary
  echo Date of run requested is $currentday 
  set nowday = `date +%Y%m%d`
  set tomorrow = `date +%Y%m%d --date="tomorrow"`
  echo It is now date of $nowday
  echo Tomorrow is $tomorrow
  if ( $currentday == $nowday ) then # It is already the date of the requested run, run immediately.
	echo RUN NOW
  else if ( $currentday == $tomorrow) then # wait until after 10:30 PM
     set STARTTIME = 2230 # for 22:30 
     echo DELAYED STARTTIME specified as HHMM is $STARTTIME
     set now = `date | cut -c 12-16 | tr -d ':' | sed 's/^0//'` # for time without colon.
     echo It is now $now as HHMM
     echo Delay until STARTTIME $STARTTIME 
     while (  ${now} <  ${STARTTIME} )
         sleep 20
         echo check date-time
         date
         set now = `date | cut -c 12-16 | tr -d ':' | sed 's/^0//'` # for time without colon.
         echo Now is $now as HHMM
     end
     echo delay done
  else if ( $currentday < $nowday ) then
     echo RUN earlier date of $currentday
  else 
     echo Seems to be a wrong date and bound to fail.
     echo We could kill it here with exit.
  endif

# some prerequesites ---------------------------------------------------

  setenv airroot      /data/lar/projects/airpact5/AIRRUN
  setenv airrootday2  /data/lar/projects/airpact5/AIRRUNDAY2
  setenv airrun   $airroot/$thisyear                   # output location 
  if ( ! -d $airrun/DONE ) mkdir $airrun/DONE
  setenv mciproot /data/lar/projects/airpact5/AIRRUN/$thisyear      # path to find MCIP files
  setenv bconroot /data/lar/projects/airpact5/AIRRUN/$thisyear      # path to find MOZART-4(?) files for BCON
  setenv airsave  /data/lar/projects/airpact5/saved/$thisyear

# run scripts to submit jobs -------------------------------------------
  #Modified 09/03/20 by JKV for inclusion of FIS_BSP
  # the order of running (if all components are to be run) is
  #
  #   PRECCTM (jproc, bcon, anthro emis) |            | CCTM         | POSTCCTM | PLOT_CCTM | 
  #   FIS_BSP        | EMIS_FIRE_ORL     | EMIS_MERGE |                                     | CLEANUP
  #   MEGAN_PARALLEL                     |            | PLOT_NONCCTM                        |
  #
  #   1) (It is assumed that if a jobid is passed as argument #2 then it will be applied to one or more of 
  #       these first three processes: PRECCTM, FIS_BSP and MEGAN_PARALLEL.  JKV 090420)
  #          a) PRECCTM
  #          b) FIS_BSP 
  #          c) MEGAN_PARALLEL 
  #      a and b and c start together (run simultaneously)
  #   2) EMIS_FIRE_ORL 
  #        runs after FIS_BSP is done
  #        and could run while 1c, MEGAN_PARALLAL is still running
  #   3) EMIS_MERGE 
  #        runs after PRECCTM and EMIS_FIRE_ORL and MEGAN_PARALLEL are all three done
  #   4)
  #          a) PLOT_NONCCTM
  #          b) CCTM
  #      after EMIS_MERGE is done
  #   5) POSTCCTM
  #      after CCTM is done
  #   6) PLOT_CCTM
  #      fater POSTCCTM is done
  #   7) CLEANUP
  #      after PLOT_CCTM is done
  #

  # 1a) run the script that will submit the pre-CCTM job
    if ( $RUN_PRECCTM == "Y" ) then
       echo `date` "run script that submits pre-cctm job"
       if ( $?runid0 ) then
          set runid0_saved = $runid0
          source $basedir/submit_precctm_WACCM-bcon-py3.csh $currentday $runid0
#          source $basedir/submit_precctm_WACCM-bcon.csh $currentday $runid0
          setenv runid0 $runid0_saved
       else
          source $basedir/submit_precctm_WACCM-bcon-py3.csh $currentday
#          source $basedir/submit_precctm_WACCM-bcon.csh $currentday
       endif
       echo runid_precctm is $runid_precctm
    endif

  # 1b) run the script that will submit the FIS_BSP job
    if ( $RUN_FIS_BSP_FIRES == "Y" ) then
       echo `date` "run script that submits FIS_BSP job"
       if ( $?runid0 ) then
          set runid0_saved = $runid0
          source $basedir/submit_FIS-BSP.csh $currentday $runid0
          setenv runid0 $runid0_saved
       else
          source $basedir/submit_FIS-BSP.csh $currentday
       endif
       echo runid_FIS_BSP is $runid_FIS_BSP 
    endif

  # 1c) run the script that will submit the parallel MEGAN job
    if ( $RUN_MEGAN_PARALLEL == "Y" ) then
       echo `date` "run script that submits parallel MEGAN job"
       if ( $?runid0 ) then
          set runid0_saved = $runid0
          source $basedir/submit_megan_parallel.csh $currentday $runid0
          setenv runid0 $runid0_saved
       else
          source $basedir/submit_megan_parallel.csh $currentday
       endif
       echo runid_megan is $runid_megan
     endif

# any dependencies on runid0 that were desired for the run are now satisfied.
    if ( $?runid0 ) then
       unsetenv runid0
    endif

  # 2) run the script that will submit the fire emission processing job
    if ( $RUN_EMIS_FIRE_ORL == "Y" ) then
       echo `date` "run script that submits the fire emission processing job job"
       if ( $?runid_FIS_BSP ) then
          source $basedir/submit_fireemis.csh $currentday $runid_FIS_BSP
       else
          source $basedir/submit_fireemis.csh $currentday
       endif
     endif

  # 3) run the script that will submit the mrgemis job
    if ( $RUN_EMIS_MERGE == "Y" ) then
       echo `date` "run script that submits mrgemis job"
       if ( $?runid_precctm && $?runid_fireemis && $?runid_megan ) then # wait on all three jobs
          source $basedir/submit_mrgemis.csh $currentday $runid_precctm $runid_fireemis $runid_megan 
       else if ( $?runid_precctm && $?runid_fireemis ) then # first of three for wait on two jobs
          source $basedir/submit_mrgemis.csh $currentday $runid_precctm $runid_fireemis
       else if ( $?runid_precctm && $?runid_megan ) then  # second of three for two
          source $basedir/submit_mrgemis.csh $currentday $runid_precctm $runid_megan 
       else if ( $?runid_fireemis && $?runid_megan ) then # third of three for two
          source $basedir/submit_mrgemis.csh $currentday $runid_fireemis $runid_megan 
       else if ( $?runid_precctm ) then			# first of three for wait on one job 
          source $basedir/submit_mrgemis.csh $currentday $runid_precctm
       else if ( $?runid_fireemis ) then		# second of three for wait on one job
          source $basedir/submit_mrgemis.csh $currentday $runid_fireemis
       else if ( $?runid_megan ) then			# third of three for wait on one job
          source $basedir/submit_mrgemis.csh $currentday $runid_megan 
       else
          source $basedir/submit_mrgemis.csh $currentday # wait on no jobs
       endif
    endif

  # 4) run the script that will submit the plot_bcon job
    if ( $RUN_PLOT_BCON == "Y" ) then
       echo `date` "run script that submits plot WACCM-bcon job"
       if ( $?runid_precctm ) then
          source $basedir/submit_plot_WACCM-bcon.csh $currentday $runid_precctm
       else
          source $basedir/submit_plot_WACCM-bcon.csh $currentday
       endif
    endif

  # 4a) run the script that will submit the plot_noncctm job
    if ( $RUN_PLOT_NONCCTM == "Y" ) then
       echo `date` "run script that submits plot_noncctm job"
       if ( $?runid_mrgemis ) then
          source $basedir/submit_plot_noncctm.csh $currentday $runid_mrgemis
       else
          source $basedir/submit_plot_noncctm.csh $currentday
       endif
    endif

  # 4b) run the script that will submit the CCTM job
    if ( $RUN_CCTM == "Y" ) then
       echo `date` "run script that submits cctm job"
       if ( $?runid_mrgemis ) then
          source $basedir/submit_cctm.csh $currentday $runid_mrgemis
       else
          source $basedir/submit_cctm.csh $currentday
       endif

  # 4c) write the runid_cctm value to ~/AIRHOME/run_ap5_day1/cctm_day1_jobid.txt
    if ( -f ~/AIRHOME/run_ap5_day1/cctm_day1_jobid.txt ) rm -f ~/AIRHOME/run_ap5_day1/cctm_day1_jobid.txt
    echo $runid_cctm > ~/AIRHOME/run_ap5_day1/cctm_day1_jobid.txt
    echo CCTM JOBID from ~/AIRHOME/run_ap5_day1/cctm_day1_jobid.txt is $runid_cctm
    endif
 
 
  # 5) run the script that will submit the post-CCTM job
    if ( $RUN_POSTCCTM == "Y" ) then
       echo `date` "run script that submits post-cctm job"
       if ( $?runid_cctm ) then
          source $basedir/submit_postcctm.csh $currentday $runid_cctm
       else
          source $basedir/submit_postcctm.csh $currentday
       endif
#   	write jobid for day1 qsub4postcctm.csh for use submitting day2 qsub4postcctm_day2.csh 
#   	to $basedir/POSTCCTM_JobID.txt
    	echo $runid_postcctm  >&! $basedir/POSTCCTM_JobID.txt
	ls -lt $basedir/POSTCCTM_JobID.txt
    endif

  # 6) run the script that will submit the plot_cctm job
    if ( $RUN_PLOT_CCTM == "Y" ) then
       echo `date` "run script that submits plot_cctm job"
       if ( $?runid_postcctm ) then
          source $basedir/submit_plot_cctm.csh $currentday $runid_postcctm
       else
          source $basedir/submit_plot_cctm.csh $currentday
       endif
    endif

  # 7) run the script that will submit the job to cleanup CCTM, BCON,
  #    JPROC and EMISSION output files
    if ( $RUN_CLEANUP == "Y" ) then
       echo `date` "run script that submits the job to cleanup CCTM output"
       if ( $?runid_plot_cctm && $?runid_plot_noncctm ) then
          source $basedir/submit_cleanup.csh $currentday $runid_plot_cctm $runid_plot_noncctm
       else if ( $?runid_plot_cctm ) then
          source $basedir/submit_cleanup.csh $currentday $runid_plot_cctm
       else if ( $?runid_plot_noncctm ) then
          source $basedir/submit_cleanup.csh $currentday $runid_plot_noncctm
       else
          source $basedir/submit_cleanup.csh $currentday
       endif
    endif


    qstat -fu airpact5 >&! ~/AIRHOME/run_ap5_day1/qstatus_${$}.log

exit(0)
