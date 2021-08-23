#!/bin/csh -fX

# Example of using this script:
# 
#   > run_ncl_W-E-pm25-curtain_at_irow.csh YYYYMMDD IROW
#
#    where YYYYMMDD denotes forecast start time of 8 GMT on Nov 5, 2010
#    IROW is AIRPACT domain row number in range of 1-258
#    Latitude of Columbia Gorge near Hood River is      and jrow is 143
#
# Joseph K. Vaughan      2017-11-29 Modified for arbitrary row curtain plot.
# Farren Herron-Thorpe   2013-04-26
# Serena H. Chung       2013-04-26
#
# This C shell script creates hourly gif files of North-South curtain plots based on AIRPACT-5
# output files. For each hour, the script 1) creates an NCL script, 2) runs the NCL script
# to create the figure in postcript format, and 3) converts the postscript file to a gif file.
# Loops over 24 hours.

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
      setenv IROW $2
   else
      echo 'invalid argument. '
      echo "usage $0 <yyyymmdd> <irow>"
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
   set PSDIR      = $indir/IMAGES/aconc/ps
   mkdir -p $PSDIR

# > create and run ncl script hour by hour ----------------------------
    setenv NHR 24 
    set ihour  = 0 
    @ NHRm1 = $NHR - 1  
    while ( $ihour <= ${NHRm1}  )

       if ( $ihour < 10 ) then
          set ahour = 0$ihour
       else
          set ahour = $ihour
       endif
       echo " ihour = " $ihour
setenv IHOUR $ihour
setenv AHOUR $ahour
cat > $NCLSCRIPTS/W-E_${IROW}_curtain.ncl <<EOF

;*************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

  ; open NetCDF files.
  ; file(s) of data to plot (remember that even if the netcdf file name doesn't end with ".nc",
  ; must include ".nc" in NCL script)

    fgrid = addfile ("$mcip" + "/GRIDCRO2D.nc", "r")
    fmet  = addfile ("$mcip" + "/METCRO3D.nc", "r")
    fpm25 = addfile ("$indir" + "/POST/CCTM/combined3d_" + "$currentday" + ".ncf.nc", "r")

    ; itime = stringtointeger(getenv("ihour"))
    itime = $IHOUR

;********************************************************
; Read in data
;********************************************************
  ; position and time to read
    irow = $IROW  - 1  ; because subscripts run from 0 ...
    location_description = "West-to-East Curtain Plot for Row $IROW "

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
          res@gsnCenterString        = "$MONTH"+"-"+"$DAY"+"-"+"$YEAR ( hour $ahour PST )"
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
    location_description = "West-to-East Curtain Plot for Row $IROW "
    res@tiMainString         = "PM2.5 " + location_description
    wks = gsn_open_wks("ps" ,"$PSDIR"+"/airpact5_W-E_${IROW}_pm25_curtain_" + "$ahour")  
    gsn_define_colormap(wks,"BlGrYeOrReVi200")           ; select color map
    res@cnLevels             = (/1.0, 2.0, 4.0, 6.0, 8.0 ,10 ,15, 20 ,30, 40 ,80 ,160/)
    res@lbTitleString         = "(" + pmij@units + ")"
    plot  = gsn_csm_contour(wks,pmij(:,:),res)
    draw(plot)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end 

EOF
# end of W-E_${IROW}_curtain.ncl

       ncl -Q $NCLSCRIPTS/W-E_${IROW}_curtain.ncl
      #rm -r -f $PSDIR/*.ps
       @ ihour ++
end #while


# convert to gif files
  set GIFDIR     = $indir/IMAGES/aconc/hourly/gif
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

#/bin/rm -f $NCLSCRIPTS/W-E_${IROW}_curtain.ncl
exit
