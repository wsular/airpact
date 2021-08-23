#!/bin/csh -f

# Serena H. Chung
# 2016-05-04
#    examples of using this script:

#           qsub -V -N aod20160504 -v currentday=20160504 qsub_aod.csh
#
#PBS -l nodes=1:smp:ppn=8,mem=7Gb
#PBS -l walltime=00:20:00
#PBS -d ~airpact5/AIRHOME/run_ap5_day1
#PBS -o ~airpact5/AIRHOME/run_ap5_day1/post/cctm/aod
#PBS -e ~airpact5/AIRHOME/run_ap5_day1/post/cctm/aod
#PBS -j oe

# mail options
###PBS -m abe
###PBS -m a
###PBS -M serena_chung@wsu.edu

# -------------------------- end of PBS options ------------------------


#> location of the combine program ---------------------------------
   set prgdir = ~airpact5/AIRHOME/build/aod550nm/parallel
   set exec = driver_aod550nm.x

#> initialize exit status ----------------------------------------------
   set exitstat = 0

#> dates stuff ---------------------------------------------------------

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
   setenv OUTFILE $OUTDIR/aod550nm_${currentday}.ncf
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

#> ---------------------------------------------------------------------

  #echo attempting to create $OUTFILE
   set logfile = $AIROUT/LOGS/post/aod/log_aod_main.txt
  if ( ! -d $AIROUT/LOGS/post/aod ) mkdir -p $AIROUT/LOGS/post/aod
  cd $AIROUT/LOGS/post/aod
  mpirun $prgdir/${exec} >&! $logfile

   # echo "checking" $logfile
   # set tmp_str1 = `tail -4 $logfile`
   # set tmp_str2 = `echo "$tmp_str1[1-6]"`
   # if ( `echo $tmp_str2` == `echo "--->> Normal Completion of program DRIVER"` ) then
   #    set tmp = `grep -i error $logfile`
   #    if ( $#tmp == 0 ) then
   #        echo "  ok; created" $OUTFILE
   #    else
   #       echo "  error in" $logfile
   #       echo $tmp
   #       set run_status = 1
   #       exit($run_status)
   #    endif
   # else
   #    echo "      error running get_cmaq_aod3d_aero6"
   #    echo `tail -4 $logfile`
   #    echo $tmp_str2
   #    set run_status = 1
   #    exit($run_status)
   # endif

