#!/bin/csh -f
#BSUB 0:30

#
# Version @(#)$Id: smk_pt_nctox.csh,v 1.3 2004/06/28 14:14:50 cseppan Exp $
# Path    $Source: /afs/isis/depts/cep/emc/apps/archive/smoke/smoke/scripts/run/smk_pt_nctox.csh,v $
# Date    $Date: 2004/06/28 14:14:50 $

# This script sets up needed environment variables for running wild-fire point source
# emissions in SMOKE, and calls the script that runs the SMOKE programs. 
#
# Script created by : M. Houyoux, CEP Environmental Modeling Center 
# J.K. Vaughan        July 14, 2010
# S.H. Chung          May 2012
# R. Gonzales-Abraham Oct 2012
# Farren              July 2015
#*********************************************************************


#> setup directory and file location -----------------------------------

   setenv SMK_HOME    ~airpact5/models/SMOKEv3.5.1
   setenv SMK_SUBSYS  $SMK_HOME/subsys                               # SMOKE subsystem dir
   setenv SMKROOT     $SMK_SUBSYS/smoke                              # System root dir
   setenv SMOKE_EXE   Linux2_x86_64pg
   setenv SMK_BIN     ${SMKROOT}/${SMOKE_EXE}

   setenv IOAPI_GRIDNAME_1   'AIRPACT_04km'  # set grid name
   setenv EBASE    ${PBS_O_WORKDIR}/emis/fire_orl

   setenv BIN     $SMK_BIN

   setenv ASSIGNS $EBASE/assigns
   setenv ASSIGNS_FILE $EBASE/assigns/ASSIGNS_AIRPACT5_canfire.csh # wildfire only as pt emis

#> subprogram switches -------------------------------------------------

   # time independent programs ( RUN_PART1 must be Y for any of these)
     setenv RUN_SMKINVEN  Y        #  run inventory import program  Tested OK 08/20/10 JKV
     setenv RUN_SPCMAT    Y        #  run speciation matrix program
     setenv RUN_GRDMAT    Y        #  run gridding matrix program
     setenv RUN_CNTLMAT   N        #  run control matrix program
   # time-dependent programs ( Trying to run from here with RUN_PART2 = Y JKV ) 
     setenv RUN_LAYPOINT  Y        #  run layer fractions program
     setenv RUN_TEMPORAL  Y        #  run temporal allocation program
     setenv RUN_ELEVPOINT N        #  run elevated/PinG sources selection program
     setenv RUN_SMKMERGE  Y        #  run merge program
     setenv RUN_SMK2EMIS  N        #  run conversion of 2-d to UAM binary

#> set source category -------------------------------------------------

   setenv SMK_SOURCE P           # source category to process
   setenv MRG_SOURCE P           # source category to merge
   setenv MRG_CTLMAT_MULT ' '    # [A|P|AP] for merging with multiplier controls
   setenv MRG_CTLMAT_ADD  ' '    # [A|P|AP] for merging with additive controls
   setenv MRG_CTLMAT_REAC ' '    # [A|M|P|AMP] for merging with reactivity controls

#> quality assurance
   setenv RUN_SMKREPORT Y        # Y runs reporting for state reports

#> program-specific controls -------------------------------------------

  # For Smkinven
    setenv CHECK_STACKS_YN      N   # after Rodrigo
    setenv FILL_ANNUAL          N # Y fills annual value when only average day is provided & after Rodrigo
  # setenv FLOW_RATE_FACTOR     15878 # Manually entered by FHT on 3/14/2013 to match the AP3 script (may not be needed)  
    setenv HOURLY_TO_DAILY      N # Y reads daily total only from hourly file
    setenv HOURLY_TO_PROFILE    Y # Y converts hourly data to source-specific profs & after Rodrigo
    setenv IMPORT_AVEINV_YN     Y # Y then import annual/average inventory JKV set to N 08/19/10 
    setenv RAW_DUP_CHECK        N # Y errors on duplicate records
    setenv SMK_BASEYR_OVERRIDE  0 # Enter year of the base year when future-year inven provided
    setenv SMK_NHAPEXCLUDE_YN   N # Y uses NonHAP exclusions file (IS Y in AP3)
    setenv SMK_SWITCH_EPSXY     N # Y corrects x-y location in file for for EPS format
    setenv WEST_HSPHERE         Y # Y converts ALL stack coords to western hemisphere
    setenv WKDAY_NORMALIZE      N # Y normalizes weekly profiles by weekdays
    setenv WRITE_ANN_ZERO       Y # Y allows zeros for annual inv intermediate files  JKV 08/19/10
   #setenv FULLSCC_ONLY  N #JKV encountered a problem with SMOKE v2.1 mis-reading EMS-95 file; Rodrigo sugested FULL_SCCONLY N

  # For Spcmat
    setenv POLLUTANT_CONVERSION Y     # Y uses ROG to TOG file, for example

  # For Grdmat

  # For Cntlmat
    setenv REACTIVITY_POL       ' '   # Set to VOC or ROG (only for reactivity controls) 

  # For Elevpoint
    setenv SMK_ELEV_METHOD      0     # 0=Laypoint sets elev srcs; 1=use PELVCONFIG
    setenv UNIFORM_STIME        080000 # JKV 071910  # -1    # -1 or HHMMSS for uniform start hour for daily emissions days

  # For Temporal
   #setenv MRG_SOURCE         $SMK_SOURCE  # merge source 
    setenv MRG_TEMPORAL_YN    Y            # merge with temporal 
    setenv MRG_SPCMAT_YN      Y            # merge with speciation 
    setenv MRG_GRDOUT_YN      Y            # merge with gridding 
    setenv MRG_LAYERS_YN      Y            # Y merges with layer fractions 
    setenv MRG_REPCNY_YN      N            # report county 
    setenv MRG_REPSTA_YN      Y            # report state (changed to Y 3/14/2013) 
    setenv MRG_METCHK_YN      Y            # check header consistency 
    setenv MRG_GRDOUT_UNIT    'moles/s'    #  output unit 
    setenv MRG_TOTOUT_UNIT    'moles/day'  # report output unit 
    setenv SMK_ASCIIELEV_YN   N 
    setenv SMK_PING_METHOD    0            # 1 PING, 0 no PING 2 for CMAQ processing of plumes
   #setenv UNIFORM_TROF_YN    Y    # not uniform profile (maybe an error from RAG)
   #setenv PROMPTFLAG         N

  # For Laypoint
    setenv EXPLICIT_PLUMES_YN   N   # only process explicit plume rise sources from PELV
    setenv SMK_SPECELEV_YN      N   # Y: Laypoint uses Elevpoint outputs to pick elevated 
    setenv FIRE_AREA            0.  # daily area burned; only needed when processing fires 
    setenv FIRE_HFLUX           0.  # hourly heat flux; only needed when processing fires 
    setenv FIRE_PLUME_YN        Y   # Y uses fire-specific plume rise calculations 
    setenv HOUR_PLUMEDATA_YN    N   # Y reads hourly plume rise data from the PHOUR file 
    setenv HOURLY_FIRE_YN       Y   # Y reads fire data from the PTMP and PDAY files 
    setenv REP_LAYER_MAX        -1  # layer number for reporting high plume rise 
    setenv VERTICAL_SPREAD      0   # sets the vertica 
    setenv USE_VARIABLE_GRID 	N   # from BHB

  # For Smkmerge
    setenv MRG_TEMPORAL_YN      Y          # Y merges with hourly emissions
    setenv MRG_SPCMAT_YN        Y          # Y merges with speciation matrix
    setenv MRG_LAYERS_YN        Y          # Y merges with layer fractions
    setenv MRG_GRDOUT_YN        Y          # Y outputs gridded file
    setenv MRG_REPSTA_YN        N          # Y outputs state totals
    setenv MRG_REPCNY_YN        N          # Y outputs county totals
    setenv SMK_ASCIIELEV_YN     N          # Y outputs ASCII elevated file
    setenv MRG_GRDOUT_UNIT      'moles/s'    # JKV /day #tons/day #moles/s    # units for gridded output file
    setenv MRG_TOTOUT_UNIT      'tons/day'  #moles/day  # units for state and/or county totals
    setenv MRG_REPORT_TIME      000000     # hour in OUTZONE for reporting emissions
    setenv MRG_MARKETPEN_YN     N          # apply reac. controls market penetration
   #settings after RAG.  JKV 090210 
    setenv MRG_METCHK_YN      Y            # check header consistency # after RAG.  JKV 090210 

   # For Smk2emis
     setenv SMK2EMIS_VMAP_YN     N     # Y uses name remapping file

   # Multiple-program controls
     setenv DAY_SPECIFIC_YN      Y     # Y imports and uses day-specific inventory
     setenv EXPLICIT_PLUME_YN    N     # Y for special wildfire processing for UAM/REMSAD/CAMx
     setenv HOUR_SPECIFIC_YN     N  # JKV 071910 # N     # Y imports and uses hour-specific inventory
     setenv OUTZONE              0     # output time zone of emissions
     setenv REPORT_DEFAULTS      N     # Y reports default profile application
     setenv SMK_EMLAYS           37 # JKV 071910  # 17    # number of emissions layers
     setenv SMK_DEFAULT_TZONE    8     # time zone to fix in missing COSTCY file
     setenv SMK_AVEDAY_YN        N     # Y uses average day emissions instead of annual 
     setenv SMK_MAXWARNING       1000   # maximum number of warnings in log file
     setenv SMK_MAXERROR         100    # maximum number of errors in log file
     setenv SMK_PING_METHOD      0     # 1 outputs for PinG (using Elevpoint outputs), 0 no PING
     setenv SMK_SPECELEV_YN      N     # Y uses the indicator for major/minor sources
     setenv VELOC_RECALC         N     # Y recalculates velocity from diam and flow
     setenv UNIFORM_TPROF_YN 	 N 

   # Script settings
     setenv SRCABBR            pt      # abbreviation for naming log files
     setenv QA_TYPE            all     # [none, all, part1-part4, or custom]
     setenv PROMPTFLAG         N       # Y (never set to Y for batch processing)
     setenv AUTO_DELETE        N # JKV 071910  # Y       # Y deletes SMOKE I/O API output files (recommended)
     setenv AUTO_DELETE_LOG    N # JKV 071910  # Y       # Y automatically deletes logs without asking
     setenv DEBUGMODE          N       # Y changes script to use debugger
     setenv DEBUG_EXE          pgdbg     # Sets the debugger to use when DEBUGMODE = Y

#> run smkinven, spcmat, grdmat, cntlmat, if needed --------------------

   if ($RUN_SMKINVEN == 'Y' || $RUN_SPCMAT == 'Y' || $RUN_GRDMAT == 'Y' ) then

      setenv RUN_PART1 Y
      source $ASSIGNS_FILE $SRTYR $SRTMN $SRTDT  # Invoke Assigns file

      if ($RUN_SMKINVEN == 'Y' ) then
        #rm -vf  $PSCC $PNTS $REPINVEN 
         rm -vfR  ${SMK_SUBSYS}/smoke/data/inventory/fire/*  # JKV 072210
      endif

      if ($RUN_SPCMAT   == 'Y' ) then
         rm -vf $PSMAT_S $PSMAT_L 
      endif

      if ($RUN_GRDMAT   == 'Y' ) then
         rm -vf $PGMAT
      endif

      # Reset NHAPEXCLUDE file to exclude all sources 
      # This is needed for now because the criteria and toxics point source
      # inventories are not consistent and should not be integrated.
	setenv NHAPEXCLUDE $INVDIR/other/nhapexclude.all.txt

      # run programs
        source ${PBS_O_WORKDIR}/emis/fire_orl/run_smk_canfire.csh     # Run programs
        if ( $status != 0 ) then
	   echo "abort run_smk_pt_fire.csh "
	   exit
        endif 

      # run QA for part 1  
	source $SCRIPTS/run/qa_run.csh      # Run QA 
	setenv RUN_PART1 N

   endif

#> run other subprograms -----------------------------------------------

   # temporal
     if ( $RUN_TEMPORAL == 'Y' ) then
	if ( $RUN_SMKMERGE == 'Y' ) then
	   echo "   HIDE RUN_SMKMERGE "
	   setenv RUN_SMKMERGE LATER
	endif
        source $ASSIGNS_FILE $SRTYR $SRTMN $SRTDT
  	setenv PTMP $SMKDAT/run_$PSCEN/scenario/ptmp.$ESDATE.$NDAYS.$PSCEN.ncf
        setenv RUN_PART2 Y
   	whereis -b temporal
	source ${PBS_O_WORKDIR}/emis/fire_orl/run_smk_canfire.csh     # Run programs
	setenv RUN_PART2 N
	set exitstat = $status
	if ( $exitstat ) then
	   echo "*** Error running TEMPORAL using run_smk_canfire.csh ***"
	   exit ( $exitstat )
	endif
     endif # RUN_TEMPORAL

   # laypoint
     if ( $RUN_LAYPOINT == 'Y' ) then
	source $ASSIGNS_FILE $SRTYR $SRTMN $SRTDT
	source ${PBS_O_WORKDIR}/emis/fire_orl/run_smk_canfire.csh     # Run programs
	set exitstat = $status
	if ( $exitstat ) then
	   echo "*** Error running LAYPOINT using run_smk_canfire.csh***"
	   exit ( $exitstat )
	endif
     endif # RUN_LAYPOINT

   # smkmerg
     if ( $RUN_SMKMERGE == 'LATER' ) then
	echo "   REVEAL RUN_SMKMERGE "
	setenv RUN_SMKMERGE  Y 
     endif
     if ( $RUN_SMKMERGE == 'Y' ) then
        source $ASSIGNS_FILE $SRTYR $SRTMN $SRTDT  # Invoke Assigns file
        setenv RUN_PART4 Y
        source ${PBS_O_WORKDIR}/emis/fire_orl/run_smk_canfire.csh     # Run programs
        setenv RUN_PART4 N
        set exitstat = $status
	if ( $exitstat ) then
	   echo "*** Error running SMKMERGE using run_smk_canfire.csh***"
	   exit ( $exitstat )
	endif
	setenv RUN_SMKMERGE N
     endif # RUN_SMKMERGE


exit( 0 )

