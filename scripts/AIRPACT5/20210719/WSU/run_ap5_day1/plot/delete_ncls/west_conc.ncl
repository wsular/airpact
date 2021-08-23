
;*************************************************

load "/home/lar/opt/ncl-6.0.0/gcc-4.1.2/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/home/lar/opt/ncl-6.0.0/gcc-4.1.2/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/home/lar/opt/ncl-6.0.0/gcc-4.1.2/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/home/lar/opt/ncl-6.0.0/gcc-4.1.2/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

  ; open NetCDF files.
  ; file(s) of data to plot (remember that even if the netcdf file name doesn't end with ".nc",
  ; must include ".nc" in NCL script)

  ; File(s) with latitude and longitude values.
fconc = addfile ("/data/lar/projects/airpact5/AIRRUN/2017/2017120800" + "/CCTM/CONC_" + "20171208" + ".ncf.nc", "r")
fgrid = addfile ("/data/lar/projects/airpact5/AIRRUN/2017/2017120800/MCIP37" + "/GRIDCRO2D.nc", "r")
fmet  = addfile ("/data/lar/projects/airpact5/AIRRUN/2017/2017120800/MCIP37" + "/METCRO3D.nc", "r")
itime = stringtointeger(getenv("ihour"))

;********************************************************
; Read in data
;********************************************************
  ; position and time to read
    icol= 1 - 1 ;  284 ; i.e., locate Eastmostcolumn from the south-west corner (NCL counter starts from zero)
    location_description = "Eastern Boundary O3" ; some text to describe the location
  ; BEGIN READ IN species from conc file
        	O3_conc = fconc->O3
        	west_O3 = O3_conc(23,:,:,icol)
  ; END READ IN conc species

    west_O3       = west_O3 *1000.                  ; convert to ppb
    ; define/modify dimensions and attributes in a way that NCL understands
  ;    west_O3!0 = "time"       ; first dimension
      west_O3!0 = "lev"       ; first dimension
      west_O3!1 = "south_north" ; second dimension
      west_O3@long_name = "Ozone MOZART BCON"
      west_O3@units = "ppb"

   ; get dimension sizes
     dimsiz = dimsizes(west_O3)
;     ntime = dimsiz(0) ; number of time steps
     mz    = dimsiz(0) ; number of vertical layers
     my    = dimsiz(1) ; number of rows

  ; pressure at mid-level
    pres      = fmet->PRES(23,:,:,icol)         ; time,level,j,i
    ; define/modify dimensions and attributes in a way that NCL understands
;      pres!0 = "time"
      pres!0 = "lev"
      pres!1 = "south_north"
      pres@long_name = "Pressure at Mid-Level"
      pres@units = "Pa"
  ; layer top height above ground
    h_top_agl    = fmet->ZF(23,:,:,icol)/1000.         ; time,level,j,i; convert to km
    ; define/modify dimensions and attributes in a way that NCL understands
;      h_top_agl!0 = "time"
      h_top_agl!0 = "lev"
      h_top_agl!1 = "south_north"
      h_top_agl@long_name = "Layer Top Height Above Ground"
      h_top_agl@units = "Kilometers"
  ; terrain height above sea-level
    HT = fgrid->HT(0,0,:,icol)/1000.   ; terrain elevation TSTEP,LAY,ROW,COL; convert to km
    h_top_asl = h_top_agl 
    do j  = 0, my-1
       h_top_asl(:,j) = h_top_agl(:,j) + HT(j)
    end do

  ; force elev of 0 a.s.l. into a single point along boundary JKV 050317
    h_top_asl(0,0) = 0.0

  ; height above sea level for each cell's top and bottom
    ;h_bound_asl = new((/ntime,mz+1,my/),typeof(h_top_asl))
    h_bound_asl = new((/mz+1,my/),typeof(h_top_asl))
       h_bound_asl(0,:) = HT(:) ; lev, row
    do ilevel  = 1, mz
       h_bound_asl(ilevel,:) = h_top_asl(ilevel-1,:)
    end do


  ; get/assign some dimension information
    dx       = fconc@XCELL/1000.         ; horizontal resolution in x-directio in km
    south_north_1d  = ispan(0,my-1,1)*dx
    dims_array = dimsizes(pres(lev|:,south_north|:))
    ;dims_array = dimsizes(pres(time|0,lev|:,south_north|:))
    south_north = new ((/mz+1,my/),typeof(south_north_1d))
    ;south_north = new (dims_array,typeof(south_north_1d))
    do i = 0,dimsizes(south_north_1d)-1
       south_north(:,i)=south_north_1d(i)
    end do
    south_north@long_name = "south_north"
    south_north@units = "km"

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
          res@tiMainString         = "AIRPACT-5, " + location_description
          res@gsnLeftString       = " "
          res@gsnCenterString        = "12"+"-"+"08"+"-"+"2017 ( hour 23 PST )"
          res@gsnRightString       = " "
          res@tiXAxisString        = "South to North (km)"   ; x-axis title
          res@tiYAxisString        = "Height Above Sea Level (km)"
          ;res@sfYArray              = h_asl(:,:)
          res@sfYArray              = h_bound_asl(:,:)
	res@gsnMaximize = True
	res@lbOrientation         = "Vertical"      ; move label bar
        res@cnLevelSelectionMode = "ExplicitLevels"
	res@cnLevels             = (/40,50,60,65,70,75,80,90,100,120,150,200,400/)

	res@trYMinF =  0.0
	res@trYMaxF = 20.0

;********************************************************
; create plots
;********************************************************
;OZONE
  wks = gsn_open_wks("ps" ,"/data/lar/projects/airpact5/AIRRUN/2017/2017120800/IMAGES/conc/ps"+"/airpact5_BCON_west_O3_" + "23")          ; ps,pdf,x11,ncgm,eps
  gsn_define_colormap(wks,"BlGrYeOrReVi200")           ; select color map
      res@lbTitleString         = "(" + west_O3@units + ")"
          plot  = gsn_csm_contour(wks,west_O3(:,:),res)
        draw(plot)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end 

