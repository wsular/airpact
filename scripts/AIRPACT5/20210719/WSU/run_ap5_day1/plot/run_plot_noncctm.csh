#!/bin/csh -f

# Example of using this script:
# 
#   > run_plot_noncctm.csh 20151220 24
#
#
#  Serena H. Chung 2011-10-10
# 
#  Description:
#

#  Precondition(s):
#
#     setenv AIRHOME
#     setenv AIROUT
#     setenv AIRLOGDIR
#

#> initialize exit status ----------------------------------------------
   set exitstat = 0

#> check argument & set date strings  ----------------------------------

  if ( $1 > 20000100 ) then     
     set YEAR = `echo $1 | cut -c1-4`
     set MONTH = `echo $1 | cut -c5-6`
     set DAY = `echo $1 | cut -c7-8`
     set SRTHR = `echo $1 | cut -c9-10`
     set YMD = $YEAR$MONTH$DAY
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
      set RUN_PLOT_MET      = Y
      set RUN_PLOT_EMIS     = Y
   endif

#> plotting ------------------------------------------------------------

   mkdir -p $AIRLOGDIR/plot/noncctm
   if ( $RUN_PLOT_MET == "Y" ) then
      $PBS_O_WORKDIR/plot/run_ncl_met.csh   $1 $2 >&! $AIRLOGDIR/plot/noncctm/log01_plot_ncl_met.txt
   endif
   if ( $RUN_PLOT_WIND == "Y" ) then
      $PBS_O_WORKDIR/plot/run_ncl_wind_hourly.csh   $1 $2 >&! $AIRLOGDIR/plot/noncctm/log02_plot_ncl_wind.txt
   endif
   if ( $RUN_PLOT_EMIS == "Y" ) then
      $PBS_O_WORKDIR/plot/run_ncl_emis.csh    $1 $2 >&! $AIRLOGDIR/plot/noncctm/log03_plot_ncl_emis.txt
   endif


   echo ' finished in run_plot_noncctm.csh'
