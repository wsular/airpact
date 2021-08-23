#!/bin/tcsh -f 
cd ~/AIRRUN/2020/${1}00/POST/CCTM
pwd
ls -lt aqsid.csv
set cnt = `wc -l aqsid.csv | cut -f1 -d" "`
echo cnt $cnt

set tail_cnt = `expr $cnt - 2 `
echo tail_cnt $tail_cnt

tail -$tail_cnt aqsid.csv | sed 's/ /_/g' | tr ',' '\t' > aqsid-2.csv 
ls -lt $cwd/aqsid-2.csv

exit()
