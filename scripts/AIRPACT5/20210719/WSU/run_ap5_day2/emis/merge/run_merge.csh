#!/bin/csh -f
# example of using this script:
# 
#   > ./run_merge.csh 20120801
#
#
#  Serena H. Chung 2015-10-19
# 
#  Description:
#
#       This script merges anthropogenic, biogenic (MEGAN), and fire (if avaiable) emissions files.
#       (based 2015-07-02 version of AIRPACT-4 script)
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

#> some prerequesite
  if ( ! $?PBS_O_WORKDIR ) then
    setenv PBS_O_WORKDIR   ~airpact5/AIRHOME/run_ap5_day2
    setenv AIRRUN          /data//lar/projects/airpact5/AIRRUN/$SRTYR
    setenv AIROUT          $AIRRUN/${1}00
    setenv AIRLOGDIR       $AIROUT/LOGS
   endif

#> initialize exit status
   set exitstat = 0

#> set environment variables for input, output, and log files

   set USAFIRE = "N"
   set CANFIRE = "N"
   set USALOGFILE = $AIRLOGDIR/emis/fire/smkmerge_pt_fire_AIRPACT_04km.log
   if ( -e $USALOGFILE ) then
      set tmp_str1 = `tail -3 "$USALOGFILE"`
      if ( `echo $tmp_str1` == `echo "--->> Normal Completion of program SMKMERGE"` ) then 
         set USAFIRE = "Y"
      endif
   endif
   set CANLOGFILE = $AIRLOGDIR/emis/fire_can/smkmerge_pt_fire_AIRPACT_04km.log
   if ( -e $CANLOGFILE ) then
      set tmp_str1 = `tail -3 "$CANLOGFILE"`
      if ( `echo $tmp_str1` == `echo "--->> Normal Completion of program SMKMERGE"` ) then 
         set CANFIRE = "Y"
      endif
   endif

   setenv FILELIST       $BASE/mrggrid_filelist_nofire.txt
   setenv EFILE_USAFIRE  $AIROUT/EMISSION/fire/smoke/pgts3d_l_${YEARDOY}_1_AIRPACT_04km_fire.ncf 
   setenv EFILE_CANFIRE  $AIROUT/EMISSION/fire_can/smoke/pgts3d_l_${YEARDOY}_1_AIRPACT_04km_fire.ncf 
   if ( $USAFIRE == "Y" && $CANFIRE == "Y" ) then
      echo '    fire emissions from both the USA and Canada will be included' > $AIRLOGDIR/summary.txt
      setenv FILELIST       $BASE/mrggrid_filelist_wcanusafire.txt
   else if ( $USAFIRE == "Y" ) then
      echo '    no Canada fire emissions' > $AIRLOGDIR/summary.txt
      setenv FILELIST       $BASE/mrggrid_filelist_wusafire.txt
      unsetenv EFILE_CANFIRE
   else if ( $CANFIRE == "Y" ) then
      echo '    no USA fire emissions' > $AIRLOGDIR/summary.txt
      setenv FILELIST       $BASE/mrggrid_filelist_wcanfire.txt
      unsetenv EFILE_USAFIRE
   else
      echo '    no fire emissions' > $AIRLOGDIR/summary.txt
      unsetenv EFILE_USAFIRE
      unsetenv EFILE_CANFIRE
   endif

   setenv EFILE_ANTHRO $AIROUT/EMISSION/anthro/output/merged/EMISSIONS_AIRPACT_04km_CB05_2014nw_${YEARDOY}.ncf
   setenv EFILE_MEGAN  $AIROUT/EMISSION/megan2.10/CB05_${YMD}.ncf
   setenv OUTDIR       $AIROUT/EMISSION/merged
   setenv OUTFILE      $OUTDIR/EMISSIONS_3D_AIRPACT_04km_$YMD.ncf
   setenv LOGFILE      $AIRLOGDIR/emis/emis_merge_mrggrid.log
   if (-e $LOGFILE ) /bin/rm -f $LOGFILE

#> other stuff
   setenv PROMPTFLAG F
   setenv IOAPI_GRIDNAME_1 'AIRPACT_04km' 
   mkdir -p $OUTDIR

#> use SMOKE's mrggrid to merge emission files
    ~airpact5/models/SMOKEv3.5.1/subsys/smoke/Linux2_x86_64pg/mrggrid


