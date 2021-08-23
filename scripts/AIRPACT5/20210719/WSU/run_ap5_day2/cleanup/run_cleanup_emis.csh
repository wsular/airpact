#!/bin/csh -f

# example of using this script:
# 
#   > ./run_cleanup_emis.csh 20160530
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
     set twodaysago  = `date -d "$currentday -2 days" '+%Y%m%d'`
     set DOYstring = `juldate $MONTH $DAY $YEAR | cut -d',' -f 2`
     set DOY       = `echo $DOYstring | cut -c5-7`
     set YEARDOY   = $YEAR$DOY
   endif

# "pre"conditions --need to set during test ----------------------------

   if ( ! $?AIRHOME        ) set AIRHOME = ~airpact5/AIRHOME
   if ( ! $?AIRRUN         ) set AIRRUN  = /data/lar/projects/airpact5/AIRRUNDAY2/$YEAR
   if ( ! $?AIROUT         ) set AIROUT = $AIRRUN/${currentday}00
   if ( ! $?AIRLOGDIR      ) set AIRLOGDIR = $AIROUT/LOGS
   if ( ! $?MCIPDIR        ) set MCIPDIR   = $AIROUT/MCIP
   if ( ! $?BCONDIR        ) set BCONDIR   = $AIROUT/BCON
   if ( ! $?PBS_O_WORKDIR  ) set PBS_O_WORKDIR = ~airpact5/AIRHOME/run_ap5_day2

# ----------------------------------------------------------------------

  # MEGAN
    set logfile = $AIRLOGDIR/emis/megan2.10/log01_met2mgn.txt
    if ( -e $logfile ) then
         set tmp_str1 = `tail -1 $logfile`
         set tmp_str2 = `echo "$tmp_str1[1-4]"`
         if ( `echo $tmp_str2` != `echo "Normal completion by met2mgn"` ) then
            echo `date` >> $AIRLOGDIR/summary.txt
            echo "  error in" $logfile        >> $AIRLOGDIR/summary.txt
            exit(1) 
         endif
     else
        echo `date` >> $AIRLOGDIR/summary.txt
        echo " " $logfile "does not exist!"   >> $AIRLOGDIR/summary.txt
        exit(1) 
     endif
    set logfile = $AIRLOGDIR/emis/megan2.10/log02_emproc.txt
    if ( -e $logfile ) then
       set tmp_str1 = `tail -4 $logfile`
       set tmp_str2 = `echo "$tmp_str1[1-6]"`
       if ( `echo $tmp_str2` != `echo "--->> Normal Completion of program EMPROC"` ) then
          echo `date` >> $AIRLOGDIR/summary.txt
          echo "  error in" $logfile     >> $AIRLOGDIR/summary.txt
          exit(1)
       endif
    else
       echo `date` >> $AIRLOGDIR/summary.txt
       echo "  because" $logfile "does not exist!" >> $AIRLOGDIR/summary.txt
       exit(1)
   endif

   /bin/rm -f $AIROUT/EMISSION/megan2.10/met4megan_${currentday}.ncf
   /bin/rm -f $AIROUT/EMISSION/megan2.10/er_${currentday}.ncf
   echo `date` >> $AIRLOGDIR/summary.txt
   echo "  intermediate MEGAN files removed            "  >> $AIRLOGDIR/summary.txt

  # anthropogenic emission files
    set logfile = $AIRLOGDIR/emis/anthro/log03c_mrggrid_AIRPACT_04km_CB05_2014nw_${YEARDOY}.txt
    if ( -e $logfile ) then
       set tmp_str1 = `tail -4 $logfile`
       set tmp_str2 = `echo "$tmp_str1[1-6]"`
       if ( `echo $tmp_str2` != `echo "--->> Normal Completion of program MRGGRID"` ) then
          echo `date` >> $AIRLOGDIR/summary.txt
          echo "  error in" $logfile     >> $AIRLOGDIR/summary.txt
          exit(1)
       endif
    else
       echo `date` >> $AIRLOGDIR/summary.txt
       echo "  " $logfile "does not exist!" >> $AIRLOGDIR/summary.txt
       exit(1)
   endif


   /bin/rm -rf $AIROUT/EMISSION/anthro/scenario
   if ( -d $AIROUT/EMISSION/anthro/output/all_other/*.ncf ) then
      /bin/rm -f  $AIROUT/EMISSION/anthro/output/all_other/*.ncf
   endif
   if ( -d $AIROUT/EMISSION/anthro/output/all_afdust/*.ncf ) then
      /bin/rm -f  $AIROUT/EMISSION/anthro/output/all_afdust/*.ncf
   endif
   if ( -d $AIROUT/EMISSION/anthro/output/all_nodust/*.ncf ) then
      /bin/rm -f  $AIROUT/EMISSION/anthro/output/all_nodust/*.ncf
   endif
   /bin/rm -f  $AIROUT/EMISSION/anthro/output/nonroad_model/*.ncf
   /bin/rm -f  $AIROUT/EMISSION/anthro/output/point/*.ncf
   /bin/rm -f  $AIROUT/EMISSION/anthro/output/rwc_tpy_method/*.ncf
   /bin/rm -f  $AIROUT/EMISSION/anthro/output/seca/*.ncf
   /bin/rm -rf $AIROUT/EMISSION/anthro/moves/met
   /bin/rm -rf $AIROUT/EMISSION/anthro/moves/scenario
   /bin/rm -rf $AIROUT/EMISSION/anthro/moves/output/cmaq_cb05_soa

   echo `date` >> $AIRLOGDIR/summary.txt
   echo "  intermediate emission files removed "  >> $AIRLOGDIR/summary.txt

   /bin/rm -rf $AIROUT/EMISSION/fire/smoke
   /bin/rm -rf $AIROUT/EMISSION/fire_can/smoke
   /bin/rm -rf $AIROUT/EMISSION/fire_can/scenario
   echo "  fire SMOKE output files deleted   "  >> $AIRLOGDIR/summary.txt
