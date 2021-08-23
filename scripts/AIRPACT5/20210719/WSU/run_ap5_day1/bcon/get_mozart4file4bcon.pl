#!/usr/bin/perl

#
#  usage examples:
#   
#       get_mozart4file4bcon.pl 20120816
#       get_mozart4file4bcon.pl 
# 
#    If an input argument is provided, it is assumed to the 
#    the date in YYYYMMDD for which MOZART-4 files will be
#    downloaded. Otherwise, the script grabs the file for the 
#    current date (in GMT).
#
#    This script also removes the variable CO_ORIG_VMR from the MOZART-4
#    file.
#
#    This script is also run as a crontab job that runs daily.
#   
#
#  2015-11-13    Serena H. Chung      initial version
#

# get month, day, year for the current day -----------------------------

   $numArgs = $#ARGV + 1;

   if ( $numArgs == 0 ) { #if no input argument, get current date info
      ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime(time);
      $curyear = $year + 1900;
      $curmon  = ++$mon;
      $curday  = $mday;
      if (length($curmon ) == 1) { 
         $CURMON  = "0" . $curmon; 
      } else {
         $CURMON = $curmon;
      }
      if (length($curday ) == 1) { 
         $CURDAY  = "0" . $curday; 
      } else {
        $CURDAY = $curday;
      }
      $currentday = "$curyear"."$CURMON"."$CURDAY";
   } else { # use date specified by the input argument
      $arg = shift;
      print "input argument for $0 is $arg \n";
      $currentday = substr($arg,0,8);
      $curyear = substr($arg,0,4);
     #$CURMON  = substr($arg,4,2);
     #$CURDAY  = substr($arg,6,2);
   }

   print "running $0; currentday is $currentday\n";
   print "running $0; curyear is $curyear\n";

# "pre"conditions ------------------------------------------------------   
   $AIRHOME       = "~airpact5/AIRHOME";
   $AIRRUN        = "/data/lar/projects/airpact5/AIRRUN"."/"."${curyear}";
   $AIROUT        = "$AIRRUN"."/"."${currentday}"."00";
   $AIRLOGDIR     = "$AIROUT"."/"."LOGS";
   $BASE          = "~airpact5/AIRHOME/run_ap5_day1/bcon";
   $ENV{OUTDIR}   = "$AIROUT"."/BCON/input";

# directories and file setup -------------------------------------------
  system("mkdir -p $ENV{OUTDIR}");
  chdir ("$ENV{OUTDIR}");
  $mz4fileroot = "mz4geos_nwus_1h_"."$currentday"."_8z_f65";
  $mz4server = "http://www.acom.ucar.edu/acresp/AMADEUS/mz4_output/chemfcst";
  $file2get = "$mz4fileroot".".nc";
  $trimmedfile = "mz4geos_nwus_1h_"."$currentday".".nc";

# get the MOZART-4 file ------------------------------------------------
  print "use wget to get MOZART-4 file $mz4server/$file2get \n";
  system("wget -N -nv $mz4server/$file2get");

# remove variable CO_ORIG_VMR from the file ----------------------------
  print "remove variable CO_ORIG_VMR from MOZART-4 file \n";
  system("ncks -x -v  CO_ORIG_VMR_inst $file2get $trimmedfile");
  system("gzip $file2get");
   

