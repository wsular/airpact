#!/bin/csh -f
#
# Version @(#)$Id: smk_offroad-rpp_MOVES.csh,v 1.1 2010/09/26 20:30:32 bbaek Exp $
# Path    $Source: /afs/isis/depts/cep/emc/apps/archive/smoke/smoke/scripts/run/smk_offroad-rpp_MOVES.csh,v $
# Date    $Date: 2010/09/26 20:30:32 $
#
# This script sets up needed environment variables for processing area source
# emissions in SMOKE and calls the scripts that run the SMOKE programs. 
#
# Script created by : B. Baek, Institute for the Environment in UNC at Chapel Hill 
#
#*********************************************************************

## Set Assigns file name
   setenv ASSIGNS_FILE $ASSIGNS/ASSIGNS_AIRPACT5_MOVES.csh

## Set source category
   setenv SMK_SOURCE    M          # source category to process
   setenv MRG_SOURCE    M          # source category to merge
   setenv SUBSECT       offroad_rpp

## Set programs to run...

## Time-independent programs
   setenv RUN_SMKINVEN  Y          # run inventory import program  # turned Y vikram 6/4/15
   setenv RUN_SPCMAT    Y          # run speciation matrix program # turned Y vikram 6/4/15
   setenv RUN_GRDMAT    Y          # run gridding matrix program

## Time-dependent programs
   setenv RUN_MOVESMRG  N          # run merge program  # turned N vikram 6/4/15

## Program-specific controls...

## For Smkinven
   setenv FILL_ANNUAL          N   # Y fills annual data with average-day data
   setenv RAW_DUP_CHECK        Y   # Y checks for duplicate records
   setenv SMK_BASEYR_OVERRIDE  0   # year to override the base year of the inventory
   setenv SMK_NHAPEXCLUDE_YN   N   # Y uses NHAPEXCLUDE file when integrating toxic sources
   setenv SMKINVEN_FORMULA     ""  # formula for computing emissions value
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
   setenv SMK_DEFAULT_SRGID    100 # surrogate code number to use as fallback  # vikram 7/5/2015 100 is the new code for population in srgdesc file
#      IOAPI_ISPH       set by Assigns file
#      REPORT_DEFAULTS  see "Multiple-program controls" below

## For Spcmat
   setenv POLLUTANT_CONVERSION N   # Y uses the GSCNV pollutant conversion file
#      REPORT_DEFAULTS  see "Multiple-program controls" below

# For Movesmrg
  setenv RPD_MODE             N          # Y process on-roadway emission factors
  setenv RPV_MODE             N          # Y process off-network emission factors
  setenv RPP_MODE             Y          # Y process off-network vapor venting EFs
  setenv MRG_GRDOUT_YN        Y          # Y outputs gridded file
  setenv MRG_TEMPORAL_YN      Y          # Y merges with hourly emissions
  setenv MRG_SPCMAT_YN        Y          # Y merges with speciation matrix
  setenv MRG_REPCNY_YN        Y          # Y produces a report of emission totals by county
  setenv MRG_REPSTA_YN        Y          # Y produces a report of emission totals by state
  setenv MRG_GRDOUT_UNIT      moles/s    # units for gridded output file
  setenv MRG_TOTOUT_UNIT      tons/day  # units for state and/or county totals
  setenv SMK_REPORT_TIME      070000     # hour in OUTZONE for reporting emissions
  setenv TVARNAME             TEMP2      # define name of temperature for the lookup tables
  setenv MOVESMRG_CUSTOM_OUTPUT Y        # Y allows AOUT, BOUT, MOUT, and POUT

## For Smkreport
  setenv REPORT_ZERO_VALUES   N     # Y outputs entries with all zero values

## Multiple-program controls
  setenv OUTZONE              0     # output time zone of emissions
  setenv REPORT_DEFAULTS      Y     # Y reports default profile application
  setenv SMK_DEFAULT_TZONE    8     # time zone to fix in missing COSTCY file
  setenv SMK_AVEDAY_YN        N     # Y uses average day emissions instead of annual
  #setenv SMK_MAXWARNING       100   # maximum number of warnings in log file
  setenv SMK_MAXWARNING       1000   # maximum number of warnings in log file      # vikram 7/5/2015
  setenv SMK_MAXERROR         900000   # maximum number of errors in log file     
  setenv USE_SPEED_PROFILES   Y     # Y uses speed profiles instead of inventory speeds
  setenv FULLSCC_ONLY         N     # Y only matches profiles by full SCCs

## Script settings
  setenv SRCABBR              rateperprofile  # abbreviation for naming log files
  setenv QA_TYPE              all # type of QA to perform [none, all, part1, part2, or custom]
  setenv PROMPTFLAG           N   # Y prompts for user input
  setenv AUTO_DELETE          Y   # Y automatically deletes I/O API NetCDF output files
  setenv AUTO_DELETE_LOG      Y   # Y automatically deletes log files
  setenv DEBUGMODE            N   # Y runs program in debugger
  setenv DEBUG_EXE            pgdbg # debugger to use when DEBUGMODE = Y

## Assigns file override settings
# setenv SPC_OVERRIDE  cmaq.cb4p25  # chemical mechanism override
# setenv YEAR_OVERRIDE              # base year override
# setenv INVTABLE_OVERRIDE          # inventory table override

##############################################################################

## Run Smkinven, Spcmat, and Grdmat
#
  setenv RUN_PART1 Y
  source $ASSIGNS_FILE   # Invoke Assigns file

  # Reset NHAPEXCLUDE file to exclude all sources
  # This is needed for now because the stationary area criteria and non-point 
  #    toxics inventories are not consistent and should not be integrated.
  setenv NHAPEXCLUDE $INVDIR/other/nhapexclude.all.txt
  echo " run smk_run.csh for part1"
  source $SCRIPTS/run/smk_run.csh     # Run programs
  echo " run qa_run.csh for part1"
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
      source $ASSIGNS_FILE $1  # Invoke Assigns file to set new dates
      echo " run smk_run.csh for part2 and part 4"
      source $SCRIPTS/run/smk_run.csh     # Run programs
      echo " run qa_run.csh for part2 and part 4"
      source $SCRIPTS/run/qa_run.csh      # Run QA for part 2

      #shc below is only for temporal has been run
	#convert CB05 to SAPRC99
	#set mout_cb05 = $MOUT
	#setenv SPC_OVERRIDE cmaq.SAPRC99
	#source $ASSIGNS_FILE $1  # Invoke Assigns file to set new output file
	#set mout_saprc99 = $MOUT
	#unsetenv SPC_OVERRIDE
	#unsetenv LOGFILE
	#$SCRIPTS/run/run.m3combo.cb05.to.saprc99.offroad-rpp.csh $mout_cb05 $mout_saprc99

   setenv G_STDATE_ADVANCE $cnt
	
  end
  setenv RUN_PART2 N
  setenv RUN_PART4 N
  unsetenv G_STDATE_ADVANCE

#
## Ending of script
#
exit( 0 )
