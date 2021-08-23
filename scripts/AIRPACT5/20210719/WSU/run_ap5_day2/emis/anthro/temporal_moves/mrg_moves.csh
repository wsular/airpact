#!/bin/csh -f

#  called from ./smk_mb_moves.csh
#
#
#   created April 2013
#   Serena H. Chung
#
#
# ----------------------------------------------------------------------


#> initialize exit status
  set exitstat = 0

#>
   setenv PROMPTFLAG N
   setenv CGDATE ${ESDATE}

#> input directories and files 
   set SPC     = cmaq_cb05_soa # changed vikram 6/19/15
   setenv FILELIST        $EMISBASE/mrggrid_moves_filelist.txt
   setenv MOVES_RPD       $M_OUT/output/$SPC/mgts_l_onroad.ncf
   setenv MOVES_RPP       $M_OUT/output/$SPC/mgts_l_offroad_rpp.ncf
   setenv MOVES_RPV       $M_OUT/output/$SPC/mgts_l_offroad_rpv.ncf

#> output directories and files
   set OUTDIR  = $M_OUT/output/merged
   if ( ! -e $OUTDIR ) mkdir -p $OUTDIR
   setenv OUTFILE  $OUTDIR/mgts_l_moves_usa_canada.ncf
   setenv LOGFILE  $LOGDIR/log07b_mrggrid_moves.txt

#> execute program
   /bin/rm -f $LOGFILE $OUTFILE
   $BIN/mrggrid
   set exitstat = $status
   if ( $exitstat ) then
     echo "*** error running mrggrid for MOVES***"
     exit ( $exitstat )
   endif

### end

exit ( $exitstat )


