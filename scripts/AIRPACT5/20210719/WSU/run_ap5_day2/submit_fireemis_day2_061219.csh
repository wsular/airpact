#!/bin/csh -f

#
#  usage examples:
#   
#       ./submit_fireemis_day2.csh 
#       ./submit_fireemis_day2.csh <firstday in YYYYMMDD>
#       ./submit_fireemis_day2.csh <firstday in YYYYMMDD> <runid2waiton>
# 
#    If no input argument is provivded, the script will get the system
#    date (in GMT).  If an input argument(s) is (are) provided, it is 
#    assumed that the first argument is simulation date in YYYYMMDD 
#    format.  The second argument is optional; it is the job id number
#    of the job that needs to be finished before the run(s) here can 
#    start.
#

  if ( ! $?basedir  )  set basedir  = ~airpact5/AIRHOME/run_ap5_day2
  cd $basedir

# switches -------------------------------------------------------------
  set RUN_EMIS_FIRE_ORL = Y

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

# some prerequesites ---------------------------------------------------

  if ( ! $?airroot1 )  set airroot1  = /data/lar/projects/airpact5/AIRRUN
  if ( ! $?airrun1  )  set airrun1   = $airroot1/$firstdayyear
  if ( ! $?airroot  )  set airroot   = /data/lar/projects/airpact5/AIRRUNDAY2
  if ( ! $?airrun   )  set airrun    = $airroot/$seconddayyear
  if ( ! $?mciproot )  set mciproot  = $airrun

  set logdir = $airrun/${secondday}00/LOGS
  if (! -d $logdir ) mkdir -p $logdir

# estimate time required for running the job ---------------------------
  alias MATH 'set \!:1 = `echo "\!:3-$" | bc -l`'
  # estimate the total number of minutes needed for the run;
  # (give a 50-100% buffer)
    @ totalminutes = 0
    if ( $RUN_EMIS_FIRE_ORL == "Y" )  @ totalminutes = $totalminutes + 20
  # convert minutes into HH:MM:SS format
    MATH wallhours   = ( $totalminutes / 60 ) + 1          # hours in decimal, plus 1
    set nwallhours   = `echo $wallhours | cut -d . -f 1`   # integer hours, plus 1
    @ nwallhours = $nwallhours - 1                         # integer hours
    MATH wallminutes = $totalminutes - $nwallhours * 60    # minutes remaining
    if ( $nwallhours < 10 ) then
       set awallhours = 0$nwallhours
    else
       set awallhours = $nwallhours
    endif
    if ( $wallminutes < 10 ) then
       set awallminutes = 0$wallminutes
    else
       set awallminutes = $wallminutes
    endif
    set walltime = ${awallhours}:${awallminutes}:00

# create qsub file -----------------------------------------------------
  set qsubfile = "qsub4fireemis.csh"
  if ( -e input4sed.txt) /bin/rm -f input4sed.txt
  cat > input4sed.txt <<EOF
s+__qsubfile__+${qsubfile}+g
s+__walltime__+${walltime}+g
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
s+__RUN_EMIS_FIRE_ORL__+${RUN_EMIS_FIRE_ORL}+g
EOF

# job submission -------------------------------------------------------
  # create qsub script
    /bin/sed -f input4sed.txt < blueprints/blueprint_qsub_fireemis.txt > $qsubfile
    echo `date` "submitting fireemis for" $secondday
    if ( $?runid0 ) then # if waiting on a job to finish
       echo " queing behind" $runid0
       set qsubreturn = `qsub -V  -W depend=afterok:${runid0}  $qsubfile`
       unsetenv runid0
    else
       set qsubreturn = `qsub -V  $qsubfile`
    endif
    echo qsubreturn $qsubreturn
    setenv runid_fireemis  `echo $qsubreturn | cut -d "." -f 1`
    echo "   runid_fireemis:" $runid_fireemis
exit(0)
