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
#AQSID|NAME|AGENCY_ID|EPA_REGION|LAT|LONG|GMT_OFFSET|ABS_GMT_OFF
#000090402|Medicine Hat-Crescent Hts|AB1|CA|50.049200|-110.681400|-7|7.00
#000090502|Lethbridge|AB1|CA|49.716400|-112.800600|-7|7.00
#000100060|Trail Aquatic Centre|BC1|CA|49.095600|-117.697200|-8|8.00
#000100110|Kensington Park|BC2|CA|49.279400|-122.971100|-8|8.00

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

# convert the ctrl-M from the text file into newlines
cat $INFILE | sed -f ~airpact/ctrlmfix/sedscrpt_cM_t_nl | grep -iv 'Proxy' >! INFILE2

cmp $INFILE INFILE2
echo status for compare of $INFILE and INFILE2 is $status

rm -f $OUTFILE
cat > $OUTFILE   <<EOF
AQSID,Latitude,Longitude,long_name
(blank line)
EOF

cat INFILE2 | sed -e '1d' -e '/^$/d' | cut -d'|' -f1  > field1
cat INFILE2 | sed -e '1d' -e '/^$/d' | cut -d'|' -f2  > field2
#cat INFILE2 | sed -e '1d' -e '/^$/d'| cut -d'|' -f3 > field3
#cat INFILE2 | sed -e '1d' -e '/^$/d'| cut -d'|' -f4 > field4
cat INFILE2 | sed -e '1d' -e '/^$/d' | cut -d'|' -f5  > field5
cat INFILE2 | sed -e '1d' -e '/^$/d' | cut -d'|' -f6  > field6
paste field1 field5 field6 field2 | tr '\t' ',' >>  $OUTFILE 

rm -f INFILE2 field*

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


