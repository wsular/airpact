#!/bin/csh -fx
#
## HEADER ########################################################
#
#  This script sets the dependent i/o directories for SMOKE 
#
# Make sure category-specific speciation is available
if ( $?P_SPC_OVERRIDE ) then
   setenv P_SPC $P_SPC_OVERRIDE
else
   setenv P_SPC $SPC
endif

# Now set directories
   setenv INVDIR   $SMKDAT/inventory/$INVID    # Inventory dir
   setenv GE_DAT   $SMKDAT/ge_dat              # General input dir
   setenv METDAT   $SMKDAT/met                 # Met data dir
   setenv REPORTS  $SMKDAT/reports             # Output reports root dir
   setenv REPSCEN  $REPORTS/$ESCEN/scenario    # Output reports scenario dir
   setenv REPSTAT  $REPORTS/$ESCEN/static      # Output reports dir
#
   setenv PTDAT    $INVDIR/point               # point data path
#
#   setenv SCENARIO $SMKDAT/run_$ESCEN/scenario # Scen-spec daily data
   setenv SCENARIO $AIROUT/EMISSION/fire/smoke
   setenv INVOPD   $SCENARIO    # Inventory output dir
   setenv STATIC   $SMKDAT/run_$ESCEN/static   # Scen-spec static data
   setenv BASSCN   $SMKDAT/run_$INVEN/scenario # Episode-specific daily data
   setenv BASDIR   $SMKDAT/run_$INVEN/static   # Episode-specific static data
#
   setenv SMK_TMPDIR   $STATIC/tmp
   setenv SMK_METPATH  $STATIC/m6met
   setenv SMK_SPDPATH  $STATIC/m6spd
   setenv SMK_M6PATH   $STATIC/m6
   setenv SMK_EMISPATH $STATIC/m6emfac
#
   setenv P_OUT    $SMKDAT/run_$PSCEN/output/$P_SPC   # Point output
   setenv OUTPUT   $AIROUT/EMISSION/fire/smoke
   mkdir -p $OUTPUT
#
   setenv SCRIPTS  $SMKROOT/scripts            # smoke scripts
   setenv INC      $SMKROOT/src/inc            # source code for include files 
   setenv CL_SRC   $SMKROOT/src/cntlmat        # source code for controls
   setenv EL_SRC   $SMKROOT/src/lib            # source code for lib routines
   setenv GD_SRC   $SMKROOT/src/grdmat         # source code for gridding
   setenv IV_SRC   $SMKROOT/src/smkinven       # source code for inven import
   setenv MD_SRC   $SMKROOT/src/emmod          # source code for modules
   setenv MG_SRC   $SMKROOT/src/smkmerge       # source code for merge prgms
   setenv PT_SRC   $SMKROOT/src/point          # source code for point
   setenv QA_SRC   $SMKROOT/src/emqa           # source code for qa prgms
   setenv SP_SRC   $SMKROOT/src/spcmat         # source code for speciation
   setenv TM_SRC   $SMKROOT/src/temporal       # source code for temporal  
   setenv UT_SRC   $SMKROOT/src/emutil         # source code for utility prgms
   setenv LOGS     $AIROUT/LOGS/emis/fire
