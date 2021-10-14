#!/usr/local/bin/perl 

#  AIRPACT5_to_aeolus_MCIP5.1_37_DAY1.pl YYYYMMDD00

        $TRUE = 1; # or more precisely, anything but 0 and "" (the empty string)
        $FALSE = 0; # Comment out the second line of the group to have the process run.

        $SLEEP_SECS   = 800 ;

        $RUN_MCIP37   = $TRUE;
# 	$RUN_MCIP37   = $FALSE;

	$RUN_CCTM_AT_WSU = $TRUE;
# 	$RUN_CCTM_AT_WSU = $FALSE;

	$RUN_XMAIL       = $TRUE;
 	$RUN_XMAIL       = $FALSE;

	$RUN_TSTAMP      = $TRUE;
# 	$RUN_TSTAMP     = $FALSE;

###### Perl begin #######
###   Required Perl Modules
require "timelocal.pl";
require "getopts.pl";

###   Define some initialization variables ###
$iam = `whoami`; #get user id
chop ($iam);
($sec,$min,$hr,$dayOmon,$mon,$yr,$dayOwk,$dayOyr,$IsDST)=localtime(time);
$mon++; # get real month in 1-12

###   DEFINE DIRECTORY LOCATIONS and GLOBAL SUPPORT
$EMPACT =   "/home/disk/rainier_empact";
$AIRPACT =  "$EMPACT/airpact5";
$AIRHOME =  "$AIRPACT/AIRHOME";
$AIRRUN5 =  "$AIRPACT/AIRRUN5";
$AIRRUN =  "$AIRRUN5";
system ("setenv AIRHOME $AIRHOME"); 
system ("setenv AIRRUN  $AIRRUN"); 
$WRFRT =    "/home/rainier_mm5rt";
$mm5rt_data = "$WRFRT/data";
$MCIP =     "${AIRHOME}/mcip";

# LIST for two-digit strings for useful numbers. 
@DIGITS=( 0 .. 99 );
for ($i = 0; $i<= $#DIGITS ; $i += 1 ) {
   if( length($DIGITS[$i]) == 1 ) { $DIGITS[$i] = "0" . $DIGITS[$i]; }
}
# LIST for three-digit strings for day numbers. 
@DAYOYEAR=( 1 .. 366 );
for ($i = 0; $i<= $#DAYOYEAR ; $i += 1 ) {
   if( length($DAYOYEAR[$i]) == 1 ) { $DAYOYEAR[$i] = "00" . $DAYOYEAR[$i]; }
   if( length($DAYOYEAR[$i]) == 2 ) { $DAYOYEAR[$i] = "0" . $DAYOYEAR[$i]; }
}

#### Begin AIRPACT script #####
print " \n ********************************************** \n";
print " * AIRPACT CMAQ 4-km script: $0 \n";
print " * Script execute by: $iam \n";
print " * Current local time: ".`date`;
print " \n ********************************************** \n";

################ WRF HOUR RANGE, USER INPUTS BEGIN ####################
$FHST = 7 ; # first forecast hour required
$FHREQ = 33; # last forecast hour required # JKV changed to 72 01/19/12 
$HRS = $FHREQ - $FHST + 1; # Hours required from mm5
################ WRF HOUR RANGE, USER INPUTS END ######################

# Define some root locations
# EITHER (default) LOCATE MOST RECENT COMPLETE WRFRT RUN FOR D3 DOMAIN
#  LOCATE (FULLY) SPECIFIED WRFRT RUN FOR D2 DOMAIN
   print "Found an argument $ARGV[0], as specifily requested WRF run. \n";
   $wrfrun = "$ARGV[0]" ; 
   $YEAR = substr($wrfrun,0,4);
   print "YEAR   is $YEAR   \n";
   $MONTH   = substr($wrfrun,4,2);
   print "MONTH   is $MONTH   \n";
   $DAY   = substr($wrfrun,6,2);
   print "DAY   is $DAY   \n";

print "wrfrun is $wrfrun \n";

##### CHECK IN WRFRT DIRECTORY FOR COMPETE WRF D3 RUN
if ( $RUN_MCIP37 ) { print "\n!! RUN MCIP \n";

print "Checking for required 4-km WRF data in $mm5rt_data/${wrfrun} \n";
chdir ("$mm5rt_data/${wrfrun}") || die " fail on chdir to ${wrfrun}  \n"; 

@mmouts = glob("*out_d3*00");
print " First mm5 data file is $mmouts[0] \n";
print " Last  mm5 data file is $mmouts[$#mmouts] \n";
$st_targ = "f".$DIGITS[$FHST]  ; print " start target is $st_targ \n"; 
$end_targ = "f".$DIGITS[$FHREQ]; print " end target is $end_targ \n";
$START = $FALSE; $END = $FALSE;
for ( $i = 0 ; $i <= $#mmouts ; $i++ ) {
   if ( "$mmouts[$i]" =~ m/$st_targ/ ) { print " start found: $mmouts[$i]\n"; $START = $TRUE; }
   if ( "$mmouts[$i]" =~ m/$end_targ/ ) { print " end found: $mmouts[$i] \n"; $END = $TRUE; } 
}
if ( !($START && $END) && $RUN_MCIP) { print "\n ERROR Incomplete WRF input for $wrfrun\n"; exit(2);}
}

print "LOCATED $wrfrun FOR PROCESSING \n";
$RUNROOT = "$AIRRUN/$wrfrun" ; print " RUNROOT is $RUNROOT \n"; 
system ("setenv RUNROOT $RUNROOT");
mkdir ("$RUNROOT",0777) || print  " WARNING on mkdir for $RUNROOT \n";
$LOGDIR = "$RUNROOT/LOGS" ; print " LOGDIR is $LOGDIR \n";
system ("setenv LOGDIR $LOGDIR"); 
mkdir ("$LOGDIR",0777) || print " WARNING on mkdir for $LOGDIR \n";

$rundate = substr($wrfrun,0,10);

$exitstat = 0;

#************************************************* 
if ( $RUN_MCIP37 ) { print "\n!! RUN MCIP5.1 37 DAY1 \n"; 
   print "\n\n *** Begin MCIP37 processing ***  ".`date`;
   unlink("$MCIP/AP5_mcip5.1_37_DAY1.log","$MCIP/AP5_mcip5.1_37_DAY1.err");
   print "\n!! SUBMIT MCIP37 FOR AP5 and SCP MCIP37 to AEOLUS\n";
   $sysexec="$MCIP/AP5_mcip5.1_37_DAY1.csh $rundate > ${MCIP}/AP5_mcip5.1_37_DAY1.log 2> ${MCIP}/AP5_mcip5.1_37_DAY1.err"; 
   print "$sysexec \n";
   $mcipstat = system("$sysexec");
   print " *** MCIP 4-km and SCP status: $mcipstat ***  ".`date`;
}

if ($RUN_CCTM_AT_WSU) {  print "\n Submit AIRPACT-5 DAY1 script on aeolus via ssh \n";
   unlink("$LOGDIR/AP5_DAY1_ssh_aeolus.log","$LOGDIR/AP5_DAY1_ssh_aeolus.err");
   $sysexec = 
   "$AIRHOME/RUN/AP5_DAY1_ssh_aeolus.csh ${YEAR}${MONTH}${DAY} > ${LOGDIR}/AP5_DAY1_ssh_aeolus.log 2> ${LOGDIR}/AP5_DAY1_ssh_aeolus.err";
   print "$sysexec \n";
   $AP5_DAY1_ssh_script_stat  = system("$sysexec");
   print "  *** status  for AP5_DAY1_ssh_aeolus.csh is $AP5_DAY1_ssh_script_stat *** \n ";
   $exitstat = $exitstat + $AP5_DAY1_ssh_script_stat ;  }
 
# *** Send out status email ***
if ($RUN_XMAIL) { print "\n!! RUN XMAIL \n"; 
  $mailadd = 'jvaughan@wsu.edu';
  $mailer = mailx;
  $sysexec = "$mailer -s \"AIRPACT5 DAY1 script submittal status: $AP5_DAY1_ssh_script_stat\" $mailadd < ${LOGDIR}/AP5_DAY1_ssh_aeolus.log " ;
  print " $sysexec \n";
  $mailstat = system ("$sysexec");
  print " $ Status on mail of log is $mailstat \n";
}

if ($RUN_TSTAMP) { print "\n!! RUN TSTAMP \n"; 
      $sysexec = " touch $AIRPACT/DONE_TIMES/${wrfrun}";
      print "Command is: $sysexec \n";
      $tsstat = system (" $sysexec ");
      print "Status for touch for TIME_DONE: $tsstat \n";
      $sysexec2 = " date >> $AIRPACT/DONE_TIMES/${wrfrun}";
      print "Command is: $sysexec2 \n";
      $tsstat2 = system (" $sysexec2 ");
      print "Status for date for TIME_DONE: $tsstat2 \n";
      $exitstat = $exitstat + $tsstat + $tsstat2 ;
      print " *** End Time Stamp *** \n";
}

print " ****************************************** \n";
print " * $0 Finished AIRPACT-5` Run \n";
print " * Current time: ".`date`;
$iam = `whoami`; #get user id
print " * Script execute by: $iam \n";
print " * Exit status: $exitstat \n";
print " ****************************************** \n";

exit ($exitstat);

