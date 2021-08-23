#!/bin/csh
#
# MET2MGN v2.10 
# --
#  ./run_met2mgn.csh 20150505 20150505
#  ./run_met2mgn.csh 20120701 20120701
#
#     first argument is the episode starting date
#     second argument is the current simulation date

############################################################

setenv IOAPI_LOG_WRITE FALSE

#> check arguments
   if ( $#argv != 2 ) then
     echo 'invalid argument. '
     echo "usage $0 <yyyymmdd> <yyyymmdd>"
     set exitstat = 1
     exit ( $exitstat )
   else if ( $1 < 19000000 || $2 < 19000000 ) then
     echo 'invalid argument. '
     echo "usage $0 <yyyymmdd> <yyyymmdd>"
     set exitstat = 1
     exit ( $exitstat )
   endif

#> date stuff
   # the initial date/time of a whole set of run?
     set epYYYYMMDD = $1
     set epyear = `echo $epYYYYMMDD | cut -c 1-4`
     set epmm   = `echo $epYYYYMMDD | cut -c 5-6`
     set epdd   = `echo $epYYYYMMDD | cut -c 7-8`
     set DOYstring = `juldate $epmm $epdd $epyear | cut -d',' -f 2`
     set epdoy       = `echo $DOYstring | cut -c5-7`
     set epYEARDOY   = $epyear$epdoy
     setenv EPISODE_SDATE ${epYEARDOY}
     setenv EPISODE_STIME  080000
   # current day (i.e., simulation day)
     set YYYYMMDD = $2
     set cyear = `echo $YYYYMMDD | cut -c 1-4`
     set cmm   = `echo $YYYYMMDD | cut -c 5-6`
     set cdd   = `echo $YYYYMMDD | cut -c 7-8`
     set DOYstring = `juldate $cmm $cdd $cyear | cut -d',' -f 2`
     set cdoy       = `echo $DOYstring | cut -c5-7`
     set YEARDOY   = $cyear$cdoy
     @ jdy  = $YEARDOY - 2000000
     setenv STDATE ${jdy}08
   # next day 
     set nYYYYMMDD = `date -d "$YYYYMMDD 1 days" '+%Y%m%d'`
     set nyear = `echo $nYYYYMMDD | cut -c 1-4`
     set nmm   = `echo $nYYYYMMDD | cut -c 5-6`
     set ndd   = `echo $nYYYYMMDD | cut -c 7-8`
     set DOYstring = `juldate $nmm $ndd $nyear | cut -d',' -f 2`
     set ndoy       = `echo $DOYstring | cut -c5-7`
     set nYEARDOY   = $nyear$ndoy
     @ jdy  = $nYEARDOY - 2000000
     setenv ENDATE ${jdy}08
   # previous day (need meteorology for the previous day)
     set pYYYYMMDD = `date -d "$YYYYMMDD -1 days" '+%Y%m%d'`
     set pyear = `echo $pYYYYMMDD | cut -c 1-4`
     set pmm   = `echo $pYYYYMMDD | cut -c 5-6`
     set pdd   = `echo $pYYYYMMDD | cut -c 7-8`
     set DOYstring = `juldate $pmm $pdd $pyear | cut -d',' -f 2`
     set pdoy       = `echo $DOYstring | cut -c5-7`
     set pYEARDOY   = $pyear$pdoy

#> environment stuff
   # suprpress warning message "PGI Warning: ieee_inexact is signaling"
     setenv NO_STOP_MESSAGE yes
#> directories and files
   # program executable
     set base = `dirname $0`
     source $base/setcase.csh
     setenv PROG met2mgn
     setenv EXE $MGNEXE/$PROG
    
   # input
     set INPATH = $MCIPROOT/${YYYYMMDD}00/MCIP37 # testing
     setenv METCRO3Dfile  $INPATH/METCRO3D
     setenv METDOT3Dfile  $INPATH/METDOT3D
     if ( $EPISODE_SDATE == $YEARDOY )  then
        setenv METCRO2Dfile1 $INPATH/METCRO2D
     else 
        setenv METCRO2Dfile1 $MCIPROOT/${pYYYYMMDD}00/MCIP37/METCRO2D
        setenv METCRO2Dfile2 $MCIPROOT/${YYYYMMDD}00/MCIP37/METCRO2D
     endif
   # in & out
     set OUTPATH = $MGNOUT
     if ( ! -d $OUTPATH ) mkdir -p $OUTPATH
     setenv PFILE $OUTPATH/PFILE;
     if ( $EPISODE_SDATE != $YEARDOY )  then
         set tmpfile = $AIRROOT/$pyear/${pYYYYMMDD}00/EMISSION/megan2.10/PFILE_${pyear}${pmm}${pdd}.ncf
         if ( ! -e $tmpfile ) then
             set tmpfile = $AIRROOTDAY2/$pyear/${pYYYYMMDD}00/EMISSION/megan2.10/PFILE_${pyear}${pmm}${pdd}.ncf
         endif
         cp $tmpfile $PFILE
     endif
   # output and logs
     setenv OUTFILE $OUTPATH/met4megan_${YYYYMMDD}.ncf
     if ( -e $OUTFILE ) rm -f $OUTFILE

#> TEMP/PAR input choices/switches
   setenv MM5MET N
   setenv MM5RAD N
   setenv SATPAR N
   setenv MCIPMET Y
   setenv TMCIP  TEMP2          #MCIP v3.3 or newer
   setenv MCIPRAD Y 


 $EXE 
 mv $PFILE $OUTPATH/PFILE_${YYYYMMDD}.ncf
