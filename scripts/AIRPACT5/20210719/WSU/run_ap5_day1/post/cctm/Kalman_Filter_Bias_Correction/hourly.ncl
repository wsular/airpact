
;*************************************************

load "/home/lar/opt/ncl-6.0.0/gcc-4.1.2/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/home/lar/opt/ncl-6.0.0/gcc-4.1.2/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  ; read in the options passed from the csh
    border_option = getenv("ADD_BORDERS")
    scale_option  = getenv("ADD_COLORBAR")
    FillType      = getenv("IMAGEFILL")
    PLOT_PM25 = getenv("PLOT_PM25")

  ; open NetCDF files.
  ; file(s) of data to plot (remember that even if the netcdf file name does not end with ".nc",
  ; must include ".nc" in NCL script)
    f1 = addfile ( "/data/lar/projects/airpact5/AIRRUN/2021/2021081800/POST/CCTM" + "/PM25_24hr_BiasCorrected_2021081800.ncf.nc","r")
  ; File(s) with latitude and longitude values.
    g1 = addfile ( "/data/lar/projects/airpact5/AIRRUN/2021/2021081800/MCIP37" + "/GRIDCRO2D.nc","r")

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
     if ( PLOT_PM25 .eq. "Y" ) then
	; delete(res@cnLevels) 
    	outfile = "/data/lar/projects/airpact5/AIRRUN/2021/2021081800/IMAGES/KFBC"+"/KFBC_PM25_CubicInt_"+"20210818"+"00"
	wks = gsn_open_wks("ps", outfile )
	gsn_define_colormap(wks,"WhBlGrYeRe")
	x1 = f1->KFBC_PM25_CubicI(0,0,:,:)*1.0
	res@lbTitleString = ":F33:m:F0:g/m:S:3:N:"; should result in micrograms per cubic meter
   	res@cnLevels             = (/1.0, 2.0, 4.0, 6.0, 8.0 ,10 ,15, 20 ,30, 40 ,80 ,160/)
	map = gsn_csm_contour_map(wks, x1, res)
	draw(map)
	outfile = "/data/lar/projects/airpact5/AIRRUN/2021/2021081800/IMAGES/KFBC"+"/KFBC_PM25_LinKrig_"+"20210818"+"00"
	wks = gsn_open_wks("ps", outfile )
	gsn_define_colormap(wks,"WhBlGrYeRe")
	x1 = f1->KFBC_PM25_LinKri(0,0,:,:)*1.0
	res@lbTitleString = ":F33:m:F0:g/m:S:3:N:"; should result in micrograms per cubic meter
   	res@cnLevels             = (/1.0, 2.0, 4.0, 6.0, 8.0 ,10 ,15, 20 ,30, 40 ,80 ,160/)
	map = gsn_csm_contour_map(wks, x1, res)
	draw(map)
	outfile = "/data/lar/projects/airpact5/AIRRUN/2021/2021081800/IMAGES/KFBC"+"/KFBC_PM25_GausKrig_"+"20210818"+"00"
	wks = gsn_open_wks("ps", outfile )
	gsn_define_colormap(wks,"WhBlGrYeRe")
	x1 = f1->KFBC_PM25_GausKr(0,0,:,:)*1.0
	res@lbTitleString = ":F33:m:F0:g/m:S:3:N:"; should result in micrograms per cubic meter
   	res@cnLevels             = (/1.0, 2.0, 4.0, 6.0, 8.0 ,10 ,15, 20 ,30, 40 ,80 ,160/)
	map = gsn_csm_contour_map(wks, x1, res)
	draw(map)
     end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end 

