#!/bin/csh -fX

# Example of using this script:
# 
#   > run_ncl_ID_west_o3_curtain.csh 20120501 24
#
#    where 20101105 denotes forecast start time of 8 GMT on Nov 5, 2010
#               24 denotes 24 hours of forecast
#
#
# Farren Herron-Thorpe   2013-04-26
# Serena H. Chung       2013-04-26
#
# This C shell script creates hourly gif files of Idaho western boundary curtain plots based on AIRPACT-5
# output files. For each hour, the script 1) creates an NCL script, 2) runs the NCL script
# to create the figure in postcript format, and 3) converts the postscript file to a gif file.


#> plot type
   set fillmode = RasterFill

#> initialize exit status ----------------------------------------------
   set exitstat = 0

#> check argument & set date strings  ----------------------------------

   if ( $#argv == 2 ) then
      set currentday = $1
      setenv YEAR `echo $1 | cut -c1-4`
      setenv MONTH `echo $1 | cut -c5-6`
      setenv DAY `echo $1 | cut -c7-8`
      setenv NHR $2
   else
      echo 'invalid argument. '
      echo "usage $0 <yyyymmdd> 24"
      set exitstat = 1
      exit ( $exitstat )
   endif
   set yyyymmdd = ${YEAR}${MONTH}${DAY}
  #> determine day of the year
     set DOYstring = `juldate $MONTH $DAY $YEAR | cut -d',' -f 2`
     set DOY       = `echo $DOYstring | cut -c5-7`
     set YEARDOY   = $YEAR$DOY
   
#> during testing 

   # if ( ! $?PBS_O_WORKDIR ) then
      echo Setting test paths
      set PBS_O_WORKDIR = ~airpact5/AIRHOME/run_ap5_day1
      set AIRHOME = ~airpact5/AIRHOME
      set AIRRUN  = /data/lar/projects/airpact5/AIRRUN/$YEAR
      set AIROUT = $AIRRUN/${currentday}00
      set AIRLOGDIR = $AIROUT/LOGS
      set MCIPDIR   = $AIROUT/MCIP37
      echo $PBS_O_WORKDIR $AIRHOME $AIRRUN $AIRLOGDIR $MCIPDIR
   # endif

#> directory set-up ----------------------------------------------------

   set indir      = $AIROUT
   set mcip       = $MCIPDIR
   set NCLSCRIPTS = ${PBS_O_WORKDIR}/plot
   set PSDIR      = $indir/IMAGES/conc/ps
   mkdir -p $PSDIR

# > create and run ncl script hour by hour ----------------------------

    set ihour  = 0 
    @ NHRm1 = $NHR - 1  
    while ( $ihour <= ${NHRm1}  )

       if ( $ihour < 10 ) then
          set ahour = 0$ihour
       else
          set ahour = $ihour
       endif
       echo " ihour = " $ihour
setenv ihour $ihour
setenv ahour $ahour
cat > $NCLSCRIPTS/ID_west_o3_curtain.ncl <<EOF

;*************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

  ; open NetCDF files.
  ; file(s) of data to plot (remember that even if the netcdf file name doesn't end with ".nc",
  ; must include ".nc" in NCL script)

    fconc = addfile ("$indir" + "/CCTM/CONC_" + "$currentday" + ".ncf.nc", "r")
    fgrid = addfile ("$mcip" + "/GRIDCRO2D.nc", "r")
    fmet  = addfile ("$mcip" + "/METCRO3D.nc", "r")
    itime = stringtointeger(getenv("ihour"))

;********************************************************
; Read in data
;********************************************************
  ; position and time to read
    icol=155 ; ~ LON=-117. 1st column from the west NCL counts as zero)
    location_description = "Idaho Western Border Curtain" ; some text to describe the location
  ; ozone concentration
    o3      = fconc->O3(:,:,:,icol)*1000.    ; time,level,j,i
    co      = fconc->CO(:,:,:,icol)*1000.    ; time,level,j,i    
    ; define/modify dimensions and attributes in a way that NCL understands
      o3!0 = "time"       ; first dimension
      o3!1 = "lev"       ; second dimension
      o3!2 = "south_north" ; third dimension
      o3@long_name = "Ozone Concentrations"
      o3@units = "ppb"
      co!0 = "time"       ; first dimension
      co!1 = "lev"       ; second dimension
      co!2 = "south_north" ; third dimension
      co@long_name = "Carbon Monoxide"
      co@units = "ppb"

   ; get dimension sizes
     dimsiz = dimsizes(o3)
     ntime = dimsiz(0) ; number of time steps
     mz    = dimsiz(1) ; number of vertical layers
     my    = dimsiz(2) ; number of rows

  ; pressure at mid-level
    pres      = fmet->PRES(:,:,:,icol)         ; time,level,j,i
    ; define/modify dimensions and attributes in a way that NCL understands
      pres!0 = "time"
      pres!1 = "lev"
      pres!2 = "south_north"
      pres@long_name = "Pressure at Mid-Level"
      pres@units = "Pa"
  ; layer top height above ground
    h_top_agl    = fmet->ZF(:,:,:,icol)/1000.         ; time,level,j,i
    ; define/modify dimensions and attributes in a way that NCL understands
      h_top_agl!0 = "time"
      h_top_agl!1 = "lev"
      h_top_agl!2 = "south_north"
      h_top_agl@long_name = "Mid-Layer Height Above Ground"
      h_top_agl@units = "km"
  ; layer top height above sea-level
    HT = fgrid->HT(0,0,:,icol)/1000.   ; terrain elevation TSTEP,LAY,ROW,COL
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
    south_north_1d  = ispan(0,my-1,1)*dx
    dims_array = dimsizes(pres(time|0,lev|:,south_north|:))
   ;south_north = new (dims_array,typeof(south_north_1d))
    south_north = new((/mz+1,my/),typeof(south_north_1d))
    do i = 0,dimsizes(south_north_1d)-1
       south_north(:,i)=south_north_1d(i)
    end do
    south_north@long_name = "south_north"
    south_north@units = "km"
  ; get max/min for plot axis
    min_distance = min(south_north)
    max_distance = max(south_north)
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

  res@sfXArray         = south_north
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
  res@gsnCenterString      = "$MONTH"+"-"+"$DAY"+"-"+"$YEAR ( hour $ahour PST )"
  res@gsnRightString       = " "
  res@tiXAxisString        = "South to North (km)"   ; x-axis title
  res@lbOrientation        = "Vertical"      ; move label bar

;********************************************************
; create plots
;********************************************************
  ; ozone
    wks = gsn_open_wks("ps" ,"$PSDIR"+"/airpact5_ID_west_o3_curtain_" + "$ahour")          ; ps,pdf,x11,ncgm,eps
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
       "tiMainString"  : "AIRPACT-5 ID Western Border O3"
       "tiXAxisString" : "South to North (km)"    ; x-axis title
       "tiYAxisString" : "Height Above Sea Level (km)" ; y-axis title
       "cnFillMode"    : "$fillmode"
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
    wks = gsn_open_wks("ps" ,"$PSDIR"+"/airpact5_ID_west_co_curtain_" + "$ahour")          ; ps,pdf,x11,ncgm,eps
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
        "tiMainString"  : "AIRPACT-5 ID Western Border CO"
        "tiXAxisString" : "South to North (km)"    ; x-axis title
        "tiYAxisString" : "Height Above Sea Level (km)" ; y-axis title
        "cnFillMode"    : "$fillmode"
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

EOF
# end of ID_west_o3_curtain.ncl

       ncl -Q $NCLSCRIPTS/ID_west_o3_curtain.ncl
      #rm -r -f $PSDIR/*.ps
       @ ihour ++
end #while


# convert to gif files
  set GIFDIR     = $indir/IMAGES/conc/hourly/gif
  mkdir -p $GIFDIR
  cd $PSDIR
  foreach psfile ( *.ps )
    set fileroot = `echo $psfile | cut -d '.' -f 1 `
    convert -rotate 270 $PSDIR/$psfile  -background white -flatten $GIFDIR/${fileroot}.gif
    if ( -e $GIFDIR/${fileroot}.gif ) then
       chmod a+r $GIFDIR/${fileroot}.gif
       /bin/rm -f $PSDIR/$psfile
    endif
  end
  cd ../
  rmdir $PSDIR

#/bin/rm -f $NCLSCRIPTS/ID_west_o3_curtain.ncl
exit
