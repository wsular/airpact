#!/bin/csh -fx
#
# 071410 JKV created this version for wild-fire (pt) emissions from SMARTFIRE.
#
## HEADER ########################################################
#
#  SMOKE ASSIGNS file (sets up for area, biogenic, mobile, nonroad, and point sources)
#
#  Version @(#)$Id: ASSIGNS.airpact3.cmaq.cb4p25_wtox.us36-nc,v 1.6 2004/08/17 14:45:47 cseppan Exp $
#  Path    $Source: /afs/isis/depts/cep/emc/apps/archive/smoke/smoke/assigns/ASSIGNS.airpact3.cmaq.cb4p25_wtox.us36-nc,v $
#  Date    $Date: 2004/08/17 14:45:47 $
#
#  Scenario Description:
#     This assigns file sets up the environment variables for use of 
#     SMOKE Version 2.1 outside of the Models-3 system.
#     SMOKE Version 2.3 outside of the Models-3 system.
#

#
   setenv INVID     airpact5        # Inventory input identifier
   setenv INVOP     fire           # Base year inventory output name
   setenv INVEN     fire           # Base year inventory name with version

   setenv PBASE     fire           # Point base case output name JKV 072210
   setenv ABASE     firetemp
   setenv BBASE     firetemp
   setenv MBASE	    firetemp
   setenv EBASE     fire           # Output merged base case name

   setenv METSCEN     airpact5              # Met scenario name
   setenv GRID        AIRPACT_04km          # Gridding root for naming
   setenv IOAPI_GRIDNAME_1 $GRID           # Grid selected from GRIDDESC file
   setenv IOAPI_ISPH   19               # Specifies spheroid type associated with grid
   setenv SPC          cmaq.cb05 # Speciation type

   setenv EPI_STTIME  80000     # start time (HHMMSS)
   setenv EPI_NDAY   1           # number of full run days

## Per-period environment variables
   setenv G_STDATE  $YEARDOY      # Julian start date
   setenv G_STTIME    80000      # start time (HHMMSS)
   setenv G_TSTEP     10000      # time step  (HHMMSS)
   setenv G_RUNLEN   250000      # run length (HHMMSS)
   setenv NDAYS           1      # Duration in days of each emissions file
   setenv MDAYS           1      # Duration in days of met  time-based files
   setenv YEAR            $1   # Base year for year-specific files 
   setenv CurYr		$1
   setenv CurMn		$2
   setenv CurDt		$3

## Reset days if overrides are available
   if ( $?G_STDATE_ADVANCE ) then
       set date = $G_STDATE
       @ date = $date + $G_STDATE_ADVANCE
       setenv G_STDATE $date 
       setenv ESDATE `$IOAPIDIR/datshift $G_STDATE 0`
   else
       setenv ESDATE $G_STDATE # JKV 072110 
   endif

## User-defined I/O directory settings
   setenv SMKHOME     ~airpact5/models/SMOKEv3.5.1
   setenv SMKDAT      $SMKHOME/data                # Data root dir
   #shc setenv ASSIGNS     $SMKROOT/assigns               # smoke assigns files
#
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

source $ASSIGNS/set_case_fire.csh 
if ( $status > 0 ) then
	echo BAD STATUS ON set_case_fire.csh JKV
   set outstat = 1
endif

## Set dependent directory names
#
source $ASSIGNS/set_dirs_canfire.csh
if ( $status > 0 ) then
	echo BAD STATUS ON set_dirs_canfire.csh JKV
endif

## Check script settings
source $ASSIGNS/check_settings_fire.csh
if ( $status > 0 ) then
	echo BAD STATUS ON check_settings_fire.csh JKV
endif

##########  SMOKE formatted raw inputs #############
#
## Point source input files
if ( $SMK_SOURCE == 'P' ) then

# Now in ver 072110 building lists of inventory files.  JKV
   setenv PTINV      $AIROUT/EMISSION/fire_can/bluesky/invent_ptinv.txt
   echo "#LIST ORL" >! $PTINV
   echo "$AIROUT/EMISSION/fire_can/bluesky/ptinv-${CurYr}${CurMn}${CurDt}00.orl" >> $PTINV
   setenv PTDAY     $AIROUT/EMISSION/fire_can/bluesky/invent_ptday.txt
   echo "#LIST ORL" >! $PTDAY
   echo "$AIROUT/EMISSION/fire_can/bluesky/ptday-${CurYr}${CurMn}${CurDt}00.orl" >> $PTDAY
   ls -lt $PTINV $PTDAY

   setenv PELVCONFIG $INVDIR/pelvconfig.top50.txt      # elevated source selection
   setenv REPCONFIG  $INVDIR/repconfig.point.txt       # Default report configurations
   #      PTMPLIST                                           # Set automatically by script
   setenv PTPRO      $GE_DAT/aptpro_AP5_final.txt           # Temporal profiles
   setenv PTREF      $GE_DAT/aptref_AP5_final.txt           # Point temporal x-ref
   setenv PSTK       $GE_DAT/pstk_4km_2014.txt                     # Replacement stack params
endif
#
## Shared input files
   setenv INVTABLE     $GE_DAT/invtable_42125.txt # Inventory table
   setenv GRIDDESC     $GE_DAT/GRIDDESC             # Grid descriptions.
   setenv G_GRIDPATH   $GE_DAT/GRIDDESC
   setenv COSTCY       $GE_DAT/costcy_v8.txt           # country/state/county info
   setenv HOLIDAYS     $GE_DAT/holidays_2005_2019.txt         # holidays for day change
   setenv SCCDESC      $GE_DAT/scc_desc_030804.txt  # SCC descriptions
   setenv SRGDESC      $GE_DAT/srgdesc_4km_airpact5.txt             # surrogate descriptions   
   setenv ORISDESC     $GE_DAT/orisdesc_04dec2006_v0.txt        # ORIS ID descriptions
   setenv GSCNV        $GE_DAT/gscnv_42125.txt            # ROG to TOG conversion facs
   setenv GSREF        $GE_DAT/gsref_42125.txt         # Speciation x-ref
   setenv GSPRO        $GE_DAT/gspro_42125.txt       # Speciation profiles


## Override shared inputs
if ( $?INVTABLE_OVERRIDE ) then
   if ( $INVTABLE_OVERRIDE != " " ) then
      setenv INVTABLE $INVDIR/other/$INVTABLE_OVERRIDE
   endif
endif

#
## Miscellaeous input files
   if ( $RUN_MRGGRID == Y ) then
      setenv FILELIST   $INVDIR/other/filelist.mrggrid.txt
   endif
   if ( $RUN_GEOFAC == Y ) then
      setenv AGTS     $OUTPUT/no_file_set
      setenv GEOMASK  $INVDIR/other/no_file_set
      setenv SPECFACS $INVDIR/other/no_file_set
      setenv AGTSFAC  $INVDIR/other/no_file_set
   endif
   if ( $RUN_PKTREDUC == Y ) then
      setenv GCNTL_OUT $INVDIR/no_file_set   # 
   endif
   if ( $RUN_SMK2EMIS == Y ) then
      setenv VNAMMAP  $GE_DAT/VNAMMAP.dat
      setenv UAM_AGTS $OUTPUT/uam_agts_l.$ESDATE.$NDAYS.$GRID.$ASCEN.ncf
      setenv UAM_BGTS $OUTPUT/uam_bgts_l.$ESDATE.$NDAYS.$GRID.$BSCEN.ncf
      setenv UAM_MGTS $OUTPUT/uam_mgts_l.$ESDATE.$NDAYS.$GRID.$MSCEN.ncf
      setenv UAM_PGTS $OUTPUT/uam_pgts_l.$ESDATE.$NDAYS.$GRID.$PSCEN.ncf
      setenv UAM_EGTS $OUTPUT/uam_egts_l.$ESDATE.$NDAYS.$GRID.$ESCEN.ncf
   endif
   if( $RUN_UAMEMIS == Y ) then
      setenv UAMEMIS $OUTPUT/no_file_set
      setenv E2DNCF  $OUTPUT/e2dncf.ncf
   endif

##########################################################################
#
## Output and Intermediate files
#

## Point source intermediate and output files
#
if ( $SMK_SOURCE == 'P' ) then
   setenv PDAY      $INVOPD/pday.$INVOP.ncf       # Point NetCDF day-specific
   setenv PHOUR     $INVOPD/phour.$INVOP.ncf      # Point NetCDF hour-specific
   setenv PHOURPRO  $INVOPD/phourpro.$INVOP.ncf   # Pt NetCDF src-spec dnl profs
   setenv REPINVEN  $REPSTAT/repinven.p.$INVOP.txt
   setenv PTREF_ALT $INVOPD/ptref.smkout.txt      # Point temporal x-ref
#   setenv PTSUPNAME $SMKDAT/run_${PSCEN}/scenario/ptsup.$PSCEN.
   setenv PTSUPNAME $SCENARIO/ptsup_${PSCEN}_
   setenv PTSUP     ${PTSUPNAME}_$G_STDATE.txt
   setenv PCREP     $REPSTAT/pcrep.$PSCEN.rpt           
   setenv PPROJREP  $REPSTAT/pprojrep.$PSCEN.rpt
   setenv PREACREP  $REPSTAT/preacrep.$PSCEN.rpt
   setenv PCSUMREP  $REPSTAT/pcsumrep.$PSCEN.rpt
   setenv PCTLWARN  $REPSTAT/pctlwarn.$PSCEN.txt
   setenv PNTS_O    $INVOPD/pnts.map.$FYINV.txt
   setenv PTINV_O   $PTDAT/ptinv_o.$FYINV.ida.txt
   setenv REPPELV   $REPSTAT/reppelv.$PSCEN.rpt
endif

if ( $SMK_SOURCE == P || $RUN_SMKMERGE == Y && $MRG_POINT == Y ) then
   setenv PNTS     $INVOPD/pnts_map_$FYIOP.txt   # Point inventory map
   setenv PSCC     $INVOPD/PSCC_$FYIOP.txt       # Point unique SCC list
   setenv PTMPNAME $SCENARIO/ptmp_${PSCEN}_
   setenv PTMP     $PTMPNAME$G_STDATE.ncf
   setenv PSMAT_L  $SMKDAT/run_$PBASE/static/psmat_l.$SPC.$PBASE.ncf
   setenv PSMAT_S  $SMKDAT/run_$PBASE/static/psmat_s.$SPC.$PBASE.ncf
   setenv PRMAT_L  $SMKDAT/run_$PSCEN/static/prmat_l.$SPC.$PSCEN.ncf
   setenv PRMAT_S  $SMKDAT/run_$PSCEN/static/prmat_s.$SPC.$PSCEN.ncf
   setenv PRSUP    $SMKDAT/run_$PSCEN/static/prsup.$PSCEN.txt
   setenv PCMAT    $SMKDAT/run_$PSCEN/static/pcmat.$PSCEN.ncf
   setenv PGMAT    $SMKDAT/run_$PBASE/static/pgmat.$GRID.$PBASE.ncf
   setenv PPMAT    $SMKDAT/run_$PSCEN/static/ppmat.$PSCEN.ncf
   setenv STACK_GROUPS $SCENARIO/stack_groups.$GRID.$PBASE.ncf
   setenv PLAY     $SCENARIO/play_${ESDATE}_${PSCEN}_${GRID}.ncf
   setenv PELV     $SCENARIO/PELV_$ESDATE.txt       # #RGA Elev/PinG pt source list
   setenv PHOUR    $INVOPD/phour_$INVOP.ncf   
   setenv POUT     $SCENARIO/pgts2d_l.TEST.RGA.$ESDATE.ncf
endif

#
#
#  Merge output files
   source $ASSIGNS/setmerge_files_fire.csh
if ( $status > 0 ) then
	echo BAD STATUS ON setmerge_files_fire.csh JKV
endif
#
#  Create and change permissions for output directories
   $ASSIGNS/smk_mkdir_fire.csh

   if ( $status > 0 ) then
      set outstat = 1   
   endif
#
#  Get system-specific flags
   source $ASSIGNS/sysflags_fire.csh 
if ( $status > 0 ) then
	echo BAD STATUS ON sysflags_fire.csh JKV
endif

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

#  override env var
if($?APPN) source $SCRIPTS/run/override.env.txt
if ( $status > 0 ) then
	echo BAD STATUS ON override.env.txt   JKV
endif

#  Unset temporary environment variables
   source $ASSIGNS/unset_fire.csh
if ( $status > 0 ) then
	echo BAD STATUS ON unset_fire.csh JKV
endif

if ( $outstat == 1 ) then
   echo "ERROR: Problem found while setting up SMOKE."
   echo "       See messages above."
   exit( 1 )
endif


