#!/bin/csh -fX

#  2020-07-20   J K Vaughan added a sleep here to delay the master4all script by 30 minutes, to avert problems with
#		day2 cctm starting before day1 cctm.
#  2020-07-29   Changed sleep to 3600
#  2020-08-02   Changed sleep to 5400
#sleep 5400

#  2020-04-27   J K Vaughan added code to delay submit of cctm job until the CURRENTJOBID file exists.
#  		The CURRENTJOBID.txt file is created by day1 run_cctm scripting and deleted by day1 precctm scripting.
#  		Thus, existance of the CURRENTJOBID.txt file means that it is safe to submit the day2 run_cctm job and
#  		ensured it will not  be queued ahead of the day1 cctm job.
#  	
# NOTE: The code controlled by RUN_PLOT_BCON was added here by JKV 050117.
# NOTE: This new BCON plotting should be added instead to the code controlled by
#       RUN_PLOT_NONCCTM code deeper in the calling tree, logically.
#
# #
#  usage examples:
#	new_master4all_day2.csh    
#       ./master4all_day2.csh 
#       ./master4all_day2.csh <firstday in yyyymmdd>
#       ./master4all_day2.csh <firstday in yyyymmdd> <runid2waiton>

# N.B.  firstday means the date used calling master4all_day2.csh is the first of the two dates in a two day run.
# N.B.  this master4all_day2.csh script is called from rainier, from here:
# /home/disk/rainier_empact/airpact5/AIRHOME/RUN 
# AP5_DAY2_ssh_aeolus.csh:  \
# ssh -xn airpact5\@aeolus.wsu.edu "/home/airpact5/AIRHOME/run_ap5_day2/master4all_day2.csh ${SRTYR}${SRTMN}${SRTDT}"
#
#    If no input argument is provivded, the script will get the system
#    date (in GMT).  If an input argument(s) is (are) provided, it is 
#    assumed that the first argument is simulation date in YYYYMMDD 
#    format.  The second argument is optional; it is the job id number
#    of the job that needs to be finished before the run(s) here can 
#    start.
#

# ----------------------------------------------------------------------


  source ~airpact5/.tcshrc              # needed when running from crontab
                                             # crontab starts in bash
  setenv basedir  ~airpact5/AIRHOME/run_ap5_day2
  cd $basedir

  rm -f qsub4*csh

#    source set_AIRPACT_fire_season.csh #JKV 091317
# switchess ------------------------------------------------------------
  # all switches should be "Y" for daily operation
    set RUN_PRECCTM         = Y # JPROC, BCON, and anthropogenic emission
    set RUN_MEGAN_PARALLEL  = Y # added 2016-04-30
    set RUN_EMIS_FIRE_ORL   = Y # added 2016-04-30
    set RUN_EMIS_MERGE      = Y # added 2016-04-30
    set RUN_PLOT_NONCCTM    = Y
    set RUN_CCTM            = Y
    set RUN_POSTCCTM        = Y
    set RUN_PLOT_CCTM       = Y
    set RUN_CLEANUP         = Y

# get date info --------------------------------------------------------

  if ( $#argv == 1 || $#argv == 2) then
     set firstday = $1
     set thisyear  = `echo $firstday | cut -c1-4`
     set thismonth = `echo $firstday | cut -c5-6`
     set today     = `echo $firstday | cut -c7-8`
     if ( $#argv == 2 ) setenv runid0 $2
  else # if no command-line input, use system time in GMT
     set today     = `perl -e 'printf "%d\n", (gmtime(time()))[3]'` #today local time 
     set thismonth = `perl -e 'printf "%d\n", (gmtime(time()))[4]+1'`#format month (January = 0)
     set thisyear  = `perl -e 'printf "%d\n", (gmtime(time()))[5]+1900'`#format year
     if ( $thismonth < 10 ) set thismonth = 0${thismonth}
     if ( $today < 10 ) set today = 0${today}
     set firstday = ${thisyear}${thismonth}${today}
  endif
  set secondday = `date -d "$firstday 1 days" '+%Y%m%d'`
  set seconddayyear  = `echo $secondday | cut -c1-4`
  set seconddaymonth = `echo $secondday | cut -c5-6`
  set tomorrow     = `echo $secondday | cut -c7-8`

# Delay submission if necessary
# If it is already the date of the requested run, run immediately.
  echo Date of firstday run requested is $firstday 
  set nowday = `date +%Y%m%d`
  set tomorrow = `date +%Y%m%d --date="tomorrow"`
  echo It is now date of $nowday
  echo Tomorrow is $tomorrow
  if ( $firstday == $nowday ) then
	echo RUN DAY2 NOW
  else if ( $firstday == $tomorrow) then # wait until after 23:59 PM
     set STARTTIME = 2359 # for 23:59
     echo DELAYED STARTTIME specified as HHMM is $STARTTIME
     set now = `date | cut -c 12-16 | tr -d ':' | sed 's/^0//'` # for time without colon.
     echo It is now $now as HHMM
     echo Delay until STARTTIME $STARTTIME 
     while (  ${now} <  ${STARTTIME} )
         sleep 20
         echo check date-time
         date
         set now = `date | cut -c 12-16 | tr -d ':' | sed 's/^0//' | sed 's/^0//'` # for time without colon.
         echo Now is $now as HHMM
     end
     echo delay done so RUN NOW DAY2
  else if ( $firstday < $nowday ) then
     echo RUN earlier date of $firstday NOW DAY2
  else 
     echo Seems to be a wrong date and will probably die, could kill it here with exit
  endif

# some prerequesites ---------------------------------------------------

  setenv airrootday1  /data/lar/projects/airpact5/AIRRUN
  setenv airrootday2  /data/lar/projects/airpact5/AIRRUNDAY2
  setenv airrun   $airrootday2/$thisyear                   # output location 
  if ( ! -d $airrun/DONE ) mkdir $airrun/DONE
  setenv mciproot /data/lar/projects/airpact5/AIRRUNDAY2/$thisyear      # path to find MCIP files
  setenv bconroot /data/lar/projects/airpact5/AIRRUNDAY2/$thisyear      # path to find MOZART-4 files for BCON

# run scripts to submit jobs -------------------------------------------
  #
  # the order of running (if all components are to be run) is
  #
  #   PRECCTM (jproc, bcon, anthro emis) |            | CCTM         | POSTCCTM | PLOT_CCTM | 
  #                                      | EMIS_MERGE |                                     | CLEANUP
  #   MEGAN_PARALLEL | EMIS_FIRE_ORL     |            | PLOT_NONCCTM                        |
  #
  #   1) 
  #          a) MEGAN_PARALLEL 
  #          b) PRECCTM
  #      a and b run simultaneously
  #   2) EMIS_FIRE_ORL 
  #        runs after MEGAN_PARALLEL is done
  #        will be running when 1b is still running
  #   3) EMIS_MERGE 
  #        runs after PRECCTM and EMIS_FIRE_ORL are both done
  #   4)
  #          a) PLOT_NONCCTM
  #          b) CCTM
  #      after EMIS_MERGE is done
  #   5) POSTCCTM
  #      after CCTM is done
  #   6) PLOT_CCTM
  #      after POSTCCTM is done
  #   7) CLEANUP
  #      after PLOT_CCTM is done
  #

  # 1a) run the script that will submit the parallel MEGAN job
    if ( $RUN_MEGAN_PARALLEL == "Y" ) then
    echo ' '
    echo = = = = = = = = = = RUN_MEGAN_PARALLEL = = = = = = = = =
       echo `date` "run script that submits parallel MEGAN job job"
       if ( $?runid0 ) then
          set runid0_saved = $runid0
          source $basedir/submit_megan_parallel_day2.csh $firstday $runid0 >&! $basedir/submit_megan_parallel_day2.log 
          setenv runid0 $runid0_saved
       else
          source $basedir/submit_megan_parallel_day2.csh $firstday >&! $basedir/submit_megan_parallel_day2.log 
       endif
	echo $0 sees runid_megan: $runid_megan
	qstat -f $runid_megan | grep afterok
     endif

  # 1b) run the script that will submit the pre-CCTM job
    if ( $RUN_PRECCTM == "Y" ) then
    echo ' '
    echo = = = = = = = = = = RUN_PRECCTM = = = = = = = = =
       echo `date` "run script that submits pre-cctm job"
       if ( $?runid0 ) then
          source $basedir/submit_precctm_day2.csh $firstday $runid0 >&! $basedir/submit_precctm_day2.log
          unsetenv runid0
       else
          source $basedir/submit_precctm_day2.csh $firstday >&! $basedir/submit_precctm_day2.log
       endif
	echo $0 sees runid_precctm: $runid_precctm
	qstat -f $runid_precctm | grep afterok
    endif


  # 2) run the script that will submit the fire emission processing job
    if ( $RUN_EMIS_FIRE_ORL == "Y" ) then
    echo ' '
    echo = = = = = = = = = = RUN_EMIS_FIRE_ORL = = = = = = = = =
       echo `date` "run script that submits the fire emission processing job job"
       if ( $?runid_megan  ) then
          source $basedir/submit_fireemis_day2.csh $firstday $runid_megan >&! $basedir/submit_fireemis_day2.log 
       else if ( $?runid0 ) then
          source $basedir/submit_fireemis_day2.csh $firstday $runid0 >&! $basedir/submit_fireemis_day2.log 
          unsetenv runid0
       else
          source $basedir/submit_fireemis_day2.csh $firstday >&! $basedir/submit_fireemis_day2.log 
       endif
	echo $0 sees runid_fireemis: $runid_fireemis
	qstat -f $runid_fireemis | grep afterok
    endif

#111018JKV   # 3) run the script that will submit the mrgemis job
#111018JKV     if ( $RUN_EMIS_MERGE == "Y" ) then
#111018JKV     echo ' '
#111018JKV     echo = = = = = = = = = = RUN_EMIS_MERGE = = = = = = = = =
#111018JKV #  Since emissions merging depends on completion of as many as three prior qsubmitted jobs, 
#111018JKV #  there are eight possible combinations to treat (labeled as octal 0-7), plus a ninth option,
#111018JKV #  label it X, for the possible runid0 passed as an argument to master4all_day2.csh.
#111018JKV #
#111018JKV #   PRECCTM     FIREEMIS    MEGAN      Base2 = Octal
#111018JKV #      1           1          1		111 = 7
#111018JKV #      1           1          0         110 = 6
#111018JKV #      1           0          1         101 = 5
#111018JKV #      1           0          0         100 = 4
#111018JKV #      0           1          1         011 = 3
#111018JKV #      0           1          0         010 = 2
#111018JKV #      0           0          1         001 = 1
#111018JKV #      0           0          0         000 = 0
#111018JKV # Plus one for the runid0 if it is passed in:    X
#111018JKV #
#111018JKV        echo `date` "run script that submits mrgemis job"
#111018JKV        if ( $?runid_precctm && $?runid_fireemis && $?runid_megan ) then
#111018JKV 	  #  Octal 7
#111018JKV           echo  (7) jobs running: runid_precctm: $runid_precctm  runid_fireemis: $runid_fireemis runid_megan: $runid_megan 
#111018JKV           source $basedir/submit_mrgemis_day2.csh $firstday $runid_precctm $runid_fireemis $runid_megan >&! $basedir/submit_mrgemis.log
#111018JKV 
#111018JKV        else if ( $?runid_precctm && $?runid_fireemis             ) then
#111018JKV 	  # Octal 6
#111018JKV           echo (6) jobs running: runid_precctm: $runid_precctm  runid_fireemis: $runid_fireemis
#111018JKV           source $basedir/submit_mrgemis_day2.csh $firstday $runid_precctm $runid_fireemis >&! $basedir/submit_mrgemis.log
#111018JKV 
#111018JKV        else if ( $?runid_precctm &&                     $?runid_megan ) then
#111018JKV 	  # Octal 5
#111018JKV           echo (5) jobs running: runid_precctm: $runid_precctm  runid_megan: $runid_megan
#111018JKV 	  source $basedir/submit_mrgemis_day2.csh $firstday $runid_precctm $runid_megan >&! $basedir/submit_mrgemis.log
#111018JKV 
#111018JKV        else if ( $?runid_precctm                                      ) then
#111018JKV 	  # Octal 4
#111018JKV           echo (4) jobs running: runid_precctm: $runid_precctm 
#111018JKV           source $basedir/submit_mrgemis_day2.csh $firstday $runid_precctm >&! $basedir/submit_mrgemis.log
#111018JKV 
#111018JKV        else if (                    $?runid_fireemis && $?runid_megan ) then
#111018JKV 	  # Octal 3
#111018JKV           echo (3) jobs running: runid_megan: $runid_megan  runid_fireemis: $runid_fireemis
#111018JKV           source $basedir/submit_mrgemis_day2.csh $firstday $runid_megan $runid_fireemis >&! $basedir/submit_mrgemis.log
#111018JKV 
#111018JKV        else if (                    $?runid_fireemis                  ) then
#111018JKV 	  # Octal 2
#111018JKV           echo (2) jobs running: runid_fireemis: $runid_fireemis
#111018JKV           source $basedir/submit_mrgemis_day2.csh $firstday $runid_fireemis >&! $basedir/submit_mrgemis.log
#111018JKV 
#111018JKV        else if (                                        $?runid_megan ) then
#111018JKV 	  # Octal 1
#111018JKV           echo (1) jobs running: runid_megan: $runid_megan
#111018JKV           source $basedir/submit_mrgemis_day2.csh $firstday $runid_megan >&! $basedir/submit_mrgemis.log
#111018JKV 
#111018JKV        else if ( $?runid0 ) then
#111018JKV 	  #  X
#111018JKV           echo (X) jobs running: runid0: $runid0
#111018JKV           source $basedir/submit_mrgemis_day2.csh $firstday $runid0 >&! $basedir/submit_mrgemis.log
#111018JKV           unsetenv runid0
#111018JKV 
#111018JKV        else
#111018JKV 	  # Octal 0
#111018JKV           echo (0) jobs running: none
#111018JKV           source $basedir/submit_mrgemis_day2.csh $firstday >&! $basedir/submit_mrgemis.log
#111018JKV 
#111018JKV        endif
#111018JKV        echo $0 sees runid_mrgemis: $runid_mrgemis
#111018JKV        qstat -f $runid_mrgemis | grep afterok
#111018JKV     endif

# 3) run the script that will submit the mrgemis job
    if ( $RUN_EMIS_MERGE == "Y" ) echo RUN_EMIS_MERGE is still set
    if ( $RUN_EMIS_MERGE == "Y" ) then
    echo ' '
    echo = = = = = = = = = = RUN_EMIS_MERGE = = = = = = = = =
#  Since emissions merging depends on completion of as many as three prior qsubmitted jobs, 
#  there are eight possible combinations to treat (labeled as octal 0-7), plus a ninth option,
#  label it X, for the possible runid0 passed as an argument to master4all_day2.csh.
#
#   PRECCTM     FIREEMIS    MEGAN      Base2 = Octal
#      1           1          1		111 = 7
#      1           1          0         110 = 6
#      1           0          1         101 = 5
#      1           0          0         100 = 4
#      0           1          1         011 = 3
#      0           1          0         010 = 2
#      0           0          1         001 = 1
#      0           0          0         000 = 0
#    Plus one for the runid0 if it is passed in:    X
#
##       calculate an octal value for PRECCTM, FIREEMIS and MEGAN jobids being defined.
       set octval = 0
       if ( $?runid_precctm ) @ octval = $octval + 4
       if ( $?runid_fireemis ) @ octval = $octval + 2
       if ( $?runid_megan  ) @ octval = $octval + 1

       echo Octal value for PRECCTM, FIREEMIS and MEGAN jobids is $octval

       echo `date` "run script that submits mrgemis job"
#       if ( $?runid_precctm && $?runid_fireemis && $?runid_megan ) then
       if ( ${octval} == 7 ) then
	  #  Octal 7
          echo  jobs running: runid_precctm: $runid_precctm  runid_fireemis: $runid_fireemis runid_megan: $runid_megan 
          source $basedir/submit_mrgemis_day2.csh $firstday $runid_precctm $runid_fireemis $runid_megan >&! $basedir/submit_mrgemis.log

#       else if ( $?runid_precctm && $?runid_fireemis             ) then
       else if ( $octval == 6 ) then
	  # Octal 6
          echo  jobs running: runid_precctm: $runid_precctm  runid_fireemis: $runid_fireemis
          source $basedir/submit_mrgemis_day2.csh $firstday $runid_precctm $runid_fireemis >&! $basedir/submit_mrgemis.log

#       else if ( $?runid_precctm &&                     $?runid_megan ) then
       else if ( $octval == 5 ) then
	  # Octal 5
          echo  jobs running: runid_precctm: $runid_precctm  runid_megan: $runid_megan
	  source $basedir/submit_mrgemis_day2.csh $firstday $runid_precctm $runid_megan >&! $basedir/submit_mrgemis.log

#       else if ( $?runid_precctm                                      ) then
       else if ( $octval == 4 ) then
	  # Octal 4
          echo  jobs running: runid_precctm: $runid_precctm 
          source $basedir/submit_mrgemis_day2.csh $firstday $runid_precctm >&! $basedir/submit_mrgemis.log

#       else if (                    $?runid_fireemis && $?runid_megan ) then
       else if ( $octval == 3 ) then
	  # Octal 3
          echo  jobs running: runid_megan: $runid_megan  runid_fireemis: $runid_fireemis
          source $basedir/submit_mrgemis_day2.csh $firstday $runid_megan $runid_fireemis >&! $basedir/submit_mrgemis.log

#       else if (                    $?runid_fireemis                  ) then
       else if ( $octval == 2 ) then
	  # Octal 2
          echo  jobs running: runid_fireemis: $runid_fireemis
          source $basedir/submit_mrgemis_day2.csh $firstday $runid_fireemis >&! $basedir/submit_mrgemis.log

#       else if (                                        $?runid_megan ) then
       else if ( $octval == 1 ) then
	  # Octal 1
          echo  jobs running: runid_megan: $runid_megan
          source $basedir/submit_mrgemis_day2.csh $firstday $runid_megan >&! $basedir/submit_mrgemis.log

       else if ( $?runid0 ) then
	  #  X
          echo  jobs running: runid0: $runid0
          source $basedir/submit_mrgemis_day2.csh $firstday $runid0 >&! $basedir/submit_mrgemis.log
          unsetenv runid0

       else
	  # Octal 0
          echo  jobs running: none
          source $basedir/submit_mrgemis_day2.csh $firstday >&! $basedir/submit_mrgemis.log

       endif
       echo $0 sees runid_mrgemis: $runid_mrgemis
       qstat -f $runid_mrgemis | grep afterok
    endif
  
  
  # 4a) run the script that will submit the plot_noncctm job
    if ( $RUN_PLOT_NONCCTM == "Y" ) then
    echo ' '
    echo = = = = = = = = = = RUN_PLOT_NONCCTM = = = = = = = =
       echo `date` "run script that submits plot_noncctm job"
       if ( $?runid_mrgemis ) then
          source $basedir/submit_plot_noncctm_day2.csh $firstday $runid_mrgemis >&! $basedir/submit_plot_noncctm_day2.log
       else if ( $?runid0 ) then
          source $basedir/submit_plot_noncctm_day2.csh $firstday $runid0 >&! $basedir/submit_plot_noncctm_day2.log
       else
          source $basedir/submit_plot_noncctm_day2.csh $firstday >&! $basedir/submit_plot_noncctm_day2.log
       endif
    endif
  
  # 4b) run the script that will submit the CCTM job
    if ( $RUN_CCTM == "Y" ) then
# Wait on existance of the CURRENTJOBID.txt file to submit day2 cctm job.  JKV  2020-04-27
# The day1 run_cctm script writes JOBID for DAY1 4-km AIRPACT CMAQ run to ~/AIRHOME/run_ap5_day1/CURRENTJOBID.txt.
# This scripting (next) waits to find that file before submitting DAY2 CMAQ.
# The DAY1 precctm scripting deletes the CURRENTJOBID.txt file.

     if ( ! -e ~/AIRHOME/run_ap5_day1/CURRENTJOBID.txt) then
         echo  "~/AIRHOME/run_ap5_day1/CURRENTJOBID.txt is not found, so wait for it"
	 set loop_cnt = 0
	 while ( ! -e ~/AIRHOME/run_ap5_day1/CURRENTJOBID.txt )
         	echo "Waiting to detect CURRENTJOBID file to know DAY1 CCTM is enqueued"
         	set loop_cnt = `expr ${loop_cnt} + 1`
         	echo Loop Count is ${loop_cnt}
	 	if ( ${loop_cnt} == 16 ) then
			echo Four-hour Loop Ending With No CURRENTJOBID.txt file being found, Exiting
			exit(1)
	 	endif
         	sleep 900
	 end
     else
	  echo  "~/AIRHOME/run_ap5_day1/CURRENTJOBID.txt was found, so submit DAY2 CMAQ"
     endif

  # 4a.1) if there is a day1 CCTM jobcctm_day1_jobid.txt file, 
  #  and if it is currently running, use it to make CCTM wait. 
    if ( -f ~/AIRHOME/run_ap5_day1/cctm_day1_jobid.txt ) then
    echo = = = = = = = = = = CHECK ON DAY1 JOBID  and RUN STATUS = = = = = = = = =
       set runid_day1_cctm = `cat ~/AIRHOME/run_ap5_day1/cctm_day1_jobid.txt `
       echo check for run for runid_day1_cctm = $runid_day1_cctm
       qstat $runid_day1_cctm 
       qstat $runid_day1_cctm | grep -e " R \| Q "  
       if ( $status == 0 ) then
	   echo OK job $runid_day1_cctm is running or queued, so wait on it.
       else
	   echo NO job $runid_day1_cctm running or queued.  Do not wait on it.
	   unset runid_day1_cctm
       endif
    endif
  
    echo = = = = = = = = = = RUN_CCTM = = = = = = = =
       echo `date` "run script that submits cctm job"
       if ( $?runid_day1_cctm && $?runid_mrgemis ) then
	  source $basedir/submit_cctm_day2.csh $firstday $runid_day1_cctm $runid_mrgemis >&! $basedir/submit_cctm_day2.log
       else if ( $?runid_day1_cctm ) then
          source $basedir/submit_cctm_day2.csh $firstday $runid_day1_cctm >&! $basedir/submit_cctm_day2.log
       else if ( $?runid_mrgemis ) then
          source $basedir/submit_cctm_day2.csh $firstday $runid_mrgemis >&! $basedir/submit_cctm_day2.log
       else if ( $?runid0 ) then
          source $basedir/submit_cctm_day2.csh $firstday $runid0 >&! $basedir/submit_cctm_day2.log
          unsetenv runid0
       else
          source $basedir/submit_cctm_day2.csh $firstday >&! $basedir/submit_cctm_day2.log
       endif
    endif
#    if ( $RUN_CCTM == "Y" ) then
#       echo `date` "run script that submits cctm job"
#       if ( $?runid_mrgemis ) then
#          source $basedir/submit_cctm_day2.csh $firstday $runid_mrgemis
#       else if ( $?runid0 ) then
#          source $basedir/submit_cctm_day2.csh $firstday $runid0
#          unsetenv runid0
#       else
#          source $basedir/submit_cctm_day2.csh $firstday
#       endif
#    endif

 
  # 5) run the script that will submit the post-CCTM job
    if ( $RUN_POSTCCTM == "Y" ) then
    echo = = = = = = = = = = RUN_POSTCCTM = = = = = = = =

       if ( -e ~/AIRHOME/run_ap5_day1/POSTCCTM_JobID.txt ) then
           echo read old txt file for DAY1 POSTCCTM Job ID.
           set POSTCCTM_DAY1_JobID = `cat ~/AIRHOME/run_ap5_day1/POSTCCTM_JobID.txt`
           echo $POSTCCTM_DAY1_JobID | wc -c
   	   echo POSTCCTM_DAY1_JobID $POSTCCTM_DAY1_JobID
   	   rm -f ~/AIRHOME/run_ap5_day1/POSTCCTM_JobID.txt
       endif

       echo `date` "run script that submits post-cctm job"
       if ( $?runid_cctm && $?POSTCCTM_DAY1_JobID ) then
          source $basedir/submit_postcctm_day2.csh $firstday $runid_cctm $POSTCCTM_DAY1_JobID >&! $basedir/submit_postcctm_day2.log
       else if ( $?runid_cctm ) then
          source $basedir/submit_postcctm_day2.csh $firstday $runid_cctm >&! $basedir/submit_postcctm_day2.log
       else if ( $?POSTCCTM_DAY1_JobID ) then
          source $basedir/submit_postcctm_day2.csh $firstday $POSTCCTM_DAY1_JobID >&! $basedir/submit_postcctm_day2.log
       else if ( $?runid0 ) then
          source $basedir/submit_postcctm_day2.csh $firstday $runid0 >&! $basedir/submit_postcctm_day2.log
          unsetenv runid0
       else
          source $basedir/submit_postcctm_day2.csh $firstday >&! $basedir/submit_postcctm_day2.log
       endif
    endif

  # 6) run the script that will submit the plot_cctm job
    if ( $RUN_PLOT_CCTM == "Y" ) then
    echo = = = = = = = = = = RUN_PLOT_CCTM = = = = = = = =
       echo `date` "run script that submits plot_cctm job"
       if ( $?runid_postcctm ) then
          source $basedir/submit_plot_cctm_day2.csh $firstday $runid_postcctm >&! $basedir/submit_plot_cctm_day2.log
       else if ( $?runid0 ) then
          source $basedir/submit_plot_cctm_day2.csh $firstday $runid0 >&! $basedir/submit_plot_cctm_day2.log
          unsetenv runid0
       else
          source $basedir/submit_plot_cctm_day2.csh $firstday  >&! $basedir/submit_plot_cctm_day2.log
       endif
    endif

  # 7) run the script that will submit the job to cleanup CCTM, BCON,
  #    JPROC and EMISSION output files
    if ( $RUN_CLEANUP == "Y" ) then
    echo = = = = = = = = = = RUN_CLEANUP = = = = = = = =
       echo `date` "run script that submits the job to cleanup CCTM output"
       if ( $?runid_plot_cctm && $?runid_plot_noncctm ) then
          source $basedir/submit_cleanup_day2.csh $firstday $runid_plot_cctm $runid_plot_noncctm  >&! $basedir/submit_cleanup_day2.log
       else if ( $?runid_plot_cctm ) then
          source $basedir/submit_cleanup_day2.csh $firstday $runid_plot_cctm >&! $basedir/submit_cleanup_day2.log
       else if ( $?runid_plot_noncctm ) then
          source $basedir/submit_cleanup_day2.csh $firstday $runid_plot_noncctm >&! $basedir/submit_cleanup_day2.log
       else if ( $?runid0 ) then
          source $basedir/submit_cleanup_day2.csh $firstday $runid0 >&! $basedir/submit_cleanup_day2.log
          unsetenv runid0
       else
          source $basedir/submit_cleanup_day2.csh $firstday >&! $basedir/submit_cleanup_day2.log
       endif
    endif
echo End $0 for $1 

    qstat -fu airpact5 >&! ~/AIRHOME/run_ap5_day2/qstatus_${$}.log

exit(0)
