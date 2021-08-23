; This is s sample NCL script.
; This one plots total N deposition as color contours and
; 27th vertical layer(10140.36 m above the ground) u and v as vectors.
;
; Lots of NCL example scripts can be found at
;
;    http://ncl.ucar.edu/Applications/
;
; Load some libraries (do not edit the following two lines):

  load "/home/lar/opt/ncl-6.0.0/gcc-4.1.2/lib/ncarg/nclscripts/csm/gsn_code.ncl"
  load "/home/lar/opt/ncl-6.0.0/gcc-4.1.2/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  ; open NetCDF files.
  ; file(s) of data to plot (remember that even if the netcdf file name doesn't end with ".nc",
  ; must include ".nc" in NCL script)
    INFILE = addfile ( "/home/airpact5/AIRHOME/run_ap5_day1/post/cctm/deposition/request_ECY/NSdep_annualsum_2016.ncf.nc","r")

  ; File(s) with latitude and longitude values.
    g1 = addfile ( "/home/airpact5/AIRHOME/run_ap5_day1/post/cctm/deposition/request_ECY/GRIDCRO2D.nc","r")

  ; read latitude and longitude of the grid
    g1lat = g1->LAT(0,0,:,:) 
    g1lon = g1->LON(0,0,:,:) 

  ; get dimension from lat/lon info 
    nlat = dimsizes(g1lat(:,0))
    nlon = dimsizes(g1lon(0,:))

 ;  (options are ncgm, png, pdf, ps, and eps )
    outtype = "png"

  ; Puget Sound Area
   lat_trim = 150   ;lat_trim is trimming # of cells
   lon_trim = 170



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
       ; res@mpLeftCornerLatF  = g1lat(0,0)
       ; res@mpLeftCornerLonF  = g1lon(0,0)
       ; res@mpRightCornerLatF = g1lat(nlat-1,nlon-1)
       ; res@mpRightCornerLonF = g1lon(nlat-1,nlon-1)

        res@mpLeftCornerLatF  = g1lat(lat_trim-1,0)
        res@mpLeftCornerLonF  = g1lon(lat_trim-1,0)
        res@mpRightCornerLatF = g1lat(nlat-1,nlon-lon_trim-1)
        res@mpRightCornerLonF = g1lon(nlat-1,nlon-lon_trim-1)

        res@mpDataBaseVersion            = "MediumRes"
        res@mpOutlineBoundarySets        = "GeophysicalAndUSStates"
        res@mpUSStateLineThicknessF      = 2.5
        res@mpGeophysicalLineThicknessF  = 2.5
        res@mpNationalLineThicknessF     = 3.0

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

     outfile = "./AP5_totalNdep_2016"
     wks = gsn_open_wks(outtype, outfile )                                      
     gsn_define_colormap(wks,"wh-bl-gr-ye-re")
     x1 = INFILE->totDepTotN(0,0,:,:)*1.000
     
     res@lbTitleString = "kg-N/ha/yr"
     res@tiMainString  = "Total (wet+dry) Nitrogen Deposition"
     res@cnLevels      = (/0.05, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0/)
     map = gsn_csm_contour_map(wks, x1, res)
     draw(map)
    ; advance the frame
    frame(wks)



end  ;close of begin

