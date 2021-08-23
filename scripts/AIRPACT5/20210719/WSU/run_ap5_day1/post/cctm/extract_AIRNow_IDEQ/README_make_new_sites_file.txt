README describes making new sites file from file sent by Jen Hinds.
	JKV June 10, 2016

Received file from Jen.
	aqsid2016ap5_new.dat.gz

Old file that is in use as of 20160610 was:
lrwxrwxrwx 1 airpact5 airpact4   27 Apr 14 22:53 aqsid.csv -> mon_loc_ap4_asof-070215.csv
-rw-r--r-- 1 airpact5 airpact4  10K Apr 14 22:53 mon_loc_ap4_asof-070215.csv

Unzipped it:
	gunzip aqsid2016ap5_new.dat.gz
	to get aqsid2016ap5_new.dat

NOTE:  This new file contains the non_AIRNow site at Dan Jaffe's Mt Bachelor Observatory.
	123456789,Mt Bachelor non-AIRNow,43.979000,-121.678000

head command shows format of new file as:
AQSID,SiteName,Lat,Lon
000100060,Trail Aquatic Centre,49.095600,-117.697200
000100110,Kensington Park,49.279400,-122.971100
000100111,Rocky Point Park,49.280830,-122.849170
000100118,Kitsilano,49.261670,-123.163330
000100119,Burnaby South,49.215280,-122.985560
000100125,North Delta,49.158330,-122.901670
000100127,Surrey East,49.132780,-122.694170
000100128,Richmond South,49.141390,-123.108330
000100132,Mahon Park,49.323891,-123.083611

The format desired looks like:
AQSID,LAT,LONG,NAME
File mon_loc_ap4_asof-0215.csv, from Jen Hinds 021115, was rerun for AP4 from 02__15.  JKV
000100060,49.095600,-117.697200,Trail Aquatic Centre
000100110,49.279400,-122.971100,Kensington Park
000100111,49.280830,-122.849170,Rocky Point Park
000100118,49.261670,-123.163330,Kitsilano
000100119,49.215280,-122.985560,Burnaby South
000100125,49.158330,-122.901670,North Delta
000100127,49.132780,-122.694170,Surrey East
000100128,49.141390,-123.108330,Richmond South

Keep first two lines of current file:
	head -2 mon_loc_ap4_asof-070215.csv >! first_2_lines.txt

Edit first line out of new file.
	cp aqsid2016ap5_new.dat aqsid2016ap5_new.wrk
	vi aqsid2016ap5_new.wrk ( and delete the first line and re-write it)

Cut fields out of work file:
cut -d',' -f1  aqsid2016ap5_new.wrk >! AQSID  
cut -d',' -f2  aqsid2016ap5_new.wrk >! NAME
cut -d',' -f3  aqsid2016ap5_new.wrk >! LAT
cut -d',' -f4  aqsid2016ap5_new.wrk >! LONG   

Paste back in correct order:
	paste -d',' AQSID LAT LONG NAME >! NEW

Edit the two-line header to reflect the update date, etc.
	vi first_2_lines.txt

Catenate the new first_2_lines.txt abd the NEW column arrangement.

cat first_2_lines.txt NEW >! mon_loc_ap5_asof-20160610.csv 

Change the symlink pointing to the current file.

ln -sf mon_loc_ap5_asof-20160610.csv aqsid.csv

Clean up unneeded files:
rm -f aqsid2016ap5_new.dat aqsid2016ap5_new.wrk AQSID LAT LONG NAME NEW first_2_lines.txt

end of README


