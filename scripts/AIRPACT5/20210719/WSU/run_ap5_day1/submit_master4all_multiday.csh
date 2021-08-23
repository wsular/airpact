#!/bin/csh -f

# Serena H. Chung 2016-01-28 - untested

#> "control" parameters
   set firstday      = 20160314
   set lastday       = 20160322 
  #set runid_cctm    = 106935     #if waiting for job already in queue

#> loop by day
   set currentday = $firstday
   while ( $currentday <=  $lastday )
      # run the script that will submit all components of simulation
        echo `date` "run master4all.csh for" $currentday
        if ( $?runid_cctm ) then # if waiting on a job to finish
           source ./master4all.csh $currentday $runid_cctm
        else 
           source ./master4all.csh $currentday 
        endif
      # increment to the next day
        set nextday = `date -d "$currentday 1 days" '+%Y%m%d'`
        set currentday = $nextday
   end # while currentday


