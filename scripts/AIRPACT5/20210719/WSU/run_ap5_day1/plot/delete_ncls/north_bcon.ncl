
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
fbcon = addfile ("/data/lar/projects/airpact5/AIRRUN/2017/2017121400" + "/BCON/output/bcon_cb05_" + "20171214" + ".ncf.nc", "r")
fgrid = addfile ("/data/lar/projects/airpact5/AIRRUN/2017/2017121400/MCIP37" + "/GRIDCRO2D.nc", "r")
fmet  = addfile ("/data/lar/projects/airpact5/AIRRUN/2017/2017121400/MCIP37" + "/METCRO3D.nc", "r")
itime = stringtointeger(getenv("ihour"))

;********************************************************
; Read in data
;********************************************************
  ; position and time to read
    irow=257 ; i.e., locate Northmost row from the south-west corner (NCL counter starts from zero)
    location_description = "Northern Boundary PM25" ; some text to describe the location
  ;     nucleation mode I:                  APOCI                 APNCOMI
  ;  accumulations mode J: AECJ ANO3J ANH4J APOCJ ASO4J ANAJ ACLJ APNCOMJ 
  ; BEGIN READ IN  for all aerosol species from bcon file
  ;		read in AECJ
        	AECJ_bcon = fbcon->AECJ
        	north_PM25 = AECJ_bcon(23,:,546:830)
  ;
  ;		read in ANO3J
        	ANO3J_bcon = fbcon->ANO3J
        	north_ANO3J = ANO3J_bcon(23,:,546:830)
  ;
  ;		read in ANH4J
        	ANH4J_bcon = fbcon->ANH4J
        	north_ANH4J = ANH4J_bcon(23,:,546:830)
  ;
  ;		read in APOCI
        	APOCI_bcon = fbcon->APOCI
        	north_APOCI   = APOCI_bcon(23,:,546:830)
  ;
  ;		read in APOCJ
        	APOCJ_bcon = fbcon->APOCJ
        	north_APOCJ   = APOCJ_bcon(23,:,546:830)
  ;
  ;		read in APNCOMI 
        	APNCOMI_bcon = fbcon->APNCOMI
        	north_APNCOMI = APNCOMI_bcon(23,:,546:830)
  ;
  ;		read in APNCOMJ 
        	APNCOMJ_bcon = fbcon->APNCOMJ
        	north_APNCOMJ = APNCOMJ_bcon(23,:,546:830)
  ;
  ;		read in ASO4J
        	ASO4J_bcon = fbcon->ASO4J
        	north_ASO4J = ASO4J_bcon(23,:,546:830)
  ;
  ;		read in ANAJ
        	ANAJ_bcon = fbcon->ANAJ
        	north_ANAJ = ANAJ_bcon(23,:,546:830)
  ;
  ;		read in ACLJ
        	ACLJ_bcon = fbcon->ACLJ
        	north_ACLJ = ACLJ_bcon(23,:,546:830)
  ; END READ IN bcon species
  
  ; Sum eleven species into one for PM2.5
	north_PM25 = north_PM25 + north_ANO3J + north_ANH4J + north_APOCI + north_APOCJ  + north_APNCOMI 
	north_PM25 = north_PM25 + north_APNCOMJ + north_ASO4J + north_ANAJ + north_ACLJ 

  ; define/modify dimensions and attributes in a way that NCL understands
  ;    north_PM25!0 = "time"       ; first dimension
      north_PM25!0 = "lev"       ; first dimension
      north_PM25!1 = "west_east" ; second dimension
      north_PM25@long_name = "PM2.5 MOZART BCON"
      north_PM25@units = "ug/m3"

   ; get dimension sizes
     dimsiz = dimsizes(north_PM25)
;     ntime = dimsiz(0) ; number of time steps
     mz    = dimsiz(0) ; number of vertical layers
     my    = dimsiz(1) ; number of rows

  ; pressure at mid-level
    pres      = fmet->PRES(23,:,irow,:)         ; time,level,j,i
    ; define/modify dimensions and attributes in a way that NCL understands
;      pres!0 = "time"
      pres!0 = "lev"
      pres!1 = "west_east"
      pres@long_name = "Pressure at Mid-Level"
      pres@units = "Pa"
  ; layer top height above ground
    h_top_agl    = fmet->ZF(23,:,irow,:)/1000.         ; time,level,j,i; convert to km
    ; define/modify dimensions and attributes in a way that NCL understands
;      h_top_agl!0 = "time"
      h_top_agl!0 = "lev"
      h_top_agl!1 = "west_east"
      h_top_agl@long_name = "Layer Top Height Above Ground"
      h_top_agl@units = "Kilometers"
  ; terrain height above sea-level
    HT = fgrid->HT(0,0,irow,:)/1000.   ; terrain elevation TSTEP,LAY,ROW,COL; convert to km
    h_top_asl = h_top_agl 
    do j  = 0, my-1
       h_top_asl(:,j) = h_top_agl(:,j) + HT(j)
    end do
  ; height above sea level for each cell's top and bottom
    ;h_bound_asl = new((/ntime,mz+1,my/),typeof(h_top_asl))
    h_bound_asl = new((/mz+1,my/),typeof(h_top_asl))
       h_bound_asl(0,:) = HT(:) ; lev, row
    do ilevel  = 1, mz
       h_bound_asl(ilevel,:) = h_top_asl(ilevel-1,:)
    end do


  ; get/assign some dimension information
    dx       = fbcon@XCELL/1000.         ; horizontal resolution in x-directio in km
    west_east_1d  = ispan(0,my-1,1)*dx
    dims_array = dimsizes(pres(lev|:,west_east|:))
    ;dims_array = dimsizes(pres(time|0,lev|:,west_east|:))
    west_east = new ((/mz+1,my/),typeof(west_east_1d))
    ;west_east = new (dims_array,typeof(west_east_1d))
    do i = 0,dimsizes(west_east_1d)-1
       west_east(:,i)=west_east_1d(i)
    end do
    west_east@long_name = "west_east"
    west_east@units = "km"

; getting 1d height info for Y axis !nt
    lev_1d  = ispan(0,mz-1,1)*(max(h_top_asl)/mz)

;********************************************************
; shared resources
;********************************************************

     res                 = True            ; plot mods desired
     res@gsnDraw         = False   ; Don't draw plot (will do later)
     res@gsnFrame        = False   ; Don't advance framce  (will do later)
     res@tiMainFont      = "helvetica-bold"  ;title font
     res@tmXBMajorOutwardLengthF = 0.0               ; draw tickmarks inward
     res@tmXBMinorOutwardLengthF = 0.0               ; draw minor ticsk inward
     res@tmYLMajorOutwardLengthF = 0.0               ; draw tickmarks inward
     res@tmYLMinorOutwardLengthF = 0.0               ; draw minor ticsk inward

;********************************************************
; create plots
;********************************************************
;PM2.5 
  wks = gsn_open_wks("ps" ,"/data/lar/projects/airpact5/AIRRUN/2017/2017121400/IMAGES/bcon/ps"+"/airpact5_BCON_north_PM25_" + "23")          ; ps,pdf,x11,ncgm,eps
  gsn_define_colormap(wks,"BlGrYeOrReVi200")           ; select color map

;--- Plotting options for contour plot for PM2.5 -----------------------------
     opts_var = res
     opts_var@trGridType            = "TriangularMesh"
     opts_var@lbTitleOffsetF     = -0.03 ; move the title down (+) or up (-)
     opts_var@cnFillOn              = True            ; turn on color
     opts_var@cnFillMode            = "AreaFill"
     ;opts_var@cnCellFillEdgeColor   = "gray80"
     opts_var@cnCellFillMissingValEdgeColor   = "gray80"
     opts_var@cnMissingValFillColor = "black"
     opts_var@cnLinesOn             = False           ; turn off contour lines
     opts_var@gsnSpreadColors       = True            ; use entire color map
     opts_var@tiMainString         = "AIRPACT-5, " + location_description
     opts_var@gsnLeftString       = " "
     opts_var@gsnCenterString        = "12"+"-"+"14"+"-"+"2017 ( hour 23 PST )"
     opts_var@gsnRightString       = " "
     opts_var@tiXAxisString        = "West to East (km)"   ; x-axis title
     opts_var@tiYAxisString        = "Height Above Sea Level (km)"
     opts_var@sfYArray              = lev_1d
     opts_var@sfXArray              = west_east_1d

     opts_var@trYMaxF           = 16.0 ;max(h_top_asl)      ; set max range for Y-axis
     opts_var@trYMinF           =  0.0                      ; set min range for Y-axis
     opts_var@trXMaxF           = max(west_east_1d)
     opts_var@trXMinF           = 0.0

     opts_var@lbOrientation         = "Vertical"      ; move label bar
     opts_var@cnLevelSelectionMode = "ExplicitLevels"
     opts_var@cnLevels             = (/1.0, 2.0, 4.0, 6.0, 8.0 ,10 ,15, 20 ,30, 40 ,80 ,160/)

;      opts_var@lbTitleString         = "(" + north_PM25@units + ")"
      opts_var@lbTitleString = "~F33~m~F21~g/m~S~3~N"; should result in micrograms per cubic meter
    ;Draw contour plot on gsn_panel
    plot_var  = gsn_csm_contour(wks,north_PM25(:,:),opts_var)

 ;---Plotting options for terrain heights-----------
     opts_ter = res
     opts_ter@gsnYRefLine = 0.0 ; ref line
     opts_ter@gsnAboveYRefLineColor = "black" ;"gray"
     opts_ter@gsnDraw   = False
     opts_ter@gsnFrame  = False
     opts_ter@trYMaxF   = 16.0 ;max(h_top_asl)      ; set max range for Y-axis
     opts_ter@trYMinF   =  0.0                      ; set min range for Y-axis
     opts_ter@trXMaxF   = max(west_east_1d)
     opts_ter@trXMinF   = 0.0

     ; turning-off XY tick marks
     opts_ter@tmYROn = False
     opts_ter@tmYLOn = False
     opts_ter@tmXTOn = False
     opts_ter@tmXBOn = False
     opts_ter@tmYRBorderOn = False
     opts_ter@tmYLBorderOn = False
     opts_ter@tmXTBorderOn = False
     opts_ter@tmXBBorderOn = False
     opts_ter@tmYLLabelsOn = False
     opts_ter@tmXBLabelsOn = False

;      res@lbTitleString = "~F33~m~F0~g/m~S~3~N"; should result in micrograms per cubic meter 
;          plot  = gsn_csm_contour(wks,north_PM25(:,:),res)
;        draw(plot)
    ;Draw filled XY plot for terrain height
     plot_ter = gsn_csm_xy(wks,west_east_1d,HT,opts_ter)

     draw(plot_var)
     draw(plot_ter)
     frame(wks)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end 

