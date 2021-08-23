#!/usr/bin/env csh
##!/bin/csh -fX
# trying to run airpact5_KF_pm25toNetCDF.py

#    qsub4run_ncl_KFBC_PM25.template is a template to be edited using sed to substitute values for 
#    year as yyyy and date as yyyymmdd.  The tokens upon which sed will do the subsitutions are the 
#    uppercase versions of yyyy and yyyymmdd.
#   
#    examples of using this template:
#	cat <this-template> | sed -f sed.txt >! qsub<script-name>.csh
#	in the above sed operatin, only the substitutions for 2020 and 20200915 are needed in
#	the sed.txt file.
#    Once sed creates the script for the date to be run, the job can be submitted to the lar queue using qsub.	
#           qsub -V qsub4<script-name>.csh 
#    JKV 2020/05/29
#
#PBS -N KFBC-20200915 
#PBS -l nodes=1:amd:ppn=1,mem=5Gb
#PBS -l walltime=00:30:00
#PBS -q lar
#PBS -d /home/airpact5/AIRHOME/run_ap5_day1/post/cctm/KFBC
#PBS -o /data/lar/projects/airpact5/AIRRUN/2020/2020091500/LOGS/post
#PBS -e /data/lar/projects/airpact5/AIRRUN/2020/2020091500/LOGS/post
#PBS -j oe
#PBS -m ae
#PBS -M jvaughan@wsu.edu
#
#

#    forecast start time is 8 GMT 
# This template creates a script that runs a python script and then builds and executes ncl scripts. 

setenv NCARG_ROOT /home/lar/opt/ncl-6.0.0/gcc-4.1.2
setenv LOGS /data/lar/projects/airpact5/AIRRUN/2020/2020091500/LOGS/post

# Run python code section:
#
module load gcc/7.3.0
module load python/3.7.1/gcc/7.3.0
module load geos/3.7.0/gcc/7.3.0
module load proj/5.2.0/gcc/7.3.0

if ( ! $?basedir) setenv basedir /home/airpact5/AIRHOME/run_ap5_day1/post/cctm/KFBC

cd $basedir

#	This could output the log somewhere explicitly.
python3 airpact5_KF_pm25toNetCDF.py >&! $LOGS/airpact5_KF_pm25toNetCDF.log 
echo Status asfter python is $status
 
exit()
