#/bin/csh

#> Exampe of using this script
#   
#   #   set_env.csh 20101105
#
#   #   where 2010110508 denotes forecaststart time of 8 GMT on Nov 5, 2010
#
#
# Serena H. Chung
# 2013-04-24


#> Extract current date and time from input argument
   if ( $#argv == 1 ) then
     setenv SRTYR  `echo $1 | cut -c1-4`
     setenv SRTMN  `echo $1 | cut -c5-6`
     setenv SRTDT  `echo $1 | cut -c7-8`
     setenv SRTHR   00    #not sure if this is correct 
   else
     echo 'Invalid argument in set_env.csh '
     echo "Usage $0 yyyymmddhh"
     set exitstat = 1
     exit ( $exitstat )
   endif
   set CJDATE = `$EBASE/src/juldate $SRTMN $SRTDT $SRTYR` #YYYYDOY
   
   setenv RUNGDAT ${SRTYR}${SRTMN}${SRTDT}
   setenv RUNDATE ${SRTYR}${SRTMN}${SRTDT}${SRTHR}  # date in <YYYYMMDDHH>

#> extract previous and next date and time
   setenv PRVJDT `$EBASE/src/nextime $CJDATE 0 -240000 | cut -c1-7`
   setenv PRVYR  `$EBASE/src/gregdate $PRVJDT | cut -c 7-11`
   setenv PRVMN  `$EBASE/src/gregdate $PRVJDT | cut -c 1-2`
   setenv PRVDT  `$EBASE/src/gregdate $PRVJDT | cut -c 4-5`

   setenv NXTJDT `$EBASE/src/nextime $CJDATE 0 240000 | cut -c1-7`
   setenv NXTYR  `$EBASE/src/gregdate $NXTJDT | cut -c 7-11`
   setenv NXTMN  `$EBASE/src/gregdate $NXTJDT | cut -c 1-2`
   setenv NXTDT  `$EBASE/src/gregdate $NXTJDT | cut -c 4-5`
 
#> Obtain current start and end month
  set monthl = (jan feb mar apr may jun jul aug sep oct nov dec)
  setenv aMonthS $monthl[$SRTMN]
  setenv pMonthS $monthl[$PRVMN]
  setenv nMonthS $monthl[$NXTMN]

  set monthlC = (Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)
  setenv aMonthSC $monthlC[$SRTMN]     
  setenv pMonthSC $monthlC[$PRVMN]
  setenv nMonthSC $monthlC[$NXTMN]

 echo "   "
 echo "******   PROCESSING DATE  $RUNDATE   ********************"
 echo "Current julian date is $CJDATE -> ($SRTDT/$aMonthS/$SRTYR )"
 echo "Previous julian date is $PRVJDT -> ($PRVDT/$pMonthS/$PRVYR)"
 echo "Next julian date is $NXTJDT -> ($NXTDT/$nMonthS/$NXTYR)"
 echo ""

