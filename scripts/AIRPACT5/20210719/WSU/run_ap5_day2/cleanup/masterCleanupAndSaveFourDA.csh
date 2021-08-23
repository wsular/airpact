#!/bin/csh -f

#
#  usage examples:
#   
#       ./masterCleanupAndSaveFourDA.csh 
#       ./masterCleanupAndSaveFourDA.csh 20151123
# 
#    If no input argument is provivded, the script will get the system
#    date (in GMT).  If an input argument(s) is (are) provided, it is 
#    assumed that the first argument is simulation date in YYYYMMDD 
#    format.  
#
#    This script remove files from four days before the date argument
#

# ----------------------------------------------------------------------


  source ~airpact5/.tcshrc              # needed when running from crontab
                                             # (crontab starts in bash)
  setenv basedir  ~airpact5/AIRHOME/run_ap5_day2
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
  set fourdaysago  = `date -d "$currentday -4 days" '+%Y%m%d'`

# some prerequesites ---------------------------------------------------

  set AIRROOT     = /data/lar/projects/airpact5/AIRRUNDAY2
  set AIRSAVEROOT = /data/lar/projects/airpact5/savedday2
 #set MCIPROOT    = ....

# clean up files from four days ago ------------------------------------

  set DAYfourda = `echo $fourdaysago | cut -c7-8`
  set MONTHfourda = `echo $fourdaysago | cut -c5-6`
  set YEARfourda = `echo $fourdaysago | cut -c1-4`
  set AIROUTfourda = $AIRROOT/$YEARfourda/${fourdaysago}00
  set AIRSAVEfourda = $AIRSAVEROOT/$YEARfourda

  echo "Now is" `date` 
  echo " removing and moving files for" $fourdaysago
  echo "----------------------------------------------------------------" >> ./cleanup_summary.txt
  echo "Now is" `date` >> ./cleanup_summary.txt
  echo " removing and moveing files for" $fourdaysago >> ./cleanup_summary.txt

  # BCON files
    set indir =  $AIROUTfourda/BCON
    if ( -d $indir ) then
       /bin/rm -rf $indir
       echo "`date` BCON files from $fourdaysago deleted"  >> ./cleanup_summary.txt
    endif
 
  # JPROC files
    set indir =  $AIROUTfourda/JPROC
    if ( -d $indir ) then
       /bin/rm -rf $indir
       echo "`date` JPROC files from $fourdaysago deleted"  >> ./cleanup_summary.txt
    endif
 
  # EMISSION files
    set indir =  $AIROUTfourda/EMISSION
    if ( -d $indir ) then
       /bin/rm -rf $indir
       echo "`date` EMISSION files from $fourdaysago deleted"  >> ./cleanup_summary.txt
    endif
 
  # CCTM files
    set indir =  $AIROUTfourda/CCTM
    if ( -d $indir ) then
       /bin/rm -rf $indir
       echo "`date` CCTM files from $fourdaysago deleted"  >> ./cleanup_summary.txt
    endif

  # IMAGES files
    set indir =  $AIROUTfourda/IMAGES
    if ( -d $indir ) then
       /bin/rm -rf $indir
       echo "`date` IMAGES files from $fourdaysago deleted"  >> ./cleanup_summary.txt
    endif

  # post-processed files
    set indir = $AIROUTfourda/POST/CCTM
    if ( -d $indir ) then
       set infile = $AIROUTfourda/POST/CCTM/AIRNowSites_${fourdaysago}_v2.dat
       if ( -e $infile ) then
          set newdir = $AIRSAVEfourda/${MONTHfourda}/post/
          if ( ! -d $newdir ) mkdir -p $newdir
          mv $infile $newdir/
          echo `date` "AIRNowSites file from $fourdaysago moved"  >> ./cleanup_summary.txt
       endif
       rm -rf $AIROUTfourda/POST
       echo "`date` POST files from $fourdaysago deleted"  >> ./cleanup_summary.txt
    endif

  # LOGS files
    set indir =  $AIROUTfourda/LOGS
    if ( -d $indir ) then
       /bin/rm -rf $indir
       echo "`date` LOGS files from $fourdaysago deleted"  >> ./cleanup_summary.txt
    endif

  # 
    rmdir $AIROUTfourda
    echo `date` $AIROUTfourda "deleted"  >> ./cleanup_summary.txt

  # # MCIP files
  #   set indir = $MCIPROOT/${fourdaysago}00/MCIP37
  #   if ( -d $indir ) then
  #      set newdir = $AIRSAVEfourda/mcip37/${YEARfourda}${MONTHfourda}/${fourdaysago}00
  #      if ( ! -d $newdir ) mkdir -p $newdir
  #      mv $indir/* $newdir
  #      rmdir $indir
  #      echo `date` "MCIP37 files from $fourdaysago moved"  >> ./cleanup_summary.txt
  #   endif

    
