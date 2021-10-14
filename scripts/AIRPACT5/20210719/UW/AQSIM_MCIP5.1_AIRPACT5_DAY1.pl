#!/usr/local/bin/perl 

# AQSIM_MCIP5.1_AIRPACT5_DAY1.pl
#  N.B.  This script has been converted entirely to reference airpact5.  JKV 03/05/18e 

print "  #ARGV is $#ARGV  \n" ;
if ( $#ARGV == 0 ) { print " $0 called for WRF runs for $ARGV[0] \n" ; }
else { print " Call Syntax:  $0 YYYYMMDD00  \n" ;
       exit(1) ; }

# DO NOT USE FOR RESUBMITTAL OF JOBS AS THIS SCRIPT DOESN'T CONTROL INDIVIDUAL
# SWITCHES WITHIN THE AIRPACT SCRIPTS.

($Second, $Minute, $Hour, $DayOfMonth, $Month, $Year, $WeekDay, $DayOfYear, $IsDST) = localtime(time);
$RealMonth = $Month + 1;
print "AIRPACT5 START $RealMonth/$DayOfMonth/$Year $Hour:$Minute \n";

$TRUE = 1; # or more precisely, anything but 0 and "" (the empty string)
$FALSE = 0;
print " In Perl, TRUE is $TRUE and FALSE is $FALSE  \n";

$RUN_AIRPACT5_MCIP4dot3_37	  =  $TRUE; 

# print the argument
print "\n $0 called with argument $ARGV[0] \n";

### Run NEW AIRPACT5 stuff from WRF
if ($RUN_AIRPACT5_MCIP4dot3_37)  { 
print "\n\n\n *** Begin AIRPACT5 MCIP5.1_37 DAY1 from WRF *** \n\n";
$EMPACT =   "/home/rainier_empact";
$AIRPACT5 =  "$EMPACT/airpact5";
$AIRHOME =  "$AIRPACT5/AIRHOME";
$AIRRUN =   "$AIRPACT5/AIRRUN5";
system ("setenv AIRHOME $AIRHOME");
system ("setenv AIRRUN  $AIRRUN");
$mcip37 = "$AIRHOME/RUN/AIRPACT5_to_aeolus_MCIP5.1_37_DAY1.pl ".$ARGV[0]." > $AIRPACT5/AIRPACT5_MCIP5.1_37_DAY1_$ARGV[0].log 2> $AIRPACT5/AIRPACT5_MCIP5.1_37_DAY1_$ARGV[0].err & ";
print "$mcip37 \n";
$stat4 = system("$mcip37");
print "AIRPACT5 MCIP5.1_37 DAY1 background start status is: $stat4 \n"; }

# CHECK ON DISK SPACE
$checkspace = " ~/check_space.csh ";
print "$checkspace \n";
$space = system("$checkspace");
print "Check on Space Status is: $space \n"; 

exit (0); 


