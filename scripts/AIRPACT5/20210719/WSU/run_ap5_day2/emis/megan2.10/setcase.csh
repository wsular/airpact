# directory paths
  setenv MGNHOME ~airpact5/AIRHOME/build/MEGAN2.10
  setenv MGNEXE $MGNHOME
  setenv MGNINP /data/lar/projects/airpact5/input/megan2.10/ncf
  setenv MGNINT /data/lar/projects/airpact5/input/megan2.10/int
  setenv MGNOUT $AIROUT/EMISSION/megan2.10
#
  setenv GRIDDESC $AIRHOME/run_ap5_day2/emis/megan2.10/GRIDDESC
  setenv GDNAM3D AIRPACT_04km


  if ( ! -d $MGNOUT ) mkdir -p $MGNOUT
