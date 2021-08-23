#!/bin/csh -fX

# example of using this script:
# 
#   qsub -V -v YYYYMMDD=<yyyymmdd> qsub_waccm2bcon_py2.csh
#
#PBS -N WACCM2BCON
#PBS -l nodes=1:ppn=1,mem=20Gb
#PBS -l walltime=1:00:00
#PBS -d /home/airpact5/AIRHOME/run_ap5_day1/bcon_WACCM
## Defines the path to be used for the standard out and standard error stream
#PBS -o /home/airpact5/AIRHOME/run_ap5_day1/bcon_WACCM/waccm2bcon.log 
#PBS -e /home/airpact5/AIRHOME/run_ap5_day1/bcon_WACCM/waccm2bcon.log 
## Combine PBS standard output and error files
#PBS -j oe
####PBS -q lar
####PBS -W x=FLAGS:ADVRES
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
#
alias python '/share/apps/anaconda2-4.3.0/bin/python'
# 
setenv PYTHONPATH ${NETCDF}/share/apps/anaconda2-4.3.0/bin:/share/apps/anaconda2-4.3.0/pkgs
setenv PATH ${PYTHONPATH}:${PATH}
 
# check argument & set date strings  -----------------------------------
echo Running $0 with YYYYMMDD $YYYYMMDD 

  if ( $YYYYMMDD > 20000101 ) then     
     set YEAR  = `echo $YYYYMMDD | cut -c1-4`
     set MONTH = `echo $YYYYMMDD | cut -c5-6`
     set DAY   = `echo $YYYYMMDD | cut -c7-8`
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
   endif

#  exit(0)

# "pre"conditions --need to set during test ----------------------------

   if ( ! $?PBS_O_WORKDIR  ) set PBS_O_WORKDIR = ~airpact5/AIRHOME/run_day1
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
  #set prgdir  =  ~airpact5/AIRHOME/build/MOZART4_bcon/cb05_from_WACCM
  set prgdir  =  ~airpact5/AIRHOME/run_ap5_day1/bcon_WACCM
#  set wrkdir = ${PBS_O_WORKDIR}/bcon
#  set wrkdir = /home/airpact5/AIRHOME/run_day1/bcon
  mkdir -p ${AIRLOGDIR}/bcon
#	f.e20.FWSD.f09_f09_mg17.forecast.008.ch.cam.h3.2018-02-10-00000.nc
#	f.e20.FWSD.f09_f09_mg17.beta08_misc05_cam5_4_170.forecast.001.cam.h3.2018-07-11-00000.nc 
#	beta08_misc05_cam5_4_170.forecast.001.cam.h3
  set waccmfile1 = f.e21.FWSD.f09_f09_mg17.forecast.001.cam.h3.${YEAR}-${MONTH}-${DAY}-00000.nc 
  set waccmfile2 = f.e21.FWSD.f09_f09_mg17.forecast.001.cam.h3.${NYEAR}-${NMONTH}-${NDAY}-00000.nc 
  set waccmfile = waccm_forecast_${YEAR}-${MONTH}-${DAY}.nc 
  set MISC        = /data/lar/projects/airpact5/misc/WACCM_for_BCON
  set indir       = $MISC
  set outdir      = $BCONDIR/output; mkdir -p $outdir
  set bcon_template = bcon_cb05_10by6hr_template.ncf 
  set bcon_redated  = bcon_waccm_cb05_${currentday}.ncf
  echo bcon_redated is ${bcon_redated} 
  set PREVBCON    = NULL

# download CESM-WACCM file if necessary ----------------------------------

  if ( ! -d $indir) mkdir -p $indir
  cd $indir
  # should some of this be done by a cron job? 
  if ( ! -e $waccmfile1 || ! -e $waccmfile2 ) then
     if ( -e ${waccmfile1}.gz ) then
        gunzip ${waccmfile1}.gz
     endif
     if ( -e ${waccmfile2}.gz ) then
        gunzip ${waccmfile2}.gz
     endif
  endif
  if ( ! -e $waccmfile1 ) then
        echo "download CESM-WACCM file" $waccmfile1
        echo "wget -N -nv --no-check-certificate http://www.acom.ucar.edu/acresp/MODELING/mz4_output/waccm/${waccmfile1}"
        wget -N -nv --no-check-certificate http://www.acom.ucar.edu/acresp/MODELING/mz4_output/waccm/${waccmfile1}
        ls -lt $waccmfile1
  endif
  if ( ! -e $waccmfile2 ) then
        echo "download CESM-WACCM file" $waccmfile2
        echo "wget -N -nv --no-check-certificate http://www.acom.ucar.edu/acresp/MODELING/mz4_output/waccm/${waccmfile2}"
        wget -N -nv --no-check-certificate http://www.acom.ucar.edu/acresp/MODELING/mz4_output/waccm/${waccmfile2}
        ls -lt $waccmfile2
  endif

# convert CESM-WACCM output file to CMAQ BCON-formatted file -------------

#  catenate two input files into one 
#  ncrcat $waccmfile1 $waccmfile2 $waccmfile
if ( ! -e $waccmfile ) then

   rm -f  temp_waccm_1.nc 
   ncks -d lat,39.,51. -d lon,233.,251.25   $waccmfile1  temp_waccm_1.nc
#  ncks -d lat,35.,54. -d lon,230.,255.   $waccmfile1  temp_waccm_1.nc
   ls -lt temp_waccm_1.nc

   rm -f  temp_waccm_2.nc 
   ncks -d lat,39.,51. -d lon,233.,251.25   $waccmfile2  temp_waccm_2.nc
#  ncks -d lat,35.,54. -d lon,230.,255.   $waccmfile2  temp_waccm_2.nc
#  The overall process, including this scripting and the python code invoked at the bottom,
#  was tested using a somewhat larger lat&long WACCM subset, as seen in the ncks stmts commented out above. 
#  Tests show that the lat&long cuts in the ncks stmts above are adequate to find the WACCM data 
#  nearest the AIRPACT BCON preimiter cells.
   ls -lt temp_waccm_2.nc

   ncrcat  temp_waccm_1.nc temp_waccm_2.nc $waccmfile

endif

ls -lt $waccmfile

# Timeshift bcon template file
#
#get SDATE from MCIP file
set SDATE = `ncdump -h $MCIPDIR/METCRO2D | grep SDATE | cut -c12-18 ` 
setenv INFILE bcon_cb05_10by6hr_template.ncf
#setenv OUTFILE bcon_cb05_${currentday}_WACCM.ncf
setenv OUTFILE bcon_cb05_${currentday}.ncf

echo use m3tshift to convert $INFILE to $OUTFILE

cat >! m3tshift.txt << EOF
INFILE


$SDATE



OUTFILE
EOF

cat m3tshift.txt | m3tshift >! m3tshift.log
echo Status on m3tshift is $status


echo DUMP OF OUTFILE $OUTFILE ========================================================
echo DUMP OF OUTFILE $OUTFILE ========================================================
echo DUMP OF OUTFILE $OUTFILE ========================================================
ncdump -h $OUTFILE 
echo END OF DUMP OF OUTFILE $OUTFILE ========================================================
echo END OF DUMP OF OUTFILE $OUTFILE ========================================================
echo END OF DUMP OF OUTFILE $OUTFILE ========================================================

echo run python script
python -V 
python $prgdir/WACCM_open_plot_write_BCON_py2.py  $currentday >&! $AIRLOGDIR/bcon/WACCM_open_plot_write_BCON.log
echo Status on python script $status 

# Copy BCON file to outdir
mv $OUTFILE $outdir
ls -lt $outdir

echo ' finished in ${0}' 
exit(0)
