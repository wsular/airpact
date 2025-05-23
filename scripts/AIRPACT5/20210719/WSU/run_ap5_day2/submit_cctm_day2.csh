#!/bin/csh -f 


#
#  usage examples:
#   
#       ./submit_cctm_day2.csh 
#       ./submit_cctm_day2.csh <firstday in YYYYMMDD> 
#       ./submit_cctm_day2.csh <firstday in YYYYMMDD> <runid2waiton>
# 
#    If no input argument is provivded, the script will get the system
#    date (in GMT).  If an input argument(s) is (are) provided, it is
#    assumed that the first argument is the first day of the
#    simulation date in YYYYMMDD format.  The second argument is
#    optional; it is the job id number of the job that needs to be
#    finished before the run here can start.
#

  if ( ! $?basedir  )  set basedir  = ~airpact5/AIRHOME/run_ap5_day2
  cd $basedir

# get date info and/or other command line argument ---------------------

  if ( $#argv >= 1 ) then
     set firstday = $1
     set firstdayyear  = `echo $firstday | cut -c1-4`
     set firstdaymonth = `echo $firstday | cut -c5-6`
     set today     = `echo $firstday | cut -c7-8`
     if ( $#argv >= 2 ) setenv runid0 $2
     if ( $#argv == 3 ) setenv runid1 $3
  else # if no command-line input, use system time
     set today     = `perl -e 'printf "%d\n", (gmtime(time()))[3]'` #today local time 
     set firstdaymonth = `perl -e 'printf "%d\n", (gmtime(time()))[4]+1'`#format month (January = 0)
     set firstdayyear  = `perl -e 'printf "%d\n", (gmtime(time()))[5]+1900'`#format year
     if ( $firstdaymonth < 10 ) set firstdaymonth = 0${firstdaymonth}
     if ( $today < 10 ) set today = 0${today}
     set firstday = ${firstdayyear}${firstdaymonth}${today}
  endif
  set secondday = `date -d "$firstday 1 days" '+%Y%m%d'`
  set seconddayyear  = `echo $secondday | cut -c1-4`
  set seconddaymonth = `echo $secondday | cut -c5-6`
  set tomorrow     = `echo $secondday | cut -c7-8`

# some prerequesites
  if ( ! $?airroot1 )  set airroot1  = /data/lar/projects/airpact5/AIRRUN
  if ( ! $?airrun1  )  set airrun1   = $airroot1/$firstdayyear
  if ( ! $?airroot  )  set airroot   = /data/lar/projects/airpact5/AIRRUNDAY2
  if ( ! $?airrun   )  set airrun    = $airroot/$seconddayyear
  if ( ! $?mciproot )  set mciproot = $airrun
  set logdir = $airrun/${secondday}00/LOGS

# create qsub file -----------------------------------------------------
  set qsubfile = "qsub4cctm.csh"
  cat > input4sed.txt <<EOF
s+__qsubfile__+${qsubfile}+g
s+__basedir__+${basedir}+g
s+__airrun1__+${airrun1}+g
s+__airroot1__+${airroot1}+g
s+__airrun__+${airrun}+g
s+__airroot__+${airroot}+g
s+__mciproot__+${mciproot}+g
s+__logdir__+${logdir}+g
s+__pYYYYMMDD__+${firstday}+g
s+__YYYYMMDD__+${secondday}+g
s+__YEAR__+${seconddayyear}+g
s+__MONTH__+${seconddaymonth}+g
s+__DAY__+${tomorrow}+g
EOF

# job submission -------------------------------------------------------
  # first check if day 1 is still running or in the queue, if so, get the job id
    set tmp1 = `qstat -a | grep airpact5 | grep ap5cctm${firstday} | grep 'R\|H\|Q'`
    set nchar = `echo $tmp1 | awk '{print length($0)}'` 
    if ( $nchar > 0 ) then
       set runid1 = `echo $tmp1 | cut -d "." -f 1`
    endif
  # create qsub script
    /bin/sed -f input4sed.txt < blueprints/blueprint_qsub_cctm.txt > $qsubfile
  # submit the job
    echo `date` "submitting cctm for" $secondday
    if ( $?runid0 && $?runid1 ) then # if waiting on 2 jobs to finish
       echo " queuing behind" $runid0 "and" $runid1
       echo qsub -V  -W depend=afterok:${runid0}:${runid1} $qsubfile
       set qsubreturn = `qsub -V  -W depend=afterok:${runid0}:${runid1} $qsubfile`
       unsetenv runid0
       unsetenv runid1
    else if ( $?runid0 ) then # if waiting on a job to finish
       echo " queuing behind" $runid0
       echo  qsub -V  -W depend=afterok:${runid0} $qsubfile
       set qsubreturn = `qsub -V  -W depend=afterok:${runid0} $qsubfile`
       unsetenv runid0
    else
       echo qsub -V  $qsubfile
       set qsubreturn = `qsub -V  $qsubfile`
    endif
    echo qsubreturn $qsubreturn
    setenv runid_cctm  `echo $qsubreturn | cut -d "." -f 1`
    echo "   runid_cctm:" $runid_cctm
exit(0)
