  # fix MCIP5.1 files
    if ( $RUN_FIX_MCIP == 'Y'  ) then
       echo ' '
       echo '-----------------------------------------'
       echo "run FIX_MCIP script"
       ./Fix_MCIP5.1/run_fix_MCIP5.1.csh __YYYYMMDD__  >&! $AIRLOGDIR/run_fix_MCIP5.1.log
       set exitstat = $status
       if ( $exitstat ) then
          echo "--- error n __basedir__/Fix_MCIP5.1/run_fix_MCIP5.1.csh "
          exit ( $exitstat )
       endif
       echo 'end script:' `date`; echo ' '
    endif # RUN_FIX_MCIP
  
