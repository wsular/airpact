#!/bin/csh -f

#
#  usage examples:
#   
#       ./submit_precctm_bcon-WACCM.csh 20151123 
#       ./submit_precctm_bcon-WACCM.csh 20151123  76543
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

# switches -------------------------------------------------------------
  set RUN_ICON_ideal    = N
  set RUN_FIX_MCIP      = Y
  set RUN_BCON          = Y
  set RUN_JPROC         = Y
  set RUN_EMIS_ANTHRO   = Y

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

# some prerequesites ---------------------------------------------------

  if ( ! $?airroot  )  set airroot  = /data/lar/projects/airpact5/AIRRUN
  if ( ! $?airrun   )  set airrun   = $airroot/$thisyear
  if ( ! $?mciproot )  set mciproot = /data/lar/projects/airpact5/AIRRUN/$thisyear
  if ( ! $?bconroot )  set bconroot = /data/lar/projects/airpact5/AIRRUN/$thisyear
  set logdir = $airrun/${currentday}00/LOGS
  if (! -d $logdir ) mkdir -p $logdir
 #if ( -e $logdir/summary.txt )  /bin/rm -f $logdir/summary.txt
 #if ( -e $logdir/errorlog.txt ) /bin/rm -f $logdir/errorlog.txt

# estimate time required for running the job ---------------------------
  alias MATH 'set \!:1 = `echo "\!:3-$" | bc -l`'
  # estimate the total number of minutes needed for the run;
  # (give a 50-100% buffer)
    @ totalminutes = 0
    if ( $RUN_BCON == "Y" )           @ totalminutes = $totalminutes + 10
    if ( $RUN_FIX_MCIP  == "Y" )      @ totalminutes = $totalminutes + 5 
    if ( $RUN_ICON_ideal == "Y" )     @ totalminutes = $totalminutes + 3
    if ( $RUN_JPROC == "Y" )          @ totalminutes = $totalminutes + 6
    if ( $RUN_EMIS_ANTHRO == "Y" )    @ totalminutes = $totalminutes + 120
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
  set qsubfile = "qsub4precctm.csh"
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
s+__RUN_BCON__+${RUN_BCON}+g
s+__RUN_FIX_MCIP__+${RUN_FIX_MCIP}+g
s+__RUN_ICON_ideal__+${RUN_ICON_ideal}+g        
s+__RUN_JPROC__+${RUN_JPROC}+g         
s+__RUN_EMIS_ANTHRO__+${RUN_EMIS_ANTHRO}+g   
EOF

# job submission -------------------------------------------------------
  # create qsub script
    /bin/sed -f input4sed.txt < blueprints/blueprint_qsub_precctm_WACCM-bcon_FixMCIP5.1.txt > $qsubfile
    echo `date` "submitting pre-cctm for" $currentday
    if ( $?runid0 ) then # if waiting on a job to finish
       echo " queing behind" $runid0
       set qsubreturn = `qsub -V  -W depend=afterok:${runid0}  $qsubfile`
       unsetenv runid0
    else
       set qsubreturn = `qsub -V  $qsubfile`
    endif
    setenv runid_precctm  `echo $qsubreturn | cut -d "." -f 1`
    echo "   runid_precctm:" $runid_precctm
