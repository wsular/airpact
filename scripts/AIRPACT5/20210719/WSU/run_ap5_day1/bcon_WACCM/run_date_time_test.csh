#!/bin/csh -f

# example of using this script:
# 
#   > ./run_waccm2bcon_py2_10step.csh 20151113
#
#   takes ~2 minutes to run
#
#  2015-11-13    Serena H. Chung      initial version
#  2017-08-05    Joe Vaughan   Added --no-check-certificate on wget for waccm data
#  2017-11-16    Joe Vaughan   Added logic to use m3shift to redate previous day's bcon 
#  2018-08-28    Joe Vaughan   New      1) Gets WACCM files (two) and catenates them.
#					2) redates BCON template file.
#					3) python code reads WACCM file, converts data 	
#						to CB05 and AERO6 for CMAQ use, & writes it.
# initialize exit status -----------------------------------------------
  set exitstat = 0

# Amend setup to use anaconda2 python 2 stuff:
alias python '/share/apps/anaconda2-4.3.0/bin/python'
# 
setenv PYTHONPATH ${NETCDF}/share/apps/anaconda2-4.3.0/bin:/share/apps/anaconda2-4.3.0/pkgs
setenv PATH ${PYTHONPATH}:${PATH}
 
# check argument & set date strings  -----------------------------------

  if ( $1 > 20000101 ) then     
     set YEAR  = `echo $1 | cut -c1-4`
     set MONTH = `echo $1 | cut -c5-6`
     set DAY   = `echo $1 | cut -c7-8`
     set currentday  = $YEAR$MONTH$DAY
     echo CURRENTDAY $currentday 
     set previousday = `date -d "$currentday -1 days" '+%Y%m%d'`
     echo PREVIOUSDAY $previousday 
     set PYEAR  = `echo $previousday | cut -c1-4`
     set PMONTH = `echo $previousday | cut -c5-6`
     set PDAY   = `echo $previousday | cut -c7-8`
     set twodaysago  = `date -d "$currentday -2 days" '+%Y%m%d'`
     set previousdayyear = $PYEAR
     set nextday = `date -d "$currentday +1 days" '+%Y%m%d'`
     echo NEXTDAY $nextday 
     set NYEAR  = `echo $nextday | cut -c1-4`
     set NMONTH = `echo $nextday | cut -c5-6`
     set NDAY   = `echo $nextday | cut -c7-8`
     set nextnextday = `date -d "$currentday +2 days" '+%Y%m%d'`
     echo NEXTNEXTDAY $nextnextday 
     set NNYEAR  = `echo $nextnextday | cut -c1-4`
     set NNMONTH = `echo $nextnextday | cut -c5-6`
     set NNDAY   = `echo $nextnextday | cut -c7-8`
   endif

# "pre"conditions --need to set during test ----------------------------

   if ( ! $?PBS_O_WORKDIR  ) set PBS_O_WORKDIR = ~airpact5/AIRHOME/run_ap5_day1
   if ( ! $?AIRHOME        ) set AIRHOME = ~airpact5/AIRHOME
   if ( ! $?AIRRUN ) then
      set AIRROOT = /data/lar/projects/airpact5/AIRRUN
      set AIRRUN  = $AIRROOT/$YEAR
   endif
   if ( ! $?AIROUT         ) set AIROUT = $AIRRUN/${currentday}00
   if ( ! $?AIRLOGDIR      ) set AIRLOGDIR = $AIROUT/LOGS
   if ( ! $?MCIPDIR        ) then
     if ( -e $AIROUT/MCIP/METCRO2D ) then
        set MCIPDIR   = $AIROUT/MCIP37
     else
        set MCIPDIR   = /data/lar/projects/airpact5/AIRRUN/$YEAR/${currentday}00/MCIP37
     endif
   endif
   if ( ! $?BCONDIR        ) set BCONDIR   = $AIROUT/BCON


   if ( ! -e $MCIPDIR/METCRO3D ) then
      echo ${MCIPDIR}"/METCRO3D  file does not exit; exiting ${0}"
      exit(1)
   endif

# directories and files ------------------------------------------------
  set prgdir  =  ~airpact5/AIRHOME/run_ap5_day1/bcon_WACCM

#  set wrkdir = ${PBS_O_WORKDIR}/bcon
  set wrkdir = /home/airpact5/AIRHOME/run_day1/bcon
  mkdir -p ${AIRLOGDIR}/bcon
#	f.e20.FWSD.f09_f09_mg17.forecast.008.ch.cam.h3.2018-02-10-00000.nc
#	f.e20.FWSD.f09_f09_mg17.beta08_misc05_cam5_4_170.forecast.001.cam.h3.2018-07-11-00000.nc 
#	beta08_misc05_cam5_4_170.forecast.001.cam.h3
# pre2018-10-30  set waccmfile1 = f.e20.FWSD.f09_f09_mg17.beta08_misc05_cam5_4_170.forecast.001.cam.h3.${YEAR}-${MONTH}-${DAY}-00000.nc 
# pre2018-10-30  set waccmfile2 = f.e20.FWSD.f09_f09_mg17.beta08_misc05_cam5_4_170.forecast.001.cam.h3.${NYEAR}-${NMONTH}-${NDAY}-00000.nc 
  set waccmfile1 = f.e21.FWSD.f09_f09_mg17.forecast.001.cam.h3.${YEAR}-${MONTH}-${DAY}-00000.nc 
  set waccmfile2 = f.e21.FWSD.f09_f09_mg17.forecast.001.cam.h3.${NYEAR}-${NMONTH}-${NDAY}-00000.nc 
  set waccmfile3 = f.e21.FWSD.f09_f09_mg17.forecast.001.cam.h3.${NNYEAR}-${NNMONTH}-${NNDAY}-00000.nc 
  set waccmfile = waccm_forecast_${YEAR}-${MONTH}-${DAY}.nc 
  set MISC        = /data/lar/projects/airpact5/misc/WACCM_for_BCON
  set indir       = $MISC
  set outdir      = $BCONDIR/output; mkdir -p $outdir
  set bcon_template = bcon_cb05_10by6hr_template.ncf 
  set bcon_redated  = bcon_waccm_cb05_${currentday}.ncf
  set PREVBCON    = NULL

# download CESM-WACCM file if necessary ----------------------------------

  if ( ! -d $indir) mkdir -p $indir
  cd $indir

# Timeshift bcon template file
#
#get SDATE from MCIP file
set SDATE = `ncdump -h $MCIPDIR/METCRO2D | grep SDATE | cut -c12-18 ` 
setenv INFILE bcon_cb05_10by6hr_template.ncf
#setenv OUTFILE bcon_cb05_${1}_WACCM.ncf
setenv OUTFILE bcon_cb05_${1}.ncf

echo use m3tshift to convert $INFILE to $OUTFILE

cat >! m3tshift.txt << EOF
INFILE


$SDATE



OUTFILE
EOF

cat m3tshift.txt | m3tshift >! m3tshift.log
echo Status on m3tshift is $status

set greptarget = 'Timestep written'
#echo ===
#grep -a "$greptarget"  m3tshift.log | cut -c53-60 
#echo ===
#grep -a "$greptarget" m3tshift.log | cut -c53-60 
#echo ===
#grep -a "$greptarget" m3tshift.log | cut -c53-60 | tr '\n' ', ' 
#echo ===
#grep -a "$greptarget" m3tshift.log | cut -c53-60 | tr '\n' ', ' | sed 's/,$/ /' 
#echo ===
grep -a "$greptarget" m3tshift.log | cut -c53-60 | tr '\n' ', ' | sed 's/,$/ /' > ! BCON_YYYYDDD.txt 


grep -a "$greptarget" m3tshift.log | cut -c62-67 | tr '\n' ',' | sed 's/,$//' | sed 's/,/, /' > ! BCON_HHMMSS.txt 

echo BCON_YYYYDDD.txt
echo
echo ===
cat BCON_YYYYDDD.txt
echo
set BCON_YYYYDDD = `cat BCON_YYYYDDD.txt`
echo $BCON_YYYYDDD
echo
echo

echo BCON_HHMMSS.txt
cat BCON_HHMMSS.txt
echo
set BCON_HHMMSS = `cat BCON_HHMMSS.txt`
echo $BCON_HHMMSS

cat >! BCON_DATE.txt << EOF
s/__YYYYDDD__/${BCON_YYYYDDD}/
s/__HHMMSS__/${BCON_HHMMSS}/
EOF

exit(0)

cat WACCM_open_plot_write_BCON_py2_10step.template.py | sed -f BCON_DATE.txt >! $prgdir/today.py

exit(0)