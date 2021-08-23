
;*************************************************

load "/home/lar/opt/ncl-6.0.0/gcc-4.1.2/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/home/lar/opt/ncl-6.0.0/gcc-4.1.2/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/home/lar/opt/ncl-6.0.0/gcc-4.1.2/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/home/lar/opt/ncl-6.0.0/gcc-4.1.2/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

  ; open NetCDF files.
  ; file(s) of data to plot (remember that even if the netcdf file name doesn't end with ".nc",
  ; must include ".nc" in NCL script)

    fgrid = addfile ("/data/lar/projects/airpact5/AIRRUN/2020/2020093000/MCIP37" + "/GRIDCRO2D.nc", "r")
    fmet  = addfile ("/data/lar/projects/airpact5/AIRRUN/2020/2020093000/MCIP37" + "/METCRO3D.nc", "r")
    fpm25 = addfile ("/data/lar/projects/airpact5/AIRRUN/2020/2020093000" + "/POST/CCTM/combined3d_" + "20200930" + ".ncf.nc", "r")

    ; itime = stringtointeger(getenv("ihour"))
    itime = 23

;********************************************************
; Read in data
;********************************************************
  ; position and time to read
    icol = 60 - 1 ; because index in ncl ranges from 0...

  ; PM2.5 concentration
    pmij    = fpm25->PMIJ(itime,:,:,icol)        ; time,level,j,i    

     ; PM2.5
     pmij!0 = "lev"  
     pmij!1 = "south_north"
     pmij@long_name = "PM2.5"
     pmij@units = "ug/m3"

   ; get dimension sizes
     dimsiz = dimsizes(pmij)
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
    dy       = fpm25@YCELL/1000.         ; horizontal resolution in y-direction in km
    south_north_1d  = ispan(0,my-1,1)*dy
    dims_array = dimsizes(pres(lev|:,south_north|:))
    south_north = new((/mz+1,my/),typeof(south_north_1d))
    do i = 0,dimsizes(south_north_1d)-1
       south_north(:,i)=south_north_1d(i)
    end do
    south_north@long_name = "South-to-North"
    south_north@units = "Kilometers"

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
          res@gsnLeftString       = " "
          res@gsnCenterString        = "09"+"-"+"30"+"-"+"2020 ( hour 23 PST )"
          res@gsnRightString       = " "
          res@tiXAxisString        = "South to North (km)"   ; x-axis title
          res@tiYAxisString        = "Height Above Sea Level (km)"
          res@sfYArray              = h_bound_asl(:,:)
	res@gsnMaximize = True
	res@lbOrientation         = "Vertical"      ; move label bar

	res@trYMinF =  0.0
	res@trYMaxF = 20.0


;********************************************************
; create plots
;********************************************************

  ; PM2.5
    location_description = "South-to-North Curtain Plot for Col 60 "
    res@tiMainString         = "PM2.5 " + location_description
    wks = gsn_open_wks("ps" ,"/data/lar/projects/airpact5/AIRRUN/2020/2020093000/IMAGES/aconc/ps"+"/airpact5_S-N_60_pm25_curtain_" + "23") 
    gsn_define_colormap(wks,"BlGrYeOrReVi200")           ; select color map
    res@cnLevels             = (/1.0, 2.0, 4.0, 6.0, 8.0 ,10 ,15, 20 ,30, 40 ,80 ,160/)
    res@lbTitleString         = "(" + pmij@units + ")"
    plot  = gsn_csm_contour(wks,pmij(:,:),res)
    draw(plot)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end 

