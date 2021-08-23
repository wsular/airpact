#!/bin/csh -fX

#
#  usage examples:
#   
#       ./masterCleanupAndSave_forDay.csh 20151123
# 
#    Input argument is exact day to save and remove. 
#

# ----------------------------------------------------------------------


  setenv basedir  ~airpact5/AIRHOME/run_ap5_day1
  cd $basedir/cleanup

# get date info --------------------------------------------------------

  if ( $#argv == 1 ) then
     set currentday = $1
  else # if no command-line input, use system time in GMT
     echo Usage: $0 <YYYYMMDD00>
     exit(1)
  endif

# some prerequesites ---------------------------------------------------

  set AIRROOT     = /data/lar/projects/airpact5/AIRRUN
  set AIRSAVEROOT = /data/lar/projects/airpact5/saved
 #set MCIPROOT    = ....

  set DAYcur = `echo $currentday | cut -c7-8`
  set MONTHcur = `echo $currentday | cut -c5-6`
  set YEARcur = `echo $currentday | cut -c1-4`
  set YYYYMMDD = ${YEARcur}${MONTHcur}${DAYcur}
  set lastdaymonth=`cal $MONTHcur $YEARcur  |tr -s " " "\n"|tail -1`
  echo lastdaymonth $lastdaymonth

  set AIROUTcur = $AIRROOT/$YEARcur/${currentday}
  set AIRSAVEcur = $AIRSAVEROOT/$YEARcur/$MONTHcur

  echo "Now is" `date` 
  echo " removing and moving files for" $currentday
  echo "----------------------------------------------------------------" >> ./cleanup_summary.txt
  echo "Now is" `date` >> ./cleanup_summary.txt
  echo " removing and moving files for" $currentday >> ./cleanup_summary.txt

  # remove CGRID file from five days ago, unless five days ago was
  # the last day of a month or on the 14th day of a month
    set infile =  $AIROUTcur/CCTM/CGRID_${YYYYMMDD}.ncf 
    if ( -e $infile ) then
       if ( $DAYcur != $lastdaymonth & $DAYcur != '07' & $DAYcur != '14' & $DAYcur != '21' ) then
          /bin/rm -f $infile
          echo "`date` CGRID file from $YYYYMMDD deleted"  >> ./cleanup_summary.txt
       else
          set newdir = $AIRSAVEcur/cgrid
          if ( ! -d $newdir ) mkdir -p $newdir
          mv $infile $newdir/
          echo "`date`  CGRID file from $YYYYMMDD moved"  >> ./cleanup_summary.txt
       endif
    endif

  # ACONC file
    set infile = $AIROUTcur/CCTM/ACONC_${YYYYMMDD}.ncf 
    if ( -e $infile ) then
       /bin/rm -f $infile
       echo `date` "ACONC file from $YYYYMMDD deleted"  >> ./cleanup_summary.txt
    endif

  # CONC file
    set infile = $AIROUTcur/CCTM/CONC_${YYYYMMDD}.ncf 
    if ( -e $infile ) then
       /bin/rm -f $infile
       echo `date` "CONC file from $YYYYMMDD deleted"  >> ./cleanup_summary.txt
    endif
 
  # AERODIAM file
    set infile = $AIROUTcur/CCTM/AERODIAM_${YYYYMMDD}.ncf 
    if ( -e $infile ) then
       /bin/rm -f $infile
       echo `date` "AERODIAM file from $YYYYMMDD deleted"  >> ./cleanup_summary.txt
    endif

  # AEROVIS file
    set infile = $AIROUTcur/CCTM/AEROVIS_${YYYYMMDD}.ncf 
    if ( -e $infile ) then
       /bin/rm -f $infile
       echo `date` "AEROVIS file from $YYYYMMDD deleted"  >> ./cleanup_summary.txt
    endif

  # DRYDEP file
    set infile = $AIROUTcur/CCTM/DRYDEP_${YYYYMMDD}.ncf 
    if ( -e $infile ) then
       /bin/rm -f $infile
       echo `date` "DRYDEP file from $YYYYMMDD deleted"  >> ./cleanup_summary.txt
    endif

  # WETDEP1 file
    set infile = $AIROUTcur/CCTM/WETDEP1_${YYYYMMDD}.ncf 
    if ( -e $infile ) then
       /bin/rm -f $infile
       echo `date` "WETDEP1 file from $YYYYMMDD deleted"  >> ./cleanup_summary.txt
    endif
 
  # post-processed files
    set infile = $AIROUTcur/POST/CCTM/combined_${YYYYMMDD}.ncf
    if ( -e $infile ) then
       set newdir = $AIRSAVEcur/aconc
       if ( ! -d $newdir ) mkdir -p $newdir
       mv $infile $newdir/
       echo `date` "combined file from $YYYYMMDD moved"  >> ./cleanup_summary.txt
    endif
    set infile = $AIROUTcur/POST/CCTM/combined3d_${YYYYMMDD}.ncf 
    if ( -e $infile ) then
       set newdir = $AIRSAVEcur/aconc
       if ( ! -d $newdir ) mkdir -p $newdir
       mv $infile $newdir/
       echo `date` "combined3d file from $YYYYMMDD moved"  >> ./cleanup_summary.txt
     endif
    set infile = $AIROUTcur/POST/CCTM/aod550nm3d_${YYYYMMDD}.ncf
    if ( -e $infile ) then 
       /bin/rm -f $infile
       echo `date` "aod55nm3d file from $YYYYMMDD deleted"  >> ./cleanup_summary.txt
    endif
    set infile = $AIROUTcur/POST/CCTM/aod550nm2d_${YYYYMMDD}.ncf
    if ( -e $infile ) then 
       /bin/rm -f $infile
       echo `date` "aod55nm2d file from $YYYYMMDD deleted"  >> ./cleanup_summary.txt
    endif
    set infile = $AIROUTcur/POST/CCTM/AIRNowSites_${YYYYMMDD}.dat
    if ( -e $infile ) then
       /bin/rm -f $infile
       /bin/rm -f $AIROUTcur/POST/CCTM/aqsid.csv
       echo `date` "AIRNowSites_*.dat file from $YYYYMMDD deleted"  >> ./cleanup_summary.txt
    endif
    set infile = $AIROUTcur/POST/CCTM/AIRNowSites_${YYYYMMDD}_v2.dat
    if ( -e $infile ) then
       /bin/rm -f $infile
       echo `date` "AIRNowSites_*_v2.dat file from $YYYYMMDD deleted"  >> ./cleanup_summary.txt
    endif
    if ( -d $AIROUTcur/POST/CCTM ) then
       rmdir $AIROUTcur/POST/CCTM
       rmdir $AIROUTcur/POST
       echo `date` "POST from $YYYYMMDD deleted"  >> ./cleanup_summary.txt
    endif

  # MOZART-4 files
    set infile = $AIROUTcur/BCON/input/mz4geos_nwus_1h_${YYYYMMDD}_8z_f65.nc.gz
    if ( -e $infile ) then
       set newdir = $AIRSAVEcur/mozart4
       if ( ! -d $newdir ) mkdir -p $newdir
       mv $infile $newdir/
       if ( -e $AIROUTcur/BCON/input/mz4geos_nwus_1h_${YYYYMMDD}.nc ) then
          rm -f $AIROUTcur/BCON/input/mz4geos_nwus_1h_${YYYYMMDD}.nc
       endif
       echo `date` "MOZART-4 file from $YYYYMMDD moved"  >> ./cleanup_summary.txt
       rmdir $AIROUTcur/BCON/input 
       rm -rf $AIROUTcur/BCON
    endif

  # MEGAN files
    set infile = $AIROUTcur/EMISSION/megan2.10/PFILE_${YYYYMMDD}.ncf
    if ( -e $infile ) then
       if ( $DAYcur != $lastdaymonth & $DAYcur != '14' ) then
          /bin/rm -f $infile
          echo `date` "PFILE file from $YYYYMMDD deleted"  >> ./cleanup_summary.txt
       else
          newdir = $AIRSAVEcur/megan2.10
          if ( ! -d $newdir ) mkdir -p $newdir
          mv $infile $newdir/
          echo `date`  "PFILE file from $YYYYMMDD moved"  >> ./cleanup_summary.txt
       endif
    endif

   # Fire files
     set infile = $AIROUTcur/EMISSION/fire/bluesky/fire_locations.csv
     if ( -e $infile ) then
        set newdir = $AIRSAVEcur/fire
        if ( ! -d $newdir ) mkdir -p $newdir
        mv $infile $newdir/fire_locations_usa_${YYYYMMDD}.csv
        echo `date`  "fire_locations.csv for USA from $YYYYMMDD moved"  >> ./cleanup_summary.txt
     endif
     set infile = $AIROUTcur/EMISSION/fire_can/bluesky/fire_locations.csv
     if ( -e $infile ) then
        set newdir = $AIRSAVEcur/fire
        if ( ! -d $newdir ) mkdir -p $newdir
        mv $infile $newdir/fire_locations_can_${YYYYMMDD}.csv
        echo `date`  "fire_locations.csv for Canada from $YYYYMMDD moved"  >> ./cleanup_summary.txt
     endif

  # directories
    if ( -d $AIROUTcur/EMISSION ) then
       rm -rf $AIROUTcur/EMISSION
       echo `date` "EMISSION directory from $YYYYMMDD deleted"  >> ./cleanup_summary.txt
    endif
    if ( -d $AIROUTcur/LOGS ) then
       rm -rf $AIROUTcur/LOGS
       echo `date` "LOGS from $YYYYMMDD deleted"  >> ./cleanup_summary.txt
    endif
    if ( -d $AIROUTcur/CCTM ) then 
       rmdir $AIROUTcur/CCTM
       echo `date` "CCTM from $YYYYMMDD deleted"  >> ./cleanup_summary.txt
    endif
    if ( -d $AIROUTcur/BCON ) then 
       rmdir $AIROUTcur/BCON
       echo `date` "BCON from $YYYYMMDD deleted"  >> ./cleanup_summary.txt
    endif
    if ( -d $AIROUTcur/JPROC ) then 
       rm -rf $AIROUTcur/JPROC
       echo `date` "JPROC from $YYYYMMDD deleted"  >> ./cleanup_summary.txt
    endif
    if ( -d $AIROUTcur/IMAGES ) then 
       rm -rf $AIROUTcur/IMAGES
       echo `date` "IMAGES from $YYYYMMDD deleted"  >> ./cleanup_summary.txt
    endif
    if ( -d $AIROUTcur ) then 
       rmdir $AIROUTcur
       echo `date` "directory for $YYYYMMDD deleted"  >> ./cleanup_summary.txt
    endif


  # # MCIP files
  #   set indir = $MCIPROOT/${YYYYMMDD}/MCIP37  
  #   if ( -d $indir ) then
  #      set newdir = $AIRSAVEcur/mcip37${YYYYMMDD}
  #      if ( ! -d $newdir ) mkdir -p $newdir
  #      mv $indir/* $newdir
  #      rmdir $indir
  #      echo `date` "MCIP37 files from $YYYYMMDD moved"  >> ./cleanup_summary.txt
  #   endif
  #   set indir = $MCIPROOT/${YYYYMMDD}/MCIP
  #   if ( -d $indir ) then
  #      set newdir = $AIRSAVEcur/mcip21/${YYYYMMDD}
  #      if ( ! -d $newdir ) mkdir -p $newdir
  #      mv $indir/* $newdir
  #      rmdir $indir
  #      echo `date` "MCIP21 files from $YYYYMMDD moved"  >> ./cleanup_summary.txt
  #   endif

    
