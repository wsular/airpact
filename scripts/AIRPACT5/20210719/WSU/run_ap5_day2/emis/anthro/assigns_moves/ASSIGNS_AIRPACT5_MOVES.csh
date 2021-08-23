#!/bin/csh -fx
#
## HEADER ##################################################################
#
#  SMOKE ASSIGNS file (sets up for area, biogenic, mobile, nonroad, and point sources)
#
#  Version @(#)$Id: ASSIGNS.MOVES.cmaq.cb05p25tx.us12-ga,v 1.2 2010/09/26 20:59:30 bbaek Exp $
#  Path    $Source: /afs/isis/depts/cep/emc/apps/archive/smoke/smoke/assigns/ASSIGNS.MOVES.cmaq.cb05p25tx.us12-ga,v $
#  Date    $Date: 2010/09/26 20:59:30 $
#
#  Scenario Description:
#     This assigns file sets up the environment variables for use of 
#     SMOKE Version 2.1 outside of the Models-3 system.
#
#  Usage:
#     source <Assign>
#     Note: First set the SMK_HOME env variable to the base SMOKE installation
#  Change Log:
#     RUI ZHANG 2013/04/06 changed to cope with the airpact4 system
#     VIKRAM RAVI 2015/June-July some changes introduced for AP5
#
## END HEADER ##############################################################

## I/O Naming roots
#
   setenv INVID     moves   # Inventory input identifier
   setenv INVOP     moves   # Base year inventory output name
   setenv INVEN     moves   # Base year inventory name with version

   setenv ABASE     $INVOP       # Area base case output name
   setenv BBASE     $INVOP       # Biogenics base case output name
   setenv MBASE     $INVOP       # Mobile base case output name
   setenv PBASE     $INVOP       # Point base case output name

   setenv EBASE     $INVOP       # Output merged base case name   
   
   setenv GRID         AIRPACT_04km     # Gridding root for naming
   setenv METSCEN      ${INVOP}_${GRID} # Met scenario name
   setenv IOAPI_GRIDNAME_1 AIRPACT_04km # Grid selected from GRIDDESC file
   setenv IOAPI_ISPH   19               # Specifies spheroid type associated with grid
   setenv SPC          cmaq_cb05_soa     # Speciation type

## Mobile episode variables
   setenv EPI_STDATE {$INVEN}191 # Julian start date
   setenv EPI_STTIME  080000     # start time (HHMMSS)
   setenv EPI_RUNLEN 0240000     # run length (HHHMMSS)
   setenv EPI_NDAY   1           # number of full run days

## Per-period environment variables
   setenv G_STDATE  {$INVEN}191  # Julian start date
   setenv G_STTIME   080000      # start time (HHMMSS)
   setenv G_TSTEP     10000      # time step  (HHMMSS)
   setenv G_RUNLEN   250000      # run length (HHMMSS)
   setenv ESDATE   {$INVEN}0710  # Start date of emis time-based files/dirs
   setenv MSDATE   {$INVEN}0710  # Start date of met  time-based files
   setenv NDAYS           1      # Duration in days of each emissions file
   setenv MDAYS           1      # Duration in days of met  time-based files
   setenv YEAR         2011      # Base year for year-specific files

## Reset days if overrides are available
   if ( $?G_STDATE_ADVANCE ) then
       set date = $G_STDATE
       @ date = $date + $G_STDATE_ADVANCE
       setenv G_STDATE $date 
       setenv ESDATE `unsetenv LOGFILE; $IOAPIDIR/datshift $G_STDATE 0`
   endif

## User-defined I/O directory settings
  setenv SMK_SUBSYS  $SMK_HOME/subsys              # SMOKE subsystem dir
  setenv SMKROOT     $SMK_SUBSYS/smoke             # System root dir
  setenv SMKDAT      $SMK_HOME/data                # Data root dir
  #setenv SMKOUT      $MBBASE                       # Data output root dir for mobile emission
  setenv ASSIGNS     $PBS_O_WORKDIR/emis/anthro/assigns_moves     # smoke assigns files directory
  setenv METDAT      $AIROUT/MCIP                      # smoke met files
  #setenv METDAT      dummy
 
## Override speciation setting, if override variable is set
if ( $?SPC_OVERRIDE ) then
   if ( $SPC != " " ) then
      setenv SPC $SPC_OVERRIDE
   endif
endif
#
## Override year setting, if override variable is set
if ( $?YEAR_OVERRIDE ) then
   setenv YEAR $YEAR_OVERRIDE
endif
#
## Make changes to names for future year and/or control strategy
set outstat = 0
source $ASSIGNS/set_case.scr
if ( $status > 0 ) then
   set outstat = 1
endif

## Set dependent directory names
#
#shc source $ASSIGNS/set_dirs.scr

## Check script settings
#shc source $ASSIGNS/check_settings.scr

#  setenv DAT_ROOT $SMKDAT
  setenv GE_DAT   $SMKDAT/ge_dat
  setenv INVDIR   $SMK_HOME/emissions/moves
  setenv INTERMED $SMK_HOME/intermediate
  setenv OUTPUT   $SMK_HOME/output/moves/$SUBSECT
  setenv INVOPD   $INTERMED/moves/$SUBSECT

  setenv REPORTS  $SMK_HOME/reports      # Output reports root dir
  setenv REPSCEN  $REPORTS/moves/$SUBSECT/scenario                       # Output reports scenario dir
  setenv REPSTAT  $REPORTS/moves/$SUBSECT/static                         # Output reports dir

#
  source $ASSIGNS/set_dirs.scr
  source $ASSIGNS/check_settings.scr

##########  SMOKE formatted raw inputs #############
#
## Mobile source input files
if ( $SMK_SOURCE == 'M' ) then
   setenv MBINV       $INVDIR/$SRCABBR/mbinv.$SRCABBR.$INVOP.lst # mobile emissions
   setenv SPDPRO      $INVDIR/$SRCABBR/spdpro.MOVES.txt          # Speed profiles file
   setenv MCODES      $GE_DAT/mcodes.txt                         # mobile codes to build internal SCC 
   setenv MCXREF      $GE_DAT/mcref_moves_nw.txt                 # ref county cross-reference
   setenv MFMREF      $GE_DAT/fuelmonth_nw.txt                   # ref county fuel-month
   setenv METLIST     $GE_DAT/metlist.met4moves.lst              # List of Meteorology files
   setenv MGREF       $GE_DAT/amgref_4km_2014_moves.txt # Mobile gridding x-ref      # vikram 7/9/2015 Updated from Ecology
   setenv MTPRO       $GE_DAT/mtpro_AP5_final.txt                   # Temporal profiles
   setenv MTREF       $GE_DAT/mtref_AP5_final.txt             # Mobile temporal x-ref
   setenv GSREF       $GE_DAT/gsref.cmaq_cb05_soa.moves.txt               # Speciation x-ref
   setenv GSPRO       $GE_DAT/gspro.$SPC.moves.txt               # Speciation profiles
   setenv GSPRO_COMBO $GE_DAT/gspro_combo.$SPC.airpact4.txt      # Speciation Combo profiles   
   setenv MEPROC      $GE_DAT/meproc.$SRCABBR.txt                # Mobile emission processes
   setenv SMK_MVSPATH $GE_DAT/MOVES_dynamic_lookuptables/        # Dir for MOVES lookup tables
   setenv MRCLIST     $SMK_MVSPATH/mrclist.${SRCABBR}.summed.lst # List of MOVES lookup table list file

   setenv METMOVES    $METDAT/SMOKE_${GRID}_${EPI_STDATE}_${EPI_NDAY}.txt # Met4moves output
endif
#
## Shared input files
   setenv INVTABLE    $GE_DAT/invtable_hapcap_cb05soa.txt # Inventory table  vikram 6/4/15
   setenv GRIDDESC    $GE_DAT/GRIDDESC                  # Grid descriptions.
   setenv COSTCY      $GE_DAT/costcy_v8.txt             # country/state/county info  # vikram 7/5/2015
   setenv HOLIDAYS    $GE_DAT/holidays_2005_2019.txt # holidays for day change
   setenv SRGDESC     $GE_DAT/srgdesc_4km_airpact5_moves.txt # surrogate descriptions    # vikram 7/16/2015
   setenv SRGPRO_PATH $GE_DAT/SRGPRO/                    # surrogate files path      # vikram 7/5/2015
   setenv SCCDESC     $GE_DAT/scc_desc_030804.txt  # SCC descriptions
   setenv ORISDESC    $GE_DAT/oris_info.txt        # ORIS ID descriptions
   setenv MACTDESC    $GE_DAT/mact_desc.txt        # MACT descriptions
   setenv NAICSDESC   $GE_DAT/naics_desc.txt       # NAICS descriptions
#   setenv PROCDATES   $GE_DAT/procdates.txt        # time periods that Temporal should process
	
	# set the defualt time zone to PST
   setenv SMK_DEFAULT_TZONE 8

## Meteorology IO/API input files (MCIP output files)
#
   if ( $SMK_SOURCE == 'B' || $SMK_SOURCE == 'M' || $SMK_SOURCE == 'P' ) then
      setenv GRID_CRO_2D $METDAT/GRIDCRO2D
      setenv GRID_CRO_3D $METDAT/GRIDCRO3D
      setenv MET_CRO_2D  $METDAT/METCRO2D
      setenv MET_CRO_3D  $METDAT/METCRO3D
      setenv MET_DOT_3D  $METDAT/METDOT3D
      setenv MET_FILE1   $MET_CRO_2D
      setenv MET_FILE2   $MET_CRO_2D
   endif
 
#
## Override shared inputs
if ( $?INVTABLE_OVERRIDE ) then
   if ( $INVTABLE_OVERRIDE != " " ) then
      setenv INVTABLE $INVDIR/other/$INVTABLE_OVERRIDE
   endif
endif

#
##########################################################################
#
## Output and Intermediate files
#
# Mobile source intermediate and output files 
#
if ( $SMK_SOURCE == 'M' ) then
   setenv MSCC      $INVOPD/MSCC.$SRCABBR.$FYIOP.txt
   setenv REPINVEN  $REPSTAT/repinven.$SRCABBR.$INVOP.txt
#shc   setenv MTSUPNAME $SMKOUT/${MSCEN}/scenario/mtsup.$SRCABBR.$MSCEN.
#shc   setenv MTSUP     $MTSUPNAME.$G_STDATE.txt
   setenv MSSUP     $OUTPUT/${MBASE}/static/mssup.$SRCABBR.$SPC.$MBASE.txt
   setenv MGSUP     $OUTPUT/${MBASE}/static/mgsup.$SRCABBR.$GRID.$MBASE.txt
   setenv MCREP     $REPSTAT/mcrep.$SRCABBR.$MSCEN.rpt
   setenv MPROJREP  $REPSTAT/mprojrep.$SRCABBR.$MSCEN.rpt
   setenv MREACREP  $REPSTAT/mreacrep.$SRCABBR.$MSCEN.rpt
   setenv MCSUMREP  $REPSTAT/mcsumrep.$SRCABBR.$MSCEN.rpt
   setenv MCTLWARN  $REPSTAT/mctlwarn.$SRCABBR.$MSCEN.txt
   #      HOURLYT      automaticall set and created by emisfac_run.scr script
   #      MEFLIST      automatically set and created by smk_run.scr script
   setenv SPDSUM       $STATIC/spdsum.$SRCABBR.$MSCEN.txt # Speed summary file
   setenv MOBL_O   $INVOPD/mobl.map.$SRCABBR.$FYINV.txt
   setenv MBINV_O  $MBDAT/mbinv_o.$SRCABBR.$FYINV.emis.txt
   setenv MBINV_AO $MBDAT/mbinv_o.$SRCABBR.$FYINV.actv.txt
endif

if ( $SMK_SOURCE == M || $RUN_SMKMERGE == Y && $MRG_MOBILE == Y ) then
   setenv MOBL     $INVOPD/mobl.map.$SRCABBR.$FYIOP.txt   # Mobile inventory map
#shc   setenv MTMPNAME $SMKOUT/$MSCEN/scenario/mtmp.$SRCABBR.$MSCEN.
#shc   setenv MTMP     $MTMPNAME$G_STDATE.ncf
   setenv MSMAT_L  $OUTPUT/$MBASE/static/msmat_l.$SRCABBR.$SPC.$MBASE.ncf
   setenv MSMAT_S  $OUTPUT/$MBASE/static/msmat_s.$SRCABBR.$SPC.$MBASE.ncf
   setenv MRMAT_L  $OUTPUT/$MSCEN/static/mrmat_l.$SRCABBR.$SPC.$MSCEN.ncf
   setenv MRMAT_S  $OUTPUT/$MSCEN/static/mrmat_s.$SRCABBR.$SPC.$MSCEN.ncf
   setenv MRSUP    $OUTPUT/$MSCEN/static/mrsup.$SRCABBR.$MSCEN.txt
   setenv MCMAT    $OUTPUT/$MSCEN/static/mcmat.$SRCABBR.$MSCEN.ncf
   setenv MUMAT    $OUTPUT/$MBASE/static/mumat.$SRCABBR.$GRID.$MBASE.ncf
   setenv MGMAT    $OUTPUT/$MBASE/static/mgmat.$SRCABBR.$GRID.$MBASE.ncf
   setenv MPMAT    $OUTPUT/$MSCEN/static/mpmat.$SRCABBR.$MSCEN.ncf
endif

# Cumstomized Movesmrg output file names when merging all souce sectors
   if ( $MOVESMRG_CUSTOM_OUTPUT == Y && $RUN_MOVESMRG == Y ) then 
      setenv EOUT  $OUTPUT/egts_l.$ESDATE.$NDAYS.$SPC.$GRID.$ESCEN.ncf 
      setenv MOUT  $M_OUT/mgts_l.$SRCABBR.$ESDATE.$NDAYS.$GRID.$MSCEN.ncf
      setenv REPMG $REPSCEN/rep_${MM}_${SRCABBR}_${ESDATE}_${GRID}_${SPC}.txt
   else
      source $ASSIGNS/setmerge_files.scr    #  Define merging output file names 
   endif

#  Create and change permissions for output directories
   $ASSIGNS/smk_mkdir

   if ( $status > 0 ) then
      set outstat = 1   
   endif
#
#  Get system-specific flags
   source $ASSIGNS/sysflags

   if ( $status > 0 ) then
      set outstat = 1   
   endif

#  Delete appropriate NetCDF files for the programs that are being run
   if ( -e $ASSIGNS/smk_rmfiles.scr ) then
      $ASSIGNS/smk_rmfiles.scr
   else
      echo "NOTE: missing smk_rmfiles.scr in ASSIGNS directory for"
      echo "      automatic removal of SMOKE I/O API intermediate and"
      echo "      output files"
   endif
#
#  Unset temporary environment variables
   source $ASSIGNS/unset.scr

if ( $outstat == 1 ) then
   echo "ERROR: Problem found while setting up SMOKE."
   echo "       See messages above."
   exit( 1 )
endif

