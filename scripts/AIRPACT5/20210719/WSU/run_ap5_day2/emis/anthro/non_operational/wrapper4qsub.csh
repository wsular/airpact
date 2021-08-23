#!/bin/csh -f

# Serena H. Chung 2016-03-24


#> "control" parameters
   set firstday      = 20160101
   set lastday       = 20160131 

   @ icount = 0
   @ nperset = 3  # i.e., run 3 in parallel at a time

#> loop by day
   set currentday = $firstday
   while ( $currentday <=  $lastday )
      @ icount ++
      @ irem = $icount % $nperset

     if ( $icount <= $nperset ) then
        set qsubreturn = `qsub -V -v currentday=$currentday -N ap5anthro${currentday} qsub4anthroemis.csh`
     else
        set qsubreturn = `qsub -V -W depend=afterok:${runidsaved} -v currentday=$currentday -N ap5anthro${currentday} qsub4anthroemis.csh`
     endif
     set runid = `echo $qsubreturn | cut -d "." -f 1`
     echo $currentday $runid
     if ( $irem == 0 )  set runidsaved = $runid

     # increment to the next day
       set nextday = `date -d "$currentday 1 days" '+%Y%m%d'`
       set currentday = $nextday
   end # while currentday


