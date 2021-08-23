#!/bin/csh -f

# example of using this script:
# 
#   > ./run_plot_cctm.csh 20120101 24
#
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
    set RUN_PLOT_HOURLY   = N
    set RUN_PLOT_08HRO3   = N
    set RUN_PLOT_24HRPM25 = N
    set RUN_PLOT_AOD      = N # not yet for airpact5
    set RUN_PLOT_CURTAIN  = N
    set RUN_PLOT_VIS	  = N
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
      set PBS_O_WORKDIR = ~airpact5/AIRHOME/run_ap5_day1
      if ( ! $?AIRHOME        ) set AIRHOME = ~airpact5/AIRHOME
      if ( ! $?AIRRUN ) then
         set AIRRUN  = /data/lar/projects/airpact5/AIRRUN/$YEAR
      endif
      if ( ! $?AIROUT         ) set AIROUT = $AIRRUN/${currentday}00
      if ( ! $?AIRLOGDIR      ) set AIRLOGDIR = $AIROUT/LOGS
      if ( ! $?MCIPDIR        ) then
         if ( -e $AIROUT/MCIP/METCRO2D ) then
            set MCIPDIR   = $AIROUT/MCIP
         else
            set MCIPDIR   = /data/lar/projects/airpact5/AIRRUN/${currentday}00/MCIP
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

   if ( $RUN_PLOT_CURTAIN == "Y" ) then
      $PBS_O_WORKDIR/plot/run_ncl_west_curtains.csh $1 $2 >&! $AIRLOGDIR/plot/cctm/log04_plot_ncl_curtain.txt
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

   echo ' finished in run_plot_cctm_AQI.csh' 
