#!/bin/csh -f
# WITH -f; without -f option to allow module to work.  JKV 120816
#
#  Serena H. Chung 2015-06-21
# 
#  description:
#
#
#  precondition(s):
#
#     setenv AIRHOME
#     setenv AIROUT
#     setenv AIRLOGDIR
#
#> save current directory path -----------------------------------------
   set BASE = ${PBS_O_WORKDIR}/cctm

#> check argument ------------------------------------------------------

   if ( $1 > 200001 ) then     
      set YEAR = `echo $1 | cut -c1-4`
      set MONTH = `echo $1 | cut -c5-6`
      set DAY = `echo $1 | cut -c7-8`
      set NHRS  = $2
      set currentday  = $YEAR$MONTH$DAY
      set previousday = `date -d "$currentday -1 days" '+%Y%m%d'`
      set twodaysago  = `date -d "$currentday -2 days" '+%Y%m%d'`
      set previousdayyear = `echo $previousday | cut -c1-4`
      set twodaysagoyear = `echo $twodaysago | cut -c1-4`
   else
     echo 'invalid argument. '
     echo "usage $0 <yyyymmdd> <nhrs>"
     set exitstat = 1
     exit ( $exitstat )
   endif
    
#> determine day of the year -------------------------------------------
   set DOYstring = `juldate $MONTH $DAY $YEAR | cut -d',' -f 2`
   set DOY       = `echo $DOYstring | cut -c5-7`
   set YEARDOY   = $YEAR$DOY

   set yearm1  = `echo $previousday | cut -c1-4`
   set monthm1 = `echo $previousday | cut -c5-6`
   set daym1   = `echo $previousday | cut -c7-8`
   set JDstring   = `juldate $monthm1 $daym1 $yearm1 | cut -d',' -f 2`
   set DOYm1 = `echo $JDstring | cut -c5-7`
   set YEARDOYm1 = $yearm1$DOYm1

   set yearm2  = `echo $twodaysago | cut -c1-4`
   set monthm2 = `echo $twodaysago | cut -c5-6`
   set daym2   = `echo $twodaysago | cut -c7-8`
   set JDstring   = `juldate $monthm2 $daym2 $yearm2 | cut -d',' -f 2`
   set DOYm2 = `echo $JDstring | cut -c5-7`
   set YEARDOYm2 = $yearm2$DOYm2

#> initialize exit status ----------------------------------------------
   set exitstat = 0

#> timestep run parameters ---------------------------------------------
   set STDATE   = ${YEARDOY}    # beginning date
   set STTIME   = 080000        # beginning GMT time (HHMMSS)
   set NSTEPS   = ${NHRS}0000   # time duration (HHMMSS) for this run
   set TSTEP    = 010000        # output time step interval (HHMMSS)
   setenv EMISDATE ${currentday}

#> program location ----------------------------------------------------
   set EXEC_ID  = Linux2_x86_64pgi
   set APPL     = cb05tucl_ae6_aq
   set CFG      = Linux2_x86_64pgi
   set MECH     = cb05tucl_ae6_aq 
   set EXEC     = CCTM_${APPL}_$EXEC_ID
   set PROGDIR     = ~airpact5/AIRHOME/build/CMAQ5.0.2/cctm
   set BLD      = ${PROGDIR}/BLD_${APPL}
  #date; cat $BLD/cfg.CCTM_${APPL}_$CFG; echo "    "; set echo

#> horizontal domain decomposition -------------------------------------
      set NPROCS = `wc -l $PBS_NODEFILE | cut -d " " -f 1`
      @ NPCOL = 1
      @ NPROW = $NPROCS
      @ x = $NPROW % 2
      while ( $x == 0 )
            @ NPROW = $NPROW / 2
	    @ NPCOL = $NPCOL * 2
            @ x = $NPROW % 2
	    if ( $NPROW <= $NPCOL ) then
	      @ x = 1
	    endif
      end
      setenv NPCOL_NPROW "$NPCOL $NPROW"

#> input and output directories and files ------------------------------
    set OUTDIR = $AIROUT/CCTM
    mkdir -p ${OUTDIR}

   #> input files and directories
      set OCEANpath = /data/lar/projects/airpact5/misc/domain
      set OCEANfile = OCEANFile_AIRPACT_04km_fixed.ncf
      setenv OCEAN_1 $OCEANpath/$OCEANfile
      set EMISpath  = $AIROUT/EMISSION/merged
      set EMISfile  = EMISSIONS_3D_AIRPACT_04km_${currentday}.ncf
     #set TR_EMpath = $EMISpath # 
     #set TR_EMfile = $EMISfile # 
      ## default to ideal ICON file
      ## (assume that if ideal ICON file exists, there is a reason)
      set GC_ICpath = $AIROUT/ICON
      set GC_ICfile = ICON_AIRPACT_04km_${currentday}.ncf
      if ( ! -e $GC_ICpath/$GC_ICfile ) then
          set GC_ICpath = $AIRROOT/${previousdayyear}/${previousday}00/CCTM
          set GC_ICfile = CGRID_${previousday}.ncf
          if ( ! -e $GC_ICpath/$GC_ICfile ) then
                  echo $GC_ICpath/$GC_ICfile "not found"
                  echo "try for older DAY2 run CGRID file for ICON"
              set GC_ICpath = $AIRROOTDAY2/${twodaysagoyear}/${previousday}00/CCTM
#              set GC_ICpath = $AIROUT/ICON
	      set GC_ICfile = CGRID_${previousday}.ncf 
#              set GC_ICfile = ICON_AIRPACT_04km_${currentday}.ncf
              if ( ! -e $GC_ICpath/$GC_ICfile ) then
                  echo $GC_ICpath/$GC_ICfile "not found"
                  echo "no older DAY2 output to use for ICON"
                  exit(1)
              endif
          endif
      endif
      set GC_BCpath = $BCONDIR/output
      set GC_BCfile = bcon_cb05_$currentday.ncf
      set METpath   = $MCIPDIR
      set OMIpath   = /data/larinput/download/CMAQ/CMAQ5.0/CMAQv5.0/data/raw/phot
      set OMIfile   = OMI.dat
      set JVALpath  = $AIROUT/JPROC
      set JVALfile  = JTABLE_$YEAR$DOY
      set TR_DVpath = $METpath
      set TR_DVfile = METCRO2D
      setenv MCIPROOT $MCIPDIR
      setenv GRID_NAME AIRPACT_04km

   #> input files as environment variables
      setenv GRIDDESC    $MCIPROOT/GRIDDESC
      setenv INIT_GASC_1 $GC_ICpath/$GC_ICfile
      setenv INIT_AERO_1 $INIT_GASC_1
      setenv INIT_NONR_1 $INIT_GASC_1
      setenv INIT_TRAC_1 $INIT_GASC_1
      setenv BNDY_GASC_1 $GC_BCpath/$GC_BCfile
      setenv BNDY_AERO_1 $BNDY_GASC_1
      setenv BNDY_NONR_1 $BNDY_GASC_1
      setenv BNDY_TRAC_1 $BNDY_GASC_1
      setenv GRID_DOT_2D $METpath/GRIDDOT2D
      setenv GRID_CRO_2D $METpath/GRIDCRO2D
      setenv MET_CRO_2D  $METpath/METCRO2D
      setenv MET_CRO_3D  $METpath/METCRO3D
      setenv MET_DOT_3D  $METpath/METDOT3D
      setenv MET_BDY_3D  $METpath/METBDY3D
      setenv EMIS_1      $EMISpath/$EMISfile
      setenv OMI         $OMIpath/$OMIfile
      setenv XJ_DATA     $JVALpath/$JVALfile
      setenv CSQY_DATA ${BLD}/CSQY_DATA_$MECH
      if (! (-e $CSQY_DATA ) ) then
         echo " $CSQY_DATA  not found "
         exit 1
      endif

   #> output files and directories
      set CONCfile  = CONC_$currentday.ncf               # CTM_CONC_1
      set ACONCfile = ACONC_$currentday.ncf              # CTM_ACONC_1
      set CGRIDfile = CGRID_$currentday.ncf              # CTM_CGRID_1
      set DD1file   = DRYDEP_$currentday.ncf             # CTM_DRY_DEP_1
      set DV1file   = DEPV_$currentday.ncf               # CTM_DEPV_DIAG
      set WD1file   = WETDEP1_$currentday.ncf            # CTM_WET_DEP_1
      set WD2file   = WETDEP2_$currentday.ncf            # CTM_WET_DEP_2
      set SS1file   = SSEMIS1_$currentday.ncf            # CTM_SSEMIS_1
      set AV1file   = AEROVIS_$currentday.ncf            # CTM_VIS_1
      set AD1file   = AERODIAM_$currentday.ncf           # CTM_DIAM_1
      set PA1file   = PA_1_$currentday.ncf               # CTM_IPR_1
      set PA2file   = PA_2_$currentday.ncf               # CTM_IPR_2
      set PA3file   = PA_3_$currentday.ncf               # CTM_IPR_3
      set IRR1file  = IRR_1_$currentday.ncf              # CTM_IRR_1
      set IRR2file  = IRR_2_$currentday.ncf              # CTM_IRR_2
      set IRR3file  = IRR_3_$currentday.ncf              # CTM_IRR_3
      set RJ1file   = PHOTDIAG1_$currentday.ncf          # CTM_RJ_1
      set RJ2file   = PHOTDIAG2_$currentday.ncf          # CTM_RJ_2
      set PT1file   = PT3D_$currentday.ncf               # CTM_PT3D_DIAG
      set SSEfile   = SSEMI_$currentday.ncf
      set BIO1file  = B3GTS_S_$currentday.ncf
      set SOIL1file = SOILOUT_$currentday.ncf
      set DSEfile   = DUSTEMIS_$currentday.ncf
      set DEPVFSTfile = DEPVFST_$currentday.ncf
      set DEPVMOSfile = DEPVMOS_$currentday.ncf
      set DDFSTfile = DDFST_$currentday.ncf
      set DDMOSfile = DDMOS_$currentday.ncf

#> CCTM configuration options ------------------------------------------

   setenv CTM_MAXSYNC 300       #> max sync time step (sec) [default: 720]
   setenv CTM_MINSYNC  60       #> min sync time step (sec) [default: 60]
   setenv CTM_CKSUM N           #> write cksum report [ default: Y ]
   setenv CLD_DIAG N            #> write cloud diagnostic file [ default: N ]
   setenv CTM_AERDIAG Y         #> aerosol diagnostic file [ default: N ]
   setenv CTM_PHOTDIAG N        #> photolysis diagnostic file [ default: N ]
   setenv CTM_SSEMDIAG N        #> sea-salt emissions diagnostic file [ default: N ]
   setenv CTM_WB_DUST N         #> use inline windblown dust emissions [ default: Y ]
   setenv CTM_ERODE_AGLAND N    #> use agricultural activity for windblown dust [ default: N ]; ignore if CTM_WB_DUST = N
   setenv CTM_DUSTEM_DIAG N     #> windblown dust emissions diagnostic file [ default: N ]; ignore if CTM_WB_DUST = N
   setenv CTM_LTNG_NO N         #> lightning NOx [ default: N ]
   setenv CTM_WVEL N            #> save derived vertical velocity component to conc file [ default: N ]
   setenv KZMIN Y               #> use Min Kz option in edyintb [ default: Y ], otherwise revert to Kz0UT
   setenv CTM_ILDEPV N          #> calculate in-line deposition velocities [ default: Y ]
   setenv CTM_MOSAIC N          #> landuse specific deposition velocities [ default: N ]
   setenv CTM_ABFLUX N          #> Ammonia bi-directional flux for in-line deposition velocities [ default: N ]; ignore if CTM_ILDEPV = N
   setenv CTM_HGBIDI N          #> Mercury bi-directional flux for in-line deposition velocities [ default: N ]; ignore if CTM_ILDEPV = N
   setenv CTM_SFC_HONO N        #> Surface HONO interaction [ default: Y ]; ignore if CTM_ILDEPV = N
   setenv CTM_DEPV_FILE N       #> write diagnostic file for deposition velocities [ default: N ]
   setenv CTM_BIOGEMIS N        #> calculate in-line biogenic emissions [ default: N ]
   setenv B3GTS_DIAG N          #> write biogenic mass emissions diagnostic file [ default: N ]; ignore if CTM_BIOGEMIS = N
   setenv PT3DDIAG N            #> optional 3d point source emissions diagnostic file [ default: N]; ignore if CTM_PT3DEMIS = N
   setenv PT3DFRAC N            #> optional layer fractions diagnostic (play) file(s) [ default: N]; ignore if CTM_PT3DEMIS = N
   setenv IOAPI_LOG_WRITE F     #> turn on excess WRITE3 logging [ options: T | F ]
   setenv FL_ERR_STOP N         #> stop on inconsistent input files
   setenv PROMPTFLAG F          #> turn off I/O-API PROMPT*FILE interactive mode [ options: T | F ]
   setenv IOAPI_OFFSET_64 YES    #> support large timestep records (>2GB/timestep record) [ options: YES | NO ]
   setenv EXECUTION_ID $EXEC    #> define the model execution id
   setenv LOGFILE $AIRLOGDIR/cctm/CTM_LOG_master.log
 
# JKV 102815  Delete cctm.log and all logs under $AIRLOGDIR/cctm in case of a rerun
   rm -f $AIRLOGDIR/cctm.log $AIRLOGDIR/cctm/*
  #setenv CONC_SPCS "O3 NO NO2 ANO3I ANO3J HCHO ISOPRENE ANH4J ASO4I ASO4J" #> CONC file species; comment or set to "ALL" to write all species to CONC
  #setenv CONC_SPCS "ASO4I ANH4I ANO3I AORGPAI A25I AECI ANAI ACLI ASO4J ANH4J ANO3J AORGPAJ AXYL3J ATOL3J ABNZ3J AISO3J AOLGAJ AOLGBJ AORGCJ A25J AECJ ANAJ ACLJ AH2OJ AALKJ AXYL1J AXYL2J ATOL1J ATOL2J ABNZ1J ABNZ2J ATRP1J ATRP2J AISO1J AISO2J ASQTJ AH2OI O3 CO"  
  # next is based on BCON species list:  JKV 112017
  # setenv CONC_SPCS "IOLE TERP ETH ETHA OLE AECJ FORM ALD2 MGLY AACD MEOH MEPX CO CRES ALDX H2O2 HNO3 PNA HO2 ISPD ISOP PANX N2O5 NO2 NO O3 NTR PAN SO2 TOL NO3"
  # setenv CONC_SPCS "ALL"  does not seem to work.
   # Default for CONC_SPCS is all species.  JKv 112217
   # setenv CONC_SPCS "O3 CO"
   setenv AVG_CONC_SPCS "ALL"
   setenv ACONC_BLEV_ELEV " 1 37"  #> ACONC file layer range; comment to write all layers to ACONC
  #setenv ACONC_END_TIME Y #> override default beginning ACON timestamp [ default: N ]

   #> output files as environment variables
      source $BASE/outck.q
      if ( $status ) exit 1
   #> for the run control
      setenv CTM_STDATE      $STDATE
      setenv CTM_STTIME      $STTIME
      setenv CTM_RUNLEN      $NSTEPS
      setenv CTM_TSTEP       $TSTEP
      setenv CTM_PROGNAME    $EXEC

   #> inline plume rise emissions processing
      setenv CTM_PT3DEMIS N # switched to N on 2016-04-23
      # setenv NPTGRPS 1
      # set SECTOR = point
      # setenv Sect01 "mwdss_Y"
      # #> scenario "constant" files
      #    setenv STK_GRPS_01 $AIROUT/EMISSION/anthro/output/point/stack_groups_2014nw_${YEARDOY}.ncf
      # #> scenario daily files
      #    setenv STK_EMIS_01 $AIROUT/EMISSION/anthro/scenario/point/INLN_point_2014nw_${YEARDOY}.ncf
      # #> whether to get average 3D plume rise emissions in a diagnostic
      #    setenv PT3DDIAG N
      # setenv LAYP_STDATE $STDATE
      # setenv LAYP_STTIME $STTIME
      # setenv LAYP_NSTEPS $NSTEPS
      setenv CTM_EMLAYS 37

      # Create Merge dates file
cat > $AIROUT/EMISSION/anthro/MERGE_DATE_${YEARDOY}.txt <<EOF
Date, aveday_N, aveday_Y,  mwdss_N,  mwdss_Y,   week_N,   week_Y,      all
$currentday, $currentday, $currentday, $currentday, $currentday, $currentday, $currentday, $currentday
EOF
         setenv MERGE_DATES $AIROUT/EMISSION/anthro/MERGE_DATE_${YEARDOY}.txt

   #> species defn & photolysis
      setenv gc_matrix_nml ${BASE}/GC_$MECH.nml
      setenv ae_matrix_nml ${BASE}/AE_$MECH.nml
      setenv nr_matrix_nml ${BASE}/NR_$MECH.nml
      setenv tr_matrix_nml ${BASE}/Species_Table_TR_0.nml

   #> look for existing log files
      setenv DISP delete            #> [ delete | update | keep ] existing output files
      setenv CTM_APPL $APPL
      setenv FLOOR_FILE $AIRLOGDIR/cctm/CTM_FLOOR # don't think this matters
      set test = `ls ${AIRLOGDIR}/cctm/CTM_LOG_*.log`
      if ( "$test" != "" ) then
         if ( $DISP == 'delete' ) then
            echo " ancillary log files being deleted"
            foreach file ( $test )
               echo " deleting $file"
               rm $file
            end
         else
            echo "*** Logs exist - run ABORTED ***"
            exit 1
         endif
      endif
  
# ----------------------------------------------------------------------
  #> cd to the log directory so that CTM_*.log files will be stored there
   if ( ! -d $AIRLOGDIR/cctm) then
		rm -fR $AIRLOGDIR/cctm
		mkdir -p $AIRLOGDIR/cctm
   endif
   cd $AIRLOGDIR/cctm
#   touch $LOGFILE 
   echo LOGFILE is $LOGFILE 

 #> executable call for parallel executable, uncomment to invoke
    ls -l $BLD/$EXEC

#	 size $BLD/$EXEC

#    module load openmpi/1.6pgi 
    mpirun $BLD/$EXEC
#    /opt/openmpi/bin/mpirun $BLD/$EXEC
#    /opt/openmpi-pgi/1.6/bin/mpirun $BLD/$EXEC
#mpirun --mca btl openib,sm,self $BLD/$EXEC
 date
 #exit

 set exitstat = $status
 exit ($exitstat)
