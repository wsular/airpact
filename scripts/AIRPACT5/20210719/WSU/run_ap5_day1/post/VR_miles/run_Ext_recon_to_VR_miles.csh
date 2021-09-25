#!/usr/bin/env csh
# #!/bin/csh -fX

# example of using this script:
# 
#   > ./run_waccm2bcon_py3_10step_fs_ref.csh 20151113
#
#   takes ~2 minutes to run
#
#  2021-09-23    Joe Vaughan   Original VR_miles script to:
#  1) Copy (m3xtract) Ext_recon from AEROVIS file produced by CMAQ into new single variable file,
#  2) Set up python code to read new file and replace values of the Ext_recon variable with VR_miles,
#  3) Rename modified  file and variable to agree with VR_miles,
#  4) Generate graphics:
#
# initialize exit status -----------------------------------------------
  set exitstat = 0

# set flag for controlling whether full WACCM to BCON occurs using python script or previous day BCON file is redatted.
set TRUE = 0
set FALSE = 1

# Code in /home/airpact5/AIRHOME/run_ap5_day1/post/VR_miles
# files in code dir are:
#  Ext_recon_to_VR_miles.py
#  run_Ext_recon_to_VR_miles.csh (this file runs python code )

echo = = = = = = =
echo " set up module command, anew "
unalias module
source /etc/profile.d/modules.csh
which module
echo = = = = = = =
module purge
module load python/3.8/gcc/7.3.0
module load proj/5.2.0/gcc/7.3.0
module load geos/3.7.0/gcc/7.3.0
#  pip3 install --user cartopy  # comment out after successful?

module list

#  which python
which python3
  
# check argument & set date strings  -----------------------------------

  if ( $1 > 20000101 ) then     
     set YEAR  = `echo $1 | cut -c1-4`
     set MONTH = `echo $1 | cut -c5-6`
     set DAY   = `echo $1 | cut -c7-8`
     set currentday  = $YEAR$MONTH$DAY
     echo CURRENTDAY $currentday 
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
#_   if ( ! $?MCIPDIR        ) then
#_     if ( -e $AIROUT/MCIP/METCRO2D ) then
#_        set MCIPDIR   = $AIROUT/MCIP37
#_     else
#_        set MCIPDIR   = /data/lar/projects/airpact5/AIRRUN/$YEAR/${currentday}00/MCIP37
#_     endif
#_   endif
#_   if ( ! -e $MCIPDIR/METCRO3D ) then
#_      echo ${MCIPDIR}/METCRO3D " file does not exit; exiting ${0}"
#_      exit(1)
#_   endif


# directories and files ------------------------------------------------
#

  setenv LOGDIR ${AIRLOGDIR}/VR_miles
  mkdir -p ${LOGDIR}

  if ( ! $?CCTMDIR ) set CCTMDIR   = $AIROUT/CCTM
  #setenv INFILE $CCTMDIR/AEROVIS_${currentday}.ncf
  #ls -lt $INFILE

  if ( ! $?POSTDIR ) set POSTDIR   = $AIROUT/POST/CCTM
#  if ( ! -d $POSTDIR) mkdir -p $POSTDIR

  set prgdir  =  ~airpact5/AIRHOME/run_ap5_day1/post/VR_miles 

#  1) Copy (m3xtract) Ext_recon from AEROVIS file produced by CMAQ into new single variable file,
#  set up input for m3xtract
#cd $CCTMDIR
#cat >! m3xtract.txt << EOF
#INFILE
#0
#4
#
#0
#
#
#
#EXT_Recon.ncf
#EOF

# check on files
#ls -lt $INFILE m3xtract.txt
# extract to new file
#cat m3xtract.txt | m3xtract >&! $LOGDIR/m3xtract.log
#echo Status on m3xtract is $status
# check on new file
#ls -lt EXT_Recon.ncf
#mv EXT_Recon.ncf EXT_Recon_$currentday.ncf
# 
cd $prgdir

#  2) Set up python code to read new file and replace values of the Ext_recon variable with VR_miles,
# no need to  create sed input file because YYYYMMDD can be passed as argument to python script.
echo run python3 script
python3 -V 
python3 $prgdir/Ext_recon_to_VR_miles_VPW.py  $currentday >&!  $LOGDIR/Ext_recon_to_VR_miles_py3.log
echo Status after python3 $status
ls -lt

#  3) Rename modified file and variable to agree with VR_miles,
#   setenv INFILE $CCTMDIR/EXT_Recon_$currentday.ncf
##  set up m3edhdr input
#cat >! m3edhdr.txt << EOF
#INFILE
#5
#VR_miles
#mi
#Visual Range [mi]
#10
#EOF

#cat m3edhdr.txt | m3edhdr >&! $LOGDIR/m3edhdr.log
#echo Status on m3edhdr is $status

#mv $INFILE $POSTDIR/VR_miles_$currentday.ncf
ls -lt $POSTDIR/VR_miles_$currentday.ncf
ncdump -h $POSTDIR/VR_miles_$currentday.ncf

#  4) Generate graphics:

echo  finished in ${0} 
exit(0)

