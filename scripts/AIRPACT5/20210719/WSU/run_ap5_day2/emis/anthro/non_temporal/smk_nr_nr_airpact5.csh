#!/bin/csh -f
#
# Version @(#)$Id: smk_ar_nctox.csh,v 1.8 2007/06/29 13:45:46 bbaek Exp $
# Path    $Source: /afs/isis/depts/cep/emc/apps/archive/smoke/smoke/scripts/run/smk_ar_nctox.csh,v $
# Date    $Date: 2007/06/29 13:45:46 $
#
# This script sets up needed environment variables for processing area source
# emissions in SMOKE and calls the scripts that run the SMOKE programs. 
#
# Script created by : M. Houyoux, CEP Environmental Modeling Center 
#
#*********************************************************************

## Set optional customized SMKMERGE output file names
   setenv SMKMERGE_CUSTOM_OUTPUT  N  # Y define your own output file names from SMKMERGE

#
   setenv SECTOR               nonroad
   setenv SUBSECT              nonroad_model

# set Assigns file name
  setenv ASSIGNS_FILE ${ASSIGNS}/ASSIGNS.AIRPACT5_2014nw.csh
  source $ASSIGNS_FILE

## Set source category
   setenv SMK_SOURCE    A          # source category to process
   setenv MRG_SOURCE    A          # source category to merge

## Set programs to run...

## Time-independent programs
   setenv RUN_SMKINVEN  Y          # run inventory import program
   setenv RUN_SPCMAT    Y          # run speciation matrix program
   setenv RUN_GRDMAT    Y          # run gridding matrix program

## Time-dependent programs
   setenv RUN_TEMPORAL  N          # run temporal allocation program
   setenv RUN_SMKMERGE  N          # run merge program

## Quality assurance
   setenv RUN_SMKREPORT N          # run emissions reporting program

## Program-specific controls...

## For Smkinven
   setenv FILL_ANNUAL          N   # Y fills annual data with average-day data
   setenv IMPORT_GRDIOAPI_YN   N   # Y imports gridded I/O API NetCDF inventory data
   setenv RAW_DUP_CHECK        N   # Y checks for duplicate records
   setenv SMK_ARTOPNT_YN       N   # Y uses the ARTOPNT file to assign coordinates
   setenv SMK_BASEYR_OVERRIDE  0   # year to override the base year of the inventory
   setenv SMK_DEFAULT_TZONE    5   # default time zone for sources not in the COSTCY file
#   setenv SMK_PROCESS_HAPS     ALL # This is for SMOKE 2.7 ALL|NONE|PARTIAL
  #setenv SMK_NHAPEXCLUDE_YN   Y   # Y uses NHAPEXCLUDE file when integrating toxic sources
#   setenv NONHAP_TYPE          TOG # VOC or TOG for nonhap calculation 
  #setenv SMKINVEN_FORMULA     "PMC=PM10-PM2_5" # formula for computing emissions value
   setenv WEST_HSPHERE         Y   # Y converts longitudes to negative values
   setenv WKDAY_NORMALIZE      N   # Y treats average-day emissions as weekday only
   setenv WRITE_ANN_ZERO       N   # Y writes zero emission values to intermediate inventory
   setenv ALLOW_NEGATIVE       N   # Y allow negative output emission data
  #      INVNAME1         set by make_invdir.csh script
  #      INVNAME2         set by make_invdir.csh scripts
  #      OUTZONE          see "Multiple-program controls" below
  #      SMK_MAXERROR     see "Multiple-program controls" below
  #      SMK_MAXWARNING   see "Multiple-program controls" below
  #      SMK_TMPDIR       set by assigns/set_dirs.scr script

## For Grdmat
   setenv SMK_USE_FALLBACK     Y   # Y use fallback surrogate code
   setenv SMK_DEFAULT_SRGID  100   # surrogate code number to use as fallback
  #      IOAPI_ISPH       set by Assigns file
  #      REPORT_DEFAULTS  see "Multiple-program controls" below


## For Spcmat
   setenv POLLUTANT_CONVERSION Y   # Y uses the GSCNV pollutant conversion file
  #      REPORT_DEFAULTS  see "Multiple-program controls" below

## For Temporal
   setenv RENORM_TPROF         Y   # Y normalizes the temporal profiles
   setenv UNIFORM_TPROF_YN     N   # Y uses uniform temporal profiles for all sources
   setenv ZONE4WM              Y   # Y applies temporal profiles using time zones
  #      OUTZONE          see "Multiple-program controls" below
  #      REPORT_DEFAULTS  see "Multiple-program controls" below
  #      SMK_AVEDAY_YN    see "Multiple-program controls" below
  #      SMK_MAXERROR     see "Multiple-program controls" below
  #      SMK_MAXWARNING   see "Multiple-program controls" below

## For Smkmerge
   setenv MRG_SPCMAT_YN        Y   # Y produces speciated output 
   setenv MRG_TEMPORAL_YN      Y   # Y produces temporally allocated output
   setenv MRG_GRDOUT_YN        Y   # Y produces a gridded output file
   setenv MRG_REPCNY_YN        Y   # Y produces a report of emission totals by county
   setenv MRG_REPSTA_YN        Y   # Y produces a report of emission totals by state
   setenv MRG_GRDOUT_UNIT      moles/s   # units for the gridded output file
   setenv MRG_TOTOUT_UNIT      moles/day # units for the state and county reports
   setenv SMK_REPORT_TIME      230000    # hour for reporting daily emissions
  #      SMK_AVEDAY_YN    see "Multiple-program controls" below

## For Smkreport
   setenv REPORT_ZERO_VALUES   N   # Y outputs entries with all zero values

## Multiple-program controls
   setenv OUTZONE              0   # time zone of output emissions
   setenv SMK_DEFAULT_TZONE    5     # time zone to fix in missing COSTCY file
   setenv REPORT_DEFAULTS      N   # Y reports sources that use default cross-reference
   setenv SMK_AVEDAY_YN        N   # Y uses average-day emissions instead of annual emissions
   setenv SMK_MAXERROR         100 # maximum number of error messages in log file
   setenv SMK_MAXWARNING       100 # maximum number of warning messages in log file
   setenv FULLSCC_ONLY         N

## Script settings
   setenv SRCABBR              nr_model  # abbreviation for naming log files
   setenv NONROAD              Y   # Y uses nonroad files
   setenv QA_TYPE              all # type of QA to perform [none, all, part1, part2, or custom]
   setenv PROMPTFLAG           N   # Y prompts for user input
   setenv AUTO_DELETE          Y   # Y automatically deletes I/O API NetCDF output files
   setenv AUTO_DELETE_LOG      Y   # Y automatically deletes log files
   setenv DEBUGMODE            N   # Y runs program in debugger
   setenv DEBUG_EXE            pgdbg # debugger to use when DEBUGMODE = Y

## Assigns file override settings
  # setenv SPC_OVERRIDE  cmaq.cb4p25  # chemical mechanism override
  # setenv YEAR_OVERRIDE              # base year override
  # setenv INVTABLE_OVERRIDE  N        # inventory table override

##############################################################################

## Run Smkinven, Spcmat, and Grdmat
#
  setenv RUN_PART1 Y
  source $ASSIGNS_FILE   # Invoke Assigns file

# Reset NHAPEXCLUDE file to exclude all sources
# This is needed for now because the stationary area criteria and non-point 
#    toxics inventories are not consistent and should not be integrated.
#setenv NHAPEXCLUDE $GE_DAT/nhapexclude.all.txt
#setenv SRGPRO_PATH $GE_DAT/
  source $SCRIPTS/run/smk_run.csh     # Run programs
  source $SCRIPTS/run/qa_run.csh      # Run QA for part 1
  setenv RUN_PART1 N

## Loop through days to run Temporal and Smkmerge
#
  setenv RUN_PART2 Y
  setenv RUN_PART4 Y
  set cnt = 0
  set g_stdate_sav = $G_STDATE
  while ( $cnt < $EPI_NDAY )

     @ cnt = $cnt + $NDAYS
     source $ASSIGNS_FILE   # Invoke Assigns file to set new dates
     source $SCRIPTS/run/smk_run.csh     # Run programs
     source $SCRIPTS/run/qa_run.csh      # Run QA for part 2
     setenv G_STDATE_ADVANCE $cnt

  end
  setenv RUN_PART2 N
  setenv RUN_PART4 N
  unsetenv G_STDATE_ADVANCE

#
## Ending of script
#
exit( 0 )
