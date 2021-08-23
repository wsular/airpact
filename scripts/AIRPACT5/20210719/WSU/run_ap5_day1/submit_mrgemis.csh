#!/bin/csh -f

#
#  usage examples:
#   
#       ./submit_mrgemis.csh 
#       ./submit_mrgemis.csh 20151123
#       ./submit_mrgemis.csh 20160507 331547
#       ./submit_mrgemis.csh 20151123  76543 12345
#       ./submit_mrgemis.csh 20151123  76543 12345 87675
# 
#    If no input argument is provivded, the script will get the system
#    date (in GMT).  If an input argument(s) is (are) provided, it is
#    assumed that the first argument is simulation date in YYYYMMDD
#    format.  The second and third and 4th arguments are optional; they are
#    the job id number(s) of the job(s) that needs to be finished
#    before the run(s) here can start.
#

  if ( ! $?basedir  )  set basedir  = ~airpact5/AIRHOME/run_ap5_day1
  cd $basedir

# get date info --------------------------------------------------------

  if ( $#argv >= 1 ) then
     set currentday = $1
     set thisyear  = `echo $currentday | cut -c1-4`
     set thismonth = `echo $currentday | cut -c5-6`
     set today     = `echo $currentday | cut -c7-8`
     if ( $#argv > 1  ) setenv runid0 $2
     if ( $#argv > 2 ) setenv runid1 $3
     if ( $#argv == 4 ) setenv runid2 $4
  else # if no command-line input, use system time
     set today     = `perl -e 'printf "%d\n", (gmtime(time()))[3]'` #today local time 
     set thismonth = `perl -e 'printf "%d\n", (gmtime(time()))[4]+1'`#format month (January = 0)
     set thisyear  = `perl -e 'printf "%d\n", (gmtime(time()))[5]+1900'`#format year
     if ( $thismonth < 10 ) set thismonth = 0${thismonth}
     if ( $today < 10 ) set today = 0${today}
     set currentday = ${thisyear}${thismonth}${today}
  endif

# some prerequesites ---------------------------------------------------

  if ( ! $?airroot  )  set airroot  = /data/lar/projects/airpact5/AIRRUN
  if ( ! $?airrun   )  set airrun   = $airroot/$thisyear
  if ( ! $?mciproot )  set mciproot = /data/lar/projects/airpact5/AIRRUN/$thisyear
  if ( ! $?bconroot )  set bconroot = /data/lar/projects/airpact5/AIRRUN/$thisyear
  set logdir = $airrun/${currentday}00/LOGS
  if (! -d $logdir ) mkdir -p $logdir
 #if ( -e $logdir/summary.txt )  /bin/rm -f $logdir/summary.txt
 #if ( -e $logdir/errorlog.txt ) /bin/rm -f $logdir/errorlog.txt

    set walltime = 02:45:00 # 2016-09-26 long wall time because of sleep statements
# create qsub file -----------------------------------------------------
  set qsubfile = "qsub4mrgemis.csh"
  if ( -e input4sed.txt) /bin/rm -f input4sed.txt
  cat > input4sed.txt <<EOF
s+__qsubfile__+${qsubfile}+g
s+__walltime__+${walltime}+g
s+__basedir__+${basedir}+g
s+__airrun__+${airrun}+g
s+__airroot__+${airroot}+g
s+__mciproot__+${mciproot}+g
s+__bconroot__+${bconroot}+g
s+__logdir__+${logdir}+g
s+__YYYYMMDD__+${currentday}+g
s+__YEAR__+${thisyear}+g
s+__MONTH__+${thismonth}+g
s+__DAY__+${today}+g
EOF

# job submission -------------------------------------------------------
  # create qsub script
    /bin/sed -f input4sed.txt < blueprints/blueprint_qsub_mrgemis.txt > $qsubfile
    echo `date` "submitting mrgemis for" $currentday
    if ( $?runid0 && $?runid1 && $?runid2 ) then # if waiting on three jobs to finish
       echo " queing behind" $runid0 "and" $runid1 "and" $runid2
       set qsubreturn = `qsub -V  -W depend=afterok:${runid0}:${runid1}:${runid2}  $qsubfile`
       unsetenv runid0
       unsetenv runid1
       unsetenv runid2
    else if ( $?runid0 && $?runid1 ) then # if waiting on two jobs to finish
	echo " queing behind" $runid0 "and" $runid1 
	set qsubreturn = `qsub -V  -W depend=afterok:${runid0}:${runid1} $qsubfile`
	unsetenv runid0
        unsetenv runid1
    else if ( $?runid0 ) then # if waiting on one job to finish
       echo " queing behind" $runid0
       set qsubreturn = `qsub -V  -W depend=afterok:${runid0}  $qsubfile`
       unsetenv runid0
    else
       set qsubreturn = `qsub -V  $qsubfile`
    endif
    setenv runid_mrgemis  `echo $qsubreturn | cut -d "." -f 1`
    echo "   runid_mrgemis:" $runid_mrgemis
