#!/usr/bin/env csh
##!/bin/csh -fX


#    qsub4run_ncl_KFBC_PM25.template is a template to be edited using sed to substitute values for 
#    year as yyyy and date as yyyymmdd.  The tokens upon which sed will do the subsitutions are the 
#    uppercase versions of yyyy and yyyymmdd.
#   
#    examples of using this template:
#	cat <this-template> | sed -f sed.txt >! qsub<script-name>.csh
#	in the above sed operatin, only the substitutions for 2021 and 20210808 are needed in
#	the sed.txt file.
#    Once sed creates the script for the date to be run, the job can be submitted to the lar queue using qsub.	
#           qsub -V qsub4<script-name>.csh 
#    JKV 2020/05/29
#
#PBS -N KFBC-20210808 
#PBS -l nodes=1:amd:ppn=1,mem=5Gb
#PBS -l walltime=00:30:00
#PBS -q lar
#PBS -d /home/airpact5/AIRHOME/run_ap5_day1/post/cctm/KFBC
#PBS -o /data/lar/projects/airpact5/AIRRUN/2021/2021080800/LOGS/post
#PBS -e /data/lar/projects/airpact5/AIRRUN/2021/2021080800/LOGS/post
#PBS -j oe
#PBS -m ae
#PBS -M jvaughan@wsu.edu
#
#

#    forecast start time is 8 GMT 
# This template creates a script that runs a python script and then builds and executes ncl scripts. 

setenv NCARG_ROOT /home/lar/opt/ncl-6.0.0/gcc-4.1.2
setenv LOGS /data/lar/projects/airpact5/AIRRUN/2021/2021080800/LOGS/post

# Run python code section:
#
module load gcc/7.3.0
module load python/3.7.1/gcc/7.3.0
module load geos/3.7.0/gcc/7.3.0
module load proj/5.2.0/gcc/7.3.0

cd $basedir

#	This could output the log somewhere explicitly.
python3 AIRPACT_KalmanFilter.py >&! $LOGS/AIRPACT_KalmanFilter_py.log


# Run ncl plotting section

#> switches for various subcomponents and options ------------------------

   # plot options 
     setenv ADD_COLORBAR 	N  # (N for graphics for the AIRPACT website, or Y for other uses.) 
     setenv ADD_BORDERS 	N  # (N for graphics for the AIRPACT website, or Y for other uses.) 
     setenv IMAGEFILL      AreaFill  #RasterFill AreaFill or CellFill
   # species to plot
     setenv PLOT_PM25	        Y

   # image conversion ( ps to gif ) options
     set imgd = 120 
     set cx   = 863
     set cy   = 751
     set sx   =  64
     set sy   = 265

#> initialize exit status ----------------------------------------------
   set exitstat = 0

#> directory set-up ----------------------------------------------------

   set indir      = /data/lar/projects/airpact5/AIRRUN/2021/2021080800/POST/CCTM
   set mcip       = /data/lar/projects/airpact5/AIRRUN/2021/2021080800/MCIP37
   set NCLSCRIPTS = $basedir
   set PSDIR      = /data/lar/projects/airpact5/AIRRUN/2021/2021080800/IMAGES/KFBC
   mkdir -p $PSDIR
   #setenv NCARG_ROOT /home/lar/opt/ncl-6.0.0/gcc-4.1.2

# > create and run ncl script hour by hour ----------------------------

cat >! $NCLSCRIPTS/hourly.ncl <<EOF

;*************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  ; read in the options passed from the csh
    border_option = getenv("ADD_BORDERS")
    scale_option  = getenv("ADD_COLORBAR")
    FillType      = getenv("IMAGEFILL")
    PLOT_PM25 = getenv("PLOT_PM25")

  ; open NetCDF files.
  ; file(s) of data to plot (remember that even if the netcdf file name does not end with ".nc",
  ; must include ".nc" in NCL script)
    f1 = addfile ( "$indir" + "/PM25_24hr_BiasCorrected_2021080800.ncf.nc","r")
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
         ;res@mpOutlineBoundarySets = "AllBoundaries"	
        end if 
        if (scale_option .eq. "N") then
	  res@lbLabelBarOn = False 	; turn off color scale bar
        end if
        if (scale_option .eq. "Y") then
	  res@lbTitleOn        = True ; turn on title
	  res@lbTitleString    = "units"
       end if

  ; ------------------------------------------------------------------
  ; START PLOTTING SPECIES 
  ; ------------------------------------------------------------------
      x1 = g1lat*1.0
      x1@lat2d = g1lat    ; setting 2D lat/lon coords for all species
      x1@lon2d = g1lon
     if ( PLOT_PM25 .eq. "Y" ) then
	; delete(res@cnLevels) 
    	outfile = "$PSDIR"+"/KFBC_PM25_CubicInt_"+"20210808"+"00"
	wks = gsn_open_wks("ps", outfile )
	gsn_define_colormap(wks,"WhBlGrYeRe")
	x1 = f1->KFBC_PM25_CubicI(0,0,:,:)*1.0
	res@lbTitleString = ":F33:m:F0:g/m:S:3:N:"; should result in micrograms per cubic meter
   	res@cnLevels             = (/1.0, 2.0, 4.0, 6.0, 8.0 ,10 ,15, 20 ,30, 40 ,80 ,160/)
	map = gsn_csm_contour_map(wks, x1, res)
	draw(map)
	outfile = "$PSDIR"+"/KFBC_PM25_LinKrig_"+"20210808"+"00"
	wks = gsn_open_wks("ps", outfile )
	gsn_define_colormap(wks,"WhBlGrYeRe")
	x1 = f1->KFBC_PM25_LinKri(0,0,:,:)*1.0
	res@lbTitleString = ":F33:m:F0:g/m:S:3:N:"; should result in micrograms per cubic meter
   	res@cnLevels             = (/1.0, 2.0, 4.0, 6.0, 8.0 ,10 ,15, 20 ,30, 40 ,80 ,160/)
	map = gsn_csm_contour_map(wks, x1, res)
	draw(map)
	outfile = "$PSDIR"+"/KFBC_PM25_GausKrig_"+"20210808"+"00"
	wks = gsn_open_wks("ps", outfile )
	gsn_define_colormap(wks,"WhBlGrYeRe")
	x1 = f1->KFBC_PM25_GausKr(0,0,:,:)*1.0
	res@lbTitleString = ":F33:m:F0:g/m:S:3:N:"; should result in micrograms per cubic meter
   	res@cnLevels             = (/1.0, 2.0, 4.0, 6.0, 8.0 ,10 ,15, 20 ,30, 40 ,80 ,160/)
	map = gsn_csm_contour_map(wks, x1, res)
	draw(map)
     end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end 

EOF
# end of hourly.ncl

      /home/lar/opt/ncl-6.0.0/gcc-4.1.2/bin/ncl -x $NCLSCRIPTS/hourly.ncl  >&! $LOGS/hourly.ncl_20210808.log


# convert to gif files
  set GIFDIR     = $PSDIR
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

#/bin/rm -f $NCLSCRIPTS/hourly.ncl
exit
