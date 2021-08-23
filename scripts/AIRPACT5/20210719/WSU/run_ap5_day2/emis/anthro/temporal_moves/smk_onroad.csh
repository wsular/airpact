#!/bin/csh -f
#
# Version @(#)$Id: smk_onroad_MOVES.csh,v 1.1 2010/09/26 20:30:33 bbaek Exp $
# Path    $Source: /afs/isis/depts/cep/emc/apps/archive/smoke/smoke/scripts/run/smk_onroad_MOVES.csh,v $
# Date    $Date: 2010/09/26 20:30:33 $
# 
# This script generates onroad rateperdistance emission
# called by smk_mb_moves.csh
#
# This script sets up needed environment variables for processing area source
# emissions in SMOKE and calls the scripts that run the SMOKE programs. 
#
# Script created by : B. Baek, Institute for the Environment in UNC at Chapel Hill 
#
#*********************************************************************


## set source category
   setenv SMK_SOURCE    M
   setenv MRG_SOURCE    M
   setenv INVEN         moves
   setenv INVOP         moves
   setenv FYIOP         moves
   setenv ESCEN         moves
   setenv SUBSECT       onroad

## set programs to run...

   ## time-independent programs
      setenv RUN_SMKINVEN  N          # run inventory import program
      setenv RUN_SPCMAT    N          # run speciation matrix program
      setenv RUN_GRDMAT    N          # run gridding matrix program

   ## time-dependent programs
     setenv RUN_TEMPORAL  Y          # run temporal allocation program
     setenv RUN_MOVESMRG  Y          # run merge program

## program-specific controls...

## for Temporal
   setenv SMK_EF_MODEL     MOVES  # processing MOVES model for mobile source emissions
   setenv RENORM_TPROF         Y  # Y renormalizes temporal profiles
   setenv UNIFORM_TPROF_YN     N  # Y makes all temporal profiles uniform
   setenv ZONE4WM              Y  # Y uses time zones for start of day & month#      OUTZONE          see "Multiple-program controls" below
   setenv MTMP_OUTPUT_YN       Y  # Y requires variable MTMP_INV to be set below and will optionally output hourly emissions for smkreport

## for Movesmrg
   setenv RPD_MODE             Y          # Y process on-roadway emission factors
   setenv RPV_MODE             N          # Y process off-network emission factors
   setenv RPP_MODE             N          # Y process off-network vapor venting EFs
   setenv MRG_GRDOUT_YN        Y          # Y outputs gridded file
   setenv MRG_TEMPORAL_YN      Y          # Y merges with hourly emissions
   setenv MRG_SPCMAT_YN        Y          # Y merges with speciation matrix
   setenv MRG_REPCNY_YN        N          # Y produces a report of emission totals by county
   setenv MRG_REPSTA_YN        N          # Y produces a report of emission totals by state
   setenv MRG_GRDOUT_UNIT      moles/s    # units for gridded output file
   setenv MRG_TOTOUT_UNIT      tons/day  # units for state and/or county totals
   setenv SMK_REPORT_TIME      070000     # hour in OUTZONE for reporting emissions  
   setenv TVARNAME             TEMP2      # define name of temperature for the lookup tables
   setenv MOVESMRG_CUSTOM_OUTPUT Y        # Y allows AOUT, BOUT, MOUT, and POUT

## multiple-program controls
   setenv OUTZONE              0     # output time zone of emissions
   setenv REPORT_DEFAULTS      N     # Y reports default profile application
   setenv SMK_DEFAULT_TZONE    8     # time zone to fix in missing COSTCY file
   setenv SMK_AVEDAY_YN        N     # Y uses average day emissions instead of annual
   setenv SMK_MAXWARNING       100   # maximum number of warnings in log file
   setenv SMK_MAXERROR         10000   # maximum number of errors in log file
   setenv USE_SPEED_PROFILES   Y     # Y uses speed profiles instead of inventory speeds
   setenv FULLSCC_ONLY         Y     # Y only matches profiles by full SCCs

## script settings
   setenv SRCABBR              rateperdistance  # abbreviation for naming log files
   setenv QA_TYPE              all # type of QA to perform [none, all, part1, part2, or custom]
   setenv PROMPTFLAG           N   # Y prompts for user input
   setenv AUTO_DELETE          Y   # Y automatically deletes I/O API NetCDF output files
   setenv AUTO_DELETE_LOG      Y   # Y automatically deletes log files
   setenv DEBUGMODE            N   # Y runs program in debugger
   setenv DEBUG_EXE            pgdbg # debugger to use when DEBUGMODE = Y

##############################################################################

## loop through days to run temporal and smkmerge
#
   setenv RUN_PART1 N
   setenv RUN_PART2 Y
   setenv RUN_PART4 Y

   set g_stdate_sav = $G_STDATE # needed?

   setenv INVOPD    $INTERMED/moves/$SUBSECT
   setenv MOBL      $INTERMED/moves/$SUBSECT/mobl.map.$SRCABBR.$FYIOP.txt
   #setenv MRCLIST   $SMK_MVSPATH/mrclist.${SRCABBR}.summed.lst
   setenv MRCLIST   $SMK_MVSPATH/mrclist.${SRCABBR}_noRFL.summed.lst # changed since Wei's script produces *_noRFL* filename   # vikram 7/6/15
   setenv MEPROC    $GE_DAT/meproc.$SRCABBR.txt

   setenv MTMPNAME  $M_OUT/scenario/mtmp_${SUBSECT}_${SRCABBR}_
   setenv MTMP      ${MTMPNAME}$G_STDATE.ncf
   setenv MTMP_INV  ${MTMPNAME}_INV_${G_STDATE}.ncf

   setenv MTSUPNAME $M_OUT/scenario/mtsup_${SUBSECT}_${SRCABBR}_
   setenv MTSUP     ${MTSUPNAME}$G_STDATE.txt
   setenv MGMAT     $NONTEMPORAL/output/moves/$SUBSECT/merge/moves/static/mgmat.$SRCABBR.$GRID.moves.ncf
   setenv MSMAT_L   $NONTEMPORAL/output/moves/$SUBSECT/merge/moves/static/msmat_l.$SRCABBR.$SPC.moves.ncf
   setenv MSMAT_S   $NONTEMPORAL/output/moves/$SUBSECT/merge/moves/static/msmat_s.$SRCABBR.$SPC.moves.ncf

  #setenv OUTPUT   $M_OUT/output/merged
  #if (! -e $OUTPUT ) mkdir -p $OUTPUT
   setenv REPSCEN  $M_OUT/report
   if ( ! -e $REPSCEN ) mkdir -p $REPSCEN 
   setenv REPMG    $REPSCEN/rep_${SRCABBR}_${ESDATE}_${GRID}_${SPC}.rpt

   if (! -e $M_OUT/scenario ) mkdir -p $M_OUT/scenario
   setenv MOUT     $M_OUT/output/$SPC/mgts_l_${SUBSECT}.ncf
   if ( ! -e $M_OUT/output/$SPC ) mkdir -p $M_OUT/output/$SPC

   echo " run smk_run.csh for part2 and part 4"
   source $SCRIPTS/run/smk_run.csh     # Run programs
   echo " run qa_run.csh for part2 and part 4"
   source $SCRIPTS/run/qa_run.csh      # Run QA for part 2

   # convert CB05 to SAPRC99
#     set mout_cb05 = $MOUT
#     setenv SPC_OVERRIDE cmaq_saprc99
#     setenv MOUT     $M_OUT/output/${SPC_OVERRIDE}/mgts_l_${SUBSECT}.ncf
#     if ( ! -e $M_OUT/output/${SPC_OVERRIDE} ) mkdir $M_OUT/output/${SPC_OVERRIDE}
#     set mout_saprc99 = $MOUT
#     unsetenv SPC_OVERRIDE
#     unsetenv LOGFILE
#     $SCRIPTS/run/run.m3combo.cb05.to.saprc99.onroad.csh $mout_cb05 $mout_saprc99


   setenv RUN_PART2 N
   setenv RUN_PART4 N

#
## ending of script
#
exit( 0 )
