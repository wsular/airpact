#!/bin/csh -f

# called from run_smk_temporal.csh


# initialize exit status
  set exitstat = 0

setenv PROMPTFLAG    N                 # non-interactive prompt

# inventory source and general flags
  setenv INVSRC 2014nw

# input directories and files 
  setenv FILELIST        $EBASE/mrggrid_anthro_filelist_wmoves.txt
  setenv INDIR           $EIROOT
 #setenv AREA_all        $INDIR/output/all_other/agts_l_all_${INVSRC}_${CJDATE}.ncf
  setenv AREA_afdust     $INDIR/output/all_afdust/agts_s_afdust_${INVSRC}_${CJDATE}.ncf
  setenv AREA_nodust     $INDIR/output/all_nodust/agts_l_nodust_${INVSRC}_${CJDATE}.ncf
  setenv AREA_tpy        $INDIR/output/rwc_tpy_method/agts_l_tpy_${INVSRC}_${CJDATE}.ncf
  setenv POINT           $INDIR/output/point/pgts3d_l_point_${INVSRC}_${CJDATE}.ncf #shc chnaged to 3d on 2016-04-23
  setenv MOVES           $INDIR/moves/output/merged/mgts_l_moves_usa_canada.ncf
  setenv NONROAD_model   $INDIR/output/nonroad_model/agts_l_nonroad_${INVSRC}_${CJDATE}.ncf
  setenv NONROAD_seca    $INDIR/output/seca/agts_l_seca_${INVSRC}_${CJDATE}.ncf

# output directories and files
  setenv OUTDIR  $EIROOT/output/merged
  setenv LOGDIR $AIRLOGDIR/emis/anthro
  if ( ! -d $OUTDIR ) mkdir -p $OUTDIR
  setenv OUTFILE  $OUTDIR/EMISSIONS_AIRPACT_04km_CB05_${INVSRC}_${CJDATE}.ncf
  setenv LOGFILE  $LOGDIR/log03c_mrggrid_AIRPACT_04km_CB05_${INVSRC}_${CJDATE}.txt

# execute program
  /bin/rm -f $LOGFILE $OUTFILE
  $BIN/mrggrid
  set exitstat = $status
  if ( $exitstat ) then
     echo "*** error running mrggrid ***"
     exit ( $exitstat )
  endif

### END ###
exit ( $exitstat )


