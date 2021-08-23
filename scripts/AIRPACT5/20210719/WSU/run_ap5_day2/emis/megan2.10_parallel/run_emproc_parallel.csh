#! /bin/csh -f
#
# one step in MET2MGN v2.10 
#
#  ./run_emproc_parallel.csh 20150505
#
########################################################################

setenv IOAPI_LOG_WRITE FALSE
#> check arguments
   if ( $#argv != 1 ) then
     echo 'invalid argument. '
     echo "usage $0 <yyyymmdd> "
     set exitstat = 1
     exit ( $exitstat )
   else if ( $1 < 19000000 ) then
     echo 'invalid argument. '
     echo "usage $0 <yyyymmdd> <yyyymmdd>"
     set exitstat = 1
     exit ( $exitstat )
   endif

#> environment stuff
   # suprpress warning message "PGI Warning: ieee_inexact is signaling"
     setenv NO_STOP_MESSAGE yes
   setenv PROMPTFLAG N
#> date stuff
   # current day (i.e., simulation day)
     set YYYYMMDD = $1
     set cyear = `echo $YYYYMMDD | cut -c 1-4`
     set cmm   = `echo $YYYYMMDD | cut -c 5-6`
     set cdd   = `echo $YYYYMMDD | cut -c 7-8`
     set DOYstring = `juldate $cmm $cdd $cyear | cut -d',' -f 2`
     set cdoy       = `echo $DOYstring | cut -c5-7`
     set YEARDOY   = $cyear$cdoy
   # date-related environment variables ("input" to program)
     setenv SDATE $YEARDOY        #start date
     setenv STIME  80000
     setenv RLENG 250000
#> directories and files
   # program executable
     set base = `dirname $0`
     source $base/setcase.csh
     setenv PROG emproc
    #setenv EXE $MGNEXE/$PROG
   # input
     # input maps
       setenv EFMAPS $MGNINP/EFMAPS.ncf
       setenv PFTS16 $MGNINP/PFTS16.ncf
       setenv LAIS46 $MGNINP/LAIS46.ncf
     # meteorology input file (output of met2mgn)
       setenv MGNMET $MGNOUT/met4megan_${YYYYMMDD}.ncf
   # output and logs
     set OUTPATH = $MGNOUT
     if ( ! -d $OUTPATH ) mkdir -p $OUTPATH
     setenv MGNERS $OUTPATH/er_${YYYYMMDD}.ncf
     if ( -e $MGNERS ) rm -f $MGNERS
#> input choicse/switches
   setenv RUN_MEGAN   Y       # Run megan?
   # by default MEGAN will use data from MGNMET unless specify below
     setenv ONLN_DT     Y  # Use online daily average temperature
                           # No will use from EFMAPS
     setenv ONLN_DS     Y  # Use online daily average solar radiation
                           # No will use from EFMAPS

#> horizontal domain decomposition 
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
   echo "NPCOL_NPROW" $NPCOL_NPROW

#> MCIP files needed for grid information
   if ( ! $?MCIPDIR ) set MCIPDIR = $MCIPROOT/${YYYYMMDD}00/MCIP37 #Added 8/19/2016 by FHT
   echo MCIPDIR is $MCIPDIR 
   #set MCIPDIR = $MCIPROOT/${YYYYMMDD}00/MCIP37 #Test
   setenv GRID_DOT_2D  $MCIPDIR/GRIDDOT2D
   setenv GRID_CRO_2D  $MCIPDIR/GRIDCRO2D
   setenv MET_CRO_2D   $MCIPDIR/METCRO2D
   setenv MET_CRO_3D   $MCIPDIR/METCRO3D
   setenv MET_DOT_3D   $MCIPDIR/METDOT3D
   setenv MET_BDY_3D   $MCIPDIR/METBDY3D
   
#> run EMPROC component of MEGANv2.10, parallel version
   # first, cd to the directory for the MPI log files will be
     if ( ! -d $logdir/emproc ) mkdir -p $logdir/emproc
     cd $logdir/emproc
     set test = `ls *`
     if ( "$test" != "" ) /bin/rm -f *
     setenv LOGFILE $logdir/log_emproc_000.txt
     if ( -e $LOGFILE ) /bin/rm -f $LOGFILE
   mpirun $MGNEXEP/driver.x


