#!/bin/csh -f
#  Joe Vaughan February 17, 2010
#  Joe Vaughan updated Jan 11, 2013 
#  Convert a file of AQ sites from format received from Jen Hinds to
#  form needed for AIRNow site extraction.
#
#  Call as follows:
#  make_new_sites_file.csh filein fileout
#
#  The input file may need to be edited for junk in the first line.
#  This script starts with an input file in this format:
#
#	To get the '|' delimited input file, we test for '|' and if needed 
#	run tr to convert commas to |.
#
# inut used to look like:
#AQSID|NAME|AGENCY_ID|EPA_REGION|LAT|LONG|GMT_OFFSET|ABS_GMT_OFF
#000090402|Medicine Hat-Crescent Hts|AB1|CA|50.049200|-110.681400|-7|7.00
#000090502|Lethbridge|AB1|CA|49.716400|-112.800600|-7|7.00
#000100060|Trail Aquatic Centre|BC1|CA|49.095600|-117.697200|-8|8.00
#000100110|Kensington Park|BC2|CA|49.279400|-122.971100|-8|8.00

# and in 2017 input looks like:
#AQSID,SiteName,Lat,Lon,GMToffset
#000102001,Saturna,48.783300,-123.133300,8:00
#060631007,Chester BAM,40.301899,-121.235001,8:00
#060890004,Redding,40.549700,-122.379200,8:00
#
#
#  We want to get final file in format:
#AQSID,Latitude,Longitude,long_name
#blank-line
#000090402,50.049200,-110.681400,Medicine Hat-Crescent Hts
#000090502,49.716400,-112.800600,Lethbridge
#000096616,50.191700,-110.813900,03PAS

if ( $#argv == 2 ) then
   set INFILE = $1
   set OUTFILE = $2
else 
   echo 'Insufficient arguments!'
   echo "Usage: $0  infile outfile "
   exit (1)
endif

set pipe_cnt = `grep -c '|' $INFILE `
echo Pipe Count is initially ${pipe_cnt}

if ( ${pipe_cnt} == 0 ) then
	rm -f temp_file
	cat $INFILE | tr ',' '|' >! temp_file
	set pipe_cnt = `grep -c '|' temp_file `
	echo Pipe Count is now ${pipe_cnt}
	cp -f $INFILE ${INFILE}.orig
	cp -f temp_file $INFILE
endif

# Now convert ctrl-M to newlines and remove duplicate newlines.
cat $INFILE | tr '\r' '\n' | tr -s '\n' >! NEWINFILE

rm -f $OUTFILE
cat > $OUTFILE   <<EOF
AQSID,Latitude,Longitude,long_name
(blank line)
EOF

cat $INFILE | sed -e '1d' -e '/^$/d' | cut -d'|' -f1  > field1
cat $INFILE | sed -e '1d' -e '/^$/d' | cut -d'|' -f2  > field2
cat $INFILE | sed -e '1d' -e '/^$/d'| cut -d'|' -f3 > field3
cat $INFILE | sed -e '1d' -e '/^$/d'| cut -d'|' -f4 > field4
#cat $INFILE | sed -e '1d' -e '/^$/d' | cut -d'|' -f5  > field5
#cat $INFILE | sed -e '1d' -e '/^$/d' | cut -d'|' -f6  > field6
paste field1 field3 field4 field2 | tr '\t' ',' >>  $OUTFILE 

# rm -f  field*

wc $INFILE $OUTFILE
ls -lt $INFILE $OUTFILE

echo Check file sizes.  Blank lines were deleted, 
echo first line was deleted, and two header records added.
wc $INFILE
wc $OUTFILE
echo  Now show first ten lines of new file.
head $OUTFILE

echo  ++++++++++++++++++++++++++++++++++++++++++++++
echo  +++ Now link new file name to AIRNow_sites 
echo  +++ ln -f $OUTFILE AIRNow_sites           
echo  ++++++++++++++++++++++++++++++++++++++++++++++
exit(0)


