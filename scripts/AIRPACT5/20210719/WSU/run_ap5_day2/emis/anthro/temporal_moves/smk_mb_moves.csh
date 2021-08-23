#! /bin/csh -f


#  called from ./run_smk_temporal_moves.csh
#
#
#  calls scripts to run metcombine, met4moves, smoke temporal, movesmrg,
#                       and conversion from cb05 to saprc99
#
#   created April 2013
#   Serena H. Chung
#
#
# ----------------------------------------------------------------------


#> initialize exit status
   set exitstat = 0

#> working directory
   setenv EMISBASE    ${PBS_O_WORKDIR}/emis/anthro/temporal_moves
   cd $EMISBASE

#> output and input files
   #setenv SMOKE_OUTFILE    $METDAT/smoke_${STDATE}_${EPI_NDAY}.txt
   setenv SMOKE_OUTFILE    $METDAT/smoke_${STDATE}_${EPI_NDAY}.ncf  # changed based on Wei's  # vikram 6/9/2015
   setenv MOVES_OUTFILE    $METDAT/moves_${STDATE}_${EPI_NDAY}.txt
   setenv MOVES_RH_OUTFILE $METDAT/moves_RH_${STDATE}_${EPI_NDAY}.txt   # added based on Wei's script at /data/airpact4/EI_UPDATE/MOVES/moves/subsys/smoke/scripts/run/airpact4/run_met4moves.MOVES.airpact4.csh                # vikram 7/6/15
   setenv LOOKUP_TABLE_DIR $METDAT/dynamic_lookuptables
   setenv SMK_MVSPATH      $LOOKUP_TABLE_DIR/

   setenv metcomb Y
   setenv metmove Y
   setenv lookup  Y
   setenv onroad Y
   setenv offrdp Y
   setenv offrdv Y
   setenv merge  Y

# set Assigns file name
   setenv ASSIGNS_FILE ${PBS_O_WORKDIR}/emis/anthro/assigns_moves/ASSIGNS_AIRPACT5_MOVES.csh

# Source your Assigns file
#   source $ASSIGNS_FILE

# ##############################################################################
#  echo Starting date `date`

#> run metcombine to generate meteorology data set for met4moves
   if ($metcomb == 'Y') then
   echo `date`
   echo "      starting to run metcombine"
   ./run_metcombine.csh $1 >& $LOGDIR/log01_metcombine.txt
   endif

#> run met4moves
   if ($metmove == 'Y') then
   echo `date`
   echo "      starting to run met4moves"
   ./run_met4moves.csh $1 >& $LOGDIR/log02_met4moves.txt
   endif

#> run dynamic lookup tables generator
#  produce dynamic lookup tables based on MOVES generated static lookup tables
   if ($lookup == 'Y') then
   echo `date`
   echo "      starting to generate dynamic lookup tables"
   rm -rf $LOOKUP_TABLE_DIR
   mkdir -p $LOOKUP_TABLE_DIR
   ./run_lookuptable.csh $1 >& $LOGDIR/log03_lookuptable.txt
   endif

#> generate onroad rateperdistance emission
   if ($onroad == 'Y') then
   echo `date`
   echo "      starting to generate rateperdistance emission"
   ./smk_onroad.csh $1 >& $LOGDIR/log04_smk_onroad.txt
   endif

#> generate offroad ratepervehicle emission
   if ($offrdv == 'Y') then
   echo `date`
   echo "      starting to generate ratepervehicle emission"
   ./smk_offroad_rpv.csh $1 >& $LOGDIR/log05_smk_offroad_rpv.txt
   endif

#> generate offroad rateperprofile emission
   if ($offrdp == 'Y') then
   echo `date`
   echo "     starting to generate rateperprofile emission"
   ./smk_offroad_rpp.csh $1 >& $LOGDIR/log06_smk_offroad_rpp.txt
   endif

#> merge rpp rpv and rpd into one files
   if ($merge == 'Y') then
   echo `date`
   echo "      starting to merge rpp, rpv and rpd emission"
  ./mrg_moves.csh $1 >& $LOGDIR/log07_mrg_moves.txt
   endif


#> check log files for success
   # count the number of log files
     @ numLogs = `ls  $LOGDIR/movesmrg*.log  | wc  -l`
     # count the number of 'normal completion' in logfiles
       @ numSuccess = `grep -i "normal Completion of program" $LOGDIR/*.txt | wc -l`

   echo ""
   if ( $numLogs == $numSuccess ) then
	echo "--->> normal Completion of smk_mb_moves.csh"
   else
	echo "--->> unsuccessfull completion of smk_moves.csh"
	echo "--->> check into log files in $LOGDIR"
	echo $numLogs
	echo $numSuccess
   endif

echo ""
echo `date`
echo "############## end of mobiile MOVES###############"
