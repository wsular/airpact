#!/bin/csh -f

# Serena H. Chung
# 2011-12-15
# 
# Run time-independent SMOKE scripts
#


##Path of SMOKE
  setenv SMK_HOME    ~airpact5/models/SMOKEv3.5.1
  setenv SMK_SUBSYS  $SMK_HOME/subsys                                # SMOKE subsystem dir
  setenv SMKROOT     $SMK_SUBSYS/smoke                               # System root dir
  setenv SMKDAT      $SMK_HOME/data                                  # Data root dir
  setenv ASSIGNS     ${PBS_O_WORKDIR}/emis/anthro/assigns  # smoke assigns files
  setenv SMOKE_EXE   Linux2_x86_64pg
  setenv SMK_BIN     ${SMKROOT}/${SMOKE_EXE}
  setenv MD_SRC      ${SMKROOT}/src/emmod 
  setenv SMKINC      ${SMKROOT}/src/inc


#${PBS_O_WORKDIR}/emis/anthro/non_temporal/smk_pt_airpact5.csh # smkinven and grdmat

#${PBS_O_WORKDIR}/emis/anthro/non_temporal/smk_ar_all_airpact5.csh  # smkinven and grdmat 

#${PBS_O_WORKDIR}/emis/anthro/non_temporal/smk_ar_all_airpact5.csh  # smkinven and grdmat (replaced by afdust and nodust)

${PBS_O_WORKDIR}/emis/anthro/non_temporal/smk_ar_nodust_airpact5.csh  # smkinven and grdmat (partially replaces all_other)

${PBS_O_WORKDIR}/emis/anthro/non_temporal/smk_ar_afdust_airpact5.csh  # smkinven and grdmat (partially replaces all_other)

#${PBS_O_WORKDIR}/emis/anthro/non_temporal/smk_nr_seca_airpact5.csh #  smkinven and grdmat

#${PBS_O_WORKDIR}/emis/anthro/non_temporal/smk_nr_nr_airpact5.csh   # smkinven and grdmat

echo completing $0 
