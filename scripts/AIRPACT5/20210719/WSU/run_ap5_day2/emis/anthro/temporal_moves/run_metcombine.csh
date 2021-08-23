#! /bin/csh -f

# This script sets up environment variables and runs the Metcombine utility.
# Metcombine extracts data from 2D and the 1st layer of 3D meteorology files
# to create custom met files needed by Premobl.
#
# This script assumes that the meteorology files are named with the following
# convention:
#     METCRO2D_<YYYYDDD>
#     METCRO3D_<YYYYDDD>
#
# Script created by B.H. Baek, CEMPD (4/20/2010)
#
#*****************************************************************************


# Script settings
setenv PROMPTFLAG N                # Y prompts for input

setenv VARLIST "TEMP2, PRES, QV"   # list of variables to extract
setenv METFILE1  $MET_CRO_2D
setenv METFILE2  $MET_CRO_3D
setenv OUTFILE   $METDAT/METCOMBO

# Remove previous METLIST & METCOMBO file that contains a list of METCOMBO files vikram 7/6/15
rm -f $METLIST
rm -f $OUTFILE

$SMK_BIN/metcombine

## below changes based on Wei's script at /data/airpact4/EI_UPDATE/MOVES/moves/subsys/smoke/scripts/run/airpact4/run_metcombine.MOVES.airpact4.csh
## vikram 7/6/15
## expanding met data time period coverage to satisfy met4moves 
setenv INPUTFILE $OUTFILE
setenv OUTPUTFILE ${OUTFILE}_EXPANDED
rm -f $OUTPUTFILE

$SCRIPTS/run/m3texpander INPUTFILE OUTPUTFILE

echo $OUTPUTFILE > $METLIST
