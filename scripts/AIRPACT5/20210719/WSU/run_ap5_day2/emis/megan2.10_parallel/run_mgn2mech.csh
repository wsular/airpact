#! /bin/csh -f

#! /bin/csh -f
#
# one step in MET2MGN v2.10 
#
#  ./run_mgn2mech.csh 20150505
#
setenv IOAPI_LOG_WRITE FALSE

#> check arguments -----------------------------------------------------
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
#> environment stuff ---------------------------------------------------
   # suprpress message "PGI Warning: ieee_inexact is signaling"
     setenv NO_STOP_MESSAGE yes
   setenv PROMPTFLAG N
#> date/time stuff -----------------------------------------------------
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
     setenv STIME 0
     setenv RLENG 250000
#> input choicse/switches ----------------------------------------------
   setenv RUN_SPECIATE   Y    # run MG2MECH
   setenv RUN_CONVERSION Y    # run conversions?
                              # run conversions MEGAN to model mechanism
                              # units are mole/s
   setenv SPCTONHR       N    # speciation output unit in tonnes per hour
                              # This will convert 138 species to tonne per
                              # hour or mechasnim species to tonne per hour.
   # chemical mechanism for output    
    #setenv MECHANISM    RADM2
    #setenv MECHANISM    RACM
    #setenv MECHANISM    CBMZ
     setenv MECHANISM    CB05
    #setenv MECHANISM    CB6
    #setenv MECHANISM    SOAX
    #setenv MECHANISM    SAPRC99
    #setenv MECHANISM    SAPRC99Q
    #setenv MECHANISM    SAPRC99X
#> directories and files -----------------------------------------------
   # program executable
     set base = `dirname $0`
     source $base/setcase.csh
     setenv PROG mgn2mech_nosaprc07tb
     setenv EXE $MGNEXE/$PROG
   # input
     # mapped information
       setenv EFMAPS $MGNINP/EFMAPS.ncf
       setenv PFTS16 $MGNINP/PFTS16.ncf
     # output of EMPROC
       setenv MGNERS $MGNOUT/er_${YYYYMMDD}.ncf
   # output and logs
     set OUTPATH = $MGNOUT
     if ( ! -d $OUTPATH ) mkdir -p $OUTPATH
     setenv MGNOUT $OUTPATH/${MECHANISM}_$YYYYMMDD.ncf
#> run MEGANv2.10 speciation and mechanism conversion ------------------
   if ( $RUN_SPECIATE == 'Y' ) then
	if ( -e $MGNOUT ) rm -f $MGNOUT
      $EXE 
   endif

