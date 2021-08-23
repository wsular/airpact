#!/bin/csh -f
# example of using this script:
# 
#   > ./run_convertTo2D.csh 20160420
#
#
#  Serena H. Chung 2016-04-23
# 
#  Description:
#
#       This script converts merged 3D emission file to no a 2D file
#       that will be used for graph animation.
#
#  Precondition(s):
#
#     setenv AIRHOME
#     setenv AIROUT
#     setenv AIRLOGDIR
#
  setenv IOAPI_LOG_WRITE FALSE


#> check argument ------------------------------------------------------

if ( $1 > 20000100 ) then     
     set SRTYR = `echo $1 | cut -c1-4`
     set SRTMN = `echo $1 | cut -c5-6`
     set SRTDT = `echo $1 | cut -c7-8`
     set YMD = $SRTYR$SRTMN$SRTDT
else
    echo 'Invalid argument. '
    echo "Usage $0 <yyyymmdd>"
    set exitstat = 1
    exit ( $exitstat )
 endif

# "pre"conditions --need to set during test ----------------------------

   if ( ! $?AIRHOME        ) setenv AIRHOME   ~airpact5/AIRHOME
   if ( ! $?AIRRUN ) then
      set AIRRUN  = /data//lar/projects/airpact5/AIRRUN/$SRTYR
   endif
   if ( ! $?AIROUT         ) setenv AIROUT    $AIRRUN/${YMD}00
   if ( ! $?AIRLOGDIR      ) setenv AIRLOGDIR $AIROUT/LOGS
  #if ( ! $?MCIPROOT       ) setenv MCIPROOT  /data//lar/projects/airpact5/AIRRUN/$YEAR
   if ( ! $?MCIPROOT       ) setenv MCIPROOT  /data/airpact4/AIRRUN
   if ( ! $?MCIPDIR        ) setenv MCIPDIR   $AIROUT/MCIP
   if ( ! $?PBS_O_WORKDIR  ) setenv PBS_O_WORKDIR  ~airpact5/AIRHOME/run_ap5_day2

#> save current directory path -----------------------------------------
   set BASE = ${PBS_O_WORKDIR}/emis/merge


#> determine day of the year
   set DOYstring = `juldate $SRTMN $SRTDT $SRTYR | cut -d',' -f 2`
   set DOY       = `echo $DOYstring | cut -c5-7`
   set YEARDOY   = $SRTYR$DOY

#> initialize exit status
   set exitstat = 0

#> set environment variables for input, output, and log files

   set INDIR =  $AIROUT/EMISSION/merged
   set OUTDIR = $AIROUT/EMISSION/merged
   setenv INFILE   $INDIR/EMISSIONS_3D_AIRPACT_04km_$YMD.ncf
   setenv OUTFILE  $OUTDIR/emis2d4plot.ncf

   setenv LOGFILE      $AIRLOGDIR/emis/emis_convertTo2D.log
   if (-e $LOGFILE ) /bin/rm -f $LOGFILE

#> other stuff
   setenv PROMPTFLAG F
   setenv IOAPI_GRIDNAME_1 'AIRPACT_04km' 
   mkdir -p $OUTDIR

#> run fortran program
   ~airpact5/AIRHOME/build/sum_layers/sum_layers.x


