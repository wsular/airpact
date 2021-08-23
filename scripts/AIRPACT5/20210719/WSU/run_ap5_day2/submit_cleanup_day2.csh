#!/bin/csh -f

#
#  usage examples:
#   
#       ./submit_cleanup_day2.csh 
#       ./submit_cleanup_day2.csh 20151206
#       ./submit_cleanup_day2.csh <firstday in YYYYMMDD>
#       ./submit_cleanup_day2.csh <firstday in YYYYMMDD> <runid2waiton1>
#       ./submit_cleanup_day2.csh <firstday in YYYYMMDD> <runid2waiton1> <runid2waiton2>
# 
#    If no input argument is provivded, the script will get the system
#    date (in GMT).  If an input argument(s) is (are) provided, it is
#    assumed that the first argument is simulation date in YYYYMMDD
#    format.  The second and third arguments are optional; they are
#    the job id numbers of the jobs that need to be finished before
#    the run(s) here can start.
#

  if ( ! $?basedir  )  set basedir  = ~airpact5/AIRHOME/run_ap5_day2
  cd $basedir

# switches -------------------------------------------------------------

# get date info --------------------------------------------------------

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
  set walltime = 00:30:00

# create qsub file -----------------------------------------------------
  set qsubfile = "qsub4cleanup.csh"
  cat > input4sed.txt <<EOF
s+__qsubfile__+${qsubfile}+g
s+__walltime__+${walltime}+g
s+__basedir__+${basedir}+g
s+__airrun1__+${airrun1}+g
s+__airrun__+${airrun}+g
s+__mciproot__+${mciproot}+g
s+__logdir__+${logdir}+g
s+__pYYYYMMDD__+${firstday}+g
s+__YYYYMMDD__+${secondday}+g
s+__YEAR__+${seconddayyear}+g
s+__MONTH__+${seconddaymonth}+g
s+__DAY__+${tomorrow}+g
EOF

# job submission -------------------------------------------------------
  # create qsub script
    /bin/sed -f input4sed.txt < blueprints/blueprint_qsub_cleanup.txt > $qsubfile
  echo `date` "submitting post-cctm for" $secondday
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
