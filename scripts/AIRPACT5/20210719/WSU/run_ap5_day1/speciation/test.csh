#!/bin/csh -f
#   This script is meant to run monthly (13th day) for the previous year
#  
#   ./run_sitecmp_graphics_latyear_noarg.csh
#> ---------------------------------

set filename = site_locations2.csv
if ( ! -e $filename ) then
   echo "not found"
   exit(0)
endif

echo "exiting normally"
exit
