#!/bin/csh -f

# Example of using this script:
# 
#   > ./run_ncl_hourly.csh 20141202 24
#
#    where 20101104 denotes forecast start time of 8 GMT on Nov 5, 2010
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
     setenv PLOT_O3 		Y
     setenv PLOT_PM25	        Y
     setenv PLOT_NOx 	        Y
     setenv PLOT_HCHO 	        Y
     setenv PLOT_ISOPRENE 	Y
     setenv PLOT_NH3 	        Y
     setenv PLOT_CO 		Y
     setenv PLOT_VOCs 	        Y
     setenv PLOT_SO2		Y
     setenv PLOT_AOMIJ		Y
     setenv PLOT_ANO3		Y
     setenv PLOT_WSPM25	        Y # switch on 2016-02-21

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
   set PSDIR      = $indir/IMAGES/aconc/hourly/ps
   mkdir -p $PSDIR

#> wait on necessary input file, added by JKV 111317
   ~/bin/wait_for_tstep_in_ncf.csh ${indir}/POST/CCTM/combined_${currentday}.ncf 24 \
	>&! $AIRLOGDIR/wait_combined.log

# > create and run ncl script hour by hour ----------------------------

    set ihour  = 0 
    @ NHRm1 = $NHR - 1  
    while ( $ihour <= ${NHRm1}  )

       if ( $ihour < 10 ) then
          set ahour = 0$ihour
       else
          set ahour = $ihour
       endif
       echo " ihour = " $ihour

cat > $NCLSCRIPTS/hourly.ncl <<EOF

;*************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  ; read in the options passed from the csh
    border_option = getenv("ADD_BORDERS")
    scale_option  = getenv("ADD_COLORBAR")
    FillType      = getenv("IMAGEFILL")
    PLOT_O3 = getenv("PLOT_O3")
    PLOT_PM25 = getenv("PLOT_PM25")
    PLOT_CO = getenv("PLOT_CO")
    PLOT_NOx = getenv("PLOT_NOx")
    PLOT_HCHO = getenv("PLOT_HCHO")
    PLOT_VOCs = getenv("PLOT_VOCs")
    PLOT_ISOPRENE = getenv("PLOT_ISOPRENE")
    PLOT_NH3 = getenv("PLOT_NH3")
    PLOT_SO2 = getenv("PLOT_SO2")
    PLOT_AOMIJ  = getenv("PLOT_AOMIJ")
    PLOT_ANO3 = getenv("PLOT_ANO3")
    PLOT_WSPM25 = getenv("PLOT_WSPM25")

  ; open NetCDF files.
  ; file(s) of data to plot (remember that even if the netcdf file name doesn't end with ".nc",
  ; must include ".nc" in NCL script)
    f1 = addfile ( "$indir" + "/POST/CCTM/combined_${currentday}.ncf.nc","r")
   ;f2 = addfile ( "$indir" + "/POST/CCTM/ACONC_WSPM25_L01_${currentday}.ncf.nc","r")
  ; File(s) with latitude and longitude values.
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
         ;res@mpOutlineBoundarySets = "AllBoundaries"	
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
      if ( PLOT_O3 .eq. "Y" ) then
         outfile = "$PSDIR"+"/airpact5_O3_"+"${currentday}"+"${ahour}"
         wks = gsn_open_wks("ps", outfile )                                      
         gsn_define_colormap(wks,"WhBlGrYeRe")
         x1 = f1->O3($ahour,0,:,:)*1
         res@lbTitleString = "ppb"
         res@cnLevels             = (/1, 5, 10, 15, 20, 25, 30, 40, 50, 55, 60, 65, 70, 75, 80, 90, 100/)
	 map = gsn_csm_contour_map(wks, x1, res)
	 draw(map)
      end if

     if ( PLOT_NOx .eq. "Y" ) then
	delete(res@cnLevels) 
	outfile = "$PSDIR"+"/airpact5_NOx_"+"${currentday}"+"${ahour}"
	wks = gsn_open_wks("ps", outfile )                                      
	gsn_define_colormap(wks,"WhBlGrYeRe")
	x1 = f1->NOX($ihour,0,:,:)*1.000
	res@lbTitleString = "ppb"
	res@cnLevels             = (/0.2, 0.4, 0.6, 0.8, 1, 2, 4, 6, 8, 10, 20, 40, 60, 80, 100/)
	map = gsn_csm_contour_map(wks, x1, res)
	draw(map)
     end if

     if ( PLOT_HCHO .eq. "Y" ) then
	delete(res@cnLevels) 
    	outfile = "$PSDIR"+"/airpact5_HCHO_"+"${currentday}"+"${ahour}"
	wks = gsn_open_wks("ps", outfile )
	gsn_define_colormap(wks,"WhBlGrYeRe")
    	x1 = f1->FORM($ihour,0,:,:)*1.
    	res@lbTitleString = "ppb"
;	res@cnLevels             = (/0.30, 0.35, 0.40, 0.45, 0.50, 0.60, 0.70, 0.80, 0.9, 1.0, 1.5, 2.0/)
	res@cnLevels             = (/.015, .030, .060, 0.12, 0.25, 0.50, 1.0,  2.,   4. , 8.,  16., 32./)
	map = gsn_csm_contour_map(wks, x1, res)
	draw(map)
     end if

     if ( PLOT_SO2 .eq. "Y" ) then
        delete(res@cnLevels)
        outfile = "$PSDIR"+"/airpact5_SO2_"+"${currentday}"+"${ahour}"
        wks = gsn_open_wks("ps", outfile )
        gsn_define_colormap(wks,"WhBlGrYeRe")
        x1 = f1->SO2($ihour,0,:,:)*1.0
        res@lbTitleString = "ppb"
	res@cnLevels             = (/0.6, 0.8, 1, 2, 4, 6, 8, 10, 20, 40, 60, 80, 100, 300/)
        map = gsn_csm_contour_map(wks, x1, res)
        draw(map)
     end if

     if ( PLOT_NH3 .eq. "Y" ) then
	delete(res@cnLevels) 
    	outfile = "$PSDIR"+"/airpact5_NH3_"+"${currentday}"+"${ahour}"
	wks = gsn_open_wks("ps", outfile )
	gsn_define_colormap(wks,"WhBlGrYeRe")
    	x1 = f1->NH3($ihour,0,:,:)*1.0
    	res@lbTitleString = "ppb"
    	res@cnLevels             = (/0.4, 0.6, 0.8, 1, 2, 4, 6, 8, 10, 20, 40, 60, 80, 100, 200, 500/)
	map = gsn_csm_contour_map(wks, x1, res)
	draw(map)
     end if

     if ( PLOT_ISOPRENE .eq. "Y" ) then
	delete(res@cnLevels) 
    	outfile = "$PSDIR"+"/airpact5_ISOPRENE_"+"${currentday}"+"${ahour}"
	wks = gsn_open_wks("ps", outfile )
	gsn_define_colormap(wks,"WhBlGrYeRe")
    	x1 = f1->ISOP($ihour,0,:,:)*1.0
    	res@lbTitleString = "ppb"
    	res@cnLevels             = (/0.02, 0.04, 0.06, 0.08, 0.1, 0.2, 0.40, 0.60, 0.80, 1.0, 2.0/)
	map = gsn_csm_contour_map(wks, x1, res)
	draw(map)
     end if 

     if ( PLOT_CO .eq. "Y" ) then
	delete(res@cnLevels) 
    	outfile = "$PSDIR"+"/airpact5_CO_"+"${currentday}"+"${ahour}"
	wks = gsn_open_wks("ps", outfile )
	gsn_define_colormap(wks,"WhBlGrYeRe")
    	x1 = f1->CO($ihour,0,:,:)/1000.
    	res@lbTitleString = "ppm"
    	res@cnLevels             = (/0.12, 0.14, 0.16, 0.18, 0.20, 0.25, 0.30, 0.4, 0.6, 0.8, 1.0, 2.0, 4.0/)
	map = gsn_csm_contour_map(wks, x1, res)
	draw(map)
     end if

     if ( PLOT_VOCs .eq. "Y" ) then
	delete(res@cnLevels) 
    	outfile = "$PSDIR"+"/airpact5_VOCs_"+"${currentday}"+"${ahour}"
	wks = gsn_open_wks("ps", outfile )
	gsn_define_colormap(wks,"WhBlGrYeRe")
    	x1 = f1->VOC($ihour,0,:,:)*1.0
    	res@lbTitleString = "ppbC"
    	res@cnLevels             = (/10, 20, 30, 40, 50, 60, 80, 100, 150, 200, 250, 300, 400/)
	map = gsn_csm_contour_map(wks, x1, res)
	draw(map)
     end if

     if ( PLOT_PM25 .eq. "Y" ) then
	delete(res@cnLevels) 
    	outfile = "$PSDIR"+"/airpact5_PM25_"+"${currentday}"+"${ahour}"
	wks = gsn_open_wks("ps", outfile )
	gsn_define_colormap(wks,"WhBlGrYeRe")
	x1 = f1->PMIJ($ihour,0,:,:)*1.0
	res@lbTitleString = ":F33:m:F0:g/m:S:3:N:"; should result in micrograms per cubic meter
   	res@cnLevels             = (/1.0, 2.0, 4.0, 6.0, 8.0 ,10 ,15, 20 ,30, 40 ,80 ,160/)
	map = gsn_csm_contour_map(wks, x1, res)
	draw(map)
     end if

     if ( PLOT_WSPM25 .eq. "Y" ) then ; 2014-11-28
	delete(res@cnLevels) 
    	outfile = "$PSDIR"+"/airpact5_WSPM25_"+"${currentday}"+"${ahour}"
	wks = gsn_open_wks("ps", outfile )
	gsn_define_colormap(wks,"WhBlGrYeRe")
	x1 = f1->WSPM25($ihour,0,:,:)*1.0
	res@lbTitleString = ":F33:m:F0:g/m:S:3:N:"; should result in micrograms per cubic meter
   	res@cnLevels             = (/1.0, 2.0, 4.0, 6.0, 8.0 ,10 ,15, 20 ,30, 40 ,80 ,160/)
	map = gsn_csm_contour_map(wks, x1, res)
	draw(map)
     end if

     if ( PLOT_ANO3 .eq. "Y" ) then
        delete(res@cnLevels)
        outfile = "$PSDIR"+"/airpact5_ANO3_"+"${currentday}"+"${ahour}"
        wks = gsn_open_wks("ps", outfile )
        gsn_define_colormap(wks,"WhBlGrYeRe")
        x1 = f1->ANO3IJ($ihour,0,:,:)*1.0
        res@lbTitleString = ":F33:m:F0:g/m:S:3:N:"; should result in micrograms per cubic meter
        res@cnLevels             = (/0.01, 0.1, 0.5, 1.0, 2.0, 4.0, 6.0, 8.0, 10, 15, 20, 40/)
        map = gsn_csm_contour_map(wks, x1, res)
        draw(map)
     end if

     if ( PLOT_AOMIJ .eq. "Y" ) then
        delete(res@cnLevels)
        outfile = "$PSDIR"+"/airpact5_AOMIJ_"+"${currentday}"+"${ahour}"
        wks = gsn_open_wks("ps", outfile )
        gsn_define_colormap(wks,"WhBlGrYeRe")
        x1 = f1->AOMIJ($ihour,0,:,:)*1.0
        res@lbTitleString = ":F33:m:F0:g/m:S:3:N:"; should result in micrograms per cubic meter
        res@cnLevels             = (/0.01, 0.1, 0.5, 1.0, 2.0, 4.0, 6.0, 8.0, 10, 15, 20, 40/)
        map = gsn_csm_contour_map(wks, x1, res)
        draw(map)
     end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end 

EOF
# end of hourly.ncl

       ncl -Q $NCLSCRIPTS/hourly.ncl
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

/bin/rm -f $NCLSCRIPTS/hourly.ncl
exit
