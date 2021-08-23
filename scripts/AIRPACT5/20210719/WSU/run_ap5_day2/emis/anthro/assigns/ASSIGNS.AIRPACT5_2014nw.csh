#/bin/csh -fx
#
## HEADER ##################################################################
#
#  SMOKE ASSIGNS file (sets up for area, biogenic, mobile, nonroad, and point sources)
#
#  Version @(#)$Id: ASSIGNS.nctox.cmaq.cb4p25_wtox.us12-nc,v 1.5 2007/06/29 13:37:47 bbaek Exp $
#  Path    $Source: /afs/isis/depts/cep/emc/apps/archive/smoke/smoke/assigns/ASSIGNS.nctox.cmaq.cb4p25_wtox.us12-nc,v $
#  Date    $Date: 2007/06/29 13:37:47 $
#
#  Scenario Description:
#     This assigns file sets up the environment variables for use of 
#     SMOKE Version 2.1 outside of the Models-3 system.
#
#  Usage:
#     source <Assign>
#     Note: First set the SMK_HOME env variable to the base SMOKE installation
#
## END HEADER ##############################################################

## I/O Naming roots
#
   setenv INVID     2014nw        # Inventory input identifier
   setenv INVOP     2014nw        # Base year inventory output name
   setenv INVEN     2014nw        # Base year inventory name with version
   setenv FYIOP     2014nw
   setenv FYINV     2014nw

   setenv ABASE     2014nw        # Area base case output name
   setenv BBASE     2014nw        # Biogenics base case output name
   setenv MBASE     2014nw        # Mobile base case output name
   setenv PBASE     2014nw        # Point base case output name

   setenv ESCEN     2014nw
   setenv ASCEN     2014nw
   setenv MSCEN     2014nw
   setenv BSCEN     2014nw
   setenv PSCEN     2014nw
   setenv EBASE     2014nw       # Output merged base case name

   setenv METSCEN      4km              # Met scenario name
   setenv GRID         AIRPACT_04km     # Gridding root for naming
   setenv IOAPI_GRIDNAME_1 AIRPACT_04km # Grid selected from GRIDDESC file
   setenv IOAPI_ISPH   19               # Specifies spheroid type associated with grid
   setenv SPC          cmaq.CB05        #  was SAPRC99 JKV052115     # Speciation type

## Mobile episode variables
   setenv EPI_STDATE {$INVEN}191     # Julian start date
   setenv EPI_STTIME  000000     # start time (HHMMSS)
   setenv EPI_RUNLEN 0480000     # run length (HHHMMSS)
   setenv EPI_NDAY   1           # number of full run days

## Per-period environment variables
   setenv G_STDATE  {$INVEN}191      # Julian start date
   setenv G_STTIME   080000      # start time (HHMMSS)
   setenv G_TSTEP     10000      # time step  (HHMMSS)
   setenv G_RUNLEN   250000      # run length (HHMMSS)
   setenv ESDATE   {$INVEN}0710      # Start date of emis time-based files/dirs
   setenv MSDATE   {$INVEN}0710      # Start date of met  time-based files
   setenv NDAYS           1      # Duration in days of each emissions file
   setenv MDAYS           1      # Duration in days of met  time-based files
   setenv YEAR         2005      # Base year for year-specific files

## Reset days if overrides are available
   if ( $?G_STDATE_ADVANCE ) then
       set date = $G_STDATE
       @ date = $date + $G_STDATE_ADVANCE
       setenv G_STDATE $date
       setenv IOAPIDIR /home/lar/opt/ioapi_3_v2/Linux2_x86pg_pgcc_nomp_openmpi1.4.3_pgi8.0-5
       setenv ESDATE `$IOAPIDIR/datshift $G_STDATE 0`
   endif

## User-defined I/O directory settings
  #shc 2011-12-12: The following are commented out because they should have
  #                already be defined
   #setenv SMK_SUBSYS  $SMK_HOME/subsys              # SMOKE subsystem dir
   #setenv SMKROOT     $SMK_SUBSYS/smoke             # System root dir
   #setenv SMKDAT      $SMK_HOME/data                # Data root dir
   #setenv ASSIGNS     $SMKROOT/assigns              # smoke assigns files
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
   source $ASSIGNS/set_case.scr
   if ( $status > 0 ) then
      set outstat = 1
   endif

## Set dependent directory names
#
#source $ASSIGNS/set_dirs.scr

## Check script settings
#source $ASSIGNS/check_settings.scr

##########  SMOKE formatted raw inputs #############
#
  setenv SMKDAT   $SMK_HOME/data
  setenv GE_DAT   $SMKDAT/ge_dat
  setenv INVDIR   $SMK_HOME/emissions/$SECTOR
  setenv INTERMED $SMK_HOME/intermediate
  setenv OUTPUT   $SMK_HOME/output/$SECTOR/$SUBSECT
  setenv INVOPD   $INTERMED/$SECTOR/$SUBSECT

  setenv REPORTS  $SMK_HOME/reports       # Output reports root dir
  setenv REPSCEN  $REPORTS/scenario                       # Output reports scenario dir
  setenv REPSTAT  $REPORTS/static                         # Output reports dir

#
  source $ASSIGNS/set_dirs.scr
  source $ASSIGNS/check_settings.scr


## Area-source input files
if ( $SMK_SOURCE == 'A' ) then
   setenv ARINV     $INVDIR/$SUBSECT/{$SUBSECT}_2014nw.lst      # Stationary area emission inventory
   setenv REPCONFIG $INVDIR/area/REPCONFIG.area.txt             # Default report configurations
   setenv NRINV     $INVDIR/$SUBSECT/{$SUBSECT}_2014nw.lst      # Nonroad mobile emission inventory
   setenv ARTOPNT   $INVDIR/ar2pt_14OCT03_1999.txt              # area-to-point assignments
   setenv AGREF     $GE_DAT/amgref_4km_2014.txt                 # Area gridding x-ref for AIRPACT-5
   setenv ATPRO     $GE_DAT/aptpro_AP5_final.txt                    # Temporal profiles
   setenv ATREF     $GE_DAT/aptref_AP5_final.txt                # Area temporal x-ref for AIRPACT-5
endif
#
## Biogenic input files (not used, but remove the lines at your own peril)
if ( $SMK_SOURCE == 'B' ) then
   setenv BGUSE   $SMKDAT/inventory/beld2/beld.5.us36.txt  # Gridded landuse
   setenv METLIST $INVDIR/biog/metlist.tmpbio.txt          # Meteorology file list for temperatures
   setenv RADLIST $INVDIR/biog/radlist.tmpbio.txt          # Meteorology file list for solar radiation
   setenv BFAC    $GE_DAT/bfac.summer.txt                  # Default biogenic emission factors
   setenv S_BFAC  $GE_DAT/bfac.summer.txt                  # Summer biogenic emission factors
   setenv W_BFAC  $GE_DAT/bfac.winter.txt                  # Winter biogenic emission factors
   setenv BCUSE   $GE_DAT/landuse.dat                      # County landuse
   setenv B3FAC   $GE_DAT/b3fac.beis3_efac_v0.98.txt
   setenv B3XRF   $GE_DAT/b3tob2B.xrf                      # Beld3 to Beld2 cross-reference
   setenv BELD3_TOT $INVDIR/biog/beld3.${IOAPI_GRIDNAME_1}.output_tot.ncf
   setenv BELD3_A   $INVDIR/biog/beld3.${IOAPI_GRIDNAME_1}.output_a.ncf
   setenv BELD3_B   $INVDIR/biog/beld3.${IOAPI_GRIDNAME_1}.output_b.ncf
   setenv SOILINP  $STATIC/soil.beis312.$GRID.$SPC.ncf     # NO soil input file
endif

if ( $SMK_SOURCE == 'B' || $MRG_BIOG == 'Y' ) then
   setenv BGPRO   $GE_DAT/bgpro.12km_041604.nc.txt         # Biogenic gridding surrogates
endif

#

## Point source input files
if ( $SMK_SOURCE == 'P' ) then
   setenv PTINV      $INVDIR/point_2014nw.lst                 # EMS-95 point emissions
   setenv PTDAY      $INVDIR/ptday.lst                 # daily point emis
   setenv PTHOUR     $INVDIR/pthour.lst                # hourly point emis
   setenv PELVCONFIG $INVDIR/pelvconfig.top50.txt      # elevated source selection
   setenv REPCONFIG  $INVDIR/repconfig.point.txt       # Default report configurations
   #      PTMPLIST                                           # Set automatically by script
   setenv PTPRO      $GE_DAT/aptpro_AP5_final.txt   # Temporal profiles
   setenv PTREF      $GE_DAT/aptref_AP5_final.txt   # Point temporal x-ref
   setenv PSTK       $GE_DAT/pstk_4km_2014.txt        # Replacement stack params
endif
#
## Shared input files
   setenv INVTABLE    $GE_DAT/invtable_42125.txt # Inventory table
# setenv NHAPEXCLUDE $GE_DAT/ # NONHAPVOC exclusions x-ref
   setenv GRIDDESC    $GE_DAT/GRIDDESC             # Grid descriptions.
   setenv COSTCY      $GE_DAT/costcy_v8.txt        # country/state/county info
   setenv HOLIDAYS    $GE_DAT/holidays_2005_2019.txt         # holidays for day change
   setenv SCCDESC     $GE_DAT/scc_desc_030804.txt  # SCC descriptions
   setenv SRGDESC     $GE_DAT/srgdesc_4km_airpact5.txt
   setenv SRGPRO_PATH $GE_DAT/SRGPRO/     # surrogate files path # udpated 052315 JKV 
   setenv ORISDESC    $GE_DAT/orisdesc_04dec2006_v0.txt        # ORIS ID descriptions
   setenv MACTDESC    $GE_DAT/        # MACT descriptions
   setenv NAICSDESC   $GE_DAT/       # NAICS descriptions
   setenv GSCNV       $GE_DAT/gscnv_42125.txt
   setenv GSREF       $GE_DAT/gsref_42125.txt       # Speciation x-ref
   setenv GSPRO       $GE_DAT/gspro_42125.txt       # Speciation profiles
#   setenv PROCDATES   $GE_DAT/procdates.txt        # time periods that Temporal should process

#
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

## Meteorology IO/API input files (MCIP output files)
#
   setenv METDAT $AIROUT/MCIP 
   if ( $SMK_SOURCE == 'B' || $SMK_SOURCE == 'M' || $SMK_SOURCE == 'P' ) then
      setenv GRID_CRO_2D $METDAT/GRIDCRO2D
      setenv MET_CRO_2D  $METDAT/METCRO2D
      setenv MET_CRO_3D  $METDAT/METCRO3D
      setenv MET_DOT_3D  $METDAT/METDOT3D
      setenv MET_FILE1   $MET_CRO_2D
      setenv MET_FILE2   $MET_CRO_2D
   endif

#
##########################################################################
#
## Output and Intermediate files
#
## Area source intermediate and output files
#
if ( $SMK_SOURCE == 'A' ) then
   setenv ASCC     $INVOPD/ASCC.$FYIOP.txt
   setenv REPINVEN $REPSTAT/repinven.a.$INVOP.txt
   setenv ATSUPNAME $INVOPD/scenario/atsup.$ASCEN.
   setenv ATSUP    $ATSUPNAME.$G_STDATE.txt
   setenv ASSUP    $INVOPD/static/assup.$SPC.$ABASE.txt
   setenv AGSUP    $INVOPD/static/agsup.$GRID.$ABASE.txt
   setenv ACREP    $REPSTAT/acrep.$ASCEN.rpt           
   setenv APROJREP $REPSTAT/aprojrep.$ASCEN.rpt
   setenv AREACREP $REPSTAT/areacrep.$ASCEN.rpt
   setenv ACSUMREP $REPSTAT/acsumrep.$ASCEN.rpt
   setenv ACTLWARN $REPSTAT/actlwarn.$ASCEN.txt
   setenv AREA_O   $INVOPD/area.map.$FYINV.txt
   setenv ARINV_O  $ARDAT/arinv_o.$FYINV.orl.txt

   setenv NSCC     $INVOPD/NSCC.$FYIOP.txt
   setenv NEPINVEN $REPSTAT/repinven.nr.$INVOP.txt
   setenv NTSUPNAME $INVOPD/scenario/ntsup.$ASCEN.
   setenv NTSUP    $NTSUPNAME.$G_STDATE.txt
   setenv NSSUP    $INVOPD/static/nssup.$SPC.$ABASE.txt
   setenv NGSUP    $INVOPD/static/ngsup.$GRID.$ABASE.txt
   setenv NCREP    $REPSTAT/ncrep.$ASCEN.rpt           
   setenv NPROJREP $REPSTAT/nprojrep.$ASCEN.rpt
   setenv NREACREP $REPSTAT/nreacrep.$ASCEN.rpt
   setenv NCSUMREP $REPSTAT/ncsumrep.$ASCEN.rpt
   setenv NCTLWARN $REPSTAT/nctlwarn.$ASCEN.txt
   setenv NROAD_O  $INVOPD/nroad.map.$FYINV.txt
   setenv NRINV_O  $NRDAT/nrinv_o.$FYINV.ida.txt
endif

if ( $SMK_SOURCE == A || $RUN_SMKMERGE == Y && $MRG_AREA == Y ) then
   setenv AREA     $INVOPD/area.map.$FYIOP.txt   # Area inventory map
   setenv ATMPNAME $SMKDAT/run_$ASCEN/scenario/atmp.$ASCEN.
   setenv ATMP     $ATMPNAME$G_STDATE.ncf
   setenv ASMAT_S  $INVOPD/static/asmat_s.$SPC.$ABASE.ncf
   setenv ASMAT_L  $INVOPD/static/asmat_l.$SPC.$ABASE.ncf
   setenv ARMAT_L  $INVOPD/static/armat_l.$SPC.$ASCEN.ncf
   setenv ARMAT_S  $INVOPD/static/armat_s.$SPC.$ASCEN.ncf
   setenv ARSUP    $INVOPD/static/arsup.$ASCEN.txt
   setenv ACMAT    $INVOPD/static/acmat.$ASCEN.ncf          
   setenv AGMAT    $INVOPD/static/agmat.$GRID.$ABASE.ncf
   setenv APMAT    $INVOPD/static/apmat.$ASCEN.ncf

   setenv NROAD    $INVOPD/nroad.map.$FYIOP.txt  # Nonroad inventory map
   setenv NTMPNAME $INVOPD/scenario/ntmp.$ASCEN.
   setenv NTMP     $NTMPNAME$G_STDATE.ncf
   setenv NSMAT_S  $INVOPD/static/nsmat_s.$SPC.$ABASE.ncf
   setenv NSMAT_L  $INVOPD/static/nsmat_l.$SPC.$ABASE.ncf
   setenv NRMAT_L  $INVOPD/static/nrmat_l.$SPC.$ASCEN.ncf
   setenv NRMAT_S  $INVOPD/static/nrmat_s.$SPC.$ASCEN.ncf
   setenv NRSUP    $INVOPD/static/nrsup.$ASCEN.txt
   setenv NCMAT    $INVOPD/static/ncmat.$ASCEN.ncf          
   setenv NGMAT    $INVOPD/static/ngmat.$GRID.$ABASE.ncf
   setenv NPMAT    $INVOPD/static/npmat.$ASCEN.ncf
endif

## Biogenic source intermediate and output files
#
if ( $SMK_SOURCE == 'B' ) then
   setenv BGRD      $INVOPD/bgrd.summer.$GRID.$BSCEN.ncf  # Summer/default normalized bio emis
   setenv BGRDW     $INVOPD/bgrd.winter.$GRID.$BSCEN.ncf  # Winter grd normalized bio emis
   setenv BIOSEASON $GE_DAT/bioseason.$YEAR.us36.ncf
   setenv B3GRD     $INVOPD/b3grd.$GRID.$BSCEN.ncf
   setenv SOILOUT   $STATIC/soil.beis312.$GRID.$SPC.ncf  # NO soil output file
endif

if ( $SMK_SOURCE == 'B' || $MRG_BIOG == 'Y' ) then
   setenv BGTS_L    $B_OUT/b3gts_l.$ESDATE.$NDAYS.$GRID.$MSB.ncf
   setenv BGTS_S    $B_OUT/b3gts_s.$ESDATE.$NDAYS.$GRID.$MSB.ncf
   setenv B3GTS_L   $B_OUT/b3gts_l.$ESDATE.$NDAYS.$GRID.$MSB.ncf
   setenv B3GTS_S   $B_OUT/b3gts_s.$ESDATE.$NDAYS.$GRID.$MSB.ncf
   setenv BGTS_L_O  $B_OUT/bgts_l_o.$ESDATE.$NDAYS.$GRID.$MSB.ncf
   setenv BGTS_S_O  $B_OUT/bgts_s_o.$ESDATE.$NDAYS.$GRID.$MSB.ncf
   setenv B3GTS_L_O $B_OUT/b3gts_l_o.$ESDATE.$NDAYS.$GRID.$MSB.ncf
   setenv B3GTS_S_O $B_OUT/b3gts_s_o.$ESDATE.$NDAYS.$GRID.$MSB.ncf
endif

# Mobile source intermediate and output files 
#
if ( $SMK_SOURCE == 'M' ) then
   setenv MSCC     $INVOPD/MSCC.$FYIOP.txt
   setenv REPINVEN $REPSTAT/repinven.m.$INVOP.txt
   setenv MTSUPNAME $INVOPD/scenario/mtsup.$MSCEN.
   setenv MTSUP    $MTSUPNAME.$G_STDATE.txt
   setenv MSSUP    $INVOPD/static/mssup.$SPC.$MBASE.txt
   setenv MGSUP    $INVOPD/static/mgsup.$GRID.$MBASE.txt
   setenv MCREP    $REPSTAT/mcrep.$MSCEN.rpt           
   setenv MPROJREP $REPSTAT/mprojrep.$MSCEN.rpt
   setenv MREACREP $REPSTAT/mreacrep.$MSCEN.rpt
   setenv MCSUMREP $REPSTAT/mcsumrep.$MSCEN.rpt
   setenv MCTLWARN $REPSTAT/mctlwarn.$MSCEN.txt
   #      HOURLYT      automaticall set and created by emisfac_run.scr script
   #      MEFLIST      automatically set and created by smk_run.scr script
   setenv SPDSUM       $STATIC/spdsum.$MSCEN.txt        # Speed summary file
   setenv DAILYGROUP   $STATIC/group.daily.$MSCEN.txt   # Daily group file
   setenv WEEKLYGROUP  $STATIC/group.weekly.$MSCEN.txt  # Weekly group file
   setenv MONTHLYGROUP $STATIC/group.monthly.$MSCEN.txt # Monthly group file
   setenv EPISODEGROUP $STATIC/group.episode.$MSCEN.txt # Episode length group file
   setenv MOBL_O   $INVOPD/mobl.map.$FYINV.txt
   setenv MBINV_O  $MBDAT/mbinv_o.$FYINV.emis.txt
   setenv MBINV_AO $MBDAT/mbinv_o.$FYINV.actv.txt
endif

if ( $SMK_SOURCE == M || $RUN_SMKMERGE == Y && $MRG_MOBILE == Y ) then
   setenv MOBL     $INVOPD/mobl.map.$FYIOP.txt   # Mobile inventory map
   setenv MTMPNAME $SMKDAT/run_$MSCEN/scenario/mtmp.$MSCEN.
   setenv MTMP     $MTMPNAME$G_STDATE.ncf
   setenv MSMAT_L  $INVOPD/static/msmat_l.$SPC.$MBASE.ncf
   setenv MSMAT_S  $INVOPD/static/msmat_s.$SPC.$MBASE.ncf    
   setenv MRMAT_L  $INVOPD/static/mrmat_l.$SPC.$MSCEN.ncf    
   setenv MRMAT_S  $INVOPD/static/mrmat_s.$SPC.$MSCEN.ncf
   setenv MRSUP    $INVOPD/static/mrsup.$MSCEN.txt
   setenv MCMAT    $INVOPD/static/mcmat.$MSCEN.ncf           
   setenv MUMAT    $INVOPD/static/mumat.$GRID.$MBASE.ncf
   setenv MGMAT    $INVOPD/static/mgmat.$GRID.$MBASE.ncf
   setenv MPMAT    $INVOPD/static/mpmat.$MSCEN.ncf           
endif

## Point source intermediate and output files
#
if ( $SMK_SOURCE == 'P' ) then
   setenv PDAY      $INVOPD/pday.$INVOP.ncf       # Point NetCDF day-specific
   setenv PHOUR     $INVOPD/phour.$INVOP.ncf      # Point NetCDF hour-specific
   setenv PHOURPRO  $INVOPD/phourpro.$INVOP.ncf   # Pt NetCDF src-spec dnl profs
   setenv REPINVEN  $REPSTAT/repinven.p.$INVOP.txt
   setenv PTREF_ALT $INVOPD/ptref.smkout.txt      # Point temporal x-ref
   setenv PTSUPNAME $INVOPD/scenario/ptsup.$PSCEN.
   setenv PTSUP     $PTSUPNAME.$G_STDATE.txt
   setenv PSSUP     $INVOPD/static/pssup.$SPC.$PBASE.txt
   setenv PCREP     $REPSTAT/pcrep.$PSCEN.rpt           
   setenv PPROJREP  $REPSTAT/pprojrep.$PSCEN.rpt
   setenv PREACREP  $REPSTAT/preacrep.$PSCEN.rpt
   setenv PCSUMREP  $REPSTAT/pcsumrep.$PSCEN.rpt
   setenv PCTLWARN  $REPSTAT/pctlwarn.$PSCEN.txt
   setenv PNTS_O    $INVOPD/pnts.map.$FYINV.txt
   setenv PTINV_O   $PTDAT/ptinv_o.$FYINV.orl.txt
   setenv REPPELV   $REPSTAT/reppelv.$PSCEN.rpt
endif

if ( $SMK_SOURCE == P || $RUN_SMKMERGE == Y && $MRG_POINT == Y ) then
   setenv PNTS     $INVOPD/pnts.map.$FYIOP.txt   # Point inventory map
   setenv PSCC     $INVOPD/PSCC.$FYIOP.txt       # Point unique SCC list
   setenv PTMPNAME $INVOPD/scenario/ptmp.$PSCEN.
   setenv PTMP     $PTMPNAME$G_STDATE.ncf                 #shc uncommented for non_temporal 2012-10-26
   setenv PSMAT_L  $INVOPD/static/psmat_l.$SPC.$PBASE.ncf #shc uncommented for non_temporal 2012-10-26
   setenv PSMAT_S  $INVOPD/static/psmat_s.$SPC.$PBASE.ncf #shc uncommented for non_temporal 2012-10-26
   setenv PRMAT_L  $INVOPD/static/prmat_l.$SPC.$PSCEN.ncf #shc uncommented for non_temporal 2012-10-26
   setenv PRMAT_S  $INVOPD/static/prmat_s.$SPC.$PSCEN.ncf #shc uncommented for non_temporal 2012-10-26
   setenv PRSUP    $INVOPD/static/prsup.$PSCEN.txt
   setenv PCMAT    $INVOPD/static/pcmat.$PSCEN.ncf
   setenv PGMAT    $INVOPD/static/pgmat.$GRID.$PBASE.ncf
   setenv PPMAT    $INVOPD/static/ppmat.$PSCEN.ncf
#   setenv STACK_GROUPS $OUTPUT/stack_groups.$GRID.$PBASE.ncf
   setenv PLAY     $INVOPD/scenario/play.$ESDATE.$NDAYS.$GRID.$MSPBAS.ncf
   setenv PLAY_EX  $INVOPD/scenario/play_ex.$ESDATE.$NDAYS.$GRID.$MSPBAS.ncf
   setenv PELV     $STATIC/PELV.$PBASE.txt       # Elev/PinG pt source list
endif

#
## Conditional settings
   if ( $SMK_SOURCE == A && $NONROAD == Y ) then
      setenv ARINV   $NRINV
      setenv AREA    $NROAD  
      setenv ATMP    $NTMP   
      setenv ATMPNAME $NTMPNAME
      setenv ASMAT_S $NSMAT_S
      setenv ASMAT_L $NSMAT_L
      setenv ARMAT_S $NRMAT_S
      setenv ARMAT_L $NRMAT_L
      setenv ARSUP   $NRSUP  
      setenv ACMAT   $NCMAT 
      setenv AGMAT   $NGMAT  
      setenv APMAT   $NPMAT  
      setenv ASCC    $NSCC     
      setenv REPINVEN $NEPINVEN 
      setenv ATSUP    $NTSUP    
      setenv ATSUPNAME $NTSUPNAME
      setenv ASSUP    $NSSUP    
      setenv AGSUP    $NGSUP    
      setenv ACREP    $NCREP    
      setenv APROJREP $NPROJREP 
      setenv AREACREP $NREACREP
      setenv ACSUMREP $NCSUMREP
      setenv ACTLWARN $NCTLWARN
      setenv AREA_O   $NROAD_O 
      setenv ARINV_O  $NRINV_O 
   endif

   if ( $SMK_SOURCE == A ) then
      unsetenv NRINV NCNTL NROAD NTMP NTMPNAME NSMAT_S NSMAT_L NRMAT_S NRMAT_L NRSUP NCMAT NGMAT NPMAT
      unsetenv NSCC NEPINVEN NTSUP NTSUPNAME NSSUP NGSUP NCREP NPROJREP NREACREP NCSUMREP NROAD_O NRINV_O
   endif

# Cumstomized Smkmerge output file names when merging all souce sectors
# If using Smkmerge to merge all sectors
   
   if ( $SMKMERGE_CUSTOM_OUTPUT == Y && $RUN_SMKMERGE == Y ) then

         setenv EOUT  $OUTPUT/egts_l.$ESDATE.$NDAYS.$SPC.$GRID.$ESCEN.ncf 
         setenv AOUT  $A_OUT/agts_l.$ESDATE.$NDAYS.$GRID.$ASCEN.ncf 
         setenv BOUT  $B_OUT/bgts_l_o.$ESDATE.$NDAYS.$GRID.$MSB.ncf
         setenv MOUT  $M_OUT/mgts_l.$ESDATE.$NDAYS.$GRID.$MSCEN.ncf
         #(RGA) setenv POUT  $P_OUT/pgts3d_l.$ESDATE.$NDAYS.$GRID.$PSCEN.ncf
         setenv PING  $OUTPUT/pingts_l.$ESDATE.$NDAYS.$GRID.$PSCEN.ncf 
         setenv ELEV  $OUTPUT/elevts_l.$ESDATE.$NDAYS.$GRID.$PSCEN.txt 
         setenv REPEG $REPSCEN/rep_${MM}_all_${ESDATE}_${GRID}_${SPC}.txt
         setenv REPAG $REPSCEN/rep_${MM}_ar_${ESDATE}_${GRID}_${SPC}.txt
         setenv REPBG $REPSCEN/rep_${MM}_bg_${ESDATE}_${GRID}_${SPC}.txt
         setenv REPMG $REPSCEN/rep_${MM}_mb_${ESDATE}_${GRID}_${SPC}.txt
         setenv REPPG $REPSCEN/rep_${MM}_pt_${ESDATE}_${GRID}_${SPC}.txt
         setenv AGTS_L    $AOUT 
         setenv PGTS_L    $POUT
         setenv PGTS3D_L  $POUT
         setenv EGTS_L    $EOUT
         setenv REPB3GTS_L $REPSCEN/repb3gts_l.$ESDATE.$NDAYS.$GRID.$BSCEN.rpt
         setenv REPB3GTS_S $REPSCEN/repb3gts_s.$ESDATE.$NDAYS.$GRID.$BSCEN.rpt
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

