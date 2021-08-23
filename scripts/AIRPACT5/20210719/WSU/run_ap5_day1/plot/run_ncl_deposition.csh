#!/bin/csh -f

# Example of using this script:
# 
#   > run_ncl_deposition.csh 201605
#
#    where 201205 denotes YYYYMM
#
# Serena H. Chung        2016-06-20
# Farren Herron-Thorpe   2016-06-09
# Serena H. Chung        2012-05-03

# This C shell script creates monthly maps of deposition based on AIRPACT-5's
# CMAQ output files that have been summed using code in ~/AIRHOME/run_ap5_day1/post/cctm/deposition. 


#> initialize exit status ----------------------------------------------
   set exitstat = 0

#> check argument & set date strings  ----------------------------------

   if ( $#argv == 1 ) then
      setenv YEAR `echo $1 | cut -c1-4`
      setenv MONTH `echo $1 | cut -c5-6`
      echo "create deposition images for" $YEAR $MONTH
   else
      echo 'invalid argument. '
      echo "usage $0 <yyyymm>"
      set exitstat = 1
      exit ( $exitstat )
   endif
   set yyyymm = ${YEAR}${MONTH}

#> during testing

   if ( ! $?PBS_O_WORKDIR ) then
      set PBS_O_WORKDIR = ~airpact5/AIRHOME/run_ap5_day1
      if ( ! $?AIRHOME        ) set AIRHOME = ~airpact5/AIRHOME
   endif

   set indir = /data/lar/projects/airpact5/saved/$YEAR/$MONTH/deposition
   set outdir = /data/lar/projects/airpact5/AIRRUN/$YEAR/IMAGES/deposition
#> initialize exit status ----------------------------------------------
   set exitstat = 0

#> directory set-up ----------------------------------------------------

   set NCLSCRIPTS = ${PBS_O_WORKDIR}/plot
   set PSDIR      = ${outdir}/ps
   mkdir -p $PSDIR

# > create and run ncl script hour by hour ----------------------------

cat > $NCLSCRIPTS/monthly_deposition.ncl <<EOF

;*************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  ; open NetCDF files.
  ; file(s) of data to plot (remember that even if the netcdf file name doesn't end with ".nc",
  ; must include ".nc" in NCL script)
    INFILE = addfile ( "$indir" + "/NSdep_monthlysum_${1}.ncf.nc","r")

  ; File(s) with latitude and longitude values.
    g1 = addfile ( "${NCLSCRIPTS}" + "/GRIDCRO2D.nc","r")

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
	res@cnFillMode      = "RasterFill"
	res@cnFillOn        = True
	res@cnLevelSelectionMode = "ExplicitLevels"
	res@lbOrientation   = "Vertical"
        res@mpPerimOn           = False
        res@mpProjection        = "LambertConformal"
        res@mpLambertParallel1F = g1@P_ALP
        res@mpLambertParallel2F = g1@P_BET
        res@mpLambertMeridianF  = g1@P_GAM
        res@mpLimitMode         = "Corners"
        res@mpLeftCornerLatF  = g1lat(0,0)
        res@mpLeftCornerLonF  = g1lon(0,0)
        res@mpRightCornerLatF = g1lat(nlat-1,nlon-1)
        res@mpRightCornerLonF = g1lon(nlat-1,nlon-1)
        res@gsnPaperOrientation = "Portrait"
        res@cnGridBoundFillPattern = "SolidFill"
        res@cnGridBoundFillColor = "White"
	res@cnGridBoundPerimOn = True
	res@mpOutlineOn = True
	res@mpDataBaseVersion = "Ncarg4_1";
	res@mpDataSetName = "Earth..4"; replace with "Earth..3" for climate lines
	res@mpOutlineBoundarySets = "AllBoundaries"; GeophysicalAndUSStates was old option	
	res@lbTitleOn        = True ; turn on title
	res@lbTitleString    = "units"
	res@tiMainString	= "deposition"
  ; ------------------------------------------------------------------
  ; START PLOTTING
  ; ------------------------------------------------------------------
     x1 = g1lat*1.0
      x1@lat2d = g1lat    ; setting 2D lat/lon coords for all species
      x1@lon2d = g1lon

         outfile = "$PSDIR"+"/AP5DEP_DRYNGAS_"+"${1}"
         wks = gsn_open_wks("ps", outfile )                                      
         gsn_define_colormap(wks,"wh-bl-gr-ye-re")
         x1 = INFILE->dryDepGasN(0,0,:,:)*1.000
         res@lbTitleString = "kg/ha"
         res@tiMainString  = "Nitrogen Dry Deposition (Gas)"
         res@cnLevels      = (/0.001, 0.002, 0.005, 0.01, 0.02, 0.05, 0.1, 0.2, 0.5, 1, 2, 5, 10/)
	 map = gsn_csm_contour_map(wks, x1, res)
	 draw(map)

         delete(res@cnLevels)
         outfile = "$PSDIR"+"/AP5DEP_DRYNAER_"+"${1}"
         wks = gsn_open_wks("ps", outfile )
         gsn_define_colormap(wks,"wh-bl-gr-ye-re")
         x1 = INFILE->dryDepAerN(0,0,:,:)*1.000
         res@lbTitleString = "kg/ha"
	 res@tiMainString  = "Nitrogen Dry Deposition (Aerosol)"
         res@cnLevels      = (/0.001, 0.002, 0.005, 0.01, 0.02, 0.05, 0.1, 0.2, 0.5, 1, 2, 5, 10/)
         map = gsn_csm_contour_map(wks, x1, res)
         draw(map)

         delete(res@cnLevels)
         outfile = "$PSDIR"+"/AP5DEP_DRYNTOT_"+"${1}"
         wks = gsn_open_wks("ps", outfile )
         gsn_define_colormap(wks,"wh-bl-gr-ye-re")
         x1 = INFILE->dryDepTotN(0,0,:,:)*1.000
         res@lbTitleString = "kg/ha"
	 res@tiMainString  = "Nitrogen Dry Deposition (Total)"
         res@cnLevels      = (/0.001, 0.002, 0.005, 0.01, 0.02, 0.05, 0.1, 0.2, 0.5, 1, 2, 5, 10/)
         map = gsn_csm_contour_map(wks, x1, res)
         draw(map)

         delete(res@cnLevels)
         outfile = "$PSDIR"+"/AP5DEP_DRYSGAS_"+"${1}"
         wks = gsn_open_wks("ps", outfile )
         gsn_define_colormap(wks,"wh-bl-gr-ye-re")
         x1 = INFILE->dryDepGasS(0,0,:,:)*1.000
         res@lbTitleString = "kg/ha"
	 res@tiMainString  = "Sulfur Dry Deposition (Gas)"
         res@cnLevels      = (/0.001, 0.002, 0.005, 0.01, 0.02, 0.05, 0.1, 0.2, 0.5, 1, 2, 5, 10/)
         map = gsn_csm_contour_map(wks, x1, res)
         draw(map)

         delete(res@cnLevels)
         outfile = "$PSDIR"+"/AP5DEP_DRYSAER_"+"${1}"
         wks = gsn_open_wks("ps", outfile )
         gsn_define_colormap(wks,"wh-bl-gr-ye-re")
         x1 = INFILE->dryDepAerS(0,0,:,:)*1.000
         res@lbTitleString = "kg/ha"
	 res@tiMainString  = "Sulfur Dry Deposition (Aerosol)"
         res@cnLevels      = (/0.001, 0.002, 0.005, 0.01, 0.02, 0.05, 0.1, 0.2, 0.5, 1, 2, 5, 10/)
         map = gsn_csm_contour_map(wks, x1, res)
         draw(map)

         delete(res@cnLevels)
         outfile = "$PSDIR"+"/AP5DEP_DRYSTOT_"+"${1}"
         wks = gsn_open_wks("ps", outfile )
         gsn_define_colormap(wks,"wh-bl-gr-ye-re")
         x1 = INFILE->dryDepTotS(0,0,:,:)*1.000
         res@lbTitleString = "kg/ha"
	 res@tiMainString  = "Sulfur Dry Deposition (Total)"
         res@cnLevels      = (/0.001, 0.002, 0.005, 0.01, 0.02, 0.05, 0.1, 0.2, 0.5, 1, 2, 5, 10/)
         map = gsn_csm_contour_map(wks, x1, res)
         draw(map)

         delete(res@cnLevels)
         outfile = "$PSDIR"+"/AP5DEP_WETNGAS_"+"${1}"
         wks = gsn_open_wks("ps", outfile )
         gsn_define_colormap(wks,"wh-bl-gr-ye-re")
         x1 = INFILE->wetDepGasN(0,0,:,:)*1.000
         res@lbTitleString = "kg/ha"
         res@tiMainString  = "Nitrogen Wet Deposition (Gas)"
         res@cnLevels      = (/0.001, 0.002, 0.005, 0.01, 0.02, 0.05, 0.1, 0.2, 0.5, 1, 2, 5, 10/)
         map = gsn_csm_contour_map(wks, x1, res)
         draw(map)

         delete(res@cnLevels)
         outfile = "$PSDIR"+"/AP5DEP_WETNAER_"+"${1}"
         wks = gsn_open_wks("ps", outfile )
         gsn_define_colormap(wks,"wh-bl-gr-ye-re")
         x1 = INFILE->wetDepAerN(0,0,:,:)*1.000
         res@lbTitleString = "kg/ha"
	 res@tiMainString  = "Nitrogen Wet Deposition (Aerosol)"
         res@cnLevels      = (/0.001, 0.002, 0.005, 0.01, 0.02, 0.05, 0.1, 0.2, 0.5, 1, 2, 5, 10/)
         map = gsn_csm_contour_map(wks, x1, res)
         draw(map)

         delete(res@cnLevels)
         outfile = "$PSDIR"+"/AP5DEP_WETNTOT_"+"${1}"
         wks = gsn_open_wks("ps", outfile )
         gsn_define_colormap(wks,"wh-bl-gr-ye-re")
         x1 = INFILE->wetDepTotN(0,0,:,:)*1.000
         res@lbTitleString = "kg/ha"
	 res@tiMainString  = "Nitrogen Wet Deposition (Total)"
         res@cnLevels      = (/0.001, 0.002, 0.005, 0.01, 0.02, 0.05, 0.1, 0.2, 0.5, 1, 2, 5, 10/)
         map = gsn_csm_contour_map(wks, x1, res)
         draw(map)

         delete(res@cnLevels)
         outfile = "$PSDIR"+"/AP5DEP_WETSGAS_"+"${1}"
         wks = gsn_open_wks("ps", outfile )
         gsn_define_colormap(wks,"wh-bl-gr-ye-re")
         x1 = INFILE->wetDepGasS(0,0,:,:)*1.000
         res@lbTitleString = "kg/ha"
	 res@tiMainString  = "Sulfur Wet Deposition (Gas)"
         res@cnLevels      = (/0.001, 0.002, 0.005, 0.01, 0.02, 0.05, 0.1, 0.2, 0.5, 1, 2, 5, 10/)
         map = gsn_csm_contour_map(wks, x1, res)
         draw(map)

         delete(res@cnLevels)
         outfile = "$PSDIR"+"/AP5DEP_WETSAER_"+"${1}"
         wks = gsn_open_wks("ps", outfile )
         gsn_define_colormap(wks,"wh-bl-gr-ye-re")
         x1 = INFILE->wetDepAerS(0,0,:,:)*1.000
         res@lbTitleString = "kg/ha"
	 res@tiMainString  = "Sulfur Wet Deposition (Aerosol)"
         res@cnLevels     = (/0.001, 0.002, 0.005, 0.01, 0.02, 0.05, 0.1, 0.2, 0.5, 1, 2, 5, 10/)
         map = gsn_csm_contour_map(wks, x1, res)
         draw(map)

         delete(res@cnLevels)
         outfile = "$PSDIR"+"/AP5DEP_WETSTOT_"+"${1}"
         wks = gsn_open_wks("ps", outfile )
         gsn_define_colormap(wks,"wh-bl-gr-ye-re")
         x1 = INFILE->wetDepTotS(0,0,:,:)*1.000
         res@lbTitleString = "kg/ha"
	 res@tiMainString  = "Sulfur Wet Deposition (Total)"
         res@cnLevels      = (/0.001, 0.002, 0.005, 0.01, 0.02, 0.05, 0.1, 0.2, 0.5, 1, 2, 5, 10/)
         map = gsn_csm_contour_map(wks, x1, res)
         draw(map)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end 

EOF
# end of monthly.ncl

ncl -Q $NCLSCRIPTS/monthly_deposition.ncl

# convert to gif files
  set GIFDIR     = $outdir
  mkdir -p $GIFDIR
  cd $PSDIR
  foreach psfile ( *.ps )
    set fileroot = `echo $psfile | cut -d '.' -f 1 `
    convert -density 90 -crop 680x550+35+220 +repage $PSDIR/$psfile  $GIFDIR/${fileroot}.gif
    if ( -e $GIFDIR/${fileroot}.gif ) then
       convert -resize 680x550 +repage $GIFDIR/${fileroot}.gif  $GIFDIR/${fileroot}.gif
       chmod a+r $GIFDIR/${fileroot}.gif
       /bin/rm -f $PSDIR/$psfile
    endif
  end
  cd ../
  rmdir $PSDIR

/bin/rm -f $NCLSCRIPTS/monthly_deposition.ncl
exit
