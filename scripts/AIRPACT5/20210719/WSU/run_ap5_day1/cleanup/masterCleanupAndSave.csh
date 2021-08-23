#!/bin/csh -f

#
#  usage examples:
#   
#       ./masterCleanupAndSave.csh 
#       ./masterCleanupAndSave.csh 20151123
# 
#    If no input argument is provivded, the script will get the system
#    date (in GMT).  If an input argument(s) is (are) provided, it is 
#    assumed that the first argument is simulation date in YYYYMMDD 
#    format.  
#
#    This script remove files from five days before the date argument
#

# ----------------------------------------------------------------------


  source ~airpact5/.tcshrc              # needed when running from crontab
                                             # (crontab starts in bash)
  setenv basedir  ~airpact5/AIRHOME/run_ap5_day1
  cd $basedir/cleanup

# get date info --------------------------------------------------------

  if ( $#argv == 1 ) then
     set currentday = $1
  else # if no command-line input, use system time in GMT
     set today     = `perl -e 'printf "%d\n", (gmtime(time()))[3]'` #today local time 
     set thismonth = `perl -e 'printf "%d\n", (gmtime(time()))[4]+1'`#format month (January = 0)
     set thisyear  = `perl -e 'printf "%d\n", (gmtime(time()))[5]+1900'`#format year
     if ( $thismonth < 10 ) set thismonth = 0${thismonth}
     if ( $today < 10 ) set today = 0${today}
     set currentday = ${thisyear}${thismonth}${today}
  endif
  set fivedaysago = `date -d "$currentday -5 days" '+%Y%m%d'`
  set sixdaysago  = `date -d "$currentday -6 days" '+%Y%m%d'`

# some prerequesites ---------------------------------------------------

  set AIRROOT     = /data/lar/projects/airpact5/AIRRUN
  set AIRSAVEROOT = /data/lar/projects/airpact5/saved
 #set MCIPROOT    = ....

# clean up files from six days ago ------------------------------------

  set DAYfda = `echo $fivedaysago | cut -c7-8`
  set MONTHfda = `echo $fivedaysago | cut -c5-6`
  set YEARfda = `echo $fivedaysago | cut -c1-4`
  set lastdaymonth=`cal $MONTHfda $YEARfda  |tr -s " " "\n"|tail -1`
  set AIROUTfda = $AIRROOT/$YEARfda/${fivedaysago}00
  set AIRSAVEfda = $AIRSAVEROOT/$YEARfda/$MONTHfda

  echo "Now is" `date` 
  echo " removing and moving files for" $fivedaysago
  echo "----------------------------------------------------------------" >> ./cleanup_summary.txt
  echo "Now is" `date` >> ./cleanup_summary.txt
  echo " removing and moving files for" $fivedaysago >> ./cleanup_summary.txt

  # remove CGRID file from five days ago, unless five days ago was
  # the 7th, 14th, 21st or 28th or the last day of a month.
    set infile =  $AIROUTfda/CCTM/CGRID_${fivedaysago}.ncf 
    if ( -e $infile ) then
       if ( $DAYfda != $lastdaymonth & $DAYfda != '07' & $DAYfda != '14' & $DAYfda != '21' & $DAYfda != '28') then
          /bin/rm -f $infile
          echo "`date` CGRID file from $fivedaysago deleted"  >> ./cleanup_summary.txt
       else
          set newdir = $AIRSAVEfda/cgrid
          if ( ! -d $newdir ) mkdir -p $newdir
          mv $infile $newdir/
          echo "`date`  CGRID file from $fivedaysago moved"  >> ./cleanup_summary.txt
       endif
    endif

  # ACONC file
    set infile = $AIROUTfda/CCTM/ACONC_${fivedaysago}.ncf 
    if ( -e $infile ) then
       /bin/rm -f $infile
       echo `date` "ACONC file from $fivedaysago deleted"  >> ./cleanup_summary.txt
    endif

  # CONC file
    set infile = $AIROUTfda/CCTM/CONC_${fivedaysago}.ncf 
    if ( -e $infile ) then
       /bin/rm -f $infile
       echo `date` "CONC file from $fivedaysago deleted"  >> ./cleanup_summary.txt
    endif
 
  # AERODIAM file
    set infile = $AIROUTfda/CCTM/AERODIAM_${fivedaysago}.ncf 
    if ( -e $infile ) then
       /bin/rm -f $infile
       echo `date` "AERODIAM file from $fivedaysago deleted"  >> ./cleanup_summary.txt
    endif

  # AEROVIS file
    set infile = $AIROUTfda/CCTM/AEROVIS_${fivedaysago}.ncf 
    if ( -e $infile ) then
       /bin/rm -f $infile
       echo `date` "AEROVIS file from $fivedaysago deleted"  >> ./cleanup_summary.txt
    endif

  # DRYDEP file
    set infile = $AIROUTfda/CCTM/DRYDEP_${fivedaysago}.ncf 
    if ( -e $infile ) then
       /bin/rm -f $infile
       echo `date` "DRYDEP file from $fivedaysago deleted"  >> ./cleanup_summary.txt
    endif

  # WETDEP1 file
    set infile = $AIROUTfda/CCTM/WETDEP1_${fivedaysago}.ncf 
    if ( -e $infile ) then
       /bin/rm -f $infile
       echo `date` "WETDEP1 file from $fivedaysago deleted"  >> ./cleanup_summary.txt
    endif
 
  # post-processed files
    set infile = $AIROUTfda/POST/CCTM/combined_${fivedaysago}.ncf
    if ( -e $infile ) then
       set newdir = $AIRSAVEfda/aconc
       if ( ! -d $newdir ) mkdir -p $newdir
       mv $infile $newdir/
       echo `date` "combined file from $fivedaysago moved"  >> ./cleanup_summary.txt
    endif
    set infile = $AIROUTfda/POST/CCTM/combined3d_${fivedaysago}.ncf 
    if ( -e $infile ) then
       set newdir = $AIRSAVEfda/aconc
       if ( ! -d $newdir ) mkdir -p $newdir
       mv $infile $newdir/
       echo `date` "combined3d file from $fivedaysago moved"  >> ./cleanup_summary.txt
     endif
    set infile = $AIROUTfda/POST/CCTM/O3_L01_08hr_${sixdaysago}.ncf 
    if ( -e $infile ) then
       /bin/rm -f $infile
       echo `date` "O3_L01_08hr file from $fivedaysago deleted"  >> ./cleanup_summary.txt
    endif
    set infile = $AIROUTfda/POST/CCTM/PM25_L01_24hr_${sixdaysago}.ncf
    if ( -e $infile ) then
       /bin/rm -f $infile
       echo `date` "PM25_L01_24hr file from $fivedaysago deleted"  >> ./cleanup_summary.txt
    endif
    set infile = $AIROUTfda/POST/CCTM/aod550nm3d_${fivedaysago}.ncf
    if ( -e $infile ) then 
       /bin/rm -f $infile
       echo `date` "aod55nm3d file from $fivedaysago deleted"  >> ./cleanup_summary.txt
    endif
    set infile = $AIROUTfda/POST/CCTM/aod550nm2d_${fivedaysago}.ncf 
    if ( -e $infile ) then
       set newdir = $AIRSAVEfda/aconc
       if ( ! -d $newdir ) mkdir -p $newdir
       mv $infile $newdir/
       echo `date` "aod550nm2d file from $fivedaysago moved"  >> ./cleanup_summary.txt
     endif
#    set infile = $AIROUTfda/POST/CCTM/aod550nm2d_${fivedaysago}.ncf  # JKV changed to saving aod55nm2d.  07/21/17
#    if ( -e $infile ) then 
#       /bin/rm -f $infile
#       echo `date` "aod55nm2d file from $fivedaysago deleted"  >> ./cleanup_summary.txt
#    endif
    set infile = $AIROUTfda/POST/CCTM/AIRNowSites_${fivedaysago}.dat
    if ( -e $infile ) then
       /bin/rm -f $infile
       /bin/rm -f $AIROUTfda/POST/CCTM/aqsid.csv
       echo `date` "AIRNowSites_*.dat file from $fivedaysago deleted"  >> ./cleanup_summary.txt
    endif
    set infile = $AIROUTfda/POST/CCTM/AIRNowSites_${fivedaysago}_v2.dat
    if ( -e $infile ) then
       /bin/rm -f $infile
       echo `date` "AIRNowSites_*_v2.dat file from $fivedaysago deleted"  >> ./cleanup_summary.txt
    endif
    if ( -d $AIROUTfda/POST/CCTM ) then
       rmdir $AIROUTfda/POST/CCTM
       rmdir $AIROUTfda/POST
       echo `date` "POST from $fivedaysago deleted"  >> ./cleanup_summary.txt
    endif

  # MOZART-4 files
    set infile = $AIROUTfda/BCON/input/mz4geos_nwus_1h_${fivedaysago}_8z_f65.nc.gz
    if ( -e $infile ) then
       set newdir = $AIRSAVEfda/mozart4
       if ( ! -d $newdir ) mkdir -p $newdir
       mv $infile $newdir/
       if ( -e $AIROUTfda/BCON/input/mz4geos_nwus_1h_${fivedaysago}.nc ) then
          rm -f $AIROUTfda/BCON/input/mz4geos_nwus_1h_${fivedaysago}.nc
       endif
       echo `date` "MOZART-4 file from $fivedaysago moved"  >> ./cleanup_summary.txt
       rmdir $AIROUTfda/BCON/input 
       rm -rf $AIROUTfda/BCON
    endif

  # MEGAN files
    set infile = $AIROUTfda/EMISSION/megan2.10/PFILE_${fivedaysago}.ncf
    if ( -e $infile ) then
       if ( $DAYfda != $lastdaymonth & $DAYfda != '14' ) then
          /bin/rm -f $infile
          echo `date` "PFILE file from $fivedaysago deleted"  >> ./cleanup_summary.txt
       else
          newdir = $AIRSAVEfda/megan2.10
          if ( ! -d $newdir ) mkdir -p $newdir
          mv $infile $newdir/
          echo `date`  "PFILE file from $fivedaysago moved"  >> ./cleanup_summary.txt
       endif
    endif

   # Fire files
     set infile = $AIROUTfda/EMISSION/fire/bluesky/fire_locations.csv
     if ( -e $infile ) then
        set newdir = $AIRSAVEfda/fire
        if ( ! -d $newdir ) mkdir -p $newdir
        mv $infile $newdir/fire_locations_usa_${fivedaysago}.csv
        echo `date`  "fire_locations.csv for USA from $fivedaysago moved"  >> ./cleanup_summary.txt
     endif
     set infile = $AIROUTfda/EMISSION/fire_can/bluesky/fire_locations.csv
     if ( -e $infile ) then
        set newdir = $AIRSAVEfda/fire
        if ( ! -d $newdir ) mkdir -p $newdir
        mv $infile $newdir/fire_locations_can_${fivedaysago}.csv
        echo `date`  "fire_locations.csv for Canada from $fivedaysago moved"  >> ./cleanup_summary.txt
     endif

  # directories
    if ( -d $AIROUTfda/EMISSION ) then
       rm -rf $AIROUTfda/EMISSION
       echo `date` "EMISSION directory from $fivedaysago deleted"  >> ./cleanup_summary.txt
    endif
    if ( -d $AIROUTfda/LOGS ) then
       rm -rf $AIROUTfda/LOGS
       echo `date` "LOGS from $fivedaysago deleted"  >> ./cleanup_summary.txt
    endif
    if ( -d $AIROUTfda/CCTM ) then 
       rmdir $AIROUTfda/CCTM
       echo `date` "CCTM from $fivedaysago deleted"  >> ./cleanup_summary.txt
    endif
    if ( -d $AIROUTfda/BCON ) then 
       rmdir $AIROUTfda/BCON
       echo `date` "BCON from $fivedaysago deleted"  >> ./cleanup_summary.txt
    endif
    if ( -d $AIROUTfda/JPROC ) then 
       rm -rf $AIROUTfda/JPROC
       echo `date` "JPROC from $fivedaysago deleted"  >> ./cleanup_summary.txt
    endif
    if ( -d $AIROUTfda/IMAGES ) then 
       rm -rf $AIROUTfda/IMAGES
       echo `date` "IMAGES from $fivedaysago deleted"  >> ./cleanup_summary.txt
    endif
    if ( -d $AIROUTfda ) then 
       rmdir $AIROUTfda
       echo `date` "directory for $fivedaysago deleted"  >> ./cleanup_summary.txt
    endif


  # # MCIP files
  #   set indir = $MCIPROOT/${fivedaysago}00/MCIP37  
  #   if ( -d $indir ) then
  #      set newdir = $AIRSAVEfda/mcip37${fivedaysago}00
  #      if ( ! -d $newdir ) mkdir -p $newdir
  #      mv $indir/* $newdir
  #      rmdir $indir
  #      echo `date` "MCIP37 files from $fivedaysago moved"  >> ./cleanup_summary.txt
  #   endif
  #   set indir = $MCIPROOT/${fivedaysago}00/MCIP
  #   if ( -d $indir ) then
  #      set newdir = $AIRSAVEfda/mcip21/${fivedaysago}00
  #      if ( ! -d $newdir ) mkdir -p $newdir
  #      mv $indir/* $newdir
  #      rmdir $indir
  #      echo `date` "MCIP21 files from $fivedaysago moved"  >> ./cleanup_summary.txt
  #   endif

    
