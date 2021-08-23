#!/bin/csh -f

# example of using this script:
# 
#   > ./run_ncl_aod.csh 20160504 24
#
#    where 20160504 denotes forecast start time of 8 GMT on Nov 5, 2010
#               24 denotes 24 hours of forecast
#
#
# Farren Herron-Thorp   2012-04-20
# Serena H. Chung       2012-05-03
#
# This C shell script creates hourly gif files of gaseous concentrations based on AIRPACT-4's
# CMAQ output files. For each hour, the script 1) creates an NCL script, 2) runs the NCL script
# to create the figure in postcript format, and 3) converts the postscript file to a gif file.

#> switch for various subcomponents and options ------------------------

   # plot options
     setenv ADD_COLORBAR 	N
     setenv ADD_BORDERS 	N
     setenv IMAGEFILL      AreaFill  #RasterFill AreaFill or CellFill
   # species to plot
     setenv PLOT_AOD		Y
   # image conversion ( ps to gif ) options
     set imgd = 120 
     set cx   = 863
     set cy   = 751
     set sx   =  64
     set sy   = 265

#> initialize exit status ----------------------------------------------
   set exitstat = 0

#> check argument & set date strings  ----------------------------------

   if ( $#argv == 2 ) then
      set currentday = $1
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
   set previousday = `date -d "$currentday -1 days" '+%Y%m%d'`
  #> determine day of the year
     set DOYstring = `juldate $MONTH $DAY $YEAR | cut -d',' -f 2`
     set DOY       = `echo $DOYstring | cut -c5-7`
     set YEARDOY   = $YEAR$DOY
   
#> during testing 

   if ( ! $?PBS_O_WORKDIR ) then
     set PBS_O_WORKDIR = ~airpact5/AIRHOME/run_ap5_day2
     set AIROUT = /data/lar/projects/airpact5/AIRRUNDAY2/$YEAR/${1}00
     set MCIPDIR = /data/airpact4/AIRRUN/${previousday}00/MCIP37
     set NHR = $2
   endif


#> directory set-up ----------------------------------------------------

   set indir      = $AIROUT
   set mcip       = $MCIPDIR
   set NCLSCRIPTS = ${PBS_O_WORKDIR}/plot
   set PSDIR      = $indir/IMAGES/aconc/hourly/ps
   if ( ! -d $PSDIR ) mkdir -p $PSDIR

# > create and run ncl script hour by hour ----------------------------

    set ihour  = 0 
    @ NHRm1 = $NHR - 1  
    while ( $ihour <= ${NHRm1}  )
	@ shour = $ihour + 1
       if ( $shour < 10 ) then
          set ahour = 0$shour
       else
          set ahour = $shour
       endif
       echo " ihour = " $ihour

cat > $NCLSCRIPTS/hourlyaod.ncl <<EOF

;*************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  ; read in the options passed from the csh
    border_option = getenv("ADD_BORDERS")
    scale_option  = getenv("ADD_COLORBAR")
    FillType      = getenv("IMAGEFILL")

    PLOT_AOD = getenv("PLOT_AOD")

  ; open NetCDF files.
  ; file(s) of data to plot (remember that even if the netcdf file name doesn't end with ".nc",
  ; must include ".nc" in NCL script)
  ; File(s) with latitude and longitude values.
    g1 = addfile ( "$mcip" + "/GRIDCRO2D.nc","r")
    h1 = addfile ( "$indir" + "/POST/CCTM/aod550nm2d_${yyyymmdd}.ncf.nc","r")
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
	res@mpProjection 	= "Mercator"  ; because google map uses Mercator
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

  ; ------------------------------------------------------------------
  ; START PLOTTING SPECIES 
  ; ------------------------------------------------------------------
      x1 = g1lat*1.0
      x1@lat2d = g1lat    ; setting 2D lat/lon coords for all species
      x1@lon2d = g1lon

     if ( PLOT_AOD .eq. "Y" ) then
        outfile = "$PSDIR"+"/airpact5_AOD_"+"${yyyymmdd}"+"${ahour}"
        wks = gsn_open_wks("ps", outfile )
        gsn_define_colormap(wks,"BlAqGrYeOrReVi200")
        x1 = h1->AOD550nm($ihour,0,:,:)*1.00
        res@lbTitleString = "AOD"
        res@cnLevels             = (/0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2.0/)
        map = gsn_csm_contour_map(wks, x1, res)
        draw(map)
     end if




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end 

EOF
# end of hourlyaod.ncl

       ncl -Q $NCLSCRIPTS/hourlyaod.ncl
      #rm -r -f $PSDIR/*.ps
       @ ihour ++
end #while


# convert to gif files
  set GIFDIR     = $indir/IMAGES/aconc/hourly/gif
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

/bin/rm -f $NCLSCRIPTS/hourlyaod.ncl
exit
