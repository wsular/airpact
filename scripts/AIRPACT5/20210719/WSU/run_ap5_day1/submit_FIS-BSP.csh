#!/usr/bin/env csh

#
#  usage examples:
#   
#       ./submit_FIS-BSP.csh
#       ./submit_FIS-BSP.csh 20200713
#       ./submit_FIS-BSP.csh 20200713 JOBID 
# 
#    If no input argument is provivded, the script will get the system
#    date (in GMT).  If an input argument(s) is (are) provided, it is 
#    assumed that the first argument is simulation date in YYYYMMDD 
#    format.  The second argument is optional; it is the job id number
#    of the job that needs to be finished before the run(s) here can 
#    start.
#

  if ( ! $?basedir  )  set basedir  = ~airpact5/AIRHOME/run_ap5_day1
  cd $basedir

# get date info --------------------------------------------------------

  if ( $#argv == 1 || $#argv == 2) then
     set currentday = $1
     set thisyear  = `echo $currentday | cut -c1-4`
     set thismonth = `echo $currentday | cut -c5-6`
     set today     = `echo $currentday | cut -c7-8`
     if ( $#argv == 2 ) setenv runid0 $2
  else # if no command-line input, use system time
     set today     = `perl -e 'printf "%d\n", (gmtime(time()))[3]'` #today local time 
     set thismonth = `perl -e 'printf "%d\n", (gmtime(time()))[4]+1'`#format month (January = 0)
     set thisyear  = `perl -e 'printf "%d\n", (gmtime(time()))[5]+1900'`#format year
     if ( $thismonth < 10 ) set thismonth = 0${thismonth}
     if ( $today < 10 ) set today = 0${today}
     set currentday = ${thisyear}${thismonth}${today}
     echo currentday set to $currentday
  endif

# some prerequesites ---------------------------------------------------

  if ( ! $?AIRPACT5 )  set AIRPACT5 = ~airpact5
  if ( ! $?airpact5 )  set airpact5 = $AIRPACT5
  if ( ! $?airhome  )  set airhome  = $AIRPACT5/AIRHOME
  if ( ! $?airroot  )  set airroot  = /data/lar/projects/airpact5/AIRRUN
  if ( ! $?airrun   )  set airrun   = $airroot/$thisyear
  if ( ! $?airrootday2 )  set airrootday2  = /data/lar/projects/airpact5/AIRRUNDAY2
  if ( ! $?mciproot )  set mciproot = /data/lar/projects/airpact5/AIRRUN/$thisyear
  if ( ! $?bconroot )  set bconroot = /data/lar/projects/airpact5/AIRRUN/$thisyear
  set logdir = $airrun/${currentday}00/LOGS
  if (! -d $logdir ) mkdir -p $logdir

  setenv FIS_IMAGE_DIR  /fastscratch/jvaughan/singularity

  set walltime = 00:30:00

# create qsub file -----------------------------------------------------
  set qsubfile = "qsub4FIS-BSP.csh"
  if ( -e input4sed.txt) /bin/rm -f input4sed.txt
  cat > input4sed.txt <<EOF
s+__qsubfile__+${qsubfile}+g
s+__airhome__+${airhome}+g
s+__airpact5__+${airpact5}+g
s+__walltime__+${walltime}+g
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

#  
# job submission -------------------------------------------------------
  # create qsub script
    /bin/sed -f input4sed.txt < blueprints/blueprint_qsub4_FIS-BSP.txt > $qsubfile
    echo `date` "submitting fire emission for" $currentday
    if ( $?runid0 ) then # if waiting on a job to finish
       echo " queing behind" $runid0
       set qsubreturn = `qsub -V  -W depend=afterok:${runid0} $qsubfile`
       unsetenv runid0
    else
       set qsubreturn = `qsub -V $qsubfile`
    endif
    setenv runid_FIS_BSP   `echo $qsubreturn | cut -d "." -f 1`
    echo "   runid_FIS_BSP :" $runid_FIS_BSP 

exit

