#!/bin/csh -f

# Example of using this script:
# 
#   > run_ncl_dluse.csh 20120514
#
#    where 20101104 denotes forecast start time of 8 GMT on Nov 5, 2010
#
# Farren Herron-Thorp   2012-04-20
# Serena H. Chung       2012-05-06
#
# This C shell script creates a gif file of dominant land use from MCIP GRIDCRO2D
# The script 1) creates an NCL script, 2) runs the NCL script
# to create the figure in postcript format, and 3) converts the postscript file to a gif file.

#> switch for various subcomponents and options ------------------------

   # plot options
     setenv ADD_COLORBAR 	Y
     setenv ADD_BORDERS 	Y
     setenv IMAGEFILL	RasterFill#RasterFill AreaFill or CellFill

   # image conversion ( ps to gif ) options
     set imgd=120
     set cx=863
     set cy=751
     set sx=64
     set sy=265

#> initialize exit status ----------------------------------------------
   set exitstat = 0

#> check argument & set date strings  ----------------------------------

   if ( $#argv == 1 ) then
      setenv YEAR `echo $1 | cut -c1-4`
      setenv MONTH `echo $1 | cut -c5-6`
      setenv DAY `echo $1 | cut -c7-8`
   else
      echo 'invalid argument. '
      echo "usage $0 <yyyymmdd>"
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
      set PBS_O_WORKDIR = ~airpact5/AIRHOME/run_ap5_day1
      if ( ! $?AIRHOME        ) set AIRHOME = ~airpact5/AIRHOME
      if ( ! $?AIRRUN ) then
         set AIRRUN  = /data/lar/projects/airpact5/AIRRUN/$YEAR
      endif
      if ( ! $?AIROUT         ) set AIROUT = $AIRRUN/${yyyymmdd}00
      if ( ! $?AIRLOGDIR      ) set AIRLOGDIR = $AIROUT/LOGS
      if ( ! $?MCIPDIR        ) then
         if ( -e $AIROUT/MCIP37/METCRO2D ) then
            set MCIPDIR   = $AIROUT/MCIP
         else
            set MCIPDIR   = /data/lar/projects/airpact5/AIRRUN/${yyyymmdd}00/MCIP37
         endif
      endif
   endif

#> directory set-up ----------------------------------------------------

   set indir      = $AIROUT
   set mcip       = $MCIPDIR
   set NCLSCRIPTS = ${PBS_O_WORKDIR}/plot
   set PSDIR      = $NCLSCRIPTS/output
   mkdir -p $PSDIR

# > create and run ncl script ------------------------------------------

cat > $NCLSCRIPTS/dluse.ncl <<EOF

;*************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  ; read in the options passed from the csh
    border_option = getenv("ADD_BORDERS")
    scale_option = getenv("ADD_COLORBAR")
    FillType = getenv("IMAGEFILL")

  ; open NetCDF files.
    ; File(s) of data to plot (remember that even if the netcdf file name doesn't end with ".nc",
    ; must include ".nc" in NCL script)
    ; file(s) with latitude and longitude values.
      g1 = addfile ( "$mcip" + "/GRIDCRO2D.nc","r")
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
  ; START PLOTTING

  ; set-up lat, lon for variables to plot
  x1 = g1lat*1.0
  x1@lat2d = g1lat 
  x1@lon2d = g1lon

  outfile = "$PSDIR"+"/airpact5_DLUSE_"+"${yyyymmdd}"
  wks = gsn_open_wks("ps", outfile )

; this color map is not working as intended... the order is not right, perhaps due to switch to MODIS LU in WRF
;  colors = (/"white","black","red","darkgoldenrod3","yellow","darkgoldenrod2","darkolivegreen3","limegreen", \
;             "chartreuse","lightyellow3", "lightyellow4","lightgoldenrod3","springgreen1", \
;             "palegreen1","forestgreen","darkgreen","olivedrab","skyblue","dodgerblue3", \
;             "steelblue", "sienna", "lightyellow2"/)

  colors = (/"white","black","darkgreen","forestgreen","palegreen1","springgreen1","olivedrab", \
             "lightyellow4","lightyellow3","darkolivegreen3","lightgoldenrod3", "yellow",  \
             "steelblue", "darkgoldenrod2","red","darkgoldenrod3","lightyellow2","sienna","skyblue"/)


  gsn_define_colormap(wks,colors)
  x1 = g1->DLUSE(0,0,:,:)*1.0
  res@lbTitleString = "Dominant Land Use"
  res@cnLevels      = (/1.1,2.1,3.1,4.1,5.1,6.1,7.1,8.1,9.1,10.1,11.1,12.1,13.1,14.1,15.1,16.1/)
  res@lbLabelStrings = (/"Evergreen Needleleaf Forest","Evergreen Broadleaf Forest","Deciduous Needleleaf Forest", \
                       "Deciduous Broadleaf Forest","Mixed Forests","Closed Shrublands","Open Shrublands", \
                       "Woody Savannas", "Savannas", "Grasslands", "Permanent Wetlands", "Croplands", "Urban and Built-Up", \
                       "Cropland or Natural Veg.", "Snow and Ice", "Barren or Sparse Veg.", "Water"/)
  res@cnExplicitLabelBarLabelsOn = True
  res@lbLabelAlignment = "BoxCenters"

  x1@lat2d = g1lat    ; setting 2D lat/lon coords for all species
  x1@lon2d = g1lon

  map = gsn_csm_contour_map(wks, x1, res)
  draw(map)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end 

EOF
# end of dluse.ncl

       ncl -Q $NCLSCRIPTS/dluse.ncl

# convert to gif files
 if ( $ADD_COLORBAR == "N" ) then
  echo "cropping and converting image"
  cd $PSDIR
  foreach psfile ( *.ps )
    set fileroot = `echo $psfile | cut -d '.' -f 1 `
    convert -density $imgd -transparent white -crop ${cx}x${cy}+${sx}+${sy} +repage $PSDIR/$psfile  $PSDIR/${fileroot}.gif
    if ( -e $PSDIR/${fileroot}.gif ) then
       convert -resize ${cx}x${cy} +repage $PSDIR/${fileroot}.gif  $PSDIR/${fileroot}.gif
       chmod a+r $PSDIR/${fileroot}.gif
       /bin/rm -f $PSDIR/$psfile
    endif
  end #foreach psfile
  cd ../
 else
  echo "converting image"
  cd $PSDIR
  foreach psfile ( *.ps )
    set fileroot = `echo $psfile | cut -d '.' -f 1 `
    convert -density $imgd -transparent white +repage $PSDIR/$psfile  $PSDIR/${fileroot}.gif
    if ( -e $PSDIR/${fileroot}.gif ) then
       convert +repage $PSDIR/${fileroot}.gif  $PSDIR/${fileroot}.gif
       chmod a+r $PSDIR/${fileroot}.gif
       /bin/rm -f $PSDIR/$psfile
    endif
  end #foreach psfile
  cd ../
 endif

 /bin/rm -f $NCLSCRIPTS/dluse.ncl
exit
