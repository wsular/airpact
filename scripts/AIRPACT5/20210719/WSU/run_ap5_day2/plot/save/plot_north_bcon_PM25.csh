#!/bin/csh -f

# Example of using this script:
# 
#   > plot_north_bcon_PM25.csh 20120501 24
#
#    where 20101104 denotes forecast start time of 8 GMT on Nov 5, 2010
#               24 denotes 24 hours of forecast
#
# plot_north_bcon.csh 20120501 24 notes:
# Farren Herron-Thorpe   2013-04-26
# Serena H. Chung       2013-04-26
# Joe Vaughan           2013-10-17
# plot_north_bcon_PM25.csh 20120501 24 
# Joe Vaughan           2017-08-05 Modified for testing in AIRPACT5
# Here are all aerosol species in BCON as of mods of 2017-08-05
#    nucleation mode I:                  APOCI                 APNCOMI
# accumulations mode J: AECJ ANO3J ANH4J APOCJ ASO4J ANAJ ACLJ APNCOMJ 
#        coarse mode K: ASOIL                        ANAK ACLK 
#
# Old comments:
# This C shell script creates hourly gif files of plots of the PM25 on the 
# northern boundary (based on AIRPACT-5 MOZART BCON files) 
# For each hour, the script 1) creates an NCL script, 2) runs the NCL script
# to create the figure in postcript format, and 3) converts the postscript file to a gif file.

#> check argument & set date strings  ----------------------------------

   if ( $#argv == 2 ) then
      setenv YEAR `echo $1 | cut -c1-4`
      setenv MONTH `echo $1 | cut -c5-6`
      setenv DAY `echo $1 | cut -c7-8`
      setenv NHR $2
   else
      echo 'Invalid argument. '
      echo "Usage $0 <yyyymmdd> 24"
      set exitstat = 1
      exit ( $exitstat )
   endif
   set yyyymmdd = ${YEAR}${MONTH}${DAY}
  #> determine day of the year
     set DOYstring = `juldate $MONTH $DAY $YEAR | cut -d',' -f 2`
     set DOY       = `echo $DOYstring | cut -c5-7`
     set YEARDOY   = $YEAR$DOY
  
     set YEARMMDD = ${YEAR}${MONTH}$DAY 
#> during testing 

   if ( ! $?PBS_O_WORKDIR ) then
    set PBS_O_WORKDIR = ~airpact5/AIRHOME/run_ap5_day2
    set AIROUT = /data/lar/projects/airpact5/AIRRUNDAY2/$YEAR/${1}00
    set MCIPDIR = /data/lar/projects/airpact5/AIRRUNDAY2/$YEAR/${1}00/MCIP37
    set NHR = $2
   endif

#> initialize exit status ----------------------------------------------
   set exitstat = 0

#> directory set-up ----------------------------------------------------

   set indir      = $AIROUT
   set mcip       = $MCIPDIR
   set NCLSCRIPTS = ${PBS_O_WORKDIR}/plot
   set PSDIR      = $indir/IMAGES/bcon/ps
   mkdir -p $PSDIR

# > create and run ncl script hour by hour ----------------------------

    set ihour  = 0 
    @ NHRm1 = $NHR - 1  
    while ( $ihour <= ${NHRm1}  )
       @ ahour = $ihour + 24
       if ( $ihour < 10 ) then
          set phour = 0$ihour
       else
          set phour = $ihour
       endif
       echo " phour for plot header string = " $phour
       echo " ahour for output = " $ahour

setenv ihour $ihour
setenv ahour $ahour
cat > $NCLSCRIPTS/north_bcon.ncl <<EOF

;*************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

  ; open NetCDF files.
  ; file(s) of data to plot (remember that even if the netcdf file name doesn't end with ".nc",
  ; must include ".nc" in NCL script)

  ; File(s) with latitude and longitude values.
fbcon = addfile ("$indir" + "/BCON/output/bcon_cb05_" + "$YEARMMDD" + ".ncf.nc", "r")
fgrid = addfile ("$mcip" + "/GRIDCRO2D.nc", "r")
fmet  = addfile ("$mcip" + "/METCRO3D.nc", "r")
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
        	north_PM25 = AECJ_bcon(${ihour},:,546:830)
  ;
  ;		read in ANO3J
        	ANO3J_bcon = fbcon->ANO3J
        	north_ANO3J = ANO3J_bcon(${ihour},:,546:830)
  ;
  ;		read in ANH4J
        	ANH4J_bcon = fbcon->ANH4J
        	north_ANH4J = ANH4J_bcon(${ihour},:,546:830)
  ;
  ;		read in APOCI
        	APOCI_bcon = fbcon->APOCI
        	north_APOCI   = APOCI_bcon(${ihour},:,546:830)
  ;
  ;		read in APOCJ
        	APOCJ_bcon = fbcon->APOCJ
        	north_APOCJ   = APOCJ_bcon(${ihour},:,546:830)
  ;
  ;		read in APNCOMI 
        	APNCOMI_bcon = fbcon->APNCOMI
        	north_APNCOMI = APNCOMI_bcon(${ihour},:,546:830)
  ;
  ;		read in APNCOMJ 
        	APNCOMJ_bcon = fbcon->APNCOMJ
        	north_APNCOMJ = APNCOMJ_bcon(${ihour},:,546:830)
  ;
  ;		read in ASO4J
        	ASO4J_bcon = fbcon->ASO4J
        	north_ASO4J = ASO4J_bcon(${ihour},:,546:830)
  ;
  ;		read in ANAJ
        	ANAJ_bcon = fbcon->ANAJ
        	north_ANAJ = ANAJ_bcon(${ihour},:,546:830)
  ;
  ;		read in ACLJ
        	ACLJ_bcon = fbcon->ACLJ
        	north_ACLJ = ACLJ_bcon(${ihour},:,546:830)
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
    pres      = fmet->PRES(${ihour},:,irow,:)         ; time,level,j,i
    ; define/modify dimensions and attributes in a way that NCL understands
;      pres!0 = "time"
      pres!0 = "lev"
      pres!1 = "west_east"
      pres@long_name = "Pressure at Mid-Level"
      pres@units = "Pa"
  ; layer top height above ground
    h_top_agl    = fmet->ZF(${ihour},:,irow,:)/1000.         ; time,level,j,i; convert to km
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

;********************************************************
; shared resources
;********************************************************

     res                 = True            ; plot mods desired
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
          res@tiMainString         = "AIRPACT-5, " + location_description
          res@gsnLeftString       = " "
          res@gsnCenterString        = "$MONTH"+"-"+"$DAY"+"-"+"$YEAR ( hour $phour PST )"
          res@gsnRightString       = " "
          res@tiXAxisString        = "West to East (km)"   ; x-axis title
          res@tiYAxisString        = "Height Above Sea Level (km)"
          res@sfYArray              = h_bound_asl(:,:)
	res@gsnMaximize = True
	res@lbOrientation         = "Vertical"      ; move label bar
        res@cnLevelSelectionMode = "ExplicitLevels"
	res@cnLevels             = (/05,10,20,30,40,50,60,70,80,90,100,120,140,150/) 

	res@trYMinF =  0.0
	res@trYMaxF = 20.0

;********************************************************
; create plots
;********************************************************
;PM2.5 
  wks = gsn_open_wks("ps" ,"$PSDIR"+"/airpact5_BCON_north_PM25_" + "$ahour")          ; ps,pdf,x11,ncgm,eps
  gsn_define_colormap(wks,"BlGrYeOrReVi200")           ; select color map
      res@lbTitleString         = "(" + north_PM25@units + ")"
          plot  = gsn_csm_contour(wks,north_PM25(:,:),res)
        draw(plot)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end 

EOF
# end of north_bcon.ncl

       ncl $NCLSCRIPTS/north_bcon.ncl
	echo Status of ncl call for $ihour is $status
      #rm -r -f $PSDIR/*.ps
       @ ihour ++
end #while


# convert to gif files
  set GIFDIR     = $indir/IMAGES/bcon/hourly/gif
  mkdir -p $GIFDIR
  cd $PSDIR
  foreach psfile ( *.ps )
    set fileroot = `echo $psfile | cut -d '.' -f 1 `
    convert -rotate 270 -resize 680x570 $PSDIR/$psfile  $GIFDIR/${fileroot}.gif
    if ( -e $GIFDIR/${fileroot}.gif ) then
       chmod a+r $GIFDIR/${fileroot}.gif
       ls -lt    $GIFDIR/${fileroot}.gif
       /bin/rm -f $PSDIR/$psfile
    endif
  end
  cd ../
  rmdir $PSDIR

#/bin/rm -f $NCLSCRIPTS/north_bcon.ncl
exit
