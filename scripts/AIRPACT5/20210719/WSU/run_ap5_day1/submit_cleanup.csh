#!/bin/csh -f

#
#  usage examples:
#   
#       ./submit_cleanup.csh 
#       ./submit_cleanup.csh 20151206
#       ./submit_cleanup.csh 20151206  76543
#       ./submit_cleanup.csh 20151206  76543 12334
# 
#    If no input argument is provivded, the script will get the system
#    date (in GMT).  If an input argument(s) is (are) provided, it is
#    assumed that the first argument is simulation date in YYYYMMDD
#    format.  The second and third arguments are optional; they are
#    the job id numbers of the jobs that need to be finished before
#    the run(s) here can start.
#

  if ( ! $?basedir  )  set basedir  = ~airpact5/AIRHOME/run_ap5_day1
  cd $basedir

# switches -------------------------------------------------------------

# get date info --------------------------------------------------------

  if ( $#argv >= 1 ) then
     set currentday = $1
     set thisyear  = `echo $currentday | cut -c1-4`
     set thismonth = `echo $currentday | cut -c5-6`
     set today     = `echo $currentday | cut -c7-8`
     if ( $#argv > 1 ) setenv runid0 $2
     if ( $#argv > 2 ) setenv runid1 $3
  else # if no command-line input, use system time
     set today     = `perl -e 'printf "%d\n", (gmtime(time()))[3]'` #today local time 
     set thismonth = `perl -e 'printf "%d\n", (gmtime(time()))[4]+1'`#format month (January = 0)
     set thisyear  = `perl -e 'printf "%d\n", (gmtime(time()))[5]+1900'`#format year
     if ( $thismonth < 10 ) set thismonth = 0${thismonth}
     if ( $today < 10 ) set today = 0${today}
     set currentday = ${thisyear}${thismonth}${today}
  endif

# some prerequesites
  if ( ! $?airroot  )  set airroot  = /data/lar/projects/airpact5/AIRRUN
  if ( ! $?airrun   )  set airrun   = $airroot/$thisyear
  if ( ! $?mciproot )  set mciproot = /data/lar/projects/airpact5/AIRRUN/$thisyear 
  if ( ! $?bconroot )  set bconroot = /data/lar/projects/airpact5/AIRRUN/$thisyear
  if ( ! $?airsave )   set airsave  = /data/lar/projects/airpact5/saved/$thisyear
  set logdir = $airrun/${currentday}00/LOGS
  set walltime = 00:30:00

# create qsub file -----------------------------------------------------
  set qsubfile = "qsub4cleanup.csh"
  cat > input4sed.txt <<EOF
s+__qsubfile__+${qsubfile}+g
s+__walltime__+${walltime}+g
s+__basedir__+${basedir}+g
s+__airrun__+${airrun}+g
s+__mciproot__+${mciproot}+g
s+__logdir__+${logdir}+g
s+__airsave__+${airsave}+g
s+__YYYYMMDD__+${currentday}+g
s+__YEAR__+${thisyear}+g
s+__MONTH__+${thismonth}+g
s+__DAY__+${today}+g
EOF

# job submission -------------------------------------------------------
  # create qsub script
    /bin/sed -f input4sed.txt < blueprints/blueprint_qsub_cleanup.txt > $qsubfile
  echo `date` "submitting cleanup process for" $currentday
  if ( $?runid0 && $?runid1 ) then # if waiting on 2 jobs to finish
     echo " queing behind" $runid0 "and" $runid1
     set qsubreturn = `qsub -V  -W depend=afterok:${runid0}:${runid1}  $qsubfile`
     unsetenv runid0
     unsetenv runid1
  else if ( $?runid0 ) then # if waiting on a job to finish
     echo " queing behind" $runid0
     set qsubreturn = `qsub -V  -W depend=afterok:${runid0}  $qsubfile`
     unsetenv runid0
  else if ( $?runid1 ) then # if waiting on a job to finish
     echo " queing behind" $runid1
     set qsubreturn = `qsub -V  -W depend=afterok:${runid1}  $qsubfile`
     unsetenv runid1
  else
     set qsubreturn = `qsub -V  $qsubfile`
  endif
  setenv runid_cleanup  `echo $qsubreturn | cut -d "." -f 1`
  echo "   runid_cleanup:" $runid_cleanup
