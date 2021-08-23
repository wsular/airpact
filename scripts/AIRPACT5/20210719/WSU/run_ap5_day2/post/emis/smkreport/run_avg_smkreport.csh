#!/bin/csh -f

# Example of using this script:
# 
#   > run_avg_smkreport.csh 201602
#
#    where 201602 denotes year and month: Feb 2016
#
# Farren Herron-Thorpe       2016-03-10
#
# This C shell script creates monthly ASCII files of the average emissions by county by sector
# using the daily smkreport outputs. 

#> initialize exit status ----------------------------------------------
   set exitstat = 0

#> check argument & set date strings  ----------------------------------

   if ( $#argv == 1 ) then
      setenv YEAR `echo $1 | cut -c1-4`
      setenv MONTH `echo $1 | cut -c5-6`
   else
      echo 'invalid argument. '
      echo "usage $0 <YYYYMM>"
      set exitstat = 1
      exit ( $exitstat )
   endif

#> during testing 

   if ( ! $?PBS_O_WORKDIR ) then
      set PBS_O_WORKDIR = ~airpact5/AIRHOME/run_ap5_day2
      if ( ! $?AIRHOME        ) set AIRHOME = ~airpact5/AIRHOME
      if ( ! $?AIRRUN ) then
         set AIRRUN  = /data//lar/projects/airpact5/AIRRUN/$YEAR
      endif
   endif

#> Need to include days per month snippet to get DAYf

     # last day of each month
       set last_day_noleap = ( 31  28  31  30  31  30  31  31  30  31  30  31 )
     # determine if it's leap year
       if ( ${YEAR} % 400 == 0 ) then
          set ifleap = Y
       else if ( ${YEAR} % 100 == 0 ) then
          set ifleap = N
       else if ( ${YEAR} % 4 == 0 ) then
          set ifleap = Y
       else
          set ifleap = N
       endif

       set DAYf = ${last_day_noleap[$MONTH]}
       if ( $MONTH == 02 && $ifleap == "Y" ) then
          set DAYf = 29
       endif


#> directory set-up ----------------------------------------------------


   set SCRIPTS = ${PBS_O_WORKDIR}/post/emis/smkreport
   set outdir = $AIRRUN/smkrpt_avg/$YEAR$MONTH

   mkdir -pv $outdir

   cd $SCRIPTS

#> Loop through all days in the month

set daily = 1 #First day of month

while ($daily <= $DAYf)

   if ( $daily < 10 ) then
      set DAY = 0${daily}
   else
      set DAY = $daily
   endif

   echo "Simplifying Tables for $YEAR$MONTH${DAY}"
   set AIROUT = $AIRRUN/$YEAR$MONTH${DAY}00

   set all_other = $AIROUT/EMISSION/anthro/output/all_other/all_other.rpt1.${YEAR}${MONTH}${DAY}.rpt
   set rwc_tpy =   $AIROUT/EMISSION/anthro/output/rwc_tpy_method/rwc_tpy_method.rpt1.${YEAR}${MONTH}${DAY}.rpt
   set points =    $AIROUT/EMISSION/anthro/output/point/point.rpt1.${YEAR}${MONTH}${DAY}.rpt
   set seca =      $AIROUT/EMISSION/anthro/output/seca/seca.rpt1.${YEAR}${MONTH}${DAY}.rpt
   set nonroad =   $AIROUT/EMISSION/anthro/output/nonroad_model/nonroad_model.rpt1.${YEAR}${MONTH}${DAY}.rpt
   set moves_rpd = $AIROUT/EMISSION/anthro/moves/report/rep_rateperdistance_${YEAR}${MONTH}${DAY}_AIRPACT_04km_cmaq_cb05_soa.rpt
   set moves_rpp = $AIROUT/EMISSION/anthro/moves/report/rep_rateperprofile_${YEAR}${MONTH}${DAY}_AIRPACT_04km_cmaq_cb05_soa.rpt
   set moves_rpv = $AIROUT/EMISSION/anthro/moves/report/rep_ratepervehicle_${YEAR}${MONTH}${DAY}_AIRPACT_04km_cmaq_cb05_soa.rpt


   #> file preparation ----------------------------------------------------

   foreach SECTOR ( moves_rpd moves_rpp moves_rpv ) #These reports are created by movesmrg
           set file_loc = `eval echo \$$SECTOR`

           tail -n +23 $file_loc | sed 's/.$//' > $SECTOR.txt
           tr -d " \t" < $SECTOR.txt > ${SECTOR}_${YEAR}${MONTH}${DAY}.csv
           rm -f $SECTOR.txt
   end

   foreach SECTOR ( all_other rwc_tpy points seca nonroad ) #These reports are created by smkreport
           set file_loc = `eval echo \$$SECTOR`

           tail -n +10 $file_loc > $SECTOR.txt
           tr -d " \t" < $SECTOR.txt > ${SECTOR}_${YEAR}${MONTH}${DAY}.csv
           rm -f $SECTOR.txt
   end

   @ daily +=1

end #while


#>  create final monthly average by sector 

echo "Calculating $YEAR$MONTH Monthly Average of Daily SMOKE Reports" 
Rscript smkreport_monthly_avg.R

rm -f *${YEAR}${MONTH}*.csv

smkreport_monthly_summary.py

echo "Moving Monthly Average Output Tables to $outdir"
mv *.csv ${outdir}/

ls -alh $outdir

exit
