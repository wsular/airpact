#!/bin/csh -fx
#
## HEADER ########################################################
#
#  This script sets the scenarios names


setenv ASCEN   $ABASE
setenv BSCEN   $BBASE
setenv MSCEN   $MBASE
setenv PSCEN   $PBASE
setenv ESCEN   $EBASE

setenv FYINV   $INVEN
setenv FYIOP   $INVOP
setenv EF_YEAR $YEAR
setenv BYFYR `echo $YEAR | cut -c3-4`

# If future year processing requested, add future year to the scenario name
if ( $?SMK_FUTURE_YN ) then

   #  If using the future-year files as INPUT
   if ( $SMK_FUTURE_YN == Y ) then

      if ( $?FYEAR ) then

          set fyr2 = `echo $FYEAR | cut -c3-4`

          setenv ASCEN   ${ASCEN}_${fyr2}
          setenv MSCEN   ${MSCEN}_${fyr2}
          setenv PSCEN   ${PSCEN}_${fyr2}
          setenv ESCEN   ${ESCEN}_${fyr2}
          setenv FYIOP   ${FYIOP}_${fyr2}
          setenv EF_YEAR $FYEAR

      else

          echo 'ERROR: SMK_FUTURE_YN set to Y without FYEAR being set\!'
          echo '       Rerun with FYEAR set to the 4-digit future year.'   
          exit( 1 )

      endif

   endif

endif

if ( $?SMK_CONTROL_YN ) then

   #  If using the controlled-year files as INPUT
   if ( $SMK_CONTROL_YN == Y ) then

      if ( $?CNTLCASE ) then

          setenv ASCEN   ${ASCEN}_${CNTLCASE}
          setenv MSCEN   ${MSCEN}_${CNTLCASE}
          setenv PSCEN   ${PSCEN}_${CNTLCASE}
          setenv ESCEN   ${ESCEN}_${CNTLCASE}
          setenv FYIOP   ${FYIOP}_${CNTLCASE}

      else

          echo 'ERROR: SMK_CONTROL_YN set to Y without CNTLCASE being set\!'
          echo '       Rerun with CNTLCASE set to the control case name.'   
          exit( 1 )

      endif

   endif
endif

# If 4-digit future year set, at 2-digit year to the FYINV variable
if ( $?FYEAR ) then
   set fyr2 = `echo $FYEAR | cut -c3-4`
   setenv FYINV ${FYINV}_${fyr2}
   setenv BYFYR ${BYFYR}_${fyr2}
endif

# If control case name is defined, add it to the FYINV variable
if ( $?CNTLCASE ) then
   setenv FYINV ${FYINV}_${CNTLCASE}
endif

setenv MSB ${METSCEN}_${BSCEN}
setenv MSM ${METSCEN}_${MSCEN}
setenv MSP ${METSCEN}_${PSCEN}
setenv MSMBAS ${METSCEN}_${MBASE}
setenv MSPBAS ${METSCEN}_${PBASE}

exit( 0 )
