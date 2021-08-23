
;*************************************************

load "/home/lar/opt/ncl-6.0.0/gcc-4.1.2/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/home/lar/opt/ncl-6.0.0/gcc-4.1.2/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/home/lar/opt/ncl-6.0.0/gcc-4.1.2/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/home/lar/opt/ncl-6.0.0/gcc-4.1.2/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

  ; open NetCDF files.
  ; file(s) of data to plot (remember that even if the netcdf file name doesn't end with ".nc",
  ; must include ".nc" in NCL script)

    fgrid = addfile ("/data/lar/projects/airpact5/AIRRUNDAY2/2021/2021081600/MCIP37" + "/GRIDCRO2D.nc", "r")
    fmet  = addfile ("/data/lar/projects/airpact5/AIRRUNDAY2/2021/2021081600/MCIP37" + "/METCRO3D.nc", "r")
    fpm25 = addfile ("/data/lar/projects/airpact5/AIRRUNDAY2/2021/2021081600" + "/POST/CCTM/combined3d_" + "20210816" + ".ncf.nc", "r")

    ; itime = stringtointeger(getenv("ihour"))
    itime = 23

;********************************************************
; Read in data
;********************************************************
  ; position and time to read
    irow = 156  - 1  ; because subscripts run from 0 ...
    location_description = "West-to-East Curtain Plot for Row 156 "

  ; PM2.5 concentration
    pmij    = fpm25->PMIJ(itime,:,irow,:)        ; time,level,j,i    

    ; define/modify dimensions and attributes in a way that NCL understands

    ; PM2.5
    pmij!0 = "lev"
    pmij!1 = "west_east"
    pmij@long_name = "PM2.5"
    pmij@units = "ug/m3"

    ; get dimension sizes
    dimsiz = dimsizes(pmij)
   ;  ntime = dimsiz(0) ; number of time steps
    mz    = dimsiz(0) ; number of vertical layers
    my    = dimsiz(1) ; number of cols

  ; pressure at mid-level
    pres      = fmet->PRES(itime,:,irow,:)         ; time,level,j,i
    ; define/modify dimensions and attributes in a way that NCL understands
    pres!0 = "lev"
    pres!1 = "west_east"
    pres@long_name = "Pressure at Mid-Level"
    pres@units = "Pa"

  ; layer top height above ground
    h_top_agl    = fmet->ZF(itime,:,irow,:)/1000.         ; time,level,j,i
    ; define/modify dimensions and attributes in a way that NCL understands
    ;  h_top_agl!0 = "time"
      h_top_agl!0 = "lev"
      h_top_agl!1 = "west_east"
      h_top_agl@long_name = "Mid-Layer Height Above Ground"
      h_top_agl@units = "Kilometers"

  ; terrain height above sea-level
    HT = fgrid->HT(0,0,irow,:)/1000.   ; terrain elevation TSTEP,LAY,ROW,COL
    h_top_asl = h_top_agl ; "initialize" with dimension time, level, j
    do j  = 0, my-1
       h_top_asl(:,j) = h_top_agl(:,j) + HT(j) 
    end do

 ; force elev of 0 a.s.l. into a single point along boundary JKV 050317
    h_top_asl(0,0) = 0.0

  ; height above sea level for each cell's top and bottom
    h_bound_asl = new((/mz+1,my/),typeof(h_top_asl))
    h_bound_asl(0,:) = HT(:) ; row
    do ilevel  = 1, mz
       h_bound_asl(ilevel,:) = h_top_asl(ilevel-1,:)
    end do

  ; get/assign some dimension information
    dx       = fpm25@XCELL/1000.         ; horizontal resolution in x-directio in km
    west_east_1d  = ispan(0,my-1,1)*dx
    dims_array = dimsizes(pres(lev|:,west_east|:))
    west_east = new((/mz+1,my/),typeof(west_east_1d))
    do i = 0,dimsizes(west_east_1d)-1
       west_east(:,i)=west_east_1d(i)
    end do
    west_east@long_name = "West-to-East"
    west_east@units = "Kilometers"

;********************************************************
; shared resources
;********************************************************

  res                       = True            ; plot mods desired
  res@gsnDraw         = False   ; Don't draw plot (will do later)
  res@gsnFrame        = False   ; Don't advance framce  (will do later)
     res@trGridType            = "TriangularMesh"
     res@sfXArray              = west_east
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
          res@gsnCenterString        = "08"+"-"+"16"+"-"+"2021 ( hour 23 PST )"
          res@gsnRightString       = " "
          res@tiXAxisString        = "West to East (km)"   ; x-axis title
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
    location_description = "West-to-East Curtain Plot for Row 156 "
    res@tiMainString         = "PM2.5 " + location_description
    wks = gsn_open_wks("ps" ,"/data/lar/projects/airpact5/AIRRUNDAY2/2021/2021081600/IMAGES/aconc/ps"+"/airpact5_W-E_156_pm25_curtain_" + "23")  
    gsn_define_colormap(wks,"BlGrYeOrReVi200")           ; select color map
    res@cnLevels             = (/1.0, 2.0, 4.0, 6.0, 8.0 ,10 ,15, 20 ,30, 40 ,80 ,160/)
    res@lbTitleString         = "(" + pmij@units + ")"
    plot  = gsn_csm_contour(wks,pmij(:,:),res)
    draw(plot)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end 

