#! /bin/csh -f
#
# one step in MET2MGN v2.10 
#
#  ./run_emproc.csh 20150505
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
     setenv EXE $MGNEXE/$PROG
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

#> run MEGAN component
   time $EXE 


