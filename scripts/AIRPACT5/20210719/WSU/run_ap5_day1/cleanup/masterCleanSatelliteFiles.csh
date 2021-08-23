#!/bin/csh -f
#
#  usage examples:
#   
#       ./masterCleanSatelliteFiles.csh 
#       ./masterCleanSatelliteFiles.csh 20160517
#
#    If no input argument is provivded, the script will get the system
#    date (in GMT).  
#
#  This script cleanups satellite files that are from ten or more days ago.
#

  source ~airpact5/.tcshrc              # needed when running from crontab
                                             # (crontab starts in bash)
  setenv basedir  ~airpact5/AIRHOME/run_ap5_day1
  cd $basedir/cleanup

# get date info --------------------------------------------------------

  if ( $#argv == 1 ) then
     set currentday = $1
  else # if no command-line input, use system time in GMT
     set today     = `perl -e 'printf "%d\n", (gmtime(time()))[3]'` #today local time 
     set thismonth = `perl -e 'printf "%d\n", (gmtime(time()))[4]+1'`#format month (January = 0)
     set thisyear  = `perl -e 'printf "%d\n", (gmtime(time()))[5]+1900'`#format year
     if ( $thismonth < 10 ) set thismonth = 0${thismonth}
     if ( $today < 10 ) set today = 0${today}
     set currentday = ${thisyear}${thismonth}${today}
  endif
  set somedaysago  = `date -d "$currentday -10 days" '+%Y%m%d'`
  set YEARsda = `echo $somedaysago | cut -c1-4`

  echo "Now is" `date` 
  echo " removing files from" $somedaysago "and earlier"
  echo "----------------------------------------------------------------"


  set indir = /data/lar/projects/airpact5/saved/$YEARsda/satellite/IMAGES
  cd $indir

  set filelist = `ls *.dat`
  while ( $#filelist > 0 )
     set cfile = $filelist[1]
     set filedate = `echo $cfile | cut -c1-8`
     if ( $filedate <= $somedaysago ) then
        echo "removing" $cfile
        /bin/rm -f $cfile
     endif
     shift filelist
  end

  set filelist = `ls *_${YEARsda}_??_??.gif`
  while ( $#filelist > 0 )
     set cfile = $filelist[1]
     set datestr = `echo $cfile | cut -d '.' -f 1 | rev | cut -c1-10 | rev`
     set filedate = `echo $datestr | sed 's/\_//g'`
     if ( $filedate <= $somedaysago ) then
        echo "removing" $cfile
        /bin/rm -f $cfile
     endif
     shift filelist
  end

  set filelist = `ls *_${YEARsda}[0-9]?????.gif`  
  while ( $#filelist > 0 )
     set cfile = $filelist[1]
     set filedate = `echo $cfile | cut -d '.' -f 1 | rev | cut -c3-10 | rev`
     if ( $filedate <= $somedaysago ) then
        echo "removing" $cfile
        /bin/rm -f $cfile
     endif
     shift filelist
  end
