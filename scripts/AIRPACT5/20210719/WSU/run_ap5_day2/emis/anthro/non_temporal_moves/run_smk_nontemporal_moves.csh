#!/bin/csh -f

# Serena H. Chung
# 2013-04-23
# 
# Run time-independent SMOKE scripts for MOVES
#


setenv PBS_O_WORKDIR ~airpact5/AIRHOME/run_ap5_day2

##Path of SMOKE
  setenv SMK_HOME    ~airpact5/models/SMOKEv3.5.1

  setenv SMK_SUBSYS  $SMK_HOME/subsys                                # SMOKE subsystem dir
  setenv SMKROOT     $SMK_SUBSYS/smoke                               # System root dir
  setenv SMKDAT      $SMK_HOME/data                                  # Data root dir

  setenv ASSIGNS     ${PBS_O_WORKDIR}/emis/anthro/assigns_moves      # smoke assigns files
  setenv SMOKE_EXE   Linux2_x86_64pg
  setenv SMK_BIN     ${SMKROOT}/${SMOKE_EXE}
 #setenv MD_SRC      ${SMKROOT}/src/emmod 
 #setenv SMKINC      ${SMKROOT}/src/inc

${PBS_O_WORKDIR}/emis/anthro/non_temporal_moves/smk_onroad.csh
${PBS_O_WORKDIR}/emis/anthro/non_temporal_moves/smk_offroad_rpv.csh
${PBS_O_WORKDIR}/emis/anthro/non_temporal_moves/smk_offroad_rpp.csh
