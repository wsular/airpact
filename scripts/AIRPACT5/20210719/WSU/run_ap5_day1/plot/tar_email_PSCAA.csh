#!/bin/csh -f

# example of using this script:
# 
#   > ./tar_email_PSCAA.csh 20180821  
#
#   Joe Vaughan  2018-08-21  New script to tar up curatin plots for PSCAA and email them to Erik Saginac.
# 

#> initialize exit status ----------------------------------------------
   set exitstat = 0

#> check argument & set date strings  ----------------------------------

   if ( $1 > 20000100 ) then     
      set YEAR  = `echo $1 | cut -c1-4`
      set MONTH = `echo $1 | cut -c5-6`
      set DAY   = `echo $1 | cut -c7-8`
     #set HOUR = `echo $1 | cut -c9-10`
      set currentday = $YEAR$MONTH$DAY
      set previousday = `date -d "$currentday -1 days" '+%Y%m%d'`
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
   endif

#> tar up files for PSCAA

   cd $AIROUT/IMAGES/aconc/hourly/gif
   rm -f *tar.gz
   ls -1 airpact5_S-N_62_co_curtain_06.gif airpact5_S-N_62_co_curtain_12.gif airpact5_S-N_62_co_curtain_18.gif airpact5_S-N_62_co_curtain_23.gif \
     airpact5_S-N_62_pm25_curtain_06.gif airpact5_S-N_62_pm25_curtain_12.gif airpact5_S-N_62_pm25_curtain_18.gif airpact5_S-N_62_pm25_curtain_23.gif \
     airpact5_W-E_198_co_curtain_06.gif airpact5_W-E_198_co_curtain_12.gif airpact5_W-E_198_co_curtain_18.gif airpact5_W-E_198_co_curtain_23.gif \
     airpact5_W-E_198_pm25_curtain_06.gif airpact5_W-E_198_pm25_curtain_12.gif airpact5_W-E_198_pm25_curtain_18.gif airpact5_W-E_198_pm25_curtain_23.gif \
         >! PSCCA_gifs.txt

   echo Files for PSCAA
   echo  ================================================================================================================
   cat PSCCA_gifs.txt     
   echo  ================================================================================================================
         
   tar cvzf $1_PSCAA_curtains.tar.gz `cat PSCCA_gifs.txt | tr '\n' ' ' `

   set recipients = 'ErikS@pscleanair.org'
#   set recipients = 'jvaughan@wsu.edu'

   echo "Attached should be curtain plots requesetd by PSCAA for $currentday" | mail -s "CURTAINS for ${currentday}" -a $1_PSCAA_curtains.tar.gz  $recipients

   set mailstatus = $status
     echo "mail of $1_PSCAA_curtains.tar.gz file with status $mailstatus "

   echo "finished in $0 "
