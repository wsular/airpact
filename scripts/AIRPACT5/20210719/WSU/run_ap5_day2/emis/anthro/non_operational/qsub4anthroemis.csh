#!/bin/csh -f

#
#
#  2016-03-24    Serena H. Chung      
#    stand-alone to run anthropogenic emissions.  
#   for Farren to test smkreport.
#
#
#    examples of using this script:

#           qsub -V -N ap5anthro20160202 -v currentday=20160202 qsub4anthroemis.csh
#
#PBS -l nodes=1:amd:ppn=1,mem=7Gb
#PBS -l walltime=02:30:00
#PBS -d ~airpact5/AIRHOME/run_ap5_day2
#PBS -o ~airpact5/AIRHOME/run_ap5_day2/emis/anthro/non_operational
#PBS -e ~airpact5/AIRHOME/run_ap5_day2/emis/anthro/non_operational
#PBS -j oe

# mail options
###PBS -m abe
###PBS -m a
###PBS -M serena_chung@wsu.edu

# -------------------------- end of PBS options ------------------------

  # directories
    set year = `echo $currentday | cut -c1-4`
    setenv AIRHOME         ~airpact5/AIRHOME
    setenv AIRROOT         /data//lar/projects/airpact5/AIRRUN
    setenv AIRRUN          /data//lar/projects/airpact5/AIRRUN/${year}
    setenv AIROUT          /data//lar/projects/airpact5/AIRRUN/${year}/${currentday}00
    setenv AIRLOGDIR       /data//lar/projects/airpact5/AIRRUN/${year}/${currentday}00/LOGS
    setenv MCIPROOT        /data/airpact4/AIRRUN
    setenv MCIPDIR         /data/airpact4/AIRRUN/${currentday}00/MCIP
    setenv BCONDIR         /data//lar/projects/airpact5/AIRRUN/${year}/${currentday}00/BCON
  # switches
    setenv RUN_EMIS_ANTHRO     Y   
				                   
# running various pre-CCTM components
  set exitstat = 0


  # anthropogenic emissions (including MOVES)
    if ( $RUN_EMIS_ANTHRO == 'Y'  ) then
       echo ' '
       echo '-----------------------------------------'
       echo "run scripts for anthropogenic emissions"
       ./emis/anthro/run_emis_anthro.csh ${currentday} 24
       set exitstat = $status
       if ( $exitstat ) then
          echo "--- error in ~airpact5/AIRHOME/run_ap5_day2/emis/anthro/run_emis_anthro.csh"
          exit ( $exitstat )
       endif
       echo 'end script:' `date`; echo ' '
    endif # RUN_EMIS_ANTHRO



