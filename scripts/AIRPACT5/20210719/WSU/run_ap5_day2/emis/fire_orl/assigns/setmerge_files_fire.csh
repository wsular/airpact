#!/bin/csh -fx
#
## HEADER ######################################################################
#
#  This script sets the output environment variables for the Smkmerge program
#
################################################################################

if ( $RUN_SMKMERGE == 'Y' || $RUN_SMK2EMIS == 'Y' || $RUN_MRGGRID == Y ) then

   if ( $MRG_GRDOUT_YN == 'Y' || $RUN_SMK2EMIS == 'Y' || $RUN_MRGGRID == Y ) then

      if ( $MRG_TEMPORAL_YN == 'Y' && $MRG_SPCMAT_YN == 'Y' || $RUN_SMK2EMIS == 'Y' || $RUN_MRGGRID == Y ) then

         if ( $MRG_AREA == 'Y' || $SMK_SOURCE == 'A' ) then
            if ( $NONROAD == Y ) then
	       setenv AGTS_L   $A_OUT/ngts_l_${ESDATE}_${NDAYS}_${GRID}_${ASCEN}.ncf
	       setenv AGTS_S   $A_OUT/ngts_s_${ESDATE}_${NDAYS}_${GRID}_${ASCEN}.ncf
            else
	       setenv AGTS_L   $A_OUT/agts_l_${ESDATE}_${NDAYS}_${GRID}_${ASCEN}.ncf
	       setenv AGTS_S   $A_OUT/agts_s_${ESDATE}_${NDAYS}_${GRID}_${ASCEN}.ncf
	       setenv NGTS_L   $N_OUT/ngts_l_${ESDATE}_${NDAYS}_${GRID}_${ASCEN}.ncf
	       setenv NGTS_S   $N_OUT/ngts_s_${ESDATE}_${NDAYS}_${GRID}_${ASCEN}.ncf
            endif
         endif 

         if ( $SMK_SOURCE == 'A' ) then
            if ( $NONROAD == Y ) then
               setenv UAM_AGTS $A_OUT/ngts_l_${ESDATE}_${NDAYS}_${GRID}_${ASCEN}.uam
            else
               setenv UAM_AGTS $A_OUT/agts_l_${ESDATE}_${NDAYS}_${GRID}_${ASCEN}.uam
            endif
         endif

         if ( $MRG_MOBILE == 'Y' || $SMK_SOURCE == 'M' ) then
	    setenv MGTS_L   $M_OUT/mgts_l_${ESDATE}_${NDAYS}_${GRID}_${MSCEN}.ncf
	    setenv MGTS_S   $M_OUT/mgts_s_${ESDATE}_${NDAYS}_${GRID}_${MSCEN}.ncf
         endif 

         if ( $SMK_SOURCE == 'M' ) then
            setenv UAM_MGTS $M_OUT/mgts_l_${ESDATE}_${NDAYS}_${GRID}_${MSCEN}.uam
         endif

         if ( $MRG_POINT == 'Y' || $SMK_SOURCE == 'P' ) then
	    setenv PGTS_L   $OUTPUT/pgts_l_${ESDATE}_${NDAYS}_${GRID}_${PSCEN}.ncf
	    setenv PGTS_S   $OUTPUT/pgts_s_${ESDATE}_${NDAYS}_${GRID}_${PSCEN}.ncf
	    setenv PGTS3D_L $OUTPUT/pgts3d_l_${ESDATE}_${NDAYS}_${GRID}_${PSCEN}.ncf
	    setenv PGTS3D_S $OUTPUT/pgts3d_s_${ESDATE}_${NDAYS}_${GRID}_${PSCEN}.ncf
         endif 

         if ( $SMK_SOURCE == 'P' ) then
            setenv UAM_PGTS $P_OUT/pgts_l_${ESDATE}_${NDAYS}_${GRID}_${PSCEN}.uam
         endif

         if ( $MRG_MULTI == 'Y' || $SMK_SOURCE == 'E' ) then
	    setenv EGTS_L   $OUTPUT/egts_l_${ESDATE}_${NDAYS}_${GRID}_${ESCEN}.ncf
	    setenv EGTS_S   $OUTPUT/egts_s_${ESDATE}_${NDAYS}_${GRID}_${ESCEN}.ncf
	    setenv EGTS3D_L $OUTPUT/egts3d_l_${ESDATE}_${NDAYS}_${GRID}_${ESCEN}.ncf
	    setenv EGTS3D_S $OUTPUT/egts3d_s_${ESDATE}_${NDAYS}_${GRID}_${ESCEN}.ncf
         endif 

         if ( $SMK_SOURCE == 'E' ) then
            setenv UAM_EGTS $OUTPUT/egts_l_${ESDATE}_${NDAYS}_${GRID}_${ESCEN}.uam
         endif

         if ( $MRG_AREA_CNTL == 'Y' ) then
            if ( $NONROAD == Y ) then
   	       setenv AGTSC_L   $A_OUT/ngtsc_l_${ESDATE}_${NDAYS}_${GRID}_${ASCEN}.ncf
	       setenv AGTSC_S   $A_OUT/ngtsc_s_${ESDATE}_${NDAYS}_${GRID}_${ASCEN}.ncf
            else
   	       setenv AGTSC_L   $A_OUT/agtsc_l_${ESDATE}_${NDAYS}_${GRID}_${ASCEN}.ncf
	       setenv AGTSC_S   $A_OUT/agtsc_s_${ESDATE}_${NDAYS}_${GRID}_${ASCEN}.ncf
	       setenv NGTSC_L   $N_OUT/ngtsc_l_${ESDATE}_${NDAYS}_${GRID}_${ASCEN}.ncf
	       setenv NGTSC_S   $N_OUT/ngtsc_s_${ESDATE}_${NDAYS}_${GRID}_${ASCEN}.ncf
            endif
         endif 

         if ( $MRG_MOBILE_CNTL == 'Y' ) then
	    setenv MGTSC_L   $M_OUT/mgtsc_l_${ESDATE}_${NDAYS}_${GRID}_${MSCEN}.ncf
	    setenv MGTSC_S   $M_OUT/mgtsc_s_${ESDATE}_${NDAYS}_${GRID}_${MSCEN}.ncf
         endif 

         if ( $MRG_POINT_CNTL == 'Y' ) then
	    setenv PGTSC_L   $P_OUT/pgtsc_l_${ESDATE}_${NDAYS}_${GRID}_${PSCEN}.ncf
	    setenv PGTSC_S   $P_OUT/pgtsc_s_${ESDATE}_${NDAYS}_${GRID}_${PSCEN}.ncf
	    setenv PGTSC3D_L $P_OUT/pgtsc3d_l_${ESDATE}_${NDAYS}_${GRID}_${PSCEN}.ncf
	    setenv PGTSC3D_S $P_OUT/pgtsc3d_s_${ESDATE}_${NDAYS}_${GRID}_${PSCEN}.ncf
         endif 

         if ( $MRG_MULTI_CNTL == 'Y' ) then
	    setenv EGTSC_L   $OUTPUT/egtsc_l_${ESDATE}_${NDAYS}_${GRID}_${ESCEN}.ncf
	    setenv EGTSC_S   $OUTPUT/egtsc_s_${ESDATE}_${NDAYS}_${GRID}_${ESCEN}.ncf
	    setenv EGTSC3D_L $OUTPUT/egtsc3d_l_${ESDATE}_${NDAYS}_${GRID}_${ESCEN}.ncf
	    setenv EGTSC3D_S $OUTPUT/egtsc3d_s_${ESDATE}_${NDAYS}_${GRID}_${ESCEN}.ncf
         endif 
      endif

      if ( $MRG_TEMPORAL_YN != 'Y' && $MRG_SPCMAT_YN == 'Y' ) then
         if ( $NONROAD == Y ) then
   	    setenv AGS_S    $REPORTS/$ASCEN/static/ngs_s_${GRID}_${ASCEN}.ncf
         else
   	    setenv AGS_S    $REPORTS/$ASCEN/static/ags_s_${GRID}_${ASCEN}.ncf
   	    setenv NGS_S    $REPORTS/$ASCEN/static/ngs_s_${GRID}_${ASCEN}.ncf
         endif
	 setenv MGS_S    $REPORTS/$MSCEN/static/mgs_s_${GRID}_${MSCEN}.ncf
	 setenv PGS_S    $REPORTS/$PSCEN/static/pgs_s_${GRID}_${PSCEN}.ncf
	 setenv PGS3D_S  $REPORTS/$PSCEN/static/pgs3d_s_${GRID}_${PSCEN}.ncf
	 setenv EGS_S    $REPSTAT/egs_s_${GRID}_${ESCEN}.ncf
	 setenv EGS3D_S  $REPSTAT/egs3d_s_${GRID}_${ESCEN}.ncf

         if ( $NONROAD == Y ) then
	    setenv AGSC_S   $REPORTS/$ASCEN/static/ngsc_s_${GRID}_${ASCEN}.ncf
         else 
	    setenv AGSC_S   $REPORTS/$ASCEN/static/agsc_s_${GRID}_${ASCEN}.ncf
	    setenv NGSC_S   $REPORTS/$ASCEN/static/ngsc_s_${GRID}_${ASCEN}.ncf
         endif
	 setenv MGSC_S   $REPORTS/$MSCEN/static/mgsc_s_${GRID}_${MSCEN}.ncf
	 setenv PGSC_S   $REPORTS/$PSCEN/static/pgsc_s_${GRID}_${PSCEN}.ncf
	 setenv PGSC3D_S $REPORTS/$PSCEN/static/pgsc3d_s_${GRID}_${PSCEN}.ncf
	 setenv EGSC_S   $REPSTAT/egsc_s_${GRID}_${ESCEN}.ncf
	 setenv EGSC3D_S $REPSTAT/egsc3d_s_${GRID}_${ESCEN}.ncf

         if ( $NONROAD == Y ) then
	    setenv AGS_L    $REPORTS/$ASCEN/static/ngs_l_${GRID}_${ASCEN}.ncf
         else
	    setenv AGS_L    $REPORTS/$ASCEN/static/ags_l_${GRID}_${ASCEN}.ncf
	    setenv NGS_L    $REPORTS/$ASCEN/static/ngs_l_${GRID}_${ASCEN}.ncf
         endif
	 setenv MGS_L    $REPORTS/$MSCEN/static/mgs_l_${GRID}_${MSCEN}.ncf
	 setenv PGS_L    $REPORTS/$PSCEN/static/pgs_l_${GRID}_${PSCEN}.ncf
	 setenv PGS3D_L  $REPORTS/$PSCEN/static/pgs3d_l_${GRID}_${PSCEN}.ncf
	 setenv EGS_L    $REPSTAT/egs_l_${GRID}_${ESCEN}.ncf
	 setenv EGS3D_L  $REPSTAT/egs3d_l_${GRID}_${ESCEN}.ncf

         if ( $NONROAD == Y ) then
	    setenv AGSC_L   $REPORTS/$ASCEN/static/ngsc_l_${GRID}_${ASCEN}.ncf
         else
	    setenv AGSC_L   $REPORTS/$ASCEN/static/agsc_l_${GRID}_${ASCEN}.ncf
	    setenv NGSC_L   $REPORTS/$ASCEN/static/ngsc_l_${GRID}_${ASCEN}.ncf
         endif
	 setenv MGSC_L   $REPORTS/$MSCEN/static/mgsc_l_${GRID}_${MSCEN}.ncf
	 setenv PGSC_L   $REPORTS/$PSCEN/static/pgsc_l_${GRID}_${PSCEN}.ncf
	 setenv PGSC3D_L $REPORTS/$PSCEN/static/pgsc3d_l_${GRID}_${PSCEN}.ncf
	 setenv EGSC_L   $REPSTAT/egsc_l_${GRID}_${ESCEN}.ncf
	 setenv EGSC3D_L $REPSTAT/egsc3d_l_${GRID}_${ESCEN}.ncf
      endif

      if ( $MRG_TEMPORAL_YN == 'Y' && $MRG_SPCMAT_YN != 'Y' ) then
         if ( $NONROAD == Y ) then
	    setenv AGT    $REPORTS/$ASCEN/scenario/ngt_${ESDATE}_${NDAYS}_${GRID}_${ASCEN}.ncf
         else
	    setenv AGT    $REPORTS/$ASCEN/scenario/agt_${ESDATE}_${NDAYS}_${GRID}_${ASCEN}.ncf
	    setenv NGT    $REPORTS/$ASCEN/scenario/ngt_${ESDATE}_${NDAYS}_${GRID}_${ASCEN}.ncf
         endif
	 setenv MGT    $REPORTS/$MSCEN/scenario/mgt_${ESDATE}_${NDAYS}_${GRID}_${MSCEN}.ncf
	 setenv PGT    $REPORTS/$PSCEN/scenario/pgt_${ESDATE}_${NDAYS}_${GRID}_${PSCEN}.ncf
	 setenv PGT3D  $REPORTS/$PSCEN/scenario/pgt3d_${ESDATE}_${NDAYS}_${GRID}_${PSCEN}.ncf
	 setenv EGT    $REPSCEN/egt_${ESDATE}_${NDAYS}_${GRID}_${ESCEN}.ncf
	 setenv EGT3D  $REPSCEN/egt3d_${ESDATE}_${NDAYS}_${GRID}_${ESCEN}.ncf
         if ( $NONROAD == Y ) then
	    setenv AGTC   $REPORTS/$ASCEN/scenario/ngtc_${ESDATE}_${NDAYS}_${GRID}_${ASCEN}.ncf
         else
	    setenv AGTC   $REPORTS/$ASCEN/scenario/agtc_${ESDATE}_${NDAYS}_${GRID}_${ASCEN}.ncf
	    setenv NGTC   $REPORTS/$ASCEN/scenario/ngtc_${ESDATE}_${NDAYS}_${GRID}_${ASCEN}.ncf
         endif
	 setenv MGTC   $REPORTS/$MSCEN/scenario/mgtc_${ESDATE}_${NDAYS}_${GRID}_${MSCEN}.ncf
	 setenv PGTC   $REPORTS/$PSCEN/scenario/pgtc_${ESDATE}_${NDAYS}_${GRID}_${PSCEN}.ncf
	 setenv PGTC3D $REPORTS/$PSCEN/scenario/pgtc3d_${ESDATE}_${NDAYS}_${GRID}_${PSCEN}.ncf
	 setenv EGTC   $REPSCEN/egtc_${ESDATE}_${NDAYS}_${GRID}_${ESCEN}.ncf
	 setenv EGTC3D $REPSCEN/egtc3d_${ESDATE}_${NDAYS}_${GRID}_${ESCEN}.ncf
      endif

      if ( $MRG_TEMPORAL_YN != 'Y' && $MRG_SPCMAT_YN != 'Y' ) then
         if ( $NONROAD == Y ) then
            setenv AG   $REPORTS/$ASCEN/static/ng_${GRID}_${FYIOP}.ncf
         else
            setenv AG   $REPORTS/$ASCEN/static/ag_${GRID}_${FYIOP}.ncf
            setenv NG   $REPORTS/$ASCEN/static/ng_${GRID}_${FYIOP}.ncf
         endif
         setenv MG   $REPORTS/$MSCEN/static/mg_${GRID}_${FYIOP}.ncf
	 setenv PG   $REPORTS/$PSCEN/static/pg_${GRID}_${FYIOP}.ncf
	 setenv EG   $REPSTAT/eg_${GRID}_${FYIOP}.ncf
         if ( $NONROAD == Y ) then
            setenv AGC  $REPORTS/$ASCEN/static/ngc_${GRID}_${FYIOP}.ncf
         else
            setenv AGC  $REPORTS/$ASCEN/static/agc_${GRID}_${FYIOP}.ncf
            setenv NGC  $REPORTS/$ASCEN/static/ngc_${GRID}_${FYIOP}.ncf
         endif
         setenv MGC  $REPORTS/$MSCEN/static/mgc_${GRID}_${FYIOP}.ncf
	 setenv PGC  $REPORTS/$PSCEN/static/pgc_${GRID}_${FYIOP}.ncf
	 setenv EGC  $REPSTAT/egc_${GRID}_${FYIOP}.ncf
      endif

   endif

#
## State and county reports
#
   if ( $MRG_REPSTA_YN == 'Y' || $MRG_REPCNY_YN == 'Y' ) then

       if ( $MRG_TEMPORAL_YN == 'Y' && $MRG_SPCMAT_YN == 'Y' ) then

         if ( $MRG_AREA == 'Y' ) then
            if ( $NONROAD == Y ) then
	       setenv REPAGTS_L $REPORTS/$ASCEN/scenario/repngts_l_${ESDATE}_${NDAYS}_${GRID}_${ASCEN}.rpt
	       setenv REPAGTS_S $REPORTS/$ASCEN/scenario/repngts_s_${ESDATE}_${NDAYS}_${GRID}_${ASCEN}.rpt
            else
	       setenv REPAGTS_L $REPORTS/$ASCEN/scenario/repagts_l_${ESDATE}_${NDAYS}_${GRID}_${ASCEN}.rpt
	       setenv REPAGTS_S $REPORTS/$ASCEN/scenario/repagts_s_${ESDATE}_${NDAYS}_${GRID}_${ASCEN}.rpt
            endif
         endif 

         if ( $MRG_BIOG == 'Y' ) then
	    setenv REPBGTS_L  $REPORTS/$BSCEN/scenario/repbgts_l_${ESDATE}_${NDAYS}_${GRID}_${BSCEN}.rpt
	    setenv REPB3GTS_L $REPORTS/$BSCEN/scenario/repb3gts_l_${ESDATE}_${NDAYS}_${GRID}_${BSCEN}.rpt
	    setenv REPBGTS_S  $REPORTS/$BSCEN/scenario/repbgts_s_${ESDATE}_${NDAYS}_${GRID}_${BSCEN}.rpt
	    setenv REPB3GTS_S $REPORTS/$BSCEN/scenario/repb3gts_s_${ESDATE}_${NDAYS}_${GRID}_${BSCEN}.rpt
         endif 

         if ( $MRG_MOBILE == 'Y' ) then
	    setenv REPMGTS_L $REPORTS/$MSCEN/scenario/repmgts_l_${ESDATE}_${NDAYS}_${GRID}_${MSCEN}.rpt
	    setenv REPMGTS_S $REPORTS/$MSCEN/scenario/repmgts_s_${ESDATE}_${NDAYS}_${GRID}_${MSCEN}.rpt
         endif 

         if ( $MRG_POINT == 'Y' ) then
	    setenv REPPGTS_L $REPORTS/$PSCEN/scenario/reppgts_l_${ESDATE}_${NDAYS}_${GRID}_${PSCEN}.rpt
	    setenv REPPGTS_S $REPORTS/$PSCEN/scenario/reppgts_s_${ESDATE}_${NDAYS}_${GRID}_${PSCEN}.rpt
        endif 

         if ( $MRG_MULTI == 'Y' ) then
	    setenv REPEGTS_L $REPSCEN/repegts_l_${ESDATE}_${NDAYS}_${GRID}_${ESCEN}.rpt
	    setenv REPEGTS_S $REPSCEN/repegts_s_${ESDATE}_${NDAYS}_${GRID}_${ESCEN}.rpt
         endif 

         if ( $MRG_AREA_CNTL == 'Y' ) then
            if ( $NONROAD == Y ) then
      	       setenv REPAGTSC_L $REPORTS/$ASCEN/scenario/repngtsc_l_${ESDATE}_${NDAYS}_${GRID}_${ASCEN}.rpt
	       setenv REPAGTSC_S $REPORTS/$ASCEN/scenario/repngtsc_s_${ESDATE}_${NDAYS}_${GRID}_${ASCEN}.rpt
            else
      	       setenv REPAGTSC_L $REPORTS/$ASCEN/scenario/repagtsc_l_${ESDATE}_${NDAYS}_${GRID}_${ASCEN}.rpt
	       setenv REPAGTSC_S $REPORTS/$ASCEN/scenario/repagtsc_s_${ESDATE}_${NDAYS}_${GRID}_${ASCEN}.rpt
            endif
         endif 

         if ( $MRG_MOBILE_CNTL == 'Y' ) then
	    setenv REPMGTSC_L $REPORTS/$MSCEN/scenario/repmgtsc_l_${ESDATE}_${NDAYS}_${GRID}_${MSCEN}.rpt
	    setenv REPMGTSC_S $REPORTS/$MSCEN/scenario/repmgtsc_s_${ESDATE}_${NDAYS}_${GRID}_${MSCEN}.rpt
         endif 

         if ( $MRG_POINT_CNTL == 'Y' ) then
	    setenv REPPGTSC_L $REPORTS/$PSCEN/scenario/reppgtsc_l_${ESDATE}_${NDAYS}_${GRID}_${PSCEN}.rpt
	    setenv REPPGTSC_S $REPORTS/$PSCEN/scenario/reppgtsc_s_${ESDATE}_${NDAYS}_${GRID}_${PSCEN}.rpt
         endif 

         if ( $MRG_MULTI_CNTL == 'Y' ) then
	    setenv REPEGTSC_L $REPSCEN/repegtsc_l_${ESDATE}_${NDAYS}_${GRID}_${ESCEN}.rpt
	    setenv REPEGTSC_S $REPSCEN/repegtsc_s_${ESDATE}_${NDAYS}_${GRID}_${ESCEN}.rpt
         endif 
      endif

      if ( $MRG_TEMPORAL_YN != 'Y' && $MRG_SPCMAT_YN == 'Y' ) then
         if ( $NONROAD == Y ) then
	    setenv REPAGS_S    $REPORTS/$ASCEN/static/repngs_s_${GRID}_${ASCEN}.rpt
         else
	    setenv REPAGS_S    $REPORTS/$ASCEN/static/repags_s_${GRID}_${ASCEN}.rpt
         endif
	 setenv REPMGS_S    $REPORTS/$MSCEN/static/repmgs_s_${GRID}_${MSCEN}.rpt
	 setenv REPPGS_S    $REPORTS/$PSCEN/static/reppgs_s_${GRID}_${PSCEN}.rpt
	 setenv REPEGS_S    $REPSTAT/repegs_s_${GRID}_${ESCEN}.rpt

         if ( $NONROAD == Y ) then
   	    setenv REPAGSC_S   $REPORTS/$ASCEN/static/repngsc_s_${GRID}_${ASCEN}.rpt
         else
   	    setenv REPAGSC_S   $REPORTS/$ASCEN/static/repagsc_s_${GRID}_${ASCEN}.rpt
         endif
	 setenv REPMGSC_S   $REPORTS/$MSCEN/static/repmgsc_s_${GRID}_${MSCEN}.rpt
	 setenv REPPGSC_S   $REPORTS/$PSCEN/static/reppgsc_s_${GRID}_${PSCEN}.rpt
	 setenv REPEGSC_S   $REPSTAT/repegcs_s_${GRID}_${ESCEN}.rpt

         if ( $NONROAD == Y ) then
	    setenv REPAGS_L    $REPORTS/$ASCEN/static/repngs_l_${GRID}_${ASCEN}.rpt
         else
	    setenv REPAGS_L    $REPORTS/$ASCEN/static/repags_l_${GRID}_${ASCEN}.rpt
         endif
	 setenv REPMGS_L    $REPORTS/$MSCEN/static/repmgs_l_${GRID}_${MSCEN}.rpt
	 setenv REPPGS_L    $REPORTS/$PSCEN/static/reppgs_l_${GRID}_${PSCEN}.rpt
	 setenv REPEGS_L    $REPSTAT/repegs_l_${GRID}_${ESCEN}.rpt

         if ( $NONROAD == Y ) then
   	    setenv REPAGSC_L   $REPORTS/$ASCEN/static/repngsc_l_${GRID}_${ASCEN}.rpt
         else
   	    setenv REPAGSC_L   $REPORTS/$ASCEN/static/repagsc_l_${GRID}_${ASCEN}.rpt
         endif
	 setenv REPMGSC_L   $REPORTS/$MSCEN/static/repmgsc_l_${GRID}_${MSCEN}.rpt
	 setenv REPPGSC_L   $REPORTS/$PSCEN/static/reppgsc_l_${GRID}_${PSCEN}.rpt
	 setenv REPEGSC_L   $REPSTAT/repegsc_l_${GRID}_${ESCEN}.rpt
      endif

      if ( $MRG_TEMPORAL_YN == 'Y' && $MRG_SPCMAT_YN != 'Y' ) then
         if ( $NONROAD == Y ) then
	    setenv REPAGT    $REPORTS/$ASCEN/scenario/repngt_${ESDATE}_${NDAYS}_${GRID}_${ASCEN}.rpt
         else
	    setenv REPAGT    $REPORTS/$ASCEN/scenario/repagt_${ESDATE}_${NDAYS}_${GRID}_${ASCEN}.rpt
         endif
	 setenv REPMGT    $REPORTS/$MSCEN/scenario/repmgt_${ESDATE}_${NDAYS}_${GRID}_${MSCEN}.rpt
	 setenv REPPGT    $REPORTS/$PSCEN/scenario/reppgt_${ESDATE}_${NDAYS}_${GRID}_${PSCEN}.rpt
	 setenv REPBGT    $REPORTS/$BSCEN/scenario/repbgt_${ESDATE}_${NDAYS}_${GRID}_${BSCEN}.rpt
	 setenv REPEGT    $REPSCEN/repegt_${ESDATE}_${NDAYS}_${GRID}_${ESCEN}.rpt
         if ( $NONROAD == Y ) then
	    setenv REPAGTC   $REPORTS/$ASCEN/scenario/repngtc_${ESDATE}_${NDAYS}_${GRID}_${ASCEN}.rpt
         else
	    setenv REPAGTC   $REPORTS/$ASCEN/scenario/repagtc_${ESDATE}_${NDAYS}_${GRID}_${ASCEN}.rpt
         endif
	 setenv REPMGTC   $REPORTS/$MSCEN/scenario/repmgtc_${ESDATE}_${NDAYS}_${GRID}_${MSCEN}.rpt
	 setenv REPPGTC   $REPORTS/$PSCEN/scenario/reppgtc_${ESDATE}_${NDAYS}_${GRID}_${PSCEN}.rpt
	 setenv REPEGTC   $REPSCEN/repegt_${ESDATE}_${NDAYS}_${GRID}_${ESCEN}.rpt
      endif

      if ( $MRG_TEMPORAL_YN != 'Y' && $MRG_SPCMAT_YN != 'Y' ) then
         if ( $NONROAD == Y ) then
            setenv REPAG   $REPORTS/$ASCEN/static/repng_${GRID}_${FYIOP}.rpt
         else
            setenv REPAG   $REPORTS/$ASCEN/static/repag_${GRID}_${FYIOP}.rpt
         endif
         setenv REPMG   $REPORTS/$MSCEN/static/repmg_${GRID}_${FYIOP}.rpt
	 setenv REPPG   $REPORTS/$PSCEN/static/reppg_${GRID}_${FYIOP}.rpt
	 setenv REPEG   $REPSTAT/repeg_${GRID}_${FYIOP}.rpt
         if ( $NONROAD == Y ) then
            setenv REPAGC  $REPORTS/$ASCEN/static/repngc_${GRID}_${FYIOP}.rpt
         else
            setenv REPAGC  $REPORTS/$ASCEN/static/repagc_${GRID}_${FYIOP}.rpt
         endif
         setenv REPMGC  $REPORTS/$MSCEN/static/repmgc_${GRID}_${FYIOP}.rpt
	 setenv REPPGC  $REPORTS/$PSCEN/static/reppgc_${GRID}_${FYIOP}.rpt
	 setenv REPEGC  $REPSTAT/repegc_${GRID}_${FYIOP}.rpt
      endif

   endif

#
## Elevated sources
#
   if ( $MRG_POINT == 'Y' && $SMK_PING_METHOD == 1 ) then
      setenv PINGT      $OUTPUT/pingt_${ESDATE}_${NDAYS}_${GRID}_${PSCEN}.ncf    
      setenv PINGTS_L   $OUTPUT/pingts_l_${ESDATE}_${NDAYS}_${GRID}_${PSCEN}.ncf 
      setenv PINGTS_S   $OUTPUT/pingts_s_${ESDATE}_${NDAYS}_${GRID}_${PSCEN}.ncf 
   endif

   if ( $MRG_POINT == 'Y' && $SMK_ASCIIELEV_YN == 'Y' || $SMK_ELEV_METHOD == 2 ) then
      setenv ELEVTS_L   $OUTPUT/elevts_l_${ESDATE}_${NDAYS}_${GRID}_${PSCEN}.txt 
      setenv ELEVTS_S   $OUTPUT/elevts_s_${ESDATE}_${NDAYS}_${GRID}_${PSCEN}.txt 
   endif

endif
