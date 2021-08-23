#!/bin/csh -f

# Example of using this script:
# 
#   > run_ncl_24hrPM25_PSTDay.csh 20120501
#
#   Joe Vaughan August 2017
#
#    where 20101104 denotes forecast start time of 8 GMT on Nov 5, 2010
#               24 denotes 24th hour of forecast 24-hr rolling average.
#    The run of DAY1 results are labeled as 080000 (local midnight and ICON) thru 080000 the next GMT day.
#    These hours of data allow (using the previous day's results) calculation of 
#    a day's worth of 24-hr-rolling avg PM2.5.  Conforming to Meteorological community stds,
#    the average for the period of the day1 resutls is labeled as ~midnight (local) at the start of that day. 
#
# Serena H. Chung       2012-05-14
#
# This C shell script creates hourly gif files of 24-hr PM25 concentrations based on AIRPACT-4's
# CMAQ output files. For each hour, the script 1) creates an NCL script, 2) runs the NCL script
# to create the figure in postcript format, and 3) converts the postscript file to a gif file.

#> switch for various subcomponents and options ------------------------

   # plot options
     setenv ADD_COLORBAR 	Y
     setenv ADD_BORDERS 	Y
     setenv IMAGEFILL      AreaFill  #RasterFill AreaFill or CellFill
   # image conversion ( ps to gif ) options
     set imgd = 120 
     set cx   = 899  # 863
     set cy   = 751  # 751
     set sx   =  64
     set sy   = 265

#> initialize exit status ----------------------------------------------
   set exitstat = 0

#> check argument & set date strings  ----------------------------------

   if ( $#argv == 1 ) then
      setenv YEAR `echo $1 | cut -c1-4`
      setenv MONTH `echo $1 | cut -c5-6`
      setenv DAY `echo $1 | cut -c7-8`
      set currentday = $1
      set previousday = `date -d "$currentday -1 days" '+%Y%m%d'`
   else
      echo 'invalid argument. '
      echo "usage $0 <YYYYMMDD> 
      set exitstat = 1
      exit ( $exitstat )
   endif
#   set NHR = 23  # we want the last hour of the 24-hr rolling averages file in DAY1.
    set NHR = 22  #  But for IDEQ, we shift to an hour earlier for MST day 24-hr avg.

#> during testing 

   if ( ! $?PBS_O_WORKDIR ) then
      set PBS_O_WORKDIR = ~airpact5/AIRHOME/run_ap5_day1
      if ( ! $?AIRHOME        ) set AIRHOME = ~airpact5/AIRHOME
      if ( ! $?AIRRUN ) then
         set AIRRUN  = /data/lar/projects/airpact5/AIRRUN/$YEAR
      endif
      if ( ! $?AIROUT         ) set AIROUT = $AIRRUN/${currentday}00
      if ( ! $?AIRLOGDIR      ) set AIRLOGDIR = $AIROUT/LOGS
      if ( ! $?MCIPDIR        ) then
         if ( -e $AIROUT/MCIP/METCRO2D ) then
            set MCIPDIR   = $AIROUT/MCIP
         else
            set MCIPDIR   = /data/lar/projects/airpact5/AIRRUN/$YEAR/${currentday}00/MCIP37
         endif
      endif
   endif

#> directory set-up ----------------------------------------------------

   set indir      = $AIROUT
   set mcip       = $MCIPDIR
   set NCLSCRIPTS = ${PBS_O_WORKDIR}/plot
   set PSDIR      = $indir/IMAGES/aconc/ave24hr/ps
   mkdir -p $PSDIR

# > create and run ncl script ------------------------------------------

cat > $NCLSCRIPTS/ave24hrPM25.ncl <<EOF

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
    f1 = addfile ( "$indir" + "/POST/CCTM/PM25_L01_24hr_${previousday}.ncf.nc","r")
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
	res@mpProjection 	= "Mercator"  ; because google map uses Mercator
	res@mpLimitMode 	= "LatLon"
    	res@mpMinLatF = 39
    	res@mpMaxLatF = 50
    	res@mpMinLonF = -126
    	res@mpMaxLonF = -109
	res@gsnPaperOrientation = "Portrait"
        res@cnGridBoundFillPattern = "SolidFill"
        res@cnGridBoundFillColor = "White"

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
	  res@lbTitleString    = "units"
       end if

  ; ------------------------------------------------------------------
  ; Read in data
  ; ------------------------------------------------------------------

      x1 = g1lat*1.0
      x1@lat2d = g1lat    ; setting 2D lat/lon coords for all species
      x1@lon2d = g1lon
      x0 = f1->RollingA24_PM25(:,0,:,:)*1.0
      ; dimension stuff
      a = dimsizes(x0)
      nstep = a(0)

  ; ------------------------------------------------------------------
  ; start plotting hour by hour
  ; ------------------------------------------------------------------
    
    YYYYMMDD2Use = ${previousday}
;    do ifilestep = 0, (nstep-1)
       ifilestep = $NHR
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
         YYYYMMDD2Use = ${currentday}
       end if
       outfile = "$PSDIR"+"/airpact5_24hrPM25_forIDEQ_"+YYYYMMDD2Use+ aPST

      ;delete(res@cnLevels) 
       wks = gsn_open_wks("ps", outfile )                                      
       gsn_define_colormap(wks,"WhBlGrYeRe")
       x1 = x0 (ifilestep,:,:)
       res@lbTitleString = "~F33~m~F0~g/m~S~3~N"; should result in micrograms per cubic meter
       res@cnLevels             = (/1.0, 2.0, 4.0, 6.0, 8.0 ,10 ,15, 20 ,30, 40 ,80 ,160/)
       map = gsn_csm_contour_map(wks, x1, res)
       draw(map)

;    end do ;ifilestep = 0, (nstep-1)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end 

EOF
# end of ave24hrPM25.ncl

ncl -Q $NCLSCRIPTS/ave24hrPM25.ncl


 #convert to gif files
  set GIFDIR     = $indir/IMAGES/aconc/ave24hr/gif
  mkdir -p $GIFDIR
  cd $PSDIR
  foreach psfile ( *.ps )
    set fileroot = `echo $psfile | cut -d '.' -f 1 `
    echo "   convert ps to gif :" $fileroot
    convert -density $imgd -transparent white -crop ${cx}x${cy}+${sx}+${sy} +repage $PSDIR/$psfile  $GIFDIR/${fileroot}.gif
    if ( -e $GIFDIR/${fileroot}.gif ) then
       convert -resize ${cx}x${cy} +repage $GIFDIR/${fileroot}.gif  $GIFDIR/${fileroot}.gif
       chmod a+r $GIFDIR/${fileroot}.gif
       /bin/rm -f $PSDIR/$psfile
    endif
  end
  cd ../
  rmdir $PSDIR

# /bin/rm -f $NCLSCRIPTS/ave24hrPM25.ncl
exit
