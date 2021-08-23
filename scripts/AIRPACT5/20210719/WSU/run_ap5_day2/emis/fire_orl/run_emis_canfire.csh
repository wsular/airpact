#!/bin/csh -f
#
# Example of using this script:
# 
#   > run_emis_canfire.csh 20120805
#
#  
#  Serena H. Chung 2012-05-18
#  Farren Herron-Thorpe 2016-04-28
#  Description:
#
#       This script models fire emissions using BlueSky Canada
#
#       Calling tree when running within the airpact-4 forecast operation:
#
#         qsub4precctm.csh -> run_emis_canfire.csh
#
#  Precondition(s):
#
#     setenv AIRHOME
#     setenv AIROUT
#     setenv AIRLOGDIR
#

#> check argument & set date strings -----------------------------------

   if ( $1 > 20000100 ) then     
      setenv SRTYR `echo $1 | cut -c1-4`
      setenv YY `echo $1 | cut -c3-4`
      setenv SRTMN `echo $1 | cut -c5-6`
      setenv SRTDT `echo $1 | cut -c7-8`
      set SRTHR = `echo $1 | cut -c9-10`
      set YMD = $SRTYR$SRTMN$SRTDT

   else
      echo 'Invalid argument. '
      echo "Usage $0 <yyyymmdd>"
      set exitstat = 1
       exit ( $exitstat )
   endif

  #> determine day of the year
     set DOYstring = `juldate $SRTMN $SRTDT $SRTYR | cut -d',' -f 2`
     set DOY       = `echo $DOYstring | cut -c5-7`
     setenv YEARDOY  $SRTYR$DOY

#
  #> initialize exit status
     set exitstat = 0

#> during testing only -------------------------------------------------

    if  ( ! $?PBS_O_WORKDIR ) then
      setenv PBS_O_WORKDIR ~airpact5/AIRHOME/run_ap5_day2
      setenv AIRHOME ~airpact5/AIRHOME
      setenv AIROUT  /data//lar/projects/airpact5/AIRRUNDAY2/${SRTYR}/${1}00
      setenv AIRRUN  /data//lar/projects/airpact5/AIRRUNDAY2/${SRTYR}
      setenv AIRLOGDIR $AIROUT/LOGS
      setenv MCIPDIR /data//lar/projects/airpact5/AIRRUN/$SRTYR/${1}00/MCIP37
    endif

#> setenv for paths and files ------------------------------------------

   setenv GRID_CRO_2D $MCIPDIR/GRIDCRO2D
   setenv GRID_CRO_3D $MCIPDIR/GRIDCRO3D
   setenv MET_CRO_2D  $MCIPDIR/METCRO2D
   setenv MET_CRO_3D  $MCIPDIR/METCRO3D
   setenv MET_DOT_3D  $MCIPDIR/METDOT3D
   setenv MET_BDY_3D  $MCIPDIR/METBDY3D


#> simulate date/time parameters ---------------------------------------
  
  # simulation time parameters
    setenv STIME     080000 # start time HHMMSS
    setenv RNLEN     240000 # run length HHMMSS

#> remove any files that might exist if final fire file does not exist; otherwise exit if it already exists
setenv TARGET_DIR $AIROUT/EMISSION/fire_can/bluesky
mkdir -v -p $TARGET_DIR

if ( ! -e $AIROUT/EMISSION/fire_can/smoke/pgts3d_l_${YEARDOY}_1_AIRPACT_04km_fire.ncf ) then
   rm -rf $AIROUT/EMISSION/fire_can/smoke
   rm -rf $AIRLOGDIR/emis/fire_can

else
   echo "found final fire emissions file"
   ls $AIROUT/EMISSION/fire_can/smoke/pgts3d_l_${YEARDOY}_1_AIRPACT_04km_fire.ncf
   exit(0)
endif

cd ~airpact5/AIRHOME/run_ap5_day2/emis/fire_orl

#> Copy files from DAY1 so BlueSky doesn't have to run twice
    if ( ! -e $AIROUT/EMISSION/fire_can/bluesky/ptinv-${YMD}00.orl ) then
      set DAY1 = `datshift $YMD -1`       
      #This simplified copy method will fail on January 1
      echo "Copying DAY1 fire info to DAY2"
      cp -r /data//lar/projects/airpact5/AIRRUN/${SRTYR}/${DAY1}00/EMISSION/fire_can/bluesky $AIROUT/EMISSION/fire_can/
      mv $AIROUT/EMISSION/fire_can/bluesky/ptinv-${DAY1}00.orl $AIROUT/EMISSION/fire_can/bluesky/ptinv-${YMD}00.orl
      mv $AIROUT/EMISSION/fire_can/bluesky/ptday-${DAY1}00.orl $AIROUT/EMISSION/fire_can/bluesky/ptday-${YMD}00.orl

    endif
#> End file copy

#> main SMOKE script --------------------------------------------------

   set tmp_stra = `tail -1 "${TARGET_DIR}/ptinv-${YMD}00.orl"`
   set tmp_strb = `echo ${tmp_stra} | cut -c1-10`

   if ( `echo ${tmp_strb}` == `echo "#DESC FIPS"` ) then
      echo "Fire list is empty; stopping Canadian fire emissions process."
      exit(0)
   endif

${PBS_O_WORKDIR}/emis/fire_orl/run_smk_pt_canfire.csh

#> If there is no final fire file check for no fires in domain in grdmat log
if ( ! -e $AIROUT/EMISSION/fire_can/smoke/pgts3d_l_${YEARDOY}_1_AIRPACT_04km_fire.ncf ) then

   set tmp_str1 = `tail -2 "$AIROUT/LOGS/emis/fire_can/smkinven_pt_fire.log"`
   set tmp_str2 = `echo ${tmp_str1} | cut -c1-43`

   set tmp_str5 = `tail -2 "$AIROUT/LOGS/emis/fire_can/grdmat_pt_fire_AIRPACT_04km.log"`
   set tmp_str6 = `echo ${tmp_str5} | cut -c1-34`
   if ( `echo ${tmp_str2}` == `echo "--->> Normal Completion of program SMKINVEN"` && `echo ${tmp_str6}` == `echo "No source-cell intersections found"` ) then
      echo ${tmp_str6}
      exit(0)
   endif
   

   set tmp_str1 = `tail -2 "$AIROUT/LOGS/emis/fire_can/smkinven_pt_fire.log"`
   set tmp_str2 = `echo ${tmp_str1} | cut -c1-25`
   echo ${tmp_str2}

else
   echo "Fire processing successfully completed on first attempt"
endif

ls -al $AIROUT/EMISSION/fire_can/smoke/pgts3d_l_${YEARDOY}_1_AIRPACT_04km_fire.ncf

exit(0)

