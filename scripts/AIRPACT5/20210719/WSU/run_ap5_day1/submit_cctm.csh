#!/bin/csh -f 


#
#  usage examples:
#   
#       ./submit_cctm.csh 
#       ./submit_cctm.csh 20151121
#       ./submit_cctm.csh 20151121 1234  1235
# 
#    If no input argument is provivded, the script will get the system
#    date (in GMT).  If an input argument(s) is (are) provided, it is
#    assumed that the first argument is simulation date in YYYYMMDD
#    format.  The second and third arguments are optional; they are
#    the job id number(s) of the job(s) that needs to be finished before
#    the run(s) here can start.
#

  if ( ! $?basedir  )  set basedir  = ~airpact5/AIRHOME/run_ap5_day1
  cd $basedir

# get date info and/or other command line argument ---------------------

  if ( $#argv == 1 || $#argv == 2 || $3argv == 3 ) then
     set currentday = $1
     set thisyear  = `echo $currentday | cut -c1-4`
     set thismonth = `echo $currentday | cut -c5-6`
     set today     = `echo $currentday | cut -c7-8`
     if ( $#argv >  1 ) setenv runid0 $2
     if ( $#argv == 3 ) setenv runid1 $3
  else # if no command-line input, use system time
     set today     = `perl -e 'printf "%d\n", (gmtime(time()))[3]'` #today local time 
     set thismonth = `perl -e 'printf "%d\n", (gmtime(time()))[4]+1'`#format month (January = 0)
     set thisyear  = `perl -e 'printf "%d\n", (gmtime(time()))[5]+1900'`#format year
     if ( $thismonth < 10 ) set thismonth = 0${thismonth}
     if ( $today < 10 ) set today = 0${today}
     set currentday = ${thisyear}${thismonth}${today}
  endif

# some prerequesites
  if ( ! $?airroot     )  set airroot      = /data/lar/projects/airpact5/AIRRUN
  if ( ! $?airrun      )  set airrun       = $airroot/$thisyear
  if ( ! $?airrootday2 )  set airrootday2  = /data/lar/projects/airpact5/AIRRUNDAY2
  if ( ! $?mciproot )  set mciproot = /data/lar/projects/airpact5/AIRRUN/$thisyear
  if ( ! $?bconroot )  set bconroot = /data/lar/projects/airpact5/AIRRUN/$thisyear
  set logdir = $airrun/${currentday}00/LOGS

# create qsub file -----------------------------------------------------
  set qsubfile = "qsub4cctm.csh"
  cat > input4sed.txt <<EOF
s+__qsubfile__+${qsubfile}+g
s+__basedir__+${basedir}+g
s+__airrun__+${airrun}+g
s+__airroot__+${airroot}+g
s+__airrootday2__+${airrootday2}+g
s+__mciproot__+${mciproot}+g
s+__bconroot__+${bconroot}+g
s+__logdir__+${logdir}+g
s+__YYYYMMDD__+${currentday}+g
s+__YEAR__+${thisyear}+g
s+__MONTH__+${thismonth}+g
s+__DAY__+${today}+g
EOF

# check if a job was already in the queue ------------------------------
  set INQUEUE = N
  set tmp1 = `qstat -a | grep airpact5 | grep ap5cctm${currentday} | grep R`
  set nchar = `echo $tmp1 | awk '{print length($0)}'` 
  if ( $nchar > 0 ) then
     set INQUEUE = Y
     set runid1 = `echo $tmp1 | cut -d "." -f 1`
  else
     set tmp1 = `qstat -a | grep airpact5 | grep ap5cctm${currentday} | grep Q`
     set nchar = `echo $tmp1 | awk '{print length($0)}'` 
     if ( $nchar > 0 ) then
        set INQUEUE = Y
        set runid1 = `echo $tmp1 | cut -d "." -f 1`
     endif
  endif
  if ( $INQUEUE == "Y" ) then
     echo " ap5cctm${currentday} is already in the queue with runid" $runid1
     exit(0)
  endif

# job submission -------------------------------------------------------
  # create qsub script
    /bin/sed -f input4sed.txt < blueprints/blueprint_qsub_cctm.txt > $qsubfile
  echo `date` "submitting cctm for" $currentday
  if ( $?runid0 && $?runid1 ) then # if waiting on a job to finish
     echo " queing behind" $runid0 "and" $runid1
     set qsubreturn = `qsub -V  -W depend=afterok:${runid0}:${runid1}  $qsubfile`
     unsetenv runid0
     unsetenv runid1
  else if ( $?runid0 ) then # if waiting on a job to finish
     echo " queing behind" $runid0
     set qsubreturn = `qsub -V  -W depend=afterok:${runid0}  $qsubfile`
     unsetenv runid0
  else
     set qsubreturn = `qsub -V  $qsubfile`
  endif
  setenv runid_cctm  `echo $qsubreturn | cut -d "." -f 1`
  echo "   runid_cctm:" $runid_cctm
