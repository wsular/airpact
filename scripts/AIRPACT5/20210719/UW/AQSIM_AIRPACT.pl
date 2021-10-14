#!/usr/local/bin/perl 

print "  #ARGV is $#ARGV  \n" ;
if ( $#ARGV == 0 ) { print " $0 called for WRF runs for $ARGV[0] \n" ; }
else { print " Call Syntax:  $0 YYYYMMDD00  \n" ;
       exit(1) ; }

# AQSIM_AIRPACT5_wMCIP5.1.pl for running AIRPACT5  06/17/18 JKV 
# This script is called by UW WRF operations

# DO NOT USE FOR RESUBMITTAL OF JOBS AS THIS SCRIPT DOESN'T CONTROL INDIVIDUAL
# SWITCHES WITHIN THE AIRPACT SCRIPTS.

($Second, $Minute, $Hour, $DayOfMonth, $Month, $Year, $WeekDay, $DayOfYear, $IsDST) = localtime(time);
$RealMonth = $Month + 1;
print "AIRPACT5 START $RealMonth/$DayOfMonth/$Year $Hour:$Minute \n";

$TRUE = 1; # or more precisely, anything but 0 and "" (the empty string)
$FALSE = 0;
print " In Perl, TRUE is $TRUE and FALSE is $FALSE  \n";

$RUN_AIRPACT5_MCIP37	  =  $TRUE; 
$RUN_URBANOVA_MCIP37	  =  $FALSE; 

$EMPACT = "/home/rainier_empact" ;
# print the argument
print "\n ~/$0 called with argument $ARGV[0] \n";

### Run NEW AIRPACT5 from MCIP5.1 stuff, from WRF, 050918 JKV
if ($RUN_AIRPACT5_MCIP37)  { 
$AIRPACT5="$EMPACT/airpact5";
$AIRRUN="$AIRPACT5/AIRRUN5";

if ( -e "$AIRRUN/SUBMITTED/$ARGV[0]" ) {
print " SUBMITTED FILE FOUND FOR $ARGV[0] \n";
print " DO NOT RUN  AGAIN for $ARGV[0] \n";
        }
else    {
print " RUN  for $ARGV[0] \n";

$day1 = "./AQSIM_MCIP5.1_AIRPACT5_DAY1.pl ".$ARGV[0]." > $AIRPACT5/AIRPACT5_MCIP37_$ARGV[0]_DAY1.log 2> $AIRPACT5/AIRPACT5_MCIP37_$ARGV[0]_DAY1.err & ";
print "$day1 \n";
$stat1 = system("$day1 ");
print "AIRPACT5 MCIPv5.1 background start status is: $stat1 \n"; 

$day2 = "./AQSIM_MCIP5.1_AIRPACT5_DAY2.pl ".$ARGV[0]." > $AIRPACT5/AIRPACT5_MCIP37_$ARGV[0]_DAY2.log 2> $AIRPACT5/AIRPACT5_MCIP37_$ARGV[0]_DAY2.err & ";
print "$day2 \n";
$stat2 = system("$day2 ");
print "AIRPACT5 MCIPv5.1 background start status is: $stat2 \n"; 

print " then touch file $AIRRUN/SUBMITTED/$ARGV[0] \n";
system ("touch $AIRRUN/SUBMITTED/$ARGV[0]"); }
                                                 }

### Run URBANOVA for 1.33-km Spokane domain
if ($RUN_URBANOVA_MCIP37)  {
print "\n\n\n *** Begin URBANOVA_MCIP from WRF *** \n\n";
$EMPACT =   "/home/rainier_empact" ;
$URBANOVA = "$EMPACT/urbanova" ;
$AIRHOME =  "$EMPACT/urbanova/AIRHOME" ;
$AIRRUN =   "$EMPACT/urbanova/AIRRUN" ;
system ("setenv AIRHOME $AIRHOME");
system ("setenv AIRRUN  $AIRRUN");

if ( -e "$AIRRUN/SUBMITTED/$ARGV[0]" ) {
print " SUBMITTED FILE FOUND FOR $ARGV[0] \n";
print " DO NOT RUN  AGAIN for $ARGV[0] \n";
        }
else    {
print " RUN  for $ARGV[0] \n";

$urbanova = "$AIRHOME/RUN/Urbanova_to_aeolus_MCIP37.pl ".$ARGV[0]." > $URBANOVA/URBANOVA_$ARGV[0].log 2> $URBANOVA/URBANOVA_$ARGV[0].err & ";
print "$urbanova \n";
$stat5 = system("$urbanova");
print "URBANOVA background start status is: $stat5 \n"; 

print " then touch file $AIRRUN/SUBMITTED/$ARGV[0] \n";
system ("touch $AIRRUN/SUBMITTED/$ARGV[0]"); }
                                                 }

# CHECK ON DISK SPACE
$checkspace = " ~/check_space.csh ";
print "\n\n $checkspace \n";
$space = system("$checkspace");
#print "Check on Space Status is: $space \n"; 

exit (0); 


