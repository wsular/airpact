#!/bin/csh -f

  setenv SRG_COUNTRY "USA"
  setenv PROMPTFLAG N          # Y prompts for input
  setenv SRG_LIST '1000'       # This surrogate is read for grid cell locations only (not fractions).  Needs both USA and Canada in the file.
  setenv TVARNAME  TEMP2       # chosen temperature variable name




  setenv PD_TEMP_INCREMENT 10
  setenv PV_TEMP_INCREMENT 10
  setenv PP_TEMP_INCREMENT 20
 #setenv TEMP_BUFFER_BIN 0       # changed based on Wei's script  # vikram 6/9/2015
  setenv TEMP_BUFFER_BIN 1       # shc 2015-11-23 to try to get rid of the following error:
                                 # "Grid cell temperature     20.00  out of range of minimum emission factor data     20.00"

  # changes below based on Wei's script at /data/airpact4/EI_UPDATE/MOVES/moves/subsys/smoke/scripts/run/airpact4/run_met4moves.MOVES.airpact4.csh
  # vikram 6/7/15

  # Define the modeling period
  #setenv STDATE ${EPI_STDATE}          # Starting date in Julian
  #set date = ${STDATE}
  #@ date = $date + ${EPI_NDAY}
  #setenv ENDATE $date                # Ending date in Julian

  #setenv ENDATE `$SCRIPTS/run/add2julidate.py ${STDATE} ${EPI_NDAY}`
  #echo $ENDATE
  
  #setenv STTIME 080000
  #setenv ENDTIME 080000
  # 


  $SMK_BIN/met4moves

  # remove temporary output file
  rm -f TMP_COMBINED_SRG.txt
