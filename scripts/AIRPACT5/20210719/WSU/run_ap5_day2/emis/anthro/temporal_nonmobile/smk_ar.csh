#!/bin/csh -f

# called from run_smk_temporal.csh

# switch(es)
  setenv RUN_SMKMERGE Y

# initialize exit status
  set exitstat = 0

# inventory source and general flags
  setenv INVSRC 2014nw                    # inventory source
  setenv SMK_SOURCE 'A'                   # source indicator 
  setenv PROMPTFLAG  N                    # non-interactive prompt
  setenv COSTCY   $GE_DAT/costcy_v8.txt
  setenv HOLIDAYS $GE_DAT/holidays_2005_2019.txt
  setenv ATREF    $GE_DAT/aptref_AP5_final.txt 
  setenv ATPRO    $GE_DAT/aptpro_AP5_final.txt
  setenv INVTABLE $GE_DAT/invtable_42125.txt 
  setenv GRIDDESC $GE_DAT/GRIDDESC

# input switches
  setenv OUTZONE            0    # output timezone (GMT)
  setenv SMK_DEFAULT_TZONE  5    # default timezone to be PST
  setenv UNIFORM_TROF_YN    N    # not uniform profile
  setenv ZONE4WM            Y    
  setenv RENORM_TPROF       Y    # Y renormalizes temporal profiles

# run by sector

  foreach SECTOR ( rwc_tpy_method all_nodust all_afdust ) # all_afdust turned on; update merge text list if this is changed
#  foreach SECTOR ( rwc_tpy_method all_nodust ) # all_afdust turned off; this option no longer used since Western WA/OR afdust removed from non-temporal


    if ($SECTOR == all_other) then
        set NCVN = all
        echo " running $NCVN "
    else if ($SECTOR == rwc_tpy_method ) then
        set NCVN = tpy
        echo " running $NCVN "
    else if ($SECTOR == all_nodust ) then
        set NCVN = nodust
        echo " running $NCVN "
    else if ($SECTOR == all_afdust ) then
        set NCVN = afdust
        echo " running $NCVN "
    endif

     # input directories
       setenv STATIC $ARBASE/$SECTOR/static    # for SMK time indep. inputs
       setenv INVOPD $ARBASE/$SECTOR           # for SMK output inventory
       setenv AREA   $INVOPD/area.map.2014nw.txt
       setenv ASRC   $INVOPD/asrc.txt
     # output directories & files
       setenv INTDIR $EIROOT/scenario/$SECTOR  # For intermediate files
       setenv OUTDIR $EIROOT/output/$SECTOR    # For final source output files
       setenv LOGDIR $AIRLOGDIR/emis/anthro/log01_$SECTOR
       if ( ! -d $INTDIR ) mkdir -p $INTDIR
       if ( ! -d $OUTDIR ) mkdir -p $OUTDIR
       if ( ! -d $LOGDIR ) mkdir -p $LOGDIR
       setenv ATMPNAME   $INTDIR/atmp_${NCVN}_${INVSRC}_  # used by temporal
       setenv ATMP       $ATMPNAME$G_STDATE.ncf           # not used by temporal
       setenv ATSUPNAME  $INTDIR/atsup_${NCVN}_${INVSRC}_ # used by temporal
       setenv ATSUP      $ATSUPNAME$G_STDATE.txt  # not used by temporal
       setenv LOGFILE    $LOGDIR/log01_temporal_${SMK_SOURCE}_${NCVN}_${INVSRC}_${G_STDATE}.txt
     # run SMOKE's temporal program
       rm -f $LOGFILE $ATMP $ATSUP    # remove old outputs
       $BIN/temporal
       set exitstat = $status
       if ( $exitstat ) then
          echo "*** Error running temporal in smk_ar.csh ***"
          exit ( $exitstat )
       endif

     # SMKMERGE ## 
       if ( $RUN_SMKMERGE == 'Y' ) then
          # input switches
	    setenv MRG_SOURCE         $SMK_SOURCE  # merge source
            setenv MRG_TEMPORAL_YN    Y            # merge with temporal
            setenv MRG_SPCMAT_YN      Y            # merge with speciation
            setenv MRG_GRDOUT_YN      Y            # merge with gridding
            setenv MRG_REPCNY_YN      N            # report county
            setenv MRG_REPSTA_YN      N            # report state
            setenv MRG_METCHK_YN      Y            # check header consistency
            setenv MRG_GRDOUT_UNIT    'moles/s'    # output unit
            setenv MRG_TOTOUT_UNIT    'moles/day'  # report output unit
          # input files
            setenv ATMPNAME  $INTDIR/atmp_${NCVN}_${INVSRC}_  # used by temporal
            setenv ATMP      $ATMPNAME$G_STDATE.ncf    # not used by temporal
            setenv AGMAT     $STATIC/agmat.AIRPACT_04km.{$INVSRC}.ncf
           #setenv APMAT     $STATIC/apmat.AIRPACT_04km.{$INVSRC}.ncf # growth not used
            setenv ASMAT_S   $STATIC/asmat_s.cmaq.CB05.${INVSRC}.ncf
            setenv ASMAT_L   $STATIC/asmat_l.cmaq.CB05.${INVSRC}.ncf
            setenv ASMAT     $STATIC/asmat_l.cmaq.CB05.${INVSRC}.ncf # JKV WTF?
          # output files
            setenv AGTS_L    $OUTDIR/agts_l_${NCVN}_${INVSRC}_${CJDATE}.ncf
            setenv AGTS_S    $OUTDIR/agts_s_${NCVN}_${INVSRC}_${CJDATE}.ncf
	    setenv AGTS      $OUTDIR/agts_l_${NCVN}_${INVSRC}_${CJDATE}.ncf # JKV WTF?
            setenv REPAGTS_L $LOGDIR/repagtls_l_${NCVN}_${INVSRC}_${CJDATE}.rpt
            setenv LOGFILE   $LOGDIR/log02_smkmerge_${NCVN}_${INVSRC}_${CJDATE}.txt
          # execute program
	  echo AGTS_L  file: ${AGTS_L}
	  echo AGTS_S  file: ${AGTS_S}
             rm -f $AGTS_L $AGTS_S $LOGFILE $REPAGTS_L
	  env >&! $LOGDIR/env_pre_ar_${SECTOR}.log
            $BIN/smkmerge
            set exitstat = $status
            if ( $exitstat ) then
               echo "*** error running smkmerge in smk_ar.csh***"
               exit ( $exitstat )
            endif
       endif # RUN_SMKMERGE


       if ( $RUN_SMKREPORT == 'Y' ) then
          #      Variables needed for smkreport called by qa_run (Added April 4, 2014)
          setenv FYIOP 2014nw
          setenv ESCEN $FYIOP
          setenv GRID     AIRPACT_04km
          setenv SRCABBR    ar
          setenv SCRIPTS  $SMKROOT/scripts
          setenv PGMAT      $STATIC/pgmat.AIRPACT_04km.$INVSRC.ncf
          setenv SPC        cmaq.CB05
          setenv PBASE      $FYIOP
          setenv PSMAT_S    $INVOPD/static/psmat_s.$SPC.$PBASE.ncf
          setenv SCCDESC    $GE_DAT/scc_desc_030804.txt
          setenv REPSCEN $OUTDIR
          setenv RUN_SMKREPORT Y
          setenv QA_TYPE all
          
          source $SMK_HOME/subsys/smoke/scripts/run/qa_run_AP5.csh
       
       endif # RUN_SMKREPORT

end # foreach SECTOR

echo `date`
exit ( $exitstat )

