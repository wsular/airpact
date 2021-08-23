#!/bin/csh -f

# example of using this script:
# 
#   > ./run_plot_cctm.csh 20120101 24
#
#  Joe Vaughan  2017-08-24  Version updated to also call for plot of one 24-hr PM2.5 map for IDEQ, and
#                      to call for preparation of ftp script for cron to run. 
#
#  Serena H. Chung 2011-10-10
#  Joseph K. Vaughan 2016-02-02  added AQI color plotting
# 
#  Description:
#

#  Precondition(s):
#
#     setenv AIRHOME
#     setenv AIROUT
#     setenv AIRLOGDIR
#

#> during testing only --------------------------------------------------

  if ( ! $?PBS_O_WORKDIR ) then
    set RUN_PLOT_HOURLY   = Y
    set RUN_PLOT_08HRO3   = Y
    set RUN_PLOT_24HRPM25 = Y
    set RUN_PLOT_24HRPM25_IDEQ = N
    set RUN_PLOT_AOD      = Y
    set RUN_PLOT_CURTAIN  = Y
    set RUN_PLOT_VIS	  = Y
    set RUN_PLOT_AQI_PM   = Y
    set RUN_PLOT_AQI_O3   = Y
  endif

#> initialize exit status ----------------------------------------------
   set exitstat = 0

#> check argument & set date strings  ----------------------------------

   if ( $1 > 20000100 ) then     
      set YEAR  = `echo $1 | cut -c1-4`
      set MONTH = `echo $1 | cut -c5-6`
      set DAY   = `echo $1 | cut -c7-8`
     #set HOUR = `echo $1 | cut -c9-10`
      set currentday = $YEAR$MONTH$DAY
   else
      echo 'invalid argument. '
      echo "usage $0 <yyyymmdd> <nhr>"
      set exitstat = 1
      exit ( $exitstat )
   endif

#> determine day of the year
     set DOYstring = `juldate $MONTH $DAY $YEAR | cut -d',' -f 2`
     set DOY       = `echo $DOYstring | cut -c5-7`
     set YEARDOY   = $YEAR$DOY

#> during testing 

   if ( ! $?PBS_O_WORKDIR ) then
      set PBS_O_WORKDIR = ~airpact5/AIRHOME/run_ap5_day2
      if ( ! $?AIRHOME        ) set AIRHOME = ~airpact5/AIRHOME
      if ( ! $?AIRRUN ) then
         set AIRRUN  = /data/lar/projects/airpact5/AIRRUNDAY2/$YEAR
      endif
      if ( ! $?AIROUT         ) set AIROUT = $AIRRUN/${currentday}00
      if ( ! $?AIRLOGDIR      ) set AIRLOGDIR = $AIROUT/LOGS
      if ( ! $?MCIPDIR        ) then
         if ( -e $AIROUT/MCIP37/METCRO2D ) then
            set MCIPDIR   = $AIROUT/MCIP37
         else
            set MCIPDIR   = /data/airpact4/AIRRUNDAY2/${currentday}00/MCIP37
         endif
      endif
      set NHR = $2
   endif

#> plotting ------------------------------------------------------------

   mkdir -p $AIRLOGDIR/plot/cctm
   if ( $RUN_PLOT_HOURLY == "Y" ) then
      $PBS_O_WORKDIR/plot/run_ncl_hourly.csh   $1 $2 >&! $AIRLOGDIR/plot/cctm/log01_plot_ncl_hourly.txt
   endif

   if ( $RUN_PLOT_08HRO3 == "Y" ) then
      $PBS_O_WORKDIR/plot/run_ncl_08hrO3.csh   $1 $2 >&! $AIRLOGDIR/plot/cctm/log02_plot_ncl_08hrO3.txt
   endif

   if ( $RUN_PLOT_24HRPM25 == "Y" ) then
      $PBS_O_WORKDIR/plot/run_ncl_24hrPM25.csh $1 $2 >&! $AIRLOGDIR/plot/cctm/log03_plot_ncl_24hrPM25.txt
   endif

   if ( $RUN_PLOT_24HRPM25_IDEQ == "Y" ) then
       rm -fv $PBS_O_WORKDIR/logs4crontab/DAY2_cronjob4ftp_to_IDEQ.log
       $PBS_O_WORKDIR/plot/run_ncl_24hrPM25_forIDEQ.csh $1 >&! $AIRLOGDIR/plot/cctm/log03.1_plot_ncl_24hrPM25_forIDEQ.txt
       $PBS_O_WORKDIR/submit_ftp_to_IDEQ.csh $1 >&! $AIRLOGDIR/plot/cctm/log03.2_submit_ftp_to_IDEQ.txt
   endif

   if ( $RUN_PLOT_CURTAIN == "Y" ) then
      $PBS_O_WORKDIR/plot/run_ncl_S-N-curtain_at_icol.csh $1 159 >&! $AIRLOGDIR/plot/cctm/S-N-curtain_at_icol.txt
      $PBS_O_WORKDIR/plot/run_ncl_S-N-pm25-curtain_at_icol.csh $1 159 >&! $AIRLOGDIR/plot/cctm/S-N-pm25-curtain_at_icol.txt
      $PBS_O_WORKDIR/plot/run_ncl_W-E-curtain_at_irow.csh $1 156 >&! $AIRLOGDIR/plot/cctm/W-E-curtain_at_irow.txt
      $PBS_O_WORKDIR/plot/run_ncl_W-E-pm25-curtain_at_irow.csh $1 156 >&! $AIRLOGDIR/plot/cctm/W-E-pm25-curtain_at_irow.txt
   endif

   if ( $RUN_PLOT_VIS == "Y" ) then
      $PBS_O_WORKDIR/plot/run_ncl_visibility.csh $1 $2 >&! $AIRLOGDIR/plot/cctm/log05_plot_ncl_visibility.txt
   endif

   if ( $RUN_PLOT_AQI_PM == "Y" ) then
      $PBS_O_WORKDIR/plot/run_ncl_AQIcolors_24hrPM25.csh $1 $2 >&! $AIRLOGDIR/plot/cctm/log06_plot_ncl_AQIcolors_24hrPM25.txt
   endif

   if ( $RUN_PLOT_AQI_O3 == "Y" ) then
      $PBS_O_WORKDIR/plot/run_ncl_AQIcolors_08hrO3.csh $1 $2 >&! $AIRLOGDIR/plot/cctm/log07_plot_ncl_AQIcolors_08hrO3.txt
   endif

   if ( $RUN_PLOT_AOD == "Y" ) then
      $PBS_O_WORKDIR/plot/run_ncl_aod.csh $1 $2 >&! $AIRLOGDIR/plot/cctm/log08_plot_ncl_aod.txt
   endif

   echo ' finished in run_plot_cctm.csh' 
