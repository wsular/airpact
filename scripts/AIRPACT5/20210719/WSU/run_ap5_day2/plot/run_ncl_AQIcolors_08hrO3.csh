#!/bin/csh -fX

# Example of using this script:
# 
#   > run_ncl_AQIcolors_08hrO3.csh 20120501 24
#
#    where 20101104 denotes forecast start time of 8 GMT on Nov 5, 2010
#               24 denotes 24 hours of forecast
#
# Joseph K. Vaughan      2016-02-03 Updating for airpact5
# Serena H. Chung       2012-05-14
# Farren L. Herron-Thorpe 2013-02-11
# This C shell script creates hourly gif files of 8-hr O3 concentrations based on AIRPACT-4's
# CMAQ output files. For each hour, the script 1) creates an NCL script, 2) runs the NCL script
# to create the figure in postcript format, and 3) converts the postscript file to a gif file.

#> check argument & set date strings  ----------------------------------

   if ( $#argv == 2 ) then
      setenv YEAR `echo $1 | cut -c1-4`
      setenv MONTH `echo $1 | cut -c5-6`
      setenv DAY `echo $1 | cut -c7-8`
      setenv NHR $2
      if ( $NHR > 24 ) then
        echo 'NHR = ' $NHR
 	echo ' this script is not meant for NHR > 24'
	exit
      endif
   else
      echo 'Invalid argument. '
      echo "Usage $0 <YYYYMMDD> 24"
      set exitstat = 1
      exit ( $exitstat )
   endif
   set YYYYMMDD = ${YEAR}${MONTH}${DAY}
   # trim out leading zero (for doing arithmatic)
     set year  = $YEAR # for year, no "trimming" necessary
     set leading = `echo $MONTH | cut -c1-1`
     if ( $leading == 0 ) then
        @ month = `echo $MONTH | tr '0' ' '` 
     else
        @ month = $MONTH 
     endif
     set leading = `echo $DAY | cut -c1-1`
     if ( $leading == 0 ) then
        @ day = `echo $DAY | tr '0' ' '` 
     else
        @ day = $DAY
     endif

  #> determine day of the year
     set DOYstring = `juldate $MONTH $DAY $YEAR | cut -d',' -f 2`
     set DOY       = `echo $DOYstring | cut -c5-7`
     set YEARDOY   = $YEAR$DOY

  #> date and julian day of the previous day
     # last day of each month
       set last_day_noleap = ( 31  28  31  30  31  30  31  31  30  31  30  31 )
     # determine if it's leap year
       if ( ${YEAR} % 400 == 0 ) then 
          set ifleap = Y
       else if ( ${YEAR} % 100 == 0 ) then 
          set ifleap = N
       else if ( ${YEAR} % 4 == 0 ) then
          set ifleap = Y 
       else
          set ifleap = N
       endif
     # 
     if ( ${DOY} == "001" ) then
        @ yearm1  = ${year} - 1
        @ monthm1 = 12
        @ daym1   = 31
	set MONTHm1 = 12
	set DAYm1   = 31
     else
        @ yearm1   = ${year}
        @ monthm1  = ${month}
        @ daym1    = ${day} - 1
        if ( $daym1 == 0 ) then
           @ monthm1 = ${month} - 1
           set daym1 = ${last_day_noleap[$monthm1]}
           if ( $monthm1 == 2 && $ifleap == "Y" ) then
              set daym1 = 29
           endif
	endif
        if ( $monthm1 < 10 ) then     
           set MONTHm1 = 0${monthm1}
        else
           set MONTHm1 = $monthm1
        endif
        if ( $daym1 < 10 )then
           set DAYm1 = 0${daym1}
        else
	   set DAYm1 = $daym1
        endif
     endif
     set JDstring   = `juldate $monthm1 $daym1 $yearm1 | cut -d',' -f 2`
     set DOYm1 = `echo $JDstring | cut -c5-7`
     set YEARDOYm1  = $yearm1$DOYm1
     set YYYYMMDDm1 = ${yearm1}${MONTHm1}${DAYm1}

#> during testing 

   if ( ! $?PBS_O_WORKDIR ) then
     set PBS_O_WORKDIR = ~airpact5/AIRHOME/run_ap5_day2
     set AIROUT = /data//lar/projects/airpact5/AIRRUN/${year}/${1}00
     set MCIPDIR = /data/airpact4/AIRRUN/${1}00/MCIP
     set NHR = $2
   endif

#> switch for various subcomponents and options ------------------------

   # plot options
     setenv ADD_COLORBAR 	N
     setenv ADD_BORDERS 	N
     setenv IMAGEFILL      AreaFill  #RasterFill AreaFill or CellFill
   # image conversion ( ps to gif ) options
     set imgd = 120 
     set cx   = 863
     set cy   = 751
     set sx   =  64
     set sy   = 265

#> initialize exit status ----------------------------------------------
   set exitstat = 0


#> directory set-up ----------------------------------------------------

   set indir      = $AIROUT
   set mcip       = $MCIPDIR
   set NCLSCRIPTS = ${PBS_O_WORKDIR}/plot
   set PSDIR      = $indir/IMAGES/aconc/ave08hr/ps
   mkdir -p $PSDIR

# > create and run ncl script ------------------------------------------

cat >! $NCLSCRIPTS/AQIcolors_ave08hrO3.ncl <<EOF

;*************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  ; read in the options passed from the csh
    border_option = getenv("ADD_BORDERS")
    scale_option  = getenv("ADD_COLORBAR")
    FillType      = getenv("IMAGEFILL")

  ; open NetCDF files.
  ; file(s) of data to plot (remember that even if the netcdf file name doesn't end with ".nc",
  ; must include ".nc" in NCL script)
    f1 = addfile ( "$indir" + "/POST/CCTM/O3_L01_08hr_${YYYYMMDDm1}.ncf.nc","r")
  ; File(s) with latitude and longitude values.
    g1 = addfile ( "$mcip" + "/GRIDCRO2D.nc","r")

  ; read latitude and longitude of the grid
    g1lat = g1->LAT(0,0,:,:) 
    g1lon = g1->LON(0,0,:,:) 

  ; get dimension from lat/lon info 
    nlat = dimsizes(g1lat(:,0))
    nlon = dimsizes(g1lon(0,:))
  ; ------------------------------------------------------------------
  ; Set some plot resources 
  ; ------------------------------------------------------------------
	res                 = True
	res@gsnDraw         = False   ; Don't draw plot (will do later)
	res@gsnFrame        = False   ; Don't advance framce  (will do later)
	res@gsnMaximize     = True    ; Maximize plot in frame
	res@gsnSpreadColors = True
	res@cnLinesOn       = False
	res@cnLineLabelsOn  = False
	res@cnInfoLabelOn   = False
	res@cnFillMode      = FillType
	res@cnFillOn        = True
	res@cnLevelSelectionMode = "ExplicitLevels"
	res@lbOrientation   = "Vertical"
      ; set map options
	res@mpPerimOn  		= False 
	res@mpProjection 	= "Mercator" ; because google map uses Mercator
        res@mpLimitMode         = "LatLon"
        res@mpMinLatF = 39
        res@mpMaxLatF = 50
        res@mpMinLonF = -126
        res@mpMaxLonF = -109
	res@gsnPaperOrientation = "Portrait"
        res@cnGridBoundFillPattern = "SolidFill"
        res@cnGridBoundFillColor = "White"

	AQIcolormap = (/"white", "black", "green4", "green1", "yellow1", "orange1", "red1", "maroon4", "firebrick4"/)
        res@cnLevels             = (/45.0, 60.0, 75.0, 95.0, 115.0, 375.0/)

        if (border_option .eq. "N") then
	  res@mpOutlineOn = False
        end if
        if (border_option .eq. "Y") then
	  res@mpDataBaseVersion = "MediumRes"
	  res@mpOutlineBoundarySets = "GeophysicalAndUSStates"	
        end if 
        if (scale_option .eq. "N") then
	  res@lbLabelBarOn = False 	; turn off color scale bar
        end if
        if (scale_option .eq. "Y") then
	  res@lbTitleOn        = True ; turn on title
	  res@lbTitleString    = "ppb"
       end if

  ; ------------------------------------------------------------------
  ; Read in data
  ; ------------------------------------------------------------------

      x1 = g1lat*1.0
      x1@lat2d = g1lat    ; setting 2D lat/lon coords for all species
      x1@lon2d = g1lon
      x0 = f1->RollingA8_O3(:,0,:,:)*1.0 ; ppm to ppb
      ; dimension stuff
      a = dimsizes(x0)
      nstep = a(0)

  ; ------------------------------------------------------------------
  ; start plotting hour by hour
  ; ------------------------------------------------------------------
    
   YYYYMMDD2Use = ${YYYYMMDDm1}
    do ifilestep = 0, (nstep-1)

       tflag = f1->TFLAG(ifilestep,0,:)
       filedate = tflag(0)
       filetime = tflag(1)

       iGMT = filetime/10000
       iPST = iGMT - 8
       if ( iPST .lt. 0 ) then
         iPST = iPST + 24
       end if
       aPST = sprinti("%0.2i",iPST)
       if ( aPST .eq. "00" ) then
         YYYYMMDD2Use = ${YYYYMMDD}
       end if

       outfile = "$PSDIR"+"/airpact5_AQIcolors_08hrO3_"+YYYYMMDD2Use+ aPST
;	res@tiMainString    = "Ozone (8hr avg) " +YYYYMMDD2Use + "  " +aPST + " PST"
;       delete(res@cnLevels) 
       wks = gsn_open_wks("ps", outfile )                                      
       gsn_define_colormap(wks,AQIcolormap)
       x1 = x0 (ifilestep,:,:)
       res@lbTitleString = "ppbv"; should result in ppb
; duplicates above?        res@cnLevels             = (/8.0,12.0,35.5,55.5,150.5,250.5,350.5/)
       map = gsn_csm_contour_map(wks, x1, res)
       draw(map)

    end do ;ifilestep = 0, (nstep-1)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end 

EOF
# end of AQIcolors_ave08hrO3.ncl

ncl -Q $NCLSCRIPTS/AQIcolors_ave08hrO3.ncl
if ( $status == 0 ) /bin/rm -f $NCLSCRIPTS/AQIcolors_ave08hrO3.ncl


 #convert to gif files
  set GIFDIR     = $indir/IMAGES/aconc/ave08hr/gif
  mkdir -p $GIFDIR
  cd $PSDIR
  foreach psfile ( *.ps )
    set fileroot = `echo $psfile | cut -d '.' -f 1 `
    echo "   convert ps to gif :" $fileroot
    convert -density $imgd -crop ${cx}x${cy}+${sx}+${sy} +repage $PSDIR/$psfile  $GIFDIR/${fileroot}.gif
#    convert -density $imgd +repage $PSDIR/$psfile  $GIFDIR/${fileroot}.gif

    if ( -e $GIFDIR/${fileroot}.gif ) then
       convert -resize ${cx}x${cy} +repage $GIFDIR/${fileroot}.gif  $GIFDIR/${fileroot}.gif
       chmod a+r $GIFDIR/${fileroot}.gif
       /bin/rm -f $PSDIR/$psfile
    endif
  end
  cd ../
  rmdir $PSDIR

exit
