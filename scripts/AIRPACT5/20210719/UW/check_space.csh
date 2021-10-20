#!/bin/csh -f

##  check on the space used on rainier and warn Joe if necessary
##  Joe Vaughan at jvaughan@wsu.edu and josephvaughan9@gmail.com
##  October 31, 2012

# Check On Space

set USED  = `df -h . | tr -s ' ' '\t' | cut -f5 | tail -1 | tr -d '%'`

df -h . >! DISK_USE.log

echo SPACE ALREADY USED IS $USED %

if ( $USED  >  85 ) then
	echo SEND WARNING
	set mailadd = 'jvaughan@wsu.edu, josephvaughan9@gmail.com, mahshid.fard@wsu.edu, mahshidetesamifard@yahoo.com, v.walden@wsu.edu'
	mailx -s "Rainier disk use GT 85 percent " $mailadd < DISK_USE.log 	
	echo STATUS on mailx is $status
else
	echo NO WARNING
endif
 
exit(0)

