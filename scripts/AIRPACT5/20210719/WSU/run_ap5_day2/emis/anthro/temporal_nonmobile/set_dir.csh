#!/bin/csh -f

# Serena H. Chung
# 2011-12-19
# JK Vaughan update for airpact5  09/11/2015
#
# Script to first check input met data file and setup daily anthropogenic emission processing by SMOKE

#  Precondition(s):
#
#     setenv AIRHOME
#     setenv AIROUT
#     setenv MCIPDIR
#     setenv AIRLOGDIR
#     setenv CJDATE
#     setenv STIME
#     setenv RNLEN


#> Initialize exit status
  set exitstat = 0


#> Set up directories

  # MCIP files
    setenv METDIR $MCIPDIR       # For met files
   #echo " $METDIR/METCRO3D"
   ## Check MCIP
      if ( ! -e $METDIR/METCRO3D  || \
           ! -e $METDIR/METCRO2D  || \
           ! -e $METDIR/METDOT3D  || \
           ! -e $METDIR/GRIDCRO2D ) then #|| \
          #! -e $METDIR/GRIDCRO3D ) then
         echo 'MCIP files not found'
	 exit(1)
      endif

   # Output directories
     setenv EIROOT $AIROUT/EMISSION/anthro
     if ( ! -d $EIROOT/scenario ) mkdir -p $EIROOT/scenario
     setenv INTDIR $EIROOT/scenario    # For intermediate files

     if ( ! -d $EIROOT/output ) mkdir -p $EIROOT/output
     setenv OUTDIR $EIROOT/output      # For final source output files

     setenv LOGDIR $AIRLOGDIR/emis/anthro        # For log files
     if ( ! -d $LOGDIR ) mkdir -p $LOGDIR

# Simulation period settings
  setenv G_STDATE ${CJDATE}  # Start J-date YYYYDDD
  setenv WRDCNT `echo $G_STDATE |wc -m`
  if ( $WRDCNT != '8' ) then
     echo 'Error in setting environment variable G_STDATE.'
     set exitstat = 1
     exit ( $exitstat )
  endif

# environment related to runt ime
  setenv G_STTIME     $STIME    # Start time HHMMSS
  setenv G_TSTEP      10000     # Time step HHMMSS
  setenv G_RUNLEN     `expr $RNLEN + 10000` # 250000 # Scenario period HHMMSS 1hr more than cctm run

exit ( $exitstat )
