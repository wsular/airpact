#!/bin/csh -f
# Version @(#)$Id: smk_run.csh,v 1.6 2010/09/26 20:30:33 bbaek Exp $
# Path    $Source: /afs/isis/depts/cep/emc/apps/archive/smoke/smoke/scripts/run/smk_run.csh,v $
# Date    $Date: 2010/09/26 20:30:33 $

# This script runs the SMOKE processors.  
#
# Time independent programs only need to be run once.
# Time dependent programs need to be processed once
# for each day needed for the air quality simulation.  
#
# Script created by : M. Houyoux and J. Vukovich, MCNC
#                     Environmental Modeling Center 
# Last edited : July 7, 2015 by Farren
#
#*********************************************************************

# Create directory for output program logs
  setenv OUTLOG $LOGS
  if ( ! -e $OUTLOG ) then
     mkdir -p $OUTLOG
     chmod ug+w $OUTLOG
  endif

# Initialize exit status
  set exitstat = 0

# Make sure that debug mode and debug executable are set
  if ( $?DEBUGMODE ) then
     set debugmode = $DEBUGMODE
  else
     set debugmode = N
  endif
  if ( $?DEBUG_EXE ) then
     set debug_exe = $DEBUG_EXE
  else
     set debug_exe = dbx
  endif

### Ensure new controller variables are set
  if ( $?RUN_PART1 ) then
     if ( $RUN_PART1 == Y || $RUN_PART1 == y ) then
        setenv RUN_PART1 Y
        echo 'Running part 1...'
     endif
  else
     setenv RUN_PART1 N
  endif
  if ( $?RUN_PART2 ) then
     if ( $RUN_PART2 == Y || $RUN_PART2 == y ) then
        setenv RUN_PART2 Y
        echo "Running part 2, for $ESDATE ..."
     endif
  else
   setenv RUN_PART2 N 
  endif
  if ( $?RUN_PART3 ) then
     if ( $RUN_PART3 == Y || $RUN_PART3 == y ) then
        setenv RUN_PART3 Y
        echo 'Running part `3 ...'
     endif
  else
     setenv RUN_PART3 N 
  endif
  if ( $?RUN_PART4 ) then
    if ( $RUN_PART4 == Y || $RUN_PART4 == y ) then
       setenv RUN_PART4 Y
       echo "Running part 4, for $ESDATE..."
    endif
  else
     setenv RUN_PART4 N 
  endif

#
### Raw Inventory processing
#
  set debugexestat = 0
  set exestat = 0
  setenv TMPLOG   $OUTLOG/smkinven_${SRCABBR}_${INVEN}.log
  if ( $?RUN_SMKINVEN ) then
     if ( $RUN_SMKINVEN == 'Y' && $RUN_PART1 == Y ) then
        if ( -e $TMPLOG ) then
           source $SCRIPTS/run/movelog.csh
        endif
        ##  Create output directories, if needed
         source $SCRIPTS/run/make_invdir.csh
         set exitstat = $status
         if ( $exitstat == 0 ) then         # Run program
            setenv LOGFILE $TMPLOG
            if ( $debugmode == Y ) then
               if ( -e $IV_SRC/smkinven.debug ) then
                  $debug_exe $IV_SRC/smkinven.debug
               else
                   set debugexestat = 1
               endif
            else
               time $SMK_BIN/smkinven
            endif
         endif
         if ( -e $SCRIPTS/fort.99 ) then
            mv $LOGFILE $LOGFILE.tmp
            cat $LOGFILE.tmp $SCRIPTS/fort.99 > $LOGFILE
            /bin/rm -rf $LOGFILE.tmp
            /bin/rm -rf $SCRIPTS/fort.99
         endif
         if ( $exestat == 1 ) then
            echo 'SCRIPT ERROR: smkinven program does not exist in:'
	    echo '              '$SMK_BIN
            set exitstat = 1
         endif
         if ( $debugexestat == 1 ) then
            echo 'SCRIPT ERROR: smkinven.debug program does not exist in:'
	    echo '              '$IV_SRC
            set exitstat = 1
         endif

     endif
  endif

#
### Gridding Matrix generation
#
set debugexestat = 0
set exestat = 0
setenv TMPLOG   $OUTLOG/grdmat_${SRCABBR}_${INVEN}_${GRID}.log
if ( $?RUN_GRDMAT ) then
   if ( $RUN_GRDMAT == 'Y' && $RUN_PART1 == Y ) then

      if ( -e $TMPLOG ) then
	 source $SCRIPTS/run/movelog.csh
      endif

      if ( $exitstat == 0 ) then         # Run program
         setenv LOGFILE $TMPLOG

         if ( $debugmode == Y ) then
            if ( -e $GD_SRC/grdmat.debug ) then
               $debug_exe $GD_SRC/grdmat.debug
            else
                set debugexestat = 1
            endif
         else
            if ( -e $SMK_BIN/grdmat ) then
               time $SMK_BIN/grdmat
               set tmp_str1 = `tail -2 "$TMPLOG"`
               if ( `echo $tmp_str1` == `echo "No source-cell intersections found."` ) then
                   echo "     no fires in airpact domain according to SMARTFire/BlueSky "
	       	   exit(1)
	       else 
	       	    set tmp_str1 = `tail -3 "$TMPLOG"`
	       	    if ( `echo $tmp_str1` != `echo "--->> Normal Completion of program GRDMAT"` ) then 
	               echo "     GRDMAT failed for BlueSky output files "
	               exit(1)
	            endif
	       endif
            else
               set exestat = 1 
            endif
         endif
      endif

      if ( -e $SCRIPTS/fort.99 ) then
         mv $LOGFILE $LOGFILE.tmp
         cat $LOGFILE.tmp $SCRIPTS/fort.99 > $LOGFILE
         /bin/rm -rf $LOGFILE.tmp
         /bin/rm -rf $SCRIPTS/fort.99
      endif

      if ( $exestat == 1 ) then
	 echo 'SCRIPT ERROR: grdmat program does not exist in:'
	 echo '              '$SMK_BIN
         set exitstat = 1
      endif

      if ( $debugexestat == 1 ) then
	 echo 'SCRIPT ERROR: grdmat.debug program does not exist in:'
	 echo '              '$GD_SRC
         set exitstat = 1
      endif
   endif
endif

#
### Speciation Matrix generation
#
set debugexestat = 0
set exestat = 0
setenv TMPLOG   $OUTLOG/spcmat_${SRCABBR}_${INVEN}_${SPC}.log
if ( $?RUN_SPCMAT ) then
   if ( $RUN_SPCMAT == 'Y' && $RUN_PART1 == Y ) then

      if ( -e $TMPLOG ) then
	 source $SCRIPTS/run/movelog.csh
      endif

      if ( $exitstat == 0 ) then         # Run program
         setenv LOGFILE $TMPLOG

         if ( $debugmode == Y ) then
            if ( -e $SP_SRC/spcmat.debug ) then
               $debug_exe $SP_SRC/spcmat.debug
            else
                set debugexestat = 1
            endif
         else
            if ( -e $SMK_BIN/spcmat ) then
               time $SMK_BIN/spcmat
            else
               set exestat = 1 
            endif
         endif
      endif

      if ( -e $SCRIPTS/fort.99 ) then
         mv $LOGFILE $LOGFILE.tmp
         cat $LOGFILE.tmp $SCRIPTS/fort.99 > $LOGFILE
         /bin/rm -rf $LOGFILE.tmp
         /bin/rm -rf $SCRIPTS/fort.99
      endif

      if ( $exestat == 1 ) then
	 echo 'SCRIPT ERROR: spcmat program does not exist in:'
	 echo '              '$SMK_BIN
         set exitstat = 1
      endif

      if ( $debugexestat == 1 ) then
	 echo 'SCRIPT ERROR: spcmat.debug program does not exist in:'
	 echo '              '$SP_SRC
         set exitstat = 1
      endif

   endif
endif



#
### Temporal Allocation - anthropogenic sources
# 
set debugexestat = 0
set exestat = 0
if ( $SMK_SOURCE == 'M' ) then
   setenv TMPLOG   $OUTLOG/temporal_${SRCABBR}_${INVEN}_${ESDATE}${GRID}.log
else
   setenv TMPLOG   $OUTLOG/temporal_${SRCABBR}_${INVEN}_${ESDATE}.log
endif
if ( $?RUN_TEMPORAL ) then
   if ( $RUN_TEMPORAL == 'Y' && $RUN_PART2 == Y ) then

      if ( -e $TMPLOG ) then
	 source $SCRIPTS/run/movelog.csh
      endif

      if ( $exitstat == 0 ) then         # Run program
         setenv LOGFILE $TMPLOG
        if ( $debugmode == Y ) then
            if ( -e $TM_SRC/temporal.debug ) then
               $debug_exe $TM_SRC/temporal.debug
            else
                set debugexestat = 1
            endif
         else
            time $SMK_BIN/temporal
         endif
      endif

      if ( -e $SCRIPTS/fort.99 ) then
         mv $LOGFILE $LOGFILE.tmp
         cat $LOGFILE.tmp $SCRIPTS/fort.99 > $LOGFILE
         /bin/rm -rf $LOGFILE.tmp
         /bin/rm -rf $SCRIPTS/fort.99
      endif

      if ( $exestat == 1 ) then
	 echo 'SCRIPT ERROR: temporal program does not exist in:'
	 echo '              '$SMK_BIN
         set exitstat = 1
      endif

      if ( $debugexestat == 1 ) then
	 echo 'SCRIPT ERROR: temporal.debug program does not exist in:'
	 echo '              '$TM_SRC
         set exitstat = 1
      endif
   endif
endif

#
### Layer fractions creation
#
set debugexestat = 0
set exestat = 0
setenv TMPLOG   $OUTLOG/laypoint_${SRCABBR}_${INVEN}_${ESDATE}_${GRID}.log
if ( $?RUN_LAYPOINT ) then
   if ( $RUN_LAYPOINT == 'Y' && $RUN_PART4 == Y ) then

      if ( $?SMK_PING_METHOD ) then
         if ( $SMK_PING_METHOD == 2 ) then
            setenv SMK_PING_YN Y
         endif
      endif

      if ( -e $TMPLOG ) then
	 source $SCRIPTS/run/movelog.csh
      endif

      if ( $exitstat == 0 ) then         # Run program
         setenv LOGFILE $TMPLOG
        if ( $debugmode == Y ) then
            if ( -e $PT_SRC/laypoint.debug ) then
               $debug_exe $PT_SRC/laypoint.debug
            else
                set debugexestat = 1
            endif
         else
            if ( -e $SMK_BIN/laypoint ) then
               time $SMK_BIN/laypoint
            else
               set exestat = 1 
            endif
         endif
      endif

      if ( -e $SCRIPTS/fort.99 ) then
         mv $LOGFILE $LOGFILE.tmp
         cat $LOGFILE.tmp $SCRIPTS/fort.99 > $LOGFILE
         /bin/rm -rf $LOGFILE.tmp
         /bin/rm -rf $SCRIPTS/fort.99
      endif

      if ( $exestat == 1 ) then
	 echo 'SCRIPT ERROR: laypoint program does not exist in:'
	 echo '              '$SMK_BIN
         set exitstat = 1
      endif

      if ( $debugexestat == 1 ) then
	 echo 'SCRIPT ERROR: laypoint.debug program does not exist in:'
	 echo '              '$PT_SRC
         set exitstat = 1
      endif
   endif
endif

#
### Merging
#
set debugexestat = 0
set exestat = 0
setenv TMPLOG   $OUTLOG/smkmerge_${SRCABBR}_${INVEN}_${GRID}.log
if ( $?RUN_SMKMERGE ) then
   if ( $RUN_SMKMERGE == 'Y' && $RUN_PART4 == Y ) then

      # Set mole/mass-based speciation matrices.
      set unit = tons
      if( $?MRG_GRDOUT_UNIT ) then 
         set unit = `echo $MRG_GRDOUT_UNIT | cut -c1-4`
      endif
      if ( $unit == mole ) then   # mole
         if ( $?ASMAT_L ) then
            setenv ASMAT $ASMAT_L
         endif
         if ( $?BGTS_L ) then
            setenv BGTS $BGTS_L
         endif
         if ( $?MSMAT_L ) then
            setenv MSMAT $MSMAT_L
         endif
         if ( $?PSMAT_L ) then
            setenv PSMAT $PSMAT_L
         endif

      else                       # mass
         if ( $?ASMAT_S ) then
            setenv ASMAT $ASMAT_S
         endif
         if ( $?BGTS_S ) then
            setenv BGTS $BGTS_S
         endif
         if ( $?MSMAT_S ) then
            setenv MSMAT $MSMAT_S
         endif
         if ( $?PSMAT_S ) then
            setenv PSMAT $PSMAT_S
         endif
      endif

      if ( -e $TMPLOG ) then
         source $SCRIPTS/run/movelog.csh
      endif

      if ( $exitstat == 0 ) then         # Run program
         setenv LOGFILE $TMPLOG
         if ( $debugmode == Y ) then
            if ( -e $MG_SRC/smkmerge.debug ) then
               $debug_exe $MG_SRC/smkmerge.debug
            else
                set debugexestat = 1
            endif
         else
            if ( -e $SMK_BIN/smkmerge ) then
               time $SMK_BIN/smkmerge
            else
               set exestat = 1 
            endif
         endif
      endif

      if ( -e $SCRIPTS/fort.99 ) then
         mv $LOGFILE $LOGFILE.tmp
         cat $LOGFILE.tmp $SCRIPTS/fort.99 > $LOGFILE
         /bin/rm -rf $LOGFILE.tmp
         /bin/rm -rf $SCRIPTS/fort.99
      endif

      if ( $exestat == 1 ) then
	 echo 'SCRIPT ERROR: smkmerge program does not exist in:'
	 echo '              '$SMK_BIN
         set exitstat = 1
      endif

      if ( $debugexestat == 1 ) then
	 echo 'SCRIPT ERROR: smkmerge.debug program does not exist in:'
	 echo '              '$MG_SRC
         set exitstat = 1
      endif
   endif
endif


#
## Ending of script with exit status
#
exit( $exitstat )

