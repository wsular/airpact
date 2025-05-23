#!/bin/csh -fx
# $Id: smk_mkdir,v 1.4 2006/10/05 13:23:31 bbaek Exp $

   ### Set umask to be group writable, world read and execute
   umask 2

   ### Make input and output director(ies) #######
   if ( -e $SMKDAT ) then
       if( ! -e $INVDIR/area ) mkdir -p $INVDIR/area
       if( ! -e $INVDIR/nonroad ) mkdir -p $INVDIR/nonroad
       if( ! -e $INVDIR/biog ) mkdir -p $INVDIR/biog
       if( ! -e $INVDIR/point ) mkdir -p $INVDIR/point
       if( ! -e $INVDIR/mobile ) mkdir -p $INVDIR/mobile
       if( ! -e $INVDIR/other ) mkdir -p $INVDIR/other
       if( ! -e $GE_DAT ) mkdir -p $GE_DAT
       if( ! -e $INVOPD ) mkdir -p $INVOPD
#                  $A_OUT $B_OUT $M_OUT \ #taken out of wfire version JKV 08/17/10.
#       if( ! -e $A_OUT )  mkdir -p $A_OUT
#       if( ! -e $B_OUT )  mkdir -p $B_OUT
#       if( ! -e $M_OUT )  mkdir -p $M_OUT
       if( ! -e $P_OUT )  mkdir -p $P_OUT
       if( ! -e $SCENARIO ) mkdir -p $SCENARIO
       if( ! -e $STATIC ) mkdir -p $STATIC
       if( ! -e $OUTPUT ) mkdir -p $OUTPUT
       if( ! -e $SMK_TMPDIR ) mkdir -p $SMK_TMPDIR  
       if( ! -e $SMK_METPATH ) mkdir -p $SMK_METPATH
       if( ! -e $SMK_SPDPATH ) mkdir -p $SMK_SPDPATH
       if( ! -e $SMK_M6PATH  ) mkdir -p $SMK_M6PATH
       if( ! -e $SMK_EMISPATH ) mkdir -p $SMK_EMISPATH
       if( ! -e $LOGS   ) mkdir -p $LOGS  
       if( ! -e $BASDIR ) mkdir -p $BASDIR
       if( ! -e $REPSCEN ) mkdir -p $REPSCEN
       if( ! -e $REPSTAT ) mkdir -p $REPSTAT
       if( ! -e $REPSTAT ) mkdir -p $REPSTAT
       if( ! -e $REPORTS/$ASCEN/scenario ) mkdir -p $REPORTS/$ASCEN/scenario
       if( ! -e $REPORTS/$ASCEN/static )  mkdir -p $REPORTS/$ASCEN/static
       if( ! -e $REPORTS/$BSCEN/scenario ) mkdir -p $REPORTS/$BSCEN/scenario
       if( ! -e $REPORTS/$MSCEN/scenario ) mkdir -p $REPORTS/$MSCEN/scenario
       if( ! -e $REPORTS/$MSCEN/static )  mkdir -p $REPORTS/$MSCEN/static
       if( ! -e $REPORTS/$PSCEN/scenario ) mkdir -p $REPORTS/$PSCEN/scenario
       if( ! -e $REPORTS/$PSCEN/static )  mkdir -p $REPORTS/$PSCEN/static
   else
       echo "ERROR: The SMOKE data directory does not exist!"
       echo "       Please check to make sure that the following"
       echo "       path is valid:"
       echo "       $SMKDAT"
       exit( 1 )
   endif

   ### Check permissions on output directories ####
   set user = `whoami`
#                  $A_OUT $B_OUT $M_OUT \ #taken out of wfire version JKV 08/17/10.
   foreach dir ( $INVDIR $INVDIR/area $INVDIR/nonroad $INVDIR/biog $INVDIR/mobile $INVDIR/point \
                 $INVDIR/other $INVOPD $SCENARIO $STATIC \
                 $P_OUT $OUTPUT $BASDIR $REPORTS/$ASCEN $REPORTS/$BSCEN \
                 $REPORTS/$MSCEN $REPORTS/$PSCEN $REPSCEN $REPSTAT $SMK_TMPDIR $SMK_METPATH \
                 $SMK_SPDPATH $SMK_M6PATH $SMK_EMISPATH )

       set line   = ( `/bin/ls -ld $dir` )
       set owner  = $line[3]
       set check  = ( `echo $line | grep $user` )
       if ( $status == 0 ) then

           set permis = ( `echo $line | grep drwxrw` )
           if( $status != 0 ) then
               chmod ug+w $dir
           endif

       else

           set permis = ( `echo $line | grep drwxrw` )
           if ( $status != 0 ) then
               echo "NOTE: Do not have write permission for directory"
               echo "      $dir"
               echo "      Check with user $owner for write permissions"
           endif

       endif

   end

   ## Check length of directory names with constrained lengths
   if ( $?SMK_M6PATH ) then
      set cnt = `echo $SMK_M6PATH | wc -c`
      @ cnt = $cnt - 1
      if ( $cnt > 200 ) then
         echo "NOTE: your SMK_M6PATH is constrained to 200 characters"
         echo "      but yours is $cnt characters."
         echo "      If you are going to run MOBILE6, then you"
         echo "      must reselect SMK_HOME and ESCEN values"
         echo "      to ensure that SMK_M6PATH is small enough."
      endif
   endif

   cd $ASSIGNS
