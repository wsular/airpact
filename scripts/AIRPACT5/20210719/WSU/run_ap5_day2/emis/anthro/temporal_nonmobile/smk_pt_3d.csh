#!/bin/csh -f

# called from run_smk_temporal_nonmobile.csh

# switch(es)
  setenv RUN_TEMPORAL  Y #Y
  setenv RUN_ELEVPOINT Y #Y
  setenv RUN_LAYPOINT  Y #N
  setenv RUN_SMKMERGE  Y #Y
  setenv RUN_PING      Y #Y        ## Set to run P-in-G or not
  if ( $RUN_PING == 'N' ) then
     echo "*** No plume-in-grid in point source processing ***"
     setenv RUN_ELEVPOINT  N
  endif

# initialize exit status
  set exitstat = 0

# inventory source and general flags
  setenv SECTOR point
  setenv INVSRC        2014nw
  setenv SMK_SOURCE    'P'               # source indicator 
  setenv PROMPTFLAG    N                 # non-interactive prompt
  setenv SMK_EMLAYS    37                # number of layers
  setenv COSTCY      $GE_DAT/costcy_v8.txt
  setenv HOLIDAYS    $GE_DAT/holidays_2005_2019.txt
  setenv GRIDDESC    $GE_DAT/GRIDDESC
  setenv PTREF       $GE_DAT/aptref_AP5_final.txt
  setenv PTPRO       $GE_DAT/aptpro_AP5_final.txt
  setenv PELVCONFIG  $GE_DAT/pelvconfig_allpts_29nov2006_v0.txt
  setenv INVTABLE    $GE_DAT/invtable_42125.txt 
  setenv SPC         cmaq.CB05
 
# input switches
  setenv OUTZONE            0    # output timezone (GMT)
  setenv SMK_DEFAULT_TZONE  8    # default timezone to be PST
  setenv UNIFORM_TROF_YN    N    # not uniform profile
  setenv ZONE4WM            Y    
  setenv DAY_SPECIFIC_YN    N

# input directories & files
  setenv STATIC   $PTBASE/static    # for SMK time indep. inputs
  setenv INVOPD   $PTBASE           # for SMK output inventory
  setenv PNTS     $INVOPD/pnts.map.$INVSRC.txt
  setenv PSRC     $INVOPD/psrc.txt

# output directories
  setenv INTDIR  $EIROOT/scenario/$SECTOR  # For intermediate files
  setenv OUTDIR  $EIROOT/output/$SECTOR    # For final source output files
  setenv LOGDIR $AIRLOGDIR/emis/anthro/log01_$SECTOR
  if ( ! -d $INTDIR ) mkdir -p $INTDIR
  if ( ! -d $OUTDIR ) mkdir -p $OUTDIR
  if ( ! -d $LOGDIR ) mkdir -p $LOGDIR

# TEMPORAL
  if ( $RUN_TEMPORAL == 'Y' ) then
     # output files
       setenv PTMPNAME   $INTDIR/ptmp_${SECTOR}_${INVSRC}_
       setenv PTMP       $PTMPNAME$G_STDATE.ncf
#from ASSIGNS file  setenv PTSUPNAME $INVOPD/scenario/ptsup.$PSCEN.
#from ASSIGNS file   setenv PTSUP     $PTSUPNAME.$G_STDATE.txt
# was       setenv PTSUPNAME  ptsup_${SECTOR}_${INVSRC}_
       setenv PTSUPNAME  $INTDIR/ptsup_${SECTOR}_${INVSRC}_ 
       setenv PTSUP      ${PTSUPNAME}${G_STDATE}.txt
       setenv LOGFILE    $LOGDIR/log01_temporal_${SECTOR}_${INVSRC}_${G_STDATE}.txt

     # run SMOKE's temporal program
       rm -f $LOGFILE $PTMP $PTSUP    # remove old outputs
       $BIN/temporal
       if ( $RUN_SMKREPORT == 'Y' ) then

          #      Variables needed for smkreport called by qa_run (Added April 4, 2014)
          setenv FYIOP 2014nw
          setenv ESCEN $FYIOP
          setenv GRID     AIRPACT_04km
          setenv SRCABBR    pt
          setenv SCRIPTS  $SMKROOT/scripts
          setenv PGMAT      $STATIC/pgmat.AIRPACT_04km.$INVSRC.ncf
          setenv SPC        cmaq.CB05
          setenv PBASE      $FYIOP
          setenv PSMAT_S    $INVOPD/static/psmat_s.$SPC.$PBASE.ncf
          setenv SCCDESC    $GE_DAT/scc_desc_030804.txt
          setenv REPSCEN $OUTDIR
          setenv RUN_SMKREPORT Y
          setenv QA_TYPE all
          setenv POINT Y

          source $SMK_HOME/subsys/smoke/scripts/run/qa_run_AP5.csh

       endif #RUN_SMK_REPORT
       set exitstat = $status
       if ( $exitstat ) then
          echo "*** Error running temporal in smk_pt_3d.csh ***"
          exit ( $exitstat )
       endif
  endif # RUN_TEMPORAL

# ELEVPOINT
  if ( $RUN_ELEVPOINT == 'Y' ) then
     # input switches
       setenv SMK_PING_METHOD    1 # 1 PING, 0 no PING
       setenv SMK_ELEV_METHOD    1 # 0=Laypoint sets elev srcs; 1=use PELVCONFIG 2= CMAQ inline processing for elevated sources used
#nt       setenv ELEV_WRITE_LATLON  Y 
       setenv SMK_SPECELEV_YN      Y  # Y uses PELV file from Elevpoint
       setenv VELOC_RECALC         N  # Y recalculates all stack velocities from flow & diameter

     # input files
       setenv PTMP            $INTDIR/ptmp_${SECTOR}_${INVSRC}_${CJDATE}.ncf
     # output
       setenv PELV            $INTDIR/PELV_${SECTOR}_${INVSRC}_${CJDATE}.txt 
       setenv REPPELV         $OUTDIR/reppelv_${SECTOR}_${INVSRC}_${CJDATE}.rpt
       setenv STACK_GROUPS    $OUTDIR/stack_groups_${INVSRC}_${CJDATE}.ncf
       setenv LOGFILE         $LOGDIR/log02_elevpoint_${SECTOR}_${INVSRC}_${CJDATE}.txt
     # execute program
       rm -f $LOGFILE $PELV $STACK_GROUPS $REPPELV    # remove old outputs
       $BIN/elevpoint
       set exitstat = $status
       if ( $exitstat ) then
          echo "*** Error running elevpoint in smk_pt_3d.csh ***"
          exit ( $exitstat )
       endif
  endif # RUN_ELEVPOINT

# LAYPOINT 
  if ( $RUN_LAYPOINT == 'Y' ) then
     # input switches
       setenv EXPLICIT_PLUMES_YN   N     # explicit plume rise sources from PELV
       setenv SMK_SPECELEV_YN      N     # Y: Laypoint uses Elevpoint outputs to pick elevated
       setenv HOUR_PLUMEDATA_YN    N     # Use hourly data; requires PHOUR file
       if ( $RUN_PING == 'N' ) then
          setenv EXPLICIT_PLUMES_YN   N
          setenv SMK_SPECELEV_YN      N
       endif
     # input files
       setenv GRID_CRO_2D $METDIR/GRIDCRO2D
       setenv GRID_CRO_3D $METDIR/GRIDCRO3D  #nt Ididnot used it may need to comment it
       setenv MET_CRO_2D  $METDIR/METCRO2D
       setenv MET_CRO_3D  $METDIR/METCRO3D
       setenv MET_DOT_3D  $METDIR/METDOT3D
       setenv MET_FILE1   $MET_CRO_2D  # I have MET_CRO_2D not MET_CRO_3D
       setenv MET_FILE2   $MET_CRO_2D
       if (  $RUN_PING == 'Y' ) then
          setenv PELV      $INTDIR/PELV_${SECTOR}_${INVSRC}_${CJDATE}.txt
       endif
     # output
       setenv PLAY         $INTDIR/play_${SECTOR}_${INVSRC}_${CJDATE}.ncf
       setenv REPRTLAY     $OUTDIR/reprtlay_${SECTOR}_${INVSRC}_${CJDATE}.txt
       setenv LOGFILE      $LOGDIR/log03_laypoint_${SECTOR}_${INVSRC}_${CJDATE}.txt
     # execute program
       rm -f $LOGFILE $PLAY $REPRTLAY    # remove old outputs
       $BIN/laypoint
       set exitstat = $status
       if ( $exitstat ) then
          echo "*** Error running laypoint in smk_pt_3d.csh ***"
          exit ( $exitstat )
       endif
  endif # RUN_LAYPOINT

# SMKMERGE
  if ( $RUN_SMKMERGE == 'Y' ) then
     # input switches
       setenv MRG_SOURCE         $SMK_SOURCE  # merge source
       setenv MRG_TEMPORAL_YN    Y            # merge with temporal
       setenv MRG_SPCMAT_YN      Y            # merge with speciation
       setenv MRG_GRDOUT_YN      Y            # merge with gridding
       setenv MRG_LAYERS_YN      Y            # Y merges with layer fractions
       setenv MRG_REPCNY_YN      N            # report county
       setenv MRG_REPSTA_YN      N            # report state
       setenv MRG_METCHK_YN      Y            # check header consistency
       setenv MRG_REPINV_YN      N
       setenv MRG_GRDOUT_UNIT    'moles/s'    # output unit
       setenv MRG_TOTOUT_UNIT    'moles/day'  # report output unita
       setenv SMK_ASCIIELEV_YN   N
       setenv SMK_PING_METHOD    1            # 1 PING, 0 no PING 2 for CMAQ processing of plumes 
#nt       setenv SMKMERGE_CUSTOM_OUTPUT Y        
     # input files
       setenv PTMP             $INTDIR/ptmp_${SECTOR}_${INVSRC}_$G_STDATE.ncf
       setenv PGMAT            $STATIC/pgmat.AIRPACT_04km.$INVSRC.ncf
       setenv PSMAT_S            $STATIC/psmat_s.cmaq.CB05.$INVSRC.ncf 
       setenv PSMAT_L            $STATIC/psmat_l.cmaq.CB05.$INVSRC.ncf  
       setenv PSMAT              $STATIC/psmat_l.cmaq.CB05.$INVSRC.ncf # JKV WTF? 
       setenv PLAY             $INTDIR/play_${SECTOR}_${INVSRC}_${G_STDATE}.ncf
       setenv STACK_GROUPS     $OUTDIR/stack_groups_${INVSRC}_${G_STDATE}.ncf
       setenv INVTABLE         $GE_DAT/invtable_42125.txt #(RGA) needed, although it was set previously
       if ( $RUN_PING == 'Y' ) then
           setenv PELV          $INTDIR/PELV_${SECTOR}_${INVSRC}_${G_STDATE}.txt
       endif
      # output files
        setenv PGTS3D_L         $OUTDIR/pgts3d_l_${SECTOR}_${INVSRC}_${CJDATE}.ncf # nt this is target output- 3D file
        setenv POUT             $OUTDIR/pgts2d_l_${SECTOR}_${INVSRC}_${CJDATE}.ncf
        setenv PGTS_L           $OUTDIR/pgts_l.${SECTOR}_${INVSRC}_${CJDATE}.ncf  
        setenv PGTS_M           $OUTDIR/pgts_m.${SECTOR}_${INVSRC}_${CJDATE}.ncf 
#        setenv PGTS             $OUTDIR/pgts_m.${SECTOR}_${INVSRC}_${CJDATE}.ncf  # JKV WTF?
        setenv REPPGTS_L        $LOGDIR/reppgtls_l_${SECTOR}_${INVSRC}_${CJDATE}.rpt
        setenv LOGFILE          $LOGDIR/log04_smkmerge_${SECTOR}_${INVSRC}_${CJDATE}.txt
        setenv ELEV             $OUTDIR/elev_${SECTOR}_${INVSRC}_${CJDATE}
        setenv PING             $OUTDIR/PING_${SECTOR}_${INVSRC}_${CJDATE}
        setenv INLN             $INTDIR/INLN_${SECTOR}_${INVSRC}_${CJDATE}.ncf  ##(RGA) see the .ncf adding from the previous##
       #setenv INLNST_L         $OUTDIR/INLN_${SECTOR}_${CJDATE}_$INVSRC (RGA) this is not needed
        if ( $RUN_PING == 'Y' ) then
           setenv PINGTS_L      $OUTDIR/pingts_l_${SECTOR}_${INVSRC}_${CJDATE}.ncf
           rm -f $PINGTS_L
        endif
      # execute program
        rm -f $PGTS3D_L $POUT $LOGFILE $REPPGTS_L #(RGA) ADD POUT to the remove list
        echo " $INLN " #(RGA) This was the key test
          env >&! $LOGDIR/env_pre_pt.log

        $BIN/smkmerge
        set exitstat = $status
        if ( $exitstat ) then
           echo "*** Error running smkmerge in smk_pt_3d.csh ***"
           exit ( $exitstat )
        endif
  endif # RUN_SMKMERGE


### END ###
echo `date`
exit ( $exitstat )
`
