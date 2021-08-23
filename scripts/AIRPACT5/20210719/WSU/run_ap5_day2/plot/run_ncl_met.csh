#!/bin/csh -f

# Example of using this script:
# 
#   > run_ncl_met.csh 20120514 24
#
#    where 20101104 denotes forecast start time of 8 GMT on Nov 5, 2010
#               24 denotes 24 hours of forecast
#
#
# Farren Herron-Thorp   2017-03-22
# Serena H. Chung       2012-05-06
#
# This C shell script creates hourly gif files of meteorological variables from MCIP files
# For each hour, the script 1) creates an NCL script, 2) runs the NCL script
# to create the figure in postcript format, and 3) converts the postscript file to a gif file.

#> switch for various subcomponents and options ------------------------

   # plot options
     setenv ADD_COLORBAR 	N
     setenv ADD_BORDERS 	N
     setenv IMAGEFILL	AreaFill#RasterFill AreaFill or CellFill
   # species to plot
     setenv PLOT_CFRAC	Y #Cloud Fraction
     setenv PLOT_RGRND	Y #Radiation at the Ground
     setenv PLOT_PRECIP	Y #RN + RC
     setenv PLOT_PBL	Y
     setenv PLOT_PRSFC	Y #Surface Pressure
     setenv PLOT_TEMP2	Y #Temperature at 2 meters
     setenv PLOT_VI     Y #Ventilation Index = PBL Height times 20m wind speed
   # image conversion ( ps to gif ) options
     set imgd=120
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
         set AIRRUN  = /data/lar/projects/airpact5/AIRRUNDAY2/$YEAR
      endif
      if ( ! $?AIROUT         ) set AIROUT = $AIRRUN/${yyyymmdd}00
      if ( ! $?AIRLOGDIR      ) set AIRLOGDIR = $AIROUT/LOGS
      if ( ! $?MCIPDIR        ) then
         if ( -e $AIROUT/MCIP37/METCRO2D ) then
            set MCIPDIR   = $AIROUT/MCIP37
         else
            set MCIPDIR   = /data/lar/projects/airpact5/AIRRUNDAY2/$YEAR/${yyyymmdd}00/MCIP37
         endif
      endif
      set NHR = $2
   endif

#> directory set-up ----------------------------------------------------

   set indir      = $AIROUT
   set mcip       = $MCIPDIR
   set NCLSCRIPTS = ${PBS_O_WORKDIR}/plot
   set PSDIR      = $indir/IMAGES/met/ps
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
cat > $NCLSCRIPTS/mcip.ncl <<EOF

;*************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  ; read in the options passed from the csh
    border_option = getenv("ADD_BORDERS")
    scale_option = getenv("ADD_COLORBAR")
    FillType = getenv("IMAGEFILL")
    PLOT_CFRAC = getenv("PLOT_CFRAC")
    PLOT_RGRND = getenv("PLOT_RGRND")
    PLOT_PRECIP = getenv("PLOT_PRECIP")
    PLOT_PBL = getenv("PLOT_PBL")
    PLOT_PRSFC = getenv("PLOT_PRSFC")
    PLOT_TEMP2 = getenv("PLOT_TEMP2")
    PLOT_VI = getenv("PLOT_VI")

  ; open NetCDF files.
    ; File(s) of data to plot (remember that even if the netcdf file name doesn't end with ".nc",
    ; must include ".nc" in NCL script)
    ; file(s) with latitude and longitude values.
      g1 = addfile ( "$mcip" + "/GRIDCRO2D.nc","r")
    ; file(s) with meteorology (2D).
      h1 = addfile ( "$mcip" + "/METCRO2D.nc","r")
      z1 = addfile ( "$mcip" + "/METDOT3D.nc","r")
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
        end if 
        if (scale_option .eq. "N") then
	  res@lbLabelBarOn = False 	; turn off color scale bar
        end if
        if (scale_option .eq. "Y") then
	  res@lbTitleOn        = True ; turn on title
	  res@lbTitleString    = "units"
        end if


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; START PLOTTING VARIABLES 

        ; set-up lat, lon for variables to plot
          x1 = g1lat*1.0
	  x1@lat2d = g1lat 
	  x1@lon2d = g1lon

        if ( PLOT_CFRAC .eq. "Y" ) then
           outfile = "$PSDIR"+"/airpact5_CFRAC_"+"${yyyymmdd}"+"${ahour}"
           wks = gsn_open_wks("ps", outfile )
           gsn_define_colormap(wks,"precip_11lev")
           x1 = h1->CFRAC($ihour,0,:,:)*1.0
           res@lbTitleString = "Cloud Fraction"
           res@cnLevels             = (/0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.95/)
	   x1@lat2d = g1lat    ; setting 2D lat/lon coords for all species
	   x1@lon2d = g1lon
           print ("Plotting CFRAC for hour ${ihour}")
           map = gsn_csm_contour_map(wks, x1, res)
           draw(map)
	  ;system("convert -density $imgd -transparent white -crop ${cx}x${cy}+${sx}+${sy} +repage $PSDIR/airpact5_CFRAC_${yyyymmdd}${ahour}.ps  $PSDIR/airpact5_CFRAC_${yyyymmdd}${ahour}.gif")
          ;system("convert -resize ${cx}x${cy} +repage $PSDIR/airpact5_CFRAC_${yyyymmdd}${ahour}.gif  $PSDIR/airpact5_CFRAC_${yyyymmdd}${ahour}.gif")
        end if

        if ( PLOT_RGRND .eq. "Y" ) then
           print ("Plotting RGRND for hour ${ihour}")
           delete(res@cnLevels)
           outfile = "$PSDIR"+"/airpact5_RGRND_"+"${yyyymmdd}"+"${ahour}"
	   wks = gsn_open_wks("ps", outfile )
           gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
           x1 = h1->RGRND($ihour,0,:,:)*1.0
           ;need to fake in a number less than 10 if all values are 0 so we get around constant field (all night values) error
            if (x1(1,1) .eq. 0) then
               x1(1,1)=0.1
            end if
           res@lbTitleString = "W m:S:-2:N:"
           res@cnLevels             = (/10, 20, 40, 60, 80, 100, 200, 400, 600, 800, 1000/)
           map = gsn_csm_contour_map(wks, x1, res)
           draw(map)
          ;system("convert -density $imgd -transparent white -crop ${cx}x${cy}+${sx}+${sy} +repage $PSDIR/airpact5_RGRND_${yyyymmdd}${ahour}.ps  $PSDIR/airpact5_RGRND_${yyyymmdd}${ahour}.gif")
          ;system("convert -resize ${cx}x${cy} +repage $PSDIR/airpact5_RGRND_${yyyymmdd}${ahour}.gif  $PSDIR/airpact5_RGRND_${yyyymmdd}${ahour}.gif")
        end if

        if ( PLOT_PBL .eq. "Y" ) then
           print ("Plotting PBL for hour ${ihour}")
           delete(res@cnLevels)
           outfile = "$PSDIR"+"/airpact5_PBL_"+"${yyyymmdd}"+"${ahour}"
           wks = gsn_open_wks("ps", outfile )
           gsn_define_colormap(wks,"BlAqGrYeOrRe")
           x1 = h1->PBL($ihour,0,:,:)*1.0
           res@lbTitleString = "m"
           res@cnLevels             = (/5, 30, 50, 80, 100, 150, 200, 500, 1000, 1200, 1500, 2000, 2500, 3000, 4000/)
          ;res@cnLevels             = (/30, 50, 100, 300, 500, 1000, 1500, 2000, 2500, 3000, 4000/)
           map = gsn_csm_contour_map(wks, x1, res)
           draw(map)
          ;system("convert -density $imgd -transparent white -crop ${cx}x${cy}+${sx}+${sy} +repage $PSDIR/airpact5_PBL_${yyyymmdd}${ahour}.ps  $PSDIR/airpact5_PBL_${yyyymmdd}${ahour}.gif")
          ;system("convert -resize ${cx}x${cy} +repage $PSDIR/airpact5_PBL_${yyyymmdd}${ahour}.gif  $PSDIR/airpact5_PBL_${yyyymmdd}${ahour}.gif")
        end if

        if ( PLOT_PRSFC .eq. "Y" ) then
           print ("Plotting PRSFC for hour ${ihour}")
           delete(res@cnLevels)
           outfile = "$PSDIR"+"/airpact5_PRSFC_"+"${yyyymmdd}"+"${ahour}"
           wks = gsn_open_wks("ps", outfile )
           gsn_define_colormap(wks,"BlAqGrYeOrRe")
           x1 = h1->PRSFC($ihour,0,:,:)*0.01
           res@lbTitleString = "mb"
           res@cnLevels             = (/650, 700, 750, 800, 825, 850, 875, 900, 925, 950, 975, 1000, 1010, 1020/)
           map = gsn_csm_contour_map(wks, x1, res)
           draw(map)
          ;system("convert -density $imgd -transparent white -crop ${cx}x${cy}+${sx}+${sy} +repage $PSDIR/airpact5_PRSFC_${yyyymmdd}${ahour}.ps  $PSDIR/airpact5_PRSFC_${yyyymmdd}${ahour}.gif")
          ;system("convert -resize ${cx}x${cy} +repage $PSDIR/airpact5_PRSFC_${yyyymmdd}${ahour}.gif  $PSDIR/airpact5_PRSFC_${yyyymmdd}${ahour}.gif")
        end if

        if ( PLOT_TEMP2 .eq. "Y" ) then
           print ("Plotting TEMP2 for hour ${ihour}")
           delete(res@cnLevels)
           outfile = "$PSDIR"+"/airpact5_TEMP2_"+"${yyyymmdd}"+"${ahour}"
           wks = gsn_open_wks("ps", outfile )
           gsn_define_colormap(wks,"BlAqGrYeOrRe")
           x1 = h1->TEMP2($ihour,0,:,:)*1.0-273.15
           res@lbTitleString = ":S:o:N:C"
           res@cnLevels             = (/-20, -10, -5,  0, 5, 10, 15, 20, 25, 30, 35, 40/)
           map = gsn_csm_contour_map(wks, x1, res)
           draw(map)
          ;system("convert -density $imgd -transparent white -crop ${cx}x${cy}+${sx}+${sy} +repage $PSDIR/airpact5_TEMP2_${yyyymmdd}${ahour}.ps  $PSDIR/airpact5_TEMP2_${yyyymmdd}${ahour}.gif")
          ;system("convert -resize ${cx}x${cy} +repage $PSDIR/airpact5_TEMP2_${yyyymmdd}${ahour}.gif  $PSDIR/airpact5_TEMP2_${yyyymmdd}${ahour}.gif")
        end if

        if ( PLOT_PRECIP .eq. "Y" ) then
           print ("Plotting PRECIP for hour ${ihour}")
           delete(res@cnLevels)
           outfile = "$PSDIR"+"/airpact5_PRECIP_"+"${yyyymmdd}"+"${ahour}"
           wks = gsn_open_wks("ps", outfile )
           gsn_define_colormap(wks,"precip_11lev")
           x1 = h1->RN($ihour,0,:,:)+h1->RC($ihour,0,:,:)
           x1 = x1*1.0
	   res@lbTitleString = "cm"
           res@cnLevels             = (/0.005, 0.01, 0.05, 0.1, 0.2, 0.4, 0.6, 0.8, 1.0, 1.2/)
           map = gsn_csm_contour_map(wks, x1, res)
           draw(map)
          ;system("convert -density $imgd -transparent white -crop ${cx}x${cy}+${sx}+${sy} +repage $PSDIR/airpact5_PRECIP_${yyyymmdd}${ahour}.ps  $PSDIR/airpact5_PRECIP_${yyyymmdd}${ahour}.gif")
          ;system("convert -resize ${cx}x${cy} +repage $PSDIR/airpact5_PRECIP_${yyyymmdd}${ahour}.gif  $PSDIR/airpact5_PRECIP_${yyyymmdd}${ahour}.gif")
        end if

        if ( PLOT_VI .eq. "Y" ) then
           print ("Plotting Ventilation Index for hour ${ihour}")
           delete(res@cnLevels)
           outfile = "$PSDIR"+"/airpact5_VI_"+"${yyyymmdd}"+"${ahour}"
           res@cnFillMode = "RasterFill"
           wks = gsn_open_wks("ps", outfile )
           colors = (/"white","black","purple4","purple1","mediumorchid2","plum1","firebrick4","firebrick","brown3","indianred1","lightpink1","darkorange","orange","goldenrod1","gold","yellow","white","white"/)
           gsn_define_colormap(wks,colors)
           x1 = h1->PBL($ihour,0,:,:)*0.25*(sqrt((z1->UWINDC($ihour,0,0:257,0:284))^2+(z1->VWINDC($ihour,0,0:257,0:284))^2)+sqrt((z1->UWINDC($ihour,0,1:258,0:284))^2+(z1->VWINDC($ihour,0,1:258,0:284))^2)+sqrt((z1->UWINDC($ihour,0,0:257,1:285))^2+(z1->VWINDC($ihour,0,0:257,1:285))^2)+sqrt((z1->UWINDC($ihour,0,1:258,1:285))^2+(z1->VWINDC($ihour,0,1:258,1:285))^2))
           res@lbTitleString = "m^2/s"
           res@cnLevels             = (/58.75, 117.5, 176.25, 235, 470, 940, 1410, 1880, 2350, 2820, 3290, 3760, 4230, 4700, 5170/)
           map = gsn_csm_contour_map(wks, x1, res)
           draw(map)
          ;system("convert -density $imgd -transparent white -crop ${cx}x${cy}+${sx}+${sy} +repage $PSDIR/airpact5_VI_${yyyymmdd}${ahour}.ps  $PSDIR/airpact5_VI_${yyyymmdd}${ahour}.gif")
          ;system("convert -resize ${cx}x${cy} +repage $PSDIR/airpact5_VI_${yyyymmdd}${ahour}.gif  $PSDIR/airpact5_VI_${yyyymmdd}${ahour}.gif")
        end if


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end 

EOF
# end of mcip.ncl

       ncl -Q $NCLSCRIPTS/mcip.ncl
       @ ihour ++
    end   #while

# convert to gif files
  set GIFDIR     = $indir/IMAGES/met/gif
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
  end #foreach psfile
  cd ../
  rmdir $PSDIR

/bin/rm -f $NCLSCRIPTS/mcip.ncl
exit
