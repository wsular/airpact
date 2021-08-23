#!/bin/csh -fX

# Example of using this script:
# 
#   > plot_west_bcon_O3_w.csh 20120501 
#
#    where 20101104 denotes forecast start time of 8 GMT on Nov 5, 2010
#
# Sept 2018: With adoption of code processing WACCM files to BCON input file for CMAQ in AIRPACT5, the BCON time steps have changed.
# Previous versions of BCON processing either: 
# (ending Jan 2018) used daily MOZART4 results and provided hourly BCON time steps to CMAQ, and those time steps 
# matched those of the MCIP meteorology, with 25 hourly steps in the file, providing for interpolation to intermediate times.
# (or since Jan 2018) used old monthly average MOZART4 results providing only a single hour each day.
#
# As of Sept 2018, BCON will soon be being generated from WACCM files with data every 6 hours.
# The WACCM data deosn't start at, or contain, the hour matching UTZ 08 which is the starting hour for MCIP and CMAQ.
# The BCON from WACCM will instead contain hour 06 UTZ and every six hours thereafter for a total of ten timesteps.
# CMAQ will interpolate for BCON needed bewteen the available time steps of the BCON file.
# 
# Following these Sept 2018 changes, these BCON plotting codes are being changed to plot only every 6 hours, 
# beginning with hour 06 UTZ, fora total of ten time steps, thus covering both DAY1 and DAY2 CMAQ runs.
#
# Farren Herron-Thorpe   2013-04-26
# Joe Vaughan           2013-10-17
# Joe Vaughan           2016-12-28 Modified for testing in AIRPACT5
# Joe Vaughan           2018-09-06 Modified for BCON from WACCM for AIRPACT5

# Old comments:
# This C shell script creates hourly gif files of plots of the O3 on the 
# western boundary (based on AIRPACT-5 MOZART BCON files) 
# For each hour, the script 1) creates an NCL script, 2) runs the NCL script
# to create the figure in postcript format, and 3) converts the postscript file to a gif file.

#> check argument & set date strings  ----------------------------------

echo $0 $1

   if ( $#argv == 1 ) then
      setenv YEAR `echo $1 | cut -c1-4`
      setenv MONTH `echo $1 | cut -c5-6`
      setenv DAY `echo $1 | cut -c7-8`
   else
      echo 'Invalid argument. '
      echo "Usage $0 <yyyymmdd>"
      set exitstat = 1
      exit ( $exitstat )
   endif

  #> determine date
   set yyyymmdd = ${YEAR}${MONTH}${DAY}
     set YEARMMDD = $yyyymmdd

set prevday = `date -d "$yyyymmdd -1 days" '+%Y%m%d'`
     echo PREVDAY $prevday

set nextday = `date -d "$yyyymmdd +1 days" '+%Y%m%d'`
     echo NEXTDAY $nextday

set nextnextday = `date -d "$yyyymmdd +2 days" '+%Y%m%d'`
     echo NEXTNEXTDAY $nextnextday


#> during testing 
   if ( ! $?PBS_O_WORKDIR ) then
    set PBS_O_WORKDIR = ~airpact5/AIRHOME/run_ap5_day1
    set AIROUT = /data/lar/projects/airpact5/AIRRUN/$YEAR/${1}00
    set MCIPDIR = /data/lar/projects/airpact5/AIRRUN/$YEAR/${1}00/MCIP37
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

foreach ihour ( 0   1   2   3   4   5   6   7   8   9  )

echo Starting for hour $ihour

# utz_hh       06  12  18  00  06  12  18  00  06  12   
# utz_date      D   D   D  D+1 D+1 D+1 D+1 D+2 D+2 D+2
# pst_hh       22  04  10  16  22  04  10  16  22  04   
# pst_date     D-1  D   D   D   D  D+1 D+1 D+1 D+1 D+2  
#
       if ( $ihour < 10 ) then
          set ahour = 0$ihour
       else
          set ahour = $ihour
       endif

       if ( $ihour == 0 ) then
		set utz_hh = 06
		set utz_date = $yyyymmdd
			set pst_hh = 22
			set pst_date = $prevday
	else if ( $ihour == 1 ) then
		set utz_hh = 12
		set utz_date = $yyyymmdd
			set pst_hh = 04
			set pst_date = ${YEAR}${MONTH}${DAY}
	else if ( $ihour == 2 ) then
		set utz_hh = 18
		set utz_date = $yyyymmdd
			set pst_hh = 10
			set pst_date = ${YEAR}${MONTH}${DAY}
	else if ( $ihour == 3 ) then
		set utz_hh = 00
		set utz_date = $yyyymmdd
			set pst_hh = 16
			set pst_date = ${YEAR}${MONTH}${DAY}
	else if ( $ihour == 4 ) then
		set utz_hh = 06
		set utz_date = $yyyymmdd
			set pst_hh = 22
			set pst_date = ${YEAR}${MONTH}${DAY}
	else if ( $ihour == 5 ) then
		set utz_hh = 12
		set utz_date = $yyyymmdd
			set pst_hh = 04
			set pst_date = $nextday
	else if ( $ihour == 6 ) then
		set utz_hh = 18
		set utz_date = $yyyymmdd
			set pst_hh = 10
			set pst_date = $nextday 
	else if ( $ihour == 7 ) then
		set utz_hh = 00
		set utz_date = $yyyymmdd
			set pst_hh = 16
			set pst_date = $nextday
	else if ( $ihour == 8 ) then
		set utz_hh = 06
		set utz_date = $yyyymmdd
			set pst_hh = 22
			set pst_date = $nextday
	else if ( $ihour == 9 ) then
		set utz_hh = 12
		set utz_date = $yyyymmdd
			set pst_hh = 06
			set pst_date = $nextnextday
	else if ( $ihour >= 10 ) then
		echo SOMEHOW WE GOT TO HOUR 10.  CHECK RESULTS...
		exit(1)
	endif 
		

echo " ihour = " $ihour
setenv ihour $ihour
echo " ahour " $ahour 
echo "UTZ: " utz_date utz_hh
echo "PST: " pst_date pst_hh

setenv ahour $ahour

set st_col = 832
set end_col = 1089

cat > $NCLSCRIPTS/west_bcon.ncl <<EOF

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
;fbcon = addfile ("$indir" + "/BCON/output/bcon_cb05_" + "$YEARMMDD" + "_WACCM.ncf.nc", "r")
fbcon = addfile ("$indir" + "/BCON/output/bcon_cb05_" + "$YEARMMDD" + ".ncf.nc", "r")
fgrid = addfile ("$mcip" + "/GRIDCRO2D.nc", "r")
fmet  = addfile ("$mcip" + "/METCRO3D.nc", "r")
itime = stringtointeger(getenv("ihour"))

;********************************************************
; Read in data
;********************************************************
  ; position and time to read
    icol=0 ; i.e., 1st column from the west (NCL counter starts from zero)
    location_description = "Western Boundary O3" ; some text to describe the location
  ; BEGIN READ IN species from bcon file
        ;       O3
        	O3_bcon = fbcon->O3
        	west_O3 = O3_bcon(${ihour},:,${st_col}:${end_col})
  ; END READ IN bcon species

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
    pres      = fmet->PRES(${ihour},:,:,icol)         ; time,level,j,i
; 	define/modify dimensions and attributes in a way that NCL understands
;      pres!0 = "time"
      pres!0 = "lev"
      pres!1 = "south_north"
      pres@long_name = "Pressure at Mid-Level"
      pres@units = "Pa"
  ; layer top height above ground
    h_top_agl    = fmet->ZF(${ihour},:,:,icol)/1000.         ; time,level,j,i; convert to km
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
  ; height above sea level for each cell's top and bottom
    ;h_bound_asl = new((/ntime,mz+1,my/),typeof(h_top_asl))
    h_bound_asl = new((/mz+1,my/),typeof(h_top_asl))
       h_bound_asl(0,:) = HT(:) ; lev, row
    do ilevel  = 1, mz
       h_bound_asl(ilevel,:) = h_top_asl(ilevel-1,:)
    end do


  ; get/assign some dimension information
    dx       = fbcon@XCELL/1000.         ; horizontal resolution in x-directio in km
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
     res@gsnCenterString      = "$pst_date"+"  hour $pst_hh PST" 
     res@gsnRightString       = " "
     res@tiXAxisString        = "South to North (km)"   ; x-axis title
     res@tiYAxisString        = "Height Above Sea Level (km)"
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
  wks = gsn_open_wks("ps" ,"$PSDIR"+"/airpact5_BCON_west_O3_" + "w_$ahour")          ; ps,pdf,x11,ncgm,eps
  gsn_define_colormap(wks,"BlGrYeOrReVi200")           ; select color map
      res@lbTitleString         = "(" + west_O3@units + ")"
          plot  = gsn_csm_contour(wks,west_O3(:,:),res)
        draw(plot)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end 

EOF
# end of west_bcon.ncl

       ncl $NCLSCRIPTS/west_bcon.ncl
	echo Status of ncl call for $ihour is $status
      #rm -r -f $PSDIR/*.ps
end #while


# convert to gif files
  set GIFDIR     = $indir/IMAGES/bcon/hourly/gif
  mkdir -p $GIFDIR
  cd $PSDIR
  foreach psfile ( *.ps )
    set fileroot = `echo $psfile | cut -d '.' -f 1 `
    convert -rotate 270 $PSDIR/$psfile  $GIFDIR/${fileroot}.gif
    if ( -e $GIFDIR/${fileroot}.gif ) then
       chmod a+r $GIFDIR/${fileroot}.gif
       ls -lt    $GIFDIR/${fileroot}.gif
       /bin/rm -f $PSDIR/$psfile
    endif
  end
  cd ../
  rmdir $PSDIR

#/bin/rm -f $NCLSCRIPTS/west_bcon.ncl
exit
