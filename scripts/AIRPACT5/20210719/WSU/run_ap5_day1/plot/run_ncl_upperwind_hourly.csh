#!/bin/csh -f

# example of using this script:
# 
#   > ./run_ncl_upperwind_hourly.csh 20160201 24
#
#    where 20160215 denotes forecast start time of 8 GMT on Nov 5, 2010
#               24 denotes 24 hours of forecast
#
#
# Farren Herron-Thorp   2012-04-20
# Serena H. Chung       2012-05-03
# Serena H. Chung       2016-02-25 for winds at 850 mb
#
# This C shell script creates hourly gif files of wind barbs at 10 m based on AIRPACT-4's
# MCIP output files. For each hour, the script 1) creates an NCL script, 2) runs the NCL script
# to create the figure in postcript format, and 3) converts the postscript file to a gif file.

#> switch for various subcomponents and options ------------------------

   # plot options
     setenv ADD_COLORBAR 	N
     setenv ADD_BORDERS 	N

     setenv PLOT_UPPERWIND	Y

   # image conversion ( ps to gif ) options
     set imgd=240
     set cx=1726
     set cy=1502
     set sx=128
     set sy=530

#> initialize exit status ----------------------------------------------
   set exitstat = 0

#> check argument & set date strings  ----------------------------------

   if ( $#argv == 2 ) then
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

   if ( ! $?PBS_O_WORKDIR ) then
      set PBS_O_WORKDIR = ~airpact5/AIRHOME/run_ap5_day1
   endif
   if ( ! $?AIRHOME        ) set AIRHOME = ~airpact5/AIRHOME
   if ( ! $?AIRRUN ) then
      set AIRRUN  = /data/lar/projects/airpact5/AIRRUN/$YEAR
   endif
   if ( ! $?AIROUT         ) set AIROUT = $AIRRUN/${yyyymmdd}00
   if ( ! $?AIRLOGDIR      ) set AIRLOGDIR = $AIROUT/LOGS
   if ( ! $?MCIPDIR        ) then
      if ( -e $AIROUT/MCIP/METCRO3D ) then
         set MCIPDIR   = $AIROUT/MCIP
      else
         set MCIPDIR   = /data/lar/projects/airpact5/AIRRUN/${yyyymmdd}00/MCIP
      endif
   endif
   set NHR = $2

#> directory set-up ----------------------------------------------------

   set indir      = $AIROUT
   set mcip       = $MCIPDIR
   set NCLSCRIPTS = ${PBS_O_WORKDIR}/plot
   set PSDIR      = $indir/IMAGES/met/ps
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

cat > $NCLSCRIPTS/upperwindhourly.ncl <<EOF

;*************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  ; read in the options passed from the csh
    border_option = getenv("ADD_BORDERS")
    scale_option  = getenv("ADD_COLORBAR")

    PLOT_UPPERWIND = getenv("PLOT_UPPERWIND")

  ; open NetCDF files.
  ; file(s) of data to plot (remember that even if the netcdf file name doesn't end with ".nc",
  ; must include ".nc" in NCL script)

  ; File(s) with latitude and longitude values.
    g1 = addfile ( "$mcip" + "/GRIDCRO2D.nc","r")  
    f1 = addfile ( "$mcip" + "/METDOT3D.nc","r")
    f2 = addfile ( "$mcip" + "/METCRO3D.nc","r")
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
	res@lbOrientation   = "Vertical"
      ; set map options
	res@mpPerimOn  		= False 
	res@mpProjection 	= "Mercator"  ; because google map uses Mercator
	res@mpLimitMode 	= "LatLon"
    	res@mpMinLatF = 39
    	res@mpMaxLatF = 50
    	res@mpMinLonF = -126
    	res@mpMaxLonF = -109
	res@gsnPaperOrientation = "Portrait"

        if (border_option .eq. "N") then
	  res@mpOutlineOn = False
        end if
        if (border_option .eq. "Y") then
	  res@mpDataBaseVersion = "MediumRes"
	  res@mpOutlineBoundarySets = "GeophysicalAndUSStates"	
        end if 
        if (scale_option .eq. "N") then
	  res@lbLabelBarOn = False 	; turn off color scale bar
	res@vcRefAnnoOn             = False              ; turn off ref wind barb
        end if
        if (scale_option .eq. "Y") then
	  res@lbTitleOn        = True ; turn on title
	  res@lbTitleString    = "units"
       end if

  ; ------------------------------------------------------------------
  ; START PLOTTING SPECIES 
  ; ------------------------------------------------------------------
    ; initial wind variables that will be used for plotting
      U = g1lat*1.0
      U@lat2d = g1lat    ; setting 2D lat/lon coords (cross points)
      U@lon2d = g1lon
      V = g1lat*1.0
      V@lat2d = g1lat    ; setting 2D lat/lon coords (cross points)
      V@lon2d = g1lon

     pinterest = 850.*100 ; 850 mbar in units of Pascal 
     if ( PLOT_UPPERWIND .eq. "Y" ) then

        u3d = f1->UWIND($ihour,:,:,:) ; at dot points
        v3d = f1->VWIND($ihour,:,:,:) ; at dot points
        p3d = f2->PRES( $ihour,:,:,:) ; at cross points

        dimsiz = dimsizes(p3d)
        nx = dimsiz(2)
        ny = dimsiz(1)
        nz = dimsiz(0) ; # of layers
        k2d = new(dimsizes(g1lat) ,"integer")
        k2d(:,:) = 0
        do k = 0, (nz-2)
          ;kflag3d(k,:,:)) = where(p3d(k,:,:).gt.pinterest.and.p3d(k+1,:,:).le.pinterest,1,0)
	   k2d(:,:) = where(p3d(k,:,:).gt.pinterest.and.p3d(k+1,:,:).le.pinterest,k,k2d(:,:))
        end do

	do i=0,(nx-1)
	    do j= 0,(ny-1)
               k = k2d(j,i)+1 ; "+1" because counting by dot points
	       U(j,i) = 0.25*(u3d(k,j,i) + u3d(k,j+1,i) + u3d(k,j,i+1) + u3d(k,j+1,i+1))
	       V(j,i) = 0.25*(v3d(k,j,i) + v3d(k,j+1,i) + v3d(k,j,i+1) + v3d(k,j+1,i+1))
	    end do
	end do

        outfile = "$PSDIR"+"/airpact5_upperWIND_"+"${yyyymmdd}"+"${ahour}"
        wks = gsn_open_wks("ps", outfile )

;  	res@vcRefMagnitudeF         = 2.                ; make vectors larger
  	res@vcRefLengthF            = 0.008              ; ref vec length
  	res@vcGlyphStyle            = "WindBarb"         ; select wind barbs 
  	res@vcMinDistanceF          = 0.008              ; thin out windbarbs
	res@vcMonoLineArrowColor = False
	res@mpFillOn = False

        map = gsn_csm_vector_map(wks, U, V, res)
        draw(map)
     end if



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end 

EOF
# end of upperwindhourly.ncl

       ncl -Q $NCLSCRIPTS/upperwindhourly.ncl

       @ ihour ++
end #while


# convert to gif files
  set GIFDIR     = $indir/IMAGES/met/gif
  mkdir -p $GIFDIR
  cd $PSDIR
  foreach psfile ( *.ps )
    set fileroot = `echo $psfile | cut -d '.' -f 1 `
    convert -density $imgd -transparent white -crop ${cx}x${cy}+${sx}+${sy} +repage $PSDIR/$psfile  $GIFDIR/${fileroot}.gif
    if ( -e $GIFDIR/${fileroot}.gif ) then
       convert -resize ${cx}x${cy} +repage $GIFDIR/${fileroot}.gif  $GIFDIR/${fileroot}.gif
       chmod a+r $GIFDIR/${fileroot}.gif
       /bin/rm -f $PSDIR/$psfile
    endif
  end
  cd ../
  rmdir $PSDIR

# clean up and exist
  /bin/rm -f $NCLSCRIPTS/upperwindhourly.ncl
  exit
