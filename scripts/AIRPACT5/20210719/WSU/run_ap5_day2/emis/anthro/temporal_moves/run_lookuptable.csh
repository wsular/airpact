#! /bin/csh -f

# This script sets up environment variables and runs dynamic lookuptables 
# generators to create lookup tables for this particluar run
# -O flags put on pyton calls by JKV 042915

#*****************************************************************************



# define static lookup tables directory
  setenv STATIC_LOOKUP_TABLE_DIR $GE_DAT/MOVES_static_lookuptables

# generate rateperdistance lookup tables
  #python -O $SCRIPTS/run/rateperdistance_generator.py $MOVES_OUTFILE $STATIC_LOOKUP_TABLE_DIR $LOOKUP_TABLE_DIR   # changed based on Wei # vikram 7/6/15
  python -O $SCRIPTS/run/rateperdistance_norfl_generator.py $MOVES_RH_OUTFILE $STATIC_LOOKUP_TABLE_DIR $LOOKUP_TABLE_DIR

# generate ratepervehicle lookup tables
  #python -O $SCRIPTS/run/ratepervehicle_generator.py  $MOVES_OUTFILE $STATIC_LOOKUP_TABLE_DIR $LOOKUP_TABLE_DIR   # changed based on Wei # vikram 7/6/15
  python -O $SCRIPTS/run/ratepervehicle_norfl_generator.py  $MOVES_RH_OUTFILE $STATIC_LOOKUP_TABLE_DIR $LOOKUP_TABLE_DIR

# generate rateperprofile lookup tables 
# last two arguments removed since Wei's script expects only 3 args    # vikram  7/6/2015
  #python -O $SCRIPTS/run/rateperprofile_generator.py  $MOVES_OUTFILE $STATIC_LOOKUP_TABLE_DIR $LOOKUP_TABLE_DIR $MCXREF $SMOKE_OUTFILE
  python -O $SCRIPTS/run/rateperprofile_generator.py  $MOVES_OUTFILE $STATIC_LOOKUP_TABLE_DIR $LOOKUP_TABLE_DIR

