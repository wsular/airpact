#!/bin/csh -f

# example of using this script:
# 
#   > ./run_cleanup_cctm.csh 20151202
#
#  2015-12-02    Serena H. Chung      initial version

# initialize exit status -----------------------------------------------
  set exitstat = 0

# check argument & set date strings  -----------------------------------

  if ( $1 > 20000101 ) then     
     set YEAR  = `echo $1 | cut -c1-4`
     set MONTH = `echo $1 | cut -c5-6`
     set DAY   = `echo $1 | cut -c7-8`
     set currentday  = $YEAR$MONTH$DAY
     set previousday = `date -d "$currentday -1 days" '+%Y%m%d'`
     set threedaysago  = `date -d "$currentday -3 days" '+%Y%m%d'`
     set YEARtda = `echo $threedaysago | cut -c1-4`
   endif

# "pre"conditions --need to set during test ----------------------------

   if ( ! $?AIRHOME        ) set AIRHOME = ~airpact5/AIRHOME
   if ( ! $?AIRROOT         ) set AIRROOT = /data/lar/projects/airpact5/AIRRUNDAY2
   if ( ! $?AIRRUN         ) set AIRRUN  = $AIRROOT/$YEAR
   if ( ! $?AIROUT         ) set AIROUT = $AIRRUN/${currentday}00
   if ( ! $?AIRLOGDIR      ) set AIRLOGDIR = $AIROUT/LOGS
   if ( ! $?MCIPDIR        ) set MCIPDIR   = $AIROUT/MCIP
   if ( ! $?BCONDIR        ) set BCONDIR   = $AIROUT/BCON
   if ( ! $?PBS_O_WORKDIR  ) set PBS_O_WORKDIR = ~airpact5/AIRHOME/run_ap5_day2

# ----------------------------------------------------------------------

  # check CCTM log file (again)
    set logfile = $AIRLOGDIR/cctm/CTM_LOG_master.log
    if ( -e $logfile ) then
         set tmp_str1 = `tail -7 $logfile`
         set tmp_str2 = `echo "$tmp_str1[1-6]"`
         if ( `echo $tmp_str2` != `echo "--->> Normal Completion of program DRIVER"` ) then
            echo `date` >> $AIRLOGDIR/summary.txt
            echo "  because of error in" $logfile    >> $AIRLOGDIR/summary.txt
            echo "      will not cleanup CCTM files" >> $AIRLOGDIR/summary.txt
            exit(1) 
         endif
     else
        echo `date` >> $AIRLOGDIR/summary.txt
        echo "  because" $logfile "does not exist!" >> $AIRLOGDIR/summary.txt
        echo "      will not cleanup CCTM files"    >> $AIRLOGDIR/summary.txt
        exit(1) 
     endif

  # to get to this point, CCTM must have ran fine
  # now check that "combine" ran fine
    set logfile = $AIRLOGDIR/post/log01_post_combine.txt
    if ( -e $logfile ) then
       set tmp_str1 = `tail -4 $logfile`
       set tmp_str2 = `echo "$tmp_str1[1-6]"`
       if ( `echo $tmp_str2` != `echo "--->> Normal Completion of program COMBINE"` ) then
          echo `date` >> $AIRLOGDIR/summary.txt
          echo "  because of error in" $logfile     >> $AIRLOGDIR/summary.txt
          echo "      will not cleanup CCTM files"  >> $AIRLOGDIR/summary.txt
          exit(1)
       endif
    else
       echo `date` >> $AIRLOGDIR/summary.txt
       echo "  because" $logfile "does not exist!" >> $AIRLOGDIR/summary.txt
       echo "      will not cleanup CCTM files"    >> $AIRLOGDIR/summary.txt
       exit(1)
   endif

  # to get to this point, CCTM and "combine" (post processing) ran fine,
  # so we will clean up CCTM files
    /bin/rm -f $AIRLOGDIR/cctm.log
    /bin/rm -rf $AIRLOGDIR/cctm
    /bin/rm -rf $AIRLOGDIR/JPROC
    /bin/rm -rf $AIRLOGDIR/BCONC
    /bin/rm -f $AIROUT/CCTM/ACONC_${currentday}.ncf
    echo `date` >> $AIRLOGDIR/summary.txt
    echo "  JRPOC, BCONC, ACONC file removed            "  >> $AIRLOGDIR/summary.txt

  # check of curtain plots are created; if so, delete CONC file
    set logfile = $AIRLOGDIR/plot/cctm/log04_plot_ncl_curtain.txt
    set nfile = `ls -l $AIROUT/IMAGES/conc/hourly/gif | wc`
    if ( -e $logfile ) then
       set tmp = `grep -i fatal $logfile`
      if ( $#tmp > 0 || $nfile[1] != 49 ) then
          echo `date` >> $AIRLOGDIR/summary.txt
          echo "  because of error in creating curtain plots" >> $AIRLOGDIR/summary.txt
          echo "      will not remove CONC file"              >> $AIRLOGDIR/summary.txt
          exit(1)
       endif
    else
       echo `date` >> $AIRLOGDIR/summary.txt
       echo "  because" $logfile "does not exist!" >> $AIRLOGDIR/summary.txt
       echo "      will not remove CONC file"      >> $AIRLOGDIR/summary.txt
       exit(1)
   endif
   /bin/rm -f $AIROUT/CCTM/CONC_${currentday}.ncf
   echo `date` >> $AIRLOGDIR/summary.txt
   echo "  CONC file removed"  >> $AIRLOGDIR/summary.txt

  # check if visibility plots are created; if so, delete AEROVIS file
    set logfile = $AIRLOGDIR/plot/cctm/log05_plot_ncl_visibility.txt
    if ( -e $logfile ) then
       set tmp = `grep -i fatal $logfile`
       set nfile = `ls -l $AIROUT/IMAGES/aerovis/hourly/gif | wc`
      if ( $#tmp > 0 || $nfile[1] != 25 ) then
          echo `date` >> $AIRLOGDIR/summary.txt
          echo "  because of error in plotting visibility" >> $AIRLOGDIR/summary.txt
          echo "      will not remove AEROVIS file"        >> $AIRLOGDIR/summary.txt
          exit(1)
       endif
    else
       echo `date` >> $AIRLOGDIR/summary.txt
       echo "  because" $logfile "does not exist!" >> $AIRLOGDIR/summary.txt
       echo "      will not remove AEROVIS file"   >> $AIRLOGDIR/summary.txt
       exit(1)
   endif
   /bin/rm -f $AIROUT/CCTM/AEROVIS_${currentday}.ncf
   echo `date` >> $AIRLOGDIR/summary.txt
   echo "  AEROVIS file removed"  >> $AIRLOGDIR/summary.txt

  # remove AERODIAM file (eventually will need to wait till AOD plots)
    /bin/rm -f $AIROUT/CCTM/AERODIAM_${currentday}.ncf
    echo `date` >> $AIRLOGDIR/summary.txt
    echo "  AERODIAM file removed"  >> $AIRLOGDIR/summary.txt

  # remove deposition files
    foreach type ( DRYDEP WETDEP1 )
       /bin/rm -f $AIROUT/CCTM/${type}_${currentday}.ncf
       echo `date` >> $AIRLOGDIR/summary.txt
       echo "  $type file removed"  >> $AIRLOGDIR/summary.txt
    end # type

  # major cleanup of files from three days ago
    set AIROUTtda = $AIRROOT/$YEARtda/$threedaysago
    if ( -e $AIROUTtda/CCTM/CGRID_${threedaysago}.ncf ) then
       /bin/rm -rf $AIROUTtda/${threedaysago}/CCTM
       /bin/rm -rf $AIROUTtda/${threedaysago}/POST/CCTM/*.ncf
    endif
    echo `date` >> $AIRLOGDIR/summary.txt
    echo "  all CCTM output files from three days ago removed "  >> $AIRLOGDIR/summary.txt

