#!/bin/csh -fX

#
#  usage examples:
#   
#       ./submit_plot_cctm_day2.csh 
#       ./submit_plot_cctm_day2.csh <firstday in YYYYMMDD> <runid2waiton>
#       ./submit_plot_cctm_day2.csh <firstday in YYYYMMDD> <runid2waiton>
# 
#    If an input argument(s) is (are) provided, it is assumed that the
#    first argument is simulation date in YYYYMMDD format; otherwise, 
#    the script will get the system date. The second argument is also 
#    optional; it is the job id number of the job that needs to be 
#    finished before the CCTM job can start.
#

  if ( ! $?basedir  )  set basedir  = ~airpact5/AIRHOME/run_ap5_day2
  cd $basedir

# switches -------------------------------------------------------------
  set RUN_PLOT_HOURLY   = Y
  set RUN_PLOT_08HRO3   = Y
  set RUN_PLOT_24HRPM25 = Y
  set RUN_PLOT_24HRPM25_IDEQ = Y
  set RUN_PLOT_CURTAIN  = Y
  set RUN_PLOT_VIS	= Y
  set RUN_PLOT_AQI_PM	= Y # added 2016-02-10
  set RUN_PLOT_AQI_O3	= Y # added 2016-02-10
  set RUN_PLOT_AOD      = Y # implemented 2016-05-05

# get date info --------------------------------------------------------

  if ( $#argv >= 1 ) then
     set firstday = $1
     set firstdayyear  = `echo $firstday | cut -c1-4`
     set firstdaymonth = `echo $firstday | cut -c5-6`
     set today     = `echo $firstday | cut -c7-8`
     if ( $#argv == 2 ) setenv runid0 $2
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
  if ( ! $?airroot1 )  set airroot1  = /data/lar/projects/airpact5/AIRRUNDAY2
  if ( ! $?airrun1  )  set airrun1   = $airroot1/$firstdayyear
  if ( ! $?airroot  )  set airroot   = /data/lar/projects/airpact5/AIRRUNDAY2
  if ( ! $?airrun   )  set airrun    = $airroot/$seconddayyear
  if ( ! $?mciproot )  set mciproot  = $airrun
  set logdir = $airrun/${secondday}00/LOGS
  set walltime = 01:00:00

# create qsub file -----------------------------------------------------
  set qsubfile = "qsub4plot_cctm.csh"
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
s+__RUN_PLOT_HOURLY__+${RUN_PLOT_HOURLY}+g
s+__RUN_PLOT_08HRO3__+${RUN_PLOT_08HRO3}+g
s+__RUN_PLOT_24HRPM25__+${RUN_PLOT_24HRPM25}+g
s+__RUN_PLOT_24HRPM25_IDEQ__+${RUN_PLOT_24HRPM25_IDEQ}+g
s+__RUN_PLOT_CURTAIN__+${RUN_PLOT_CURTAIN}+g
s+__RUN_PLOT_VIS__+${RUN_PLOT_VIS}+g
s+__RUN_PLOT_AQI_PM__+${RUN_PLOT_AQI_PM}+g
s+__RUN_PLOT_AQI_O3__+${RUN_PLOT_AQI_O3}+g
s+__RUN_PLOT_AOD__+${RUN_PLOT_AOD}+g
EOF

# job submission -------------------------------------------------------
  # create qsub script
    /bin/sed -f input4sed.txt < blueprints/blueprint_qsub_plot_cctm.txt > $qsubfile
  echo `date` "submitting plot_cctm for" $secondday
  if ( $?runid0 ) then # if waiting on a job to finish
     echo " queing behind" $runid0
#     set qsubreturn = `qsub -V  -W depend=afterok:${runid0}  $qsubfile`
     set qsubreturn = `qsub -V  -W depend=afterany:${runid0}  $qsubfile`
     unsetenv runid0
  else
     set qsubreturn = `qsub -V  $qsubfile`
  endif
  setenv runid_plot_cctm  `echo $qsubreturn | cut -d "." -f 1`
  echo "   runid_plot_cctm:" $runid_plot_cctm
