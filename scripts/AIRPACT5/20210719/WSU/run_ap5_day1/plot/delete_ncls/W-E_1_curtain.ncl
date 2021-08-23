
;*************************************************

load "/home/lar/opt/ncl-6.0.0/gcc-4.1.2/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/home/lar/opt/ncl-6.0.0/gcc-4.1.2/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/home/lar/opt/ncl-6.0.0/gcc-4.1.2/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/home/lar/opt/ncl-6.0.0/gcc-4.1.2/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

  ; open NetCDF files.
  ; file(s) of data to plot (remember that even if the netcdf file name doesn't end with ".nc",
  ; must include ".nc" in NCL script)

    fconc = addfile ("/data/lar/projects/airpact5/AIRRUN/2017/2017120500" + "/CCTM/CONC_" + "20171205" + ".ncf.nc", "r")
    fgrid = addfile ("/data/lar/projects/airpact5/AIRRUN/2017/2017120500/MCIP37" + "/GRIDCRO2D.nc", "r")
    fmet  = addfile ("/data/lar/projects/airpact5/AIRRUN/2017/2017120500/MCIP37" + "/METCRO3D.nc", "r")
    itime = stringtointeger(getenv("ihour"))

;********************************************************
; Read in data
;********************************************************
  ; position and time to read
    irow= 1  - 1  ; because subscripts run from 0 ...
    location_description = "West-to-East Curtain Plot for Row 1 "
  ; ozone & co concentration
    o3      = fconc->O3(:,:,irow,:)*1000.    ; time,level,j,i
    co      = fconc->CO(:,:,irow,:)*1000.    ; time,level,j,i    
    ; define/modify dimensions and attributes in a way that NCL understands
      o3!0 = "time"       ; first dimension
      o3!1 = "lev"       ; second dimension
      o3!2 = "west_east" ; third dimension
      o3@long_name = "Ozone Concentrations"
      o3@units = "ppb"
      co!0 = "time"       ; first dimension
      co!1 = "lev"       ; second dimension
      co!2 = "west_east" ; third dimension
      co@long_name = "Carbon Monoxide"
      co@units = "ppb"

   ; get dimension sizes
     dimsiz = dimsizes(o3)
     ntime = dimsiz(0) ; number of time steps
     mz    = dimsiz(1) ; number of vertical layers
     my    = dimsiz(2) ; number of cols

  ; pressure at mid-level
    pres      = fmet->PRES(:,:,irow,:)         ; time,level,j,i
    ; define/modify dimensions and attributes in a way that NCL understands
      pres!0 = "time"
      pres!1 = "lev"
      pres!2 = "west_east"
      pres@long_name = "Pressure at Mid-Level"
      pres@units = "Pa"
  ; layer top height above ground
    h_top_agl    = fmet->ZF(:,:,irow,:)/1000.         ; time,level,j,i
    ; define/modify dimensions and attributes in a way that NCL understands
      h_top_agl!0 = "time"
      h_top_agl!1 = "lev"
      h_top_agl!2 = "west_east"
      h_top_agl@long_name = "Mid-Layer Height Above Ground"
      h_top_agl@units = "km"
  ; layer top height above sea-level
    HT = fgrid->HT(0,0,irow,:)/1000.   ; terrain elevation TSTEP,LAY,ROW,COL
    h_top_asl = h_top_agl ; "initialize" with dimension time, level, j
    do j  = 0, my-1
       h_top_asl(:,:,j) = h_top_agl(:,:,j) + HT(j) 
    end do
  ; height above sea level for each cell's top and bottom
    h_bound_asl = new((/ntime,mz+1,my/),typeof(h_top_asl))
    do istep = 0, ntime-1
       h_bound_asl(istep,0,:) = HT(:) ; time, lev, row
    end do
    do ilevel  = 1, mz
       h_bound_asl(:,ilevel,:) = h_top_asl(:,ilevel-1,:)
    end do


  ; get/assign some dimension information
    dx       = fconc@XCELL/1000.         ; horizontal resolution in x-directio in km
    west_east_1d  = ispan(0,my-1,1)*dx
    dims_array = dimsizes(pres(time|0,lev|:,west_east|:))
    west_east = new((/mz+1,my/),typeof(west_east_1d))
    do i = 0,dimsizes(west_east_1d)-1
       west_east(:,i)=west_east_1d(i)
    end do
    west_east@long_name = "West to East"
    west_east@units = "km"
    min_distance = min(west_east)
    max_distance = max(west_east)
    min_height = min(h_bound_asl)
    max_height = max(h_bound_asl)

;********************************************************
; shared resources
;********************************************************

  res                       = True            ; plot mods desired
  res@gsnDraw         = False   ; Don't draw plot (will do later)
  res@gsnFrame        = False   ; Don't advance framce  (will do later)
  res@gsnMaximize = True

  ; This resource is necessary if you use gsn_csm_contour,
  ; because this function wants to modify the tickmarks to point
  ; outward. Because this plot is overlaid on an irregular domain,
  ; tickmarks essentially don't exist, and hence we can't modify
  ; them. By setting gsnScale to False, we're telling gsn_csm_contour
  ; not to attempt to "scale" the tickmarks. We'll scale the
  ; tickmarks later.
    res@gsnScale        = False

  res@sfXArray         = west_east
  res@sfYArray         = h_bound_asl(itime,:,:)
  res@cnInfoLabelOn   = False               ; turn off contour info label

  res@cnFillOn          = True                ; turn on color
  res@cnLineLabelsOn    = False               ; turn off line labels
  res@gsnSpreadColors   = True                ; use full range of colormap
  res@cnLinesOn         = False               ; turn off contour lines

  res@cnLevelSelectionMode = "ExplicitLevels"
  res@lbTitleOffsetF     = -0.03 ; move the title down (+) or up (-)

  res@tiMainString         = "AIRPACT-5 at " + location_description
  res@gsnLeftString        = ""
  res@gsnCenterString      = "12"+"-"+"05"+"-"+"2017 ( hour 23 PST )"
  res@gsnRightString       = " "
  res@tiXAxisString        = "West to Esat (km)"   ; x-axis title
  res@lbOrientation        = "Vertical"      ; move label bar

;********************************************************
; create plots
;********************************************************
  ; ozone
    wks = gsn_open_wks("ps" ,"/data/lar/projects/airpact5/AIRRUN/2017/2017120500/IMAGES/conc/ps"+"/airpact5_W-E_1_o3_curtain_" + "23")
    gsn_define_colormap(wks,"BlGrYeOrReVi200")           ; select color map
    res@cnLevels             = (/40,50,60,65,70,75,80,90,100,120,150,200,400/)
    res@lbTitleString         = "(" + o3@units + ")"
    plot  = gsn_csm_contour(wks,o3(itime,:,:),res)

   ; Linearize the plot by overlaying on a logLinPlot. It's important to use the
   ; "curvilinear" gridType instead of the default 2D "spherical" grid type
   ; because the spherical grid type assumes that the X coordinates are modular
   ; and that the Y coordinates only range from -90 to 90.

     setvalues plot
       "trGridType"    : "curvilinear"
       "tiMainString"  : "AIRPACT-5 O3 W-E Curtain Plot for Row 1 "
       "tiXAxisString" : "West to East (km)"    ; x-axis title
       "tiYAxisString" : "Height Above Sea Level (km)" ; y-axis title
       "cnFillMode"    : "RasterFill"
     end setvalues

   ; Create the irregular domain on which to overlay the contours.
   ; Here's where we can force the tickmarks to point outward.

     ll = create "ll" logLinPlotClass wks
       "trXMinF"                 : min_distance
       "trXMaxF"                 : max_distance
       "trYMinF"                 : min_height
       "trYMaxF"                 : max_height

       "pmTickMarkDisplayMode"   : "always"
       "tmYLMajorOutwardLengthF" : 0.02
       "tmXBMajorOutwardLengthF" : 0.02
       "tmYLMinorOutwardLengthF" : 0.01
       "tmXBMinorOutwardLengthF" : 0.01
       "tmYLMajorLengthF"        : 0.02
       "tmXBMajorLengthF"        : 0.02
       "tmYLMinorLengthF"        : 0.01
       "tmXBMinorLengthF"        : 0.01
     end create

    overlay(ll, plot)
    maximize_output(wks,False)

  ; CO
    wks = gsn_open_wks("ps" ,"/data/lar/projects/airpact5/AIRRUN/2017/2017120500/IMAGES/conc/ps"+"/airpact5_W-E_1_co_curtain_" + "23")          ; ps,pdf,x11,ncgm,eps
    gsn_define_colormap(wks,"BlGrYeOrReVi200")           ; select color map
    res@cnLevels             = (/50,100,120,140,160,180,200,220,240,260,280,300,400/)
    res@lbTitleString         = "(" + co@units + ")"
    plot  = gsn_csm_contour(wks,co(itime,:,:),res)

    ; Linearize the plot by overlaying on a logLinPlot. It's important to use the
    ; "curvilinear" gridType instead of the default 2D "spherical" grid type
    ; because the spherical grid type assumes that the X coordinates are modular
    ; and that the Y coordinates only range from -90 to 90.
      setvalues plot
        "trGridType"    : "curvilinear"
       "tiMainString"  : "AIRPACT-5 CO W-E Curtain Plot for Row 1 "
        "tiXAxisString" : "West to East (km)"      ; x-axis title
        "tiYAxisString" : "Height Above Sea Level (km)" ; y-axis title
        "cnFillMode"    : "RasterFill"
      end setvalues

    ; Create the irregular domain on which to overlay the contours.
    ; Here's where we can force the tickmarks to point outward.
      ll = create "ll" logLinPlotClass wks
        "trXMinF"                 : min_distance
        "trXMaxF"                 : max_distance
        "trYMinF"                 : min_height
        "trYMaxF"                 : max_height
        "pmTickMarkDisplayMode"   : "always"
        "tmYLMajorOutwardLengthF" : 0.02
        "tmXBMajorOutwardLengthF" : 0.02
        "tmYLMinorOutwardLengthF" : 0.01
        "tmXBMinorOutwardLengthF" : 0.01
        "tmYLMajorLengthF"        : 0.02
        "tmXBMajorLengthF"        : 0.02
        "tmYLMinorLengthF"        : 0.01
        "tmXBMinorLengthF"        : 0.01
      end create

    overlay(ll, plot)
    maximize_output(wks,False)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end 

