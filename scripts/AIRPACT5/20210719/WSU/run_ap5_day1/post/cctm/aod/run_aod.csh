#!/bin/csh -f

# Serena H. Chung
# 2016-05-05
#    examples of using this script:

#           ./run_aod.csh 20160504
#

#> initialize exit status ----------------------------------------------
   set exitstat = 0

#> location of the combine program ---------------------------------
   set prgdir = ~airpact5/AIRHOME/build/aod550nm/parallel
   set exec = driver_aod550nm.x

#> dates stuff ---------------------------------------------------------
  
   if ( $#argv == 1 ) then
      set currentday = $1
   else
      echo "need date in YYYYMMDD as command line input"
      exit(1)
   endif
    set YEAR  = `echo $currentday | cut -c1-4`
    set MONTH = `echo $currentday | cut -c5-6`
    set DAY   = `echo $currentday | cut -c7-8`
    set DOYstring = `juldate $MONTH $DAY $YEAR | cut -d',' -f 2`
    set DOY       = `echo $DOYstring | cut -c5-7`
    set YEARDOY   = $YEAR$DOY

#> during testing ------------------------------------------------------

   if ( ! $?PBS_O_WORKDIR ) then
      set PBS_O_WORKDIR = ~airpact5/AIRHOME/run_ap5_day1
   endif
   if ( ! $?AIROUT ) then
      set AIROUT = /data/lar/projects/airpact5/AIRRUN/${YEAR}/${currentday}00
      set MCIPDIR = /data/lar/projects/airpact5/AIRRUN/${currentday}00/MCIP37
      set AIRSAVE = /data/lar/projects/airpact5/saved/$YEAR
   endif
    
#> directory set-up ----------------------------------------------------

   set BASE    = $PBS_O_WORKDIR/post/cctm/aod
   set  INDIR  = $AIROUT/CCTM
   set OUTDIR  = $AIROUT/POST/CCTM
   if ( ! -d $OUTDIR ) mkdir -p $OUTDIR

#> timestep run parameters ---------------------------------------------
   set STDATE   = ${YEARDOY}    # beginning date
   set STTIME   = 080000        # beginning GMT time (HHMMSS)
   set NSTEPS   = 240000         # time duration (HHMMSS) for this run
   set TSTEP    = 010000        # output time step interval (HHMMSS)

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

#> input and output files -----------------------------------------------

   setenv CTM_ACONC $AIROUT/CCTM/ACONC_${currentday}.ncf
   setenv CTM_AERODIAM  $AIROUT/CCTM/AERODIAM_${currentday}.ncf
   setenv MET_CRO_3D  $MCIPDIR/METCRO3D
   setenv GRID_CRO_2D  $MCIPDIR/GRIDCRO2D
   setenv GRIDDESC  $MCIPDIR/GRIDDESC
   setenv GRID_NAME AIRPACT_04km
   setenv OUTFILE $OUTDIR/aod550nm3d_${currentday}.ncf
   if ( ! -e $CTM_ACONC ) then 
      echo $CTM_ACONC not found  
      exit(1)          
   endif
   if ( ! -e $CTM_AERODIAM ) then 
      echo $CTM_AERODIAM not found  
      exit(1)          
   endif
   if ( -e $OUTFILE ) /bin/rm -f $OUTFILE

#> for the run control -------------------------------------------------
    setenv AOD_STDATE      $STDATE
    setenv AOD_STTIME      $STTIME
    setenv AOD_RUNLEN      $NSTEPS
    setenv AOD_TSTEP       $TSTEP
    setenv AOD_PROGNAME    'aod550nm'

#> calculate 3D AOD ----------------------------------------------------
    set logfile = $AIROUT/LOGS/post/aod/log_aod3d_main.txt
    if ( ! -d $AIROUT/LOGS/post/aod ) mkdir -p $AIROUT/LOGS/post/aod
    cd $AIROUT/LOGS/post/aod
    set test = `ls *`
    if ( "$test" != "" ) /bin/rm -f *
    setenv IOAPI_LOG_WRITE FALSE
    mpirun $prgdir/${exec} >&! $logfile

#> convert to 2D AOD ---------------------------------------------------
   setenv INFILE   $OUTFILE
   setenv OUTFILE  $OUTDIR/aod550nm2d_${currentday}.ncf
   if ( ! -e $INFILE ) then 
      echo $INFILE not found  
      exit(1)          
   endif
   set logfile = $AIROUT/LOGS/post/aod/log_aod_convertTo2D.txt
   if ( -e $logfile ) /bin/rm -f $logfile
   if ( -e $OUTFILE ) /bin/rm -f $OUTFILE
   setenv PROMPTFLAG F
   setenv IOAPI_GRIDNAME_1 'AIRPACT_04km' 
   ~airpact5/AIRHOME/build/sum_layers/sum_layers.x >&! $logfile
