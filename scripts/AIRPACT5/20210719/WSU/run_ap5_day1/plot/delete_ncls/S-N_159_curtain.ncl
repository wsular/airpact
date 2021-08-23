
;*************************************************

load "/home/lar/opt/ncl-6.0.0/gcc-4.1.2/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/home/lar/opt/ncl-6.0.0/gcc-4.1.2/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/home/lar/opt/ncl-6.0.0/gcc-4.1.2/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/home/lar/opt/ncl-6.0.0/gcc-4.1.2/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

  ; open NetCDF files.
  ; file(s) of data to plot (remember that even if the netcdf file name doesn't end with ".nc",
  ; must include ".nc" in NCL script)

    fconc = addfile ("/data/lar/projects/airpact5/AIRRUN/2017/2017121100" + "/CCTM/ACONC_" + "20171211" + ".ncf.nc", "r")
    fgrid = addfile ("/data/lar/projects/airpact5/AIRRUN/2017/2017121100/MCIP37" + "/GRIDCRO2D.nc", "r")
    fmet  = addfile ("/data/lar/projects/airpact5/AIRRUN/2017/2017121100/MCIP37" + "/METCRO3D.nc", "r")
    ; itime = stringtointeger(getenv("ihour"))
    itime = 23

;********************************************************
; Read in data
;********************************************************
  ; position and time to read
    icol = 159 - 1 ; because index in ncl ranges from 0...
  ; Longitude of ID/WA Border is -117 and icol is ~155 
  ; ozone & co concentration
    o3      = fconc->O3(itime,:,:,icol)*1000.    ; time,level,j,i
    co      = fconc->CO(itime,:,:,icol)*1000.    ; time,level,j,i    
    ; define/modify dimensions and attributes in a way that NCL understands
    ;  o3!0 = "time"       ; first dimension
      o3!0 = "lev"       ; second dimension
      o3!1 = "south_north" ; third dimension
      o3@long_name = "Ozone Concentrations"
      o3@units = "ppb"
     ; co!0 = "time"       ; first dimension
      co!0 = "lev"       ; second dimension
      co!1 = "south_north" ; third dimension
      co@long_name = "Carbon Monoxide"
      co@units = "ppb"

   ; get dimension sizes
     dimsiz = dimsizes(o3)
   ;  ntime = dimsiz(0) ; number of time steps
     mz    = dimsiz(0) ; number of vertical layers
     my    = dimsiz(1) ; number of rows

  ; pressure at mid-level
    pres      = fmet->PRES(itime,:,:,icol)         ; time,level,j,i
    ; define/modify dimensions and attributes in a way that NCL understands
    ;  pres!0 = "time"
      pres!0 = "lev"
      pres!1 = "south_north"
      pres@long_name = "Pressure at Mid-Level"
      pres@units = "Pa"

  ; layer top height above ground
    h_top_agl    = fmet->ZF(itime,:,:,icol)/1000.         ; time,level,j,i
    ; define/modify dimensions and attributes in a way that NCL understands
    ;  h_top_agl!0 = "time"
      h_top_agl!0 = "lev"
      h_top_agl!1 = "south_north"
      h_top_agl@long_name = "Mid-Layer Height Above Ground"
      h_top_agl@units = "Kilometers"
  ; terrain height above sea-level
    HT = fgrid->HT(0,0,:,icol)/1000.   ; terrain elevation TSTEP,LAY,ROW,COL
    h_top_asl = h_top_agl ; "initialize" with dimension time, level, j
    do j  = 0, my-1
       h_top_asl(:,j) = h_top_agl(:,j) + HT(j) 
    end do

 ; force elev of 0 a.s.l. into a single point along boundary JKV 050317
    h_top_asl(0,0) = 0.0

  ; height above sea level for each cell's top and bottom
    h_bound_asl = new((/mz+1,my/),typeof(h_top_asl))
    h_bound_asl(0,:) = HT(:) ; lev
    do ilevel  = 1, mz
       h_bound_asl(ilevel,:) = h_top_asl(ilevel-1,:)
    end do


  ; get/assign some dimension information
    dy       = fconc@YCELL/1000.         ; horizontal resolution in y-direction in km
    south_north_1d  = ispan(0,my-1,1)*dy
    dims_array = dimsizes(pres(lev|:,south_north|:))
    south_north = new((/mz+1,my/),typeof(south_north_1d))
    do i = 0,dimsizes(south_north_1d)-1
       south_north(:,i)=south_north_1d(i)
    end do
    south_north@long_name = "South-to-North"
    south_north@units = "Kilometers"

    ;min_distance = min(south_north)
    ;max_distance = max(south_north)
    ;min_height = min(h_bound_asl)
    ;max_height = max(h_bound_asl)

;********************************************************
; shared resources
;********************************************************

     res                 = True            ; plot mods desired
     res@gsnDraw         = False   ; Don't draw plot (will do later)
     res@gsnFrame        = False   ; Don't advance framce  (will do later)
     res@trGridType            = "TriangularMesh"
     res@sfXArray              = south_north
     res@cnFillOn              = True            ; turn on color
     res@cnFillMode            = "AreaFill"
     ;res@cnCellFillEdgeColor   = "gray80"
     res@cnCellFillMissingValEdgeColor   = "gray80"
     res@cnMissingValFillColor = "black"
      res@cnLinesOn             = False           ; turn off contour lines
      res@gsnSpreadColors       = True            ; use entire color map
      res@cnLevelSelectionMode = "ExplicitLevels"
      res@lbTitleOffsetF     = -0.03 ; move the title down (+) or up (-)
       res@tmXBMajorOutwardLengthF = 0.0               ; draw tickmarks inward
       res@tmXBMinorOutwardLengthF = 0.0               ; draw minor ticsk inward
       res@tmYLMajorOutwardLengthF = 0.0               ; draw tickmarks inward
       res@tmYLMinorOutwardLengthF = 0.0               ; draw minor ticsk inward
	res@gsnPaperOrientation = "Landscape"
       ;   res@tiMainString         = "AIRPACT-5, " + location_description
          res@gsnLeftString       = " "
          res@gsnCenterString        = "12"+"-"+"11"+"-"+"2017 ( hour 23 PST )"
          ; res@gsnCenterString        = "12"+"-"+"11"+"-"+"2017 ( hour AHOUR PST )"
          res@gsnRightString       = " "
          res@tiXAxisString        = "South to North (km)"   ; x-axis title
          res@tiYAxisString        = "Height Above Sea Level (km)"
          ; bcon res@sfYArray              = h_bound_asl(:,:)
          res@sfYArray              = h_bound_asl(:,:)
	res@gsnMaximize = True
	res@lbOrientation         = "Vertical"      ; move label bar

	res@trYMinF =  0.0
	res@trYMaxF = 20.0


;********************************************************
; create plots
;********************************************************
  ; ozone
    location_description = "South-to-North Curtain Plot for Col 159 "
    res@tiMainString         = "Ozone " + location_description
    wks = gsn_open_wks("ps" ,"/data/lar/projects/airpact5/AIRRUN/2017/2017121100/IMAGES/aconc/ps"+"/airpact5_S-N_159_o3_curtain_" + "23")
    gsn_define_colormap(wks,"BlGrYeOrReVi200")           ; select color map
    res@cnLevels             = (/40,50,60,65,70,75,80,90,100,120,150,200,400/)
    res@lbTitleString         = "(" + o3@units + ")"
    plot  = gsn_csm_contour(wks,o3(:,:),res)
    draw(plot)

;   ; Linearize the plot by overlaying on a logLinPlot. It's important to use the
;   ; "curvilinear" gridType instead of the default 2D "spherical" grid type
;   ; because the spherical grid type assumes that the X coordinates are modular
;   ; and that the Y coordinates only range from -90 to 90.
;
;     setvalues plot
;       "trGridType"    : "curvilinear"
;       "tiMainString"  : "AIRPACT-5 O3 S-N Curtain Plot for Col 159 "
;       "tiXAxisString" : "South to North (km)"    ; x-axis title
;       "tiYAxisString" : "Height Above Sea Level (km)" ; y-axis title
;       "cnFillMode"    : "RasterFill"
;     end setvalues
;
;   ; Create the irregular domain on which to overlay the contours.
;   ; Here's where we can force the tickmarks to point outward.
;
;     ll = create "ll" logLinPlotClass wks
;       "trXMinF"                 : min_distance
;       "trXMaxF"                 : max_distance
;       "trYMinF"                 : min_height
;       "trYMaxF"                 : max_height
;
;       "pmTickMarkDisplayMode"   : "always"
;       "tmYLMajorOutwardLengthF" : 0.02
;       "tmXBMajorOutwardLengthF" : 0.02
;       "tmYLMinorOutwardLengthF" : 0.01
;       "tmXBMinorOutwardLengthF" : 0.01
;       "tmYLMajorLengthF"        : 0.02
;       "tmXBMajorLengthF"        : 0.02
;       "tmYLMinorLengthF"        : 0.01
;       "tmXBMinorLengthF"        : 0.01
;     end create
;
;    overlay(ll, plot)
;    maximize_output(wks,False)

  ; CO
    location_description = "South-to-North Curtain Plot for Col 159 "
    res@tiMainString         = "CO " + location_description
    wks = gsn_open_wks("ps" ,"/data/lar/projects/airpact5/AIRRUN/2017/2017121100/IMAGES/aconc/ps"+"/airpact5_S-N_159_co_curtain_" + "23")          ; ps,pdf,x11,ncgm,eps
    gsn_define_colormap(wks,"BlGrYeOrReVi200")           ; select color map
    res@cnLevels             = (/50,100,120,140,160,180,200,220,240,260,280,300,400/)
    res@lbTitleString         = "(" + co@units + ")"
    plot  = gsn_csm_contour(wks,co(:,:),res)
    draw(plot)

;    ; Linearize the plot by overlaying on a logLinPlot. It's important to use the
;    ; "curvilinear" gridType instead of the default 2D "spherical" grid type
;    ; because the spherical grid type assumes that the X coordinates are modular
;    ; and that the Y coordinates only range from -90 to 90.
;      setvalues plot
;        "trGridType"    : "curvilinear"
;        "tiMainString"  : "AIRPACT-5 CO S-N Curtain Plot for Col 159 "
;        "tiXAxisString" : "South to North (km)"    ; x-axis title
;        "tiYAxisString" : "Height Above Sea Level (km)" ; y-axis title
;        "cnFillMode"    : "RasterFill"
;      end setvalues
;
;    ; Create the irregular domain on which to overlay the contours.
;    ; Here's where we can force the tickmarks to point outward.
;      ll = create "ll" logLinPlotClass wks
;        "trXMinF"                 : min_distance
;        "trXMaxF"                 : max_distance
;        "trYMinF"                 : min_height
;        "trYMaxF"                 : max_height
;        "pmTickMarkDisplayMode"   : "always"
;        "tmYLMajorOutwardLengthF" : 0.02
;        "tmXBMajorOutwardLengthF" : 0.02
;        "tmYLMinorOutwardLengthF" : 0.01
;        "tmXBMinorOutwardLengthF" : 0.01
;        "tmYLMajorLengthF"        : 0.02
;        "tmXBMajorLengthF"        : 0.02
;        "tmYLMinorLengthF"        : 0.01
;        "tmXBMinorLengthF"        : 0.01
;      end create
;
;    overlay(ll, plot)
;    maximize_output(wks,False)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end 

