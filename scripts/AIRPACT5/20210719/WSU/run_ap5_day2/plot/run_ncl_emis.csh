#!/bin/csh -f

# example of using this script:
# 
#   > ./run_ncl_emis.csh 20151220 24
#
#    where 20101104 denotes forecast start time of 8 GMT on Nov 5, 2010
#               24 denotes 24 hours of forecast
#
#
# Farren Herron-Thorpe  2012-04-20
# Serena H. Chung       2012-05-07
# Serena H. Chung       2015-09-10 updated for CMAQv5.0. CB05 and AERO6 species
# Farren Herron-Thorpe  2015-12-23 updated WoodSmoke plotting code
#
# This C shell script creates 25 hourly gif files of gaseous concentrations based on AIRPACT-5's
# CMAQ output files. For each hour, the script 1) creates an NCL script, 2) runs the NCL script
# to create the figure in postcript format, and 3) converts the postscript file to a gif file.

#> switch for various subcomponents and options ------------------------

  # plot options
    setenv ADD_COLORBAR 	N
    setenv ADD_BORDERS 	        N
    setenv IMAGEFILL	RasterFill#RasterFill AreaFill or CellFill
    set imgd=120 #Image resolution
  # species to plot
    setenv PLOT_PM25	        Y
    setenv PLOT_NOx 	        Y
    setenv PLOT_HCHO 	        Y
    setenv PLOT_ISOPRENE 	Y
    setenv PLOT_NH3 	        Y
    setenv PLOT_CO 		Y
    setenv PLOT_VOCs 	        Y
    setenv PLOT_SO2		Y
    setenv PLOT_WSPM25		Y        #fht 2015-12-23
  # crop and shift how much?
    set cx=863
    set cy=751
    set sx=64
    set sy=265

#> initialize exit status ----------------------------------------------
   set exitstat = 0

#> check argument & set date strings  ----------------------------------

   if ( $#argv == 2 ) then
      setenv YEAR `echo $1 | cut -c1-4`
      setenv MONTH `echo $1 | cut -c5-6`
      setenv DAY `echo $1 | cut -c7-8`
      setenv NHR $2
   else
      echo 'invalid argument. '
      echo "usage $0 <yyyymmdd> 24"
      set exitstat = 1
      exit ( $exitstat )
   endif
   set yyyymmdd = ${YEAR}${MONTH}${DAY}
  #> determine day of the year
     set DOYstring = `juldate $MONTH $DAY $YEAR | cut -d',' -f 2`
     set DOY       = `echo $DOYstring | cut -c5-7`
     set YEARDOY   = $YEAR$DOY

#> during testing 

   if ( ! $?PBS_O_WORKDIR ) then
      set PBS_O_WORKDIR = ~airpact5/AIRHOME/run_ap5_day2
      if ( ! $?AIRHOME        ) set AIRHOME = ~airpact5/AIRHOME
      if ( ! $?AIRRUN ) then
         set AIRRUN  = /data//lar/projects/airpact5/AIRRUN/$YEAR
      endif
      if ( ! $?AIROUT         ) set AIROUT = $AIRRUN/${currentday}00
      if ( ! $?AIRLOGDIR      ) set AIRLOGDIR = $AIROUT/LOGS
      if ( ! $?MCIPDIR        ) then
         if ( -e $AIROUT/MCIP/METCRO2D ) then
            set MCIPDIR   = $AIROUT/MCIP
         else
            set MCIPDIR   = /data/airpact4/AIRRUN/${currentday}00/MCIP
         endif
      endif
      set NHR = $2
   endif

#> directory set-up ----------------------------------------------------

   set indir      = $AIROUT
   set mcip       = $MCIPDIR
   set NCLSCRIPTS = ${PBS_O_WORKDIR}/plot
   set PSDIR      = $indir/IMAGES/emis/ps
   mkdir -p $PSDIR


# > create and run ncl script hour by hour ----------------------------

    set ihour  = 0 
    @ NHRm1 = $NHR - 1  
    while ( $ihour <= ${NHR}  )

       if ( $ihour < 10 ) then
          set ahour = 0$ihour
       else
          set ahour = $ihour
       endif
       echo " ihour = " $ihour


cat > $NCLSCRIPTS/emis.ncl <<EOF

;*************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

  ; read in the options passed from the csh
    border_option = getenv("ADD_BORDERS")
    scale_option = getenv("ADD_COLORBAR")
    FillType = getenv("IMAGEFILL")
    PLOT_PM25 = getenv("PLOT_PM25")
    PLOT_CO = getenv("PLOT_CO")
    PLOT_NOx = getenv("PLOT_NOx")
    PLOT_HCHO = getenv("PLOT_HCHO")
    PLOT_VOCs = getenv("PLOT_VOCs")
    PLOT_ISOPRENE = getenv("PLOT_ISOPRENE")
    PLOT_NH3 = getenv("PLOT_NH3")
    PLOT_SO2 = getenv("PLOT_SO2")
    PLOT_WSPM25 = getenv("PLOT_WSPM25") ;shc 2014-11-27

 ; open NetCDF files.
  ; file(s) of data to plot (remember that even if the netcdf file name doesn't end with ".nc",
  ; must include ".nc" in NCL script)
    f1 = addfile ( "$indir" + "/EMISSION/merged/emis2d4plot.ncf.nc","r")
  ; file(s) with latitude and longitude values.
    g1 = addfile ( "$mcip" + "/GRIDCRO2D.nc","r")
  ; file with woodsmoke emissions
    w1 = addfile ( "$indir" + "/EMISSION/anthro/output/rwc_tpy_method/agts_l_tpy_2014nw_${YEARDOY}.ncf.nc","r")

 ; read latitude and longitude of the grid
   g1lat = g1->LAT(0,0,:,:) 
   g1lon = g1->LON(0,0,:,:) 

  ; get dimension from lat/lon info 
    nlat = dimsizes(g1lat(:,0))
    nlon = dimsizes(g1lon(0,:))
  ; ------------------------------------------------------------------
  ; Set some plot resources 
  ; ------------------------------------------------------------------
	res                 = True
	res@gsnDraw         = False   ; Don't draw plot (will do later)
	res@gsnFrame        = False   ; Don't advance framce  (will do later)
	res@gsnMaximize     = True    ; Maximize plot in frame
	res@gsnSpreadColors = True
	res@cnLinesOn       = False
	res@cnLineLabelsOn  = False
	res@cnInfoLabelOn   = False
	res@cnFillMode      = FillType
	res@cnFillOn        = True
	res@cnLevelSelectionMode = "ExplicitLevels"
	res@lbOrientation   = "Vertical"
      ; set map options
	res@mpPerimOn  		= False 
	res@mpProjection 	= "Mercator" 
	res@mpLimitMode 	= "LatLon"
    	res@mpMinLatF = 39
    	res@mpMaxLatF = 50
    	res@mpMinLonF = -126
    	res@mpMaxLonF = -109
	res@gsnPaperOrientation = "Portrait"
	res@cnGridBoundFillPattern = "SolidFill"
	res@cnGridBoundFillColor = "White"
        if (border_option .eq. "N") then
	   res@mpOutlineOn = False
        end if
        if (border_option .eq. "Y") then
	   res@mpDataBaseVersion = "MediumRes"
	   res@mpOutlineBoundarySets = "GeophysicalAndUSStates"	
          ;res@mpOutlineBoundarySets = "AllBoundaries"	
        end if 
        if (scale_option .eq. "N") then
	   res@lbLabelBarOn = False 	; turn off color scale bar
        end if
        if (scale_option .eq. "Y") then
	  res@lbTitleOn        = True ; turn on title
	  res@lbTitleString    = "units"
        end if

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;START PLOTTING VARIABLES 

        x1 = g1lat*1.0
        x1@lat2d = g1lat    ; setting 2D lat/lon coords for all species
        x1@lon2d = g1lon
        if ( PLOT_NOx .eq. "Y" ) then
	   outfile = "$PSDIR"+"/airpact5_emis_NOx_"+"${yyyymmdd}"+"${ahour}"
	   wks = gsn_open_wks("ps", outfile )                                      
	   gsn_define_colormap(wks,"WhViBlGrYeOrRe")
	   x1 = f1->NO($ihour,0,:,:)+f1->NO2($ihour,0,:,:)
	   res@lbTitleString = "moles/s"
	   res@cnLevels             = (/0.01, 0.05, 0.1, 0.2, 0.5, 1, 2, 5, 10, 20, 50, 100/)
           print ("Plotting NOx for hour ${ahour}")	
	   map = gsn_csm_contour_map(wks, x1, res)
	   draw(map)
        end if

       if ( PLOT_HCHO .eq. "Y" ) then
          print ("Plotting HCHO for hour ${ahour}")
	  delete(res@cnLevels) 
    	  outfile = "$PSDIR"+"/airpact5_emis_HCHO_"+"${yyyymmdd}"+"${ahour}"
	  wks = gsn_open_wks("ps", outfile )
	  gsn_define_colormap(wks,"WhViBlGrYeOrRe")
    	  x1 = f1->FORM($ihour,0,:,:)*1.0
    	  res@lbTitleString = "moles/s"
	  res@cnLevels             = (/0.01, 0.05, 0.1, 0.2, 0.50, 1.0, 2.0, 5, 10/)
	  map = gsn_csm_contour_map(wks, x1, res)
	  draw(map)
       end if

       if ( PLOT_SO2 .eq. "Y" ) then
          print ("Plotting SO2 for hour ${ahour}")
          delete(res@cnLevels)
          outfile = "$PSDIR"+"/airpact5_emis_SO2_"+"${yyyymmdd}"+"${ahour}"
          wks = gsn_open_wks("ps", outfile )
          gsn_define_colormap(wks,"WhViBlGrYeOrRe")
          x1 = f1->SO2($ihour,0,:,:)*1.0
          res@lbTitleString = "moles/s"
	  res@cnLevels             = (/0.01, 0.05, 0.1, 0.2, 0.5, 1, 2, 5, 10, 20, 50, 100/)
          map = gsn_csm_contour_map(wks, x1, res)
          draw(map)
       end if

       if ( PLOT_NH3 .eq. "Y" ) then
          print ("Plotting NH3 for hour ${ahour}")
	  delete(res@cnLevels) 
    	  outfile = "$PSDIR"+"/airpact5_emis_NH3_"+"${yyyymmdd}"+"${ahour}"
	  wks = gsn_open_wks("ps", outfile )
	  gsn_define_colormap(wks,"WhViBlGrYeOrRe")
    	  x1 = f1->NH3($ihour,0,:,:)*1.0
    	  res@lbTitleString = "moles/s"
    	  res@cnLevels             = (/0.01, 0.05, 0.1, 0.5, 1, 2, 5, 10, 20, 50, 100, 200/)
	  map = gsn_csm_contour_map(wks, x1, res)
	  draw(map)
	 ;system("convert -density $imgd -transparent white -crop ${cx}x${cy}+${sx}+${sy} +repage $PSDIR/airpact5_emis_NH3_${yyyymmdd}${ahour}.ps  $PSDIR/airpact5_emis_NH3_${yyyymmdd}${ahour}.gif")
	 ;system("convert -resize ${cx}x${cy} +repage $PSDIR/airpact5_emis_NH3_${yyyymmdd}${ahour}.gif  $PSDIR/airpact5_emis_NH3_${yyyymmdd}${ahour}.gif")
       end if

       if ( PLOT_ISOPRENE .eq. "Y" ) then
          print ("Plotting Isoprene for hour ${ahour}")
	  delete(res@cnLevels) 
    	  outfile = "$PSDIR"+"/airpact5_emis_ISOPRENE_"+"${yyyymmdd}"+"${ahour}"
	  wks = gsn_open_wks("ps", outfile )
	  gsn_define_colormap(wks,"WhViBlGrYeOrRe")
    	  x1 = f1->ISOP($ihour,0,:,:)*1.0
    	  res@lbTitleString = "moles/s"
    	  res@cnLevels             = (/0.01, 0.05, 0.1, 0.2, 0.50, 1.0, 2.0, 5.0, 10/)
	  map = gsn_csm_contour_map(wks, x1, res)
	  draw(map)
       end if 

       if ( PLOT_CO .eq. "Y" ) then
          print ("Plotting CO for hour ${ahour}")
	  delete(res@cnLevels) 
    	  outfile = "$PSDIR"+"/airpact5_emis_CO_"+"${yyyymmdd}"+"${ahour}"
	  wks = gsn_open_wks("ps", outfile )
	  gsn_define_colormap(wks,"WhViBlGrYeOrRe")
    	  x1 = f1->CO($ihour,0,:,:)*1.0
    	  res@lbTitleString = "moles/s"
    	  res@cnLevels             = (/0.01, 0.05, 0.1, 0.2, 0.50, 1.0, 2.0, 5.0, 10, 20, 50/)
	  map = gsn_csm_contour_map(wks, x1, res)
	  draw(map)
       end if

       if ( PLOT_VOCs .eq. "Y" ) then
          print ("Plotting VOCs for hour ${ahour}")
	  delete(res@cnLevels) 
    	  outfile = "$PSDIR"+"/airpact5_emis_VOCs_"+"${yyyymmdd}"+"${ahour}"
	  wks = gsn_open_wks("ps", outfile )
	  gsn_define_colormap(wks,"WhViBlGrYeOrRe")
    	  x1 = f1->PAR($ihour,0,:,:)*1+f1->ETH($ihour,0,:,:)*2+f1->ETOH($ihour,0,:,:)*2+f1->OLE($ihour,0,:,:)*2+f1->TOL($ihour,0,:,:)*7
	  x1 = x1+f1->XYL($ihour,0,:,:)*8+f1->FORM($ihour,0,:,:)*1+f1->ALD2($ihour,0,:,:)*2+f1->ISOP($ihour,0,:,:)*5
	  x1 = x1+f1->ETHA($ihour,0,:,:)*2+f1->IOLE($ihour,0,:,:)*4+f1->ALDX($ihour,0,:,:)*2+f1->TERP($ihour,0,:,:)*10
	  x1 = x1*1.0
    	  res@lbTitleString = "moles/s"
    	  res@cnLevels             = (/0.01, 0.05, 0.1, 0.2, 0.40, 0.60, 0.80, 1.0, 2.0, 5.0, 10/)
	  map = gsn_csm_contour_map(wks, x1, res)
	  draw(map)
       end if

       if ( PLOT_PM25 .eq. "Y" ) then
          print ("Plotting PM25 for hour ${ahour}")
	  delete(res@cnLevels) 
    	  outfile = "$PSDIR"+"/airpact5_emis_PM25_"+"${yyyymmdd}"+"${ahour}"
	  wks = gsn_open_wks("ps", outfile )
	  gsn_define_colormap(wks,"WhViBlGrYeOrRe")
	  x1 =      f1->PSO4($ihour,0,:,:)  + f1->PNO3($ihour,0,:,:) + f1->PCL($ihour,0,:,:)
          x1 = x1 + f1->PNH4($ihour,0,:,:)  + f1->PNA($ihour,0,:,:)  + f1->PMG($ihour,0,:,:)
          x1 = x1 + f1->PK($ihour,0,:,:)    + f1->PCA($ihour,0,:,:)  + f1->POC($ihour,0,:,:)
          x1 = x1 + f1->PNCOM($ihour,0,:,:) + f1->PEC($ihour,0,:,:)  + f1->PFE($ihour,0,:,:)
          x1 = x1 + f1->PAL($ihour,0,:,:)   + f1->PSI($ihour,0,:,:)  + f1->PTI($ihour,0,:,:)
          x1 = x1 + f1->PMN($ihour,0,:,:)   + f1->PMOTHR($ihour,0,:,:)
	  res@lbTitleString = "grams/s"
    	  res@cnLevels             = (/0.01, 0.05, 0.1, 0.2, 0.5, 1, 2, 5, 10, 20, 50, 100, 200/)
	  map = gsn_csm_contour_map(wks, x1, res)
	  draw(map)
       end if

       ;fht  2015-12-23
       if ( PLOT_WSPM25 .eq. "Y" ) then
          print ("Plotting WSPM25 for hour ${ahour}")
	  delete(res@cnLevels) 
    	  outfile = "$PSDIR"+"/airpact5_emis_WSPM25_"+"${yyyymmdd}"+"${ahour}"
	  wks = gsn_open_wks("ps", outfile )
	  gsn_define_colormap(wks,"WhViBlGrYeOrRe")
          x1 =      w1->PSO4($ihour,0,:,:)  + w1->PNO3($ihour,0,:,:) + w1->PCL($ihour,0,:,:)
          x1 = x1 + w1->PNH4($ihour,0,:,:)  + w1->PNA($ihour,0,:,:)  + w1->PMG($ihour,0,:,:)
          x1 = x1 + w1->PK($ihour,0,:,:)    + w1->PCA($ihour,0,:,:)  + w1->POC($ihour,0,:,:)
          x1 = x1 + w1->PNCOM($ihour,0,:,:) + w1->PEC($ihour,0,:,:)  + w1->PFE($ihour,0,:,:)
          x1 = x1 + w1->PAL($ihour,0,:,:)   + w1->PSI($ihour,0,:,:)  + w1->PTI($ihour,0,:,:)
          x1 = x1 + w1->PMN($ihour,0,:,:)   + w1->PMOTHR($ihour,0,:,:)
	  res@lbTitleString = "grams/s"
    	  res@cnLevels             = (/0.01, 0.05, 0.1, 0.2, 0.5, 1, 2, 5, 10, 20, 50, 100, 200/)
	  map = gsn_csm_contour_map(wks, x1, res)
	  draw(map)
       end if


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end 

EOF
# End of emis.ncl

       ncl -Q $NCLSCRIPTS/emis.ncl
      #rm -r -f $PSDIR/*.ps
       @ ihour ++
end #while

# convert to gif files
  set GIFDIR     = $indir/IMAGES/emis/gif
  mkdir -p $GIFDIR
  cd $PSDIR
  foreach psfile ( *.ps )
    set fileroot = `echo $psfile | cut -d '.' -f 1 `
    convert -density $imgd -transparent white -crop ${cx}x${cy}+${sx}+${sy} +repage $PSDIR/$psfile  $GIFDIR/${fileroot}.gif
    if ( -e $GIFDIR/${fileroot}.gif ) then
       convert -resize ${cx}x${cy} +repage $GIFDIR/${fileroot}.gif  $GIFDIR/${fileroot}.gif
       chmod a+r $GIFDIR/${fileroot}.gif
       /bin/rm -f $PSDIR/$psfile
    endif
  end
  cd ../
  rmdir $PSDIR

/bin/rm -f $NCLSCRIPTS/emis.ncl
exit
