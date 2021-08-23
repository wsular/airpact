#!/bin/csh -f

#
#  usage examples:
#   
#       ./submit_ftp_to_IDEQ.csh 
#       ./submit_ftp_to_IDEQ.csh 20151123
#    Although called submit_ftp_to_IDEQ.csh this script actually PREPARES the script needed for a cron job.
#    While most submit scripots are called by master scripts in ~/AIRHOME/run_ap5_day1 or equivalent,
#    this submit script is called from plot/run_plot_cctm.csh.  Joe Vaughan, August 2017
#    If an input argument(s) is (are) provided, it is assumed that the
#    first argument is simulation date in YYYYMMDD format; otherwise, 
#    the script will get the system date. 
#

  if ( ! $?basedir  )  set basedir  = ~airpact5/AIRHOME/run_ap5_day1
  cd $basedir

# switches -------------------------------------------------------------
#  no switches

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
  endif

# get peviousday date for name of desired 24-hr PM2.5 gif file for IDEQ in MST.
	set previousday = `date -d "$currentday -1 days" '+%Y%m%d'`

# some prerequesites
  if ( ! $?airroot  )  set airroot  = /data/lar/projects/airpact5/AIRRUN
  if ( ! $?airrun   )  set airrun   = $airroot/$thisyear
  if ( ! $?runplot  )  set runplot  = $basedir/plot/ftp_to_IDEQ
  if ( ! $?logdir   )  set logdir = $airrun/${currentday}00/LOGS
  set cronfile = "cronjob4ftp_to_IDEQ.csh"

# create cron file -----------------------------------------------------
  cat > input4sed.txt <<EOF
s+__runplot__+${runplot}+g
s+__cronfile__+${cronfile}+g
s+__YYYYMMDD__+${currentday}+g
s+__YYYYMMDDm1__+${previousday}+g
s+__AIRRUN__+${airrun}+g

EOF

# job submission -------------------------------------------------------
  # create cron script
  echo `date` "preparing ftp_to_IDEQ for" $currentday
    /bin/sed -f input4sed.txt < blueprints/blueprint_cron_ftp_to_IDEQ.txt > $runplot/$cronfile
    chmod 740 $runplot/$cronfile
  echo cronjob file is $runplot/$cronfile

exit(0)
