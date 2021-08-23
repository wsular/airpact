#!/bin/csh -f
if ( $#argv  != 1 ) then
echo "text_JKV_w_argtxt.csh 'text to send'"
exit
endif

echo "$1 " | mail -s "test txt to smartphone" -b jvaughan@wsu.edu 5093369756@txt.att.net

echo Status on mail call is $status

exit(0)

