#!/bin/tcsh -f
# this is a template for the cron job to ftp 24-hr-avg PM2.5 gif file to IDEQ 

echo Cron job to run ftp to IDEQ is cronjob4ftp_to_IDEQ.csh

cd /home/airpact5/AIRHOME/run_ap5_day1/plot/ftp_to_IDEQ

echo   /data/lar/projects/airpact5/AIRRUN/2019/2019033100/IMAGES/aconc/ave24hr/gif/airpact5_24hrPM25_forIDEQ_2019033023.gif
ls -lt /data/lar/projects/airpact5/AIRRUN/2019/2019033100/IMAGES/aconc/ave24hr/gif/airpact5_24hrPM25_forIDEQ_2019033023.gif
ln -fs /data/lar/projects/airpact5/AIRRUN/2019/2019033100/IMAGES/aconc/ave24hr/gif/airpact5_24hrPM25_forIDEQ_2019033023.gif .
ls -lt *
set HOST = 164.165.67.237 
set USER = airpact
set PASSWD = @1rP@ct

/usr/bin/ftp -pv $HOST <<END_SCRIPT
ls
pwd
delete airpact5_24hrPM25_forIDEQ_2019033023.gif
put    airpact5_24hrPM25_forIDEQ_2019033023.gif
ls 
quit
END_SCRIPT
set fstat = $status
echo Status exiting ftp is $fstat 

rm -f airpact5_24hrPM25_forIDEQ_2019033023.gif

echo "ftp status $fstat for airpact5_24hrPM25_forIDEQ_2019033023.gif" \
 | mail -s "ftp status $fstat for day1 24-hr PM2.5 to IDEQ" -b Sara.Strachan@deq.idaho.gov jvaughan@wsu.edu
echo Status on mail call is $status

exit(0)

