#!/bin/csh -fX

# mcip5.1_AP5_37_DAY1.csh    03/06/18 Joe Vaughan
echo Running $0 for argument $1

# RCS file, release, date & time of last delta, author, state, [and locker]
# $Header: /project/work/rep/MCIP2/src/mcip2/run.mcip,v 1.8 2007/08/03 20:46:21 tlotte Exp $

#=======================================================================
#
#  Script:  run.mcip
#  Purpose: Runs Models-3/CMAQ Meteorology-Chemistry Interface
#           Processor.  Part of the US EPA's Models-3/CMAQ system.
#  Method:  In UNIX/Linux:  run.mcip >&! mcip.log
#  Revised: 20 Sep 2001  Original version.  (T. Otte)
#           18 Oct 2001  Added CoordName to user definitions.  Deleted
#                        script variable DomIdMM5.  Added Fortran link
#                        for GRIDDESC file.  Moved namelist output to
#                        WorkDir, and mmheader output to OutDir.  Added
#                        user variables I0, J0, NCOLS, and NROWS for
#                        MCIP windowing.  (T. Otte)
#           29 Jan 2002  Added new namelist for file names.  Generalized
#                        the end-of-namelist delimiter.  (T. Otte)
#           27 Feb 2002  Removed minimum size for windows.  (T. Otte)
#           19 Mar 2002  Changed default grid cell for printing.
#                        (T. Otte)
#           11 Jun 2003  Clarified instructions on use of BTRIM and
#                        setting I0 and J0 for windowing option.
#                        Removed GRIDBDY2D, GRIDBDY3D, and METBDY2D
#                        from output.  (T. Otte)
#           01 Jul 2004  Restored GRIDBDY2D to output.  (T. Otte)
#           29 Nov 2004  Added TERRAIN option for input to get
#                        fractional land use from MM5 preprocessor.
#                        (T. Otte)
#           26 May 2005  Changed I0 and J0 to Y0 and X0 to make code
#                        more general.  Removed "_G1" from environment
#                        variables for output files.  Created two new
#                        user options for calculating dry deposition
#                        velocities.  Added capability to process more
#                        than five input meteorology files in a single
#                        MCIP run.  (T. Otte)
#           27 Feb 2006  Updated automated namelist generator for
#                        Linux on Mac (assumed to be) using the XLF
#                        compiler.  (T. Otte)
#           24 Jul 2007  Added option to bypass dry deposition velocity
#                        calculations in MCIP so that they can be done
#                        inline in the CCTM.  Eliminated options to
#                        use RADM (Wesely) dry deposition, eliminated
#                        multiple versions of M3Dry (Pleim) dry
#                        deposition, and eliminated options and to
#                        recalculate PBL and radiation fields in MCIP.
#                        (T. Otte)
#	    26 Feb 2008  Script modified to find UW WRF files.  (J. Vaughan)
#           27 May 2008  Added optional namelist variable to override
#                        earth radius default from MM5 and WRF.
#                        (T. Otte)
#                        Added variables to support GOES satellite
#                        cloud processing (InSatDir, InSatFile, LSAT).
#                        Requires additional data and preprocessing
#                        package available from University of Alabama
#                        at Huntsville.  Contributed by University of
#                        Alabama at Huntsville.  (A. Biazar and T. Otte)
#           23 Dec 2008  Added optional namelist variable to override
#                        default setting for reference latitude for
#                        WRF Lambert conformal projection.  (T. Otte)
#           19 Mar 2010  Added namelist variable option to compute
#                        and output potential vorticity.  Added namelist
#                        variable option to output vertical velocity
#                        predicted by meteorological model.  Allow
#                        output from WRF Preprocessing System (WPS)
#                        routine, GEOGRID, to provide fractional land
#                        use output if it is unavailable in WRF output.
#                        Add user option to output u- and v-component
#                        winds on C-staggered grid.  (T. Otte)
#	    10 Nov 2010  Added sleep 14400 to delay until all d3 files should be available. (J. Vaughan)
#	    16 Oct 2011  Changed X0 = 78 apropos WRF D3 shift and email of 101011 from S Chung, also
#			 changed InTerDir to /home/disk/rainier_empact/nairpact/domains/2011-10-17.
#	    11 Feb 2012  Removed sleep 14400 as d3 files seem to be available by ~ 8:30 PM.   (J. Vaughan)
#	    26 Mar 2013  Commented out 'source' of set_env_4km.csh; it will be called in parent script.
#	    12 Nov 2013  Changed to MODIS LU in /home/disk/rainier_empact/nairpact/domains/2013-11-08. (J. Vaughan)
#	    April_June 2016  Changes for AIRPACT5 (J. Vaughan)
#                               Removing references to nairpact. (J. Vaughan)
#                               Set LWOUT = 1 to support HYSPLIT with MCIP files.  Serena Chung
#=======================================================================

#check argument
if ( $#argv == 1 ) then
   setenv SRTYR `echo $1 | cut -c1-4`
   setenv SRTMN `echo $1 | cut -c5-6`
   setenv SRTDT `echo $1 | cut -c7-8`
   setenv SRTHR `echo $1 | cut -c9-10`
else
   echo 'Invalid argument. '
   echo "Usage $0 <yyyymmddhh>"
   set exitstat = 1
   exit ( $exitstat )
endif

# AIRPACT locations
set HOME       = /home/rainier_empact
set AIRRUN    = $HOME/airpact5/AIRRUN5
set AIRHOME   = $HOME/airpact5/AIRHOME 
set AIRDATA    = $AIRHOME/DATA
setenv STIME     080000 # start time HHMMSS
setenv RNLEN     240000 # run length HHMMSS

# set_env.csh sets CASE GridName CoordName TOOLS LOGDIR SDATE EDATE ETIME
#                  ENDYR ENDMN ENDDT NXDATE NXTIME NXNDYR NXNDMN NXNDDT
#			and RUNROOT
 source $AIRHOME/RUN/set_env_4km.csh Now called in parent script.   JKV 032613

#-----------------------------------------------------------------------
# Set identification for input and output files.
#
#   APPL       = Application Name (tag for MCIP output file names) (DON'T USE)
#   CoordName  = Coordinate system name for GRIDDESC
#   GridName   = Grid Name descriptor for GRIDDESC
#   InMetDir   = Directory that contains input meteorology files
#4.3   InTerDir   = Directory that contains input MM5 "TERRAIN" file
#                (Used for providing fractional land-use categories,
#                and it will only work if IEXTRA was set to TRUE in
#                MM5's TERRAIN program.  Is TRUE for P-X simulations.)
#   InGeoDir   = Directory that contains input WRF "GEOGRID" file to
#                provide fractional land-use categories if "LANDUSEF"
#                was not included in the WRFOUT files.

#   OutDir     = Directory to write MCIP output files
#   ProgDir    = Directory that contains the MCIP executable
#   WorkDir    = Working Directory for Fortran links and namelist
#-----------------------------------------------------------------------

# set APPL       =  (DON'T SET)
set CoordName  = LAM_49N121W         # 16-character maximum
set GridName   = AIRPACT_04km           # 16-character maximum

set InMetDir   = /home/disk/rainier_mm5rt/data # TEST 092612 Joe Vaughan
set InTerDir   = /home/disk/rainier_empact/airpact5/domains/2013-11-08 # JKV 111213 
set OutDir     = $RUNROOT/MCIP37
set ProgDir    = ${HOME}/MCIP5.1/src
set WorkDir    = $OutDir

#-----------------------------------------------------------------------
# Set name(s) of input meteorology file(s)
#
#   File name(s) must be set inside parentheses since "InMetFiles" is
#   a C-shell script array.  Multiple file names should be space-
#   delimited.  Additional lines can be used when separated by a
#   back-slash (\) continuation marker.  The file names can be as
#   they appear on your system; MCIP will link the files in by a
#   Fortran unit number and the explicit name via a namelist.  The
#   files must be listed in chronological order.  The maximum number
#   of input meteorology files must be less than or equal to the number
#   in MAX_MM in file_mod.F (default is 100).
#
#   Example:
#     set InMetFiles = ( $InMetDir/MMOUT_DOMAIN2.time1 \
#                        $InMetDir/MMOUT_DOMAIN2.time2 )
#
#-----------------------------------------------------------------------

#4.3
set IfGeo      = "F"
#set InGeoFile  = $InGeoDir/geo_em_d01.nc

#4.3
#set IfTer      = "T"
#set InTerFile  = $InTerDir/geo_em.d03.nc

#-----------------------------------------------------------------------
# Set user control for dry deposition velocity calculation.
#
#4.3   LDDEP: 0 = Do not calculate dry deposition velocities in MCIP
#          4 = Use Models-3 (Pleim) dry deposition routine with Cl & Hg
#
#   LPV:     0 = Do not compute and output potential vorticity
#            1 = Compute and output potential vorticity
#
#   LWOUT:   0 = Do not output vertical velocity
#            1 = Output vertical velocity
#
#4.3   LUVCOUT: 0 = Do not output u- and v-component winds on C-grid
#            1 = Output u- and v-component winds on C-grid
#
#   LUVBOUT: 0 = Do not output u- and v-component winds on B-grid
#            1 = Output u- and v-component winds on B-grid (cell corner)
#                in addition to the C-grid (cell face) output
#4.3   LSAT:    0 = No satellite input is available (default)
#            1 = GOES observed cloud info replaces model-derived input
#-----------------------------------------------------------------------

#4.3	set LDDEP = 0
set LPV     = 0
set LWOUT   = 1
set LUVBOUT = 1
#4.3 set LUVCOUT = 1
#4.3 set LSAT    = 0

#-----------------------------------------------------------------------
# Set run start and end date.  (YYYY-MO-DD-HH:MI:SS.SSSS)
#   MCIP_START:  First date and time to be output [UTC]
#   MCIP_END:    Last date and time to be output  [UTC]
#   INTVL:       Frequency of output [minutes]
#-----------------------------------------------------------------------

set MCIP_START = ${SRTYR}-${SRTMN}-${SRTDT}-08:00:00.0000  # [UTC]
set MCIP_END   = ${ENDYR}-${ENDMN}-${ENDDT}-08:00:00.0000  # [UTC]
echo "MCIP START: $MCIP_START END: $MCIP_END"

set INTVL      = 60 # [min]

echo "Wait for necessary 4-km files"
while ( ! -e $InMetDir/$1/wrfout_d3.$1.f33.0000 ) 
sleep 60
end

echo "What is available in $InMetDir ?"

ls -lt  $InMetDir/$1/wrfout_d3.$1.f*.0000   # TEST 092612 Joe Vaughan
echo "${SRTYR}${SRTMN}${SRTDT}00/wrfout_d3*"
set InMetFiles = ( \
        $InMetDir/$1/wrfout_d3.$1.f07.0000 \
        $InMetDir/$1/wrfout_d3.$1.f08.0000 \
        $InMetDir/$1/wrfout_d3.$1.f09.0000 \
        $InMetDir/$1/wrfout_d3.$1.f10.0000 \
        $InMetDir/$1/wrfout_d3.$1.f11.0000 \
        $InMetDir/$1/wrfout_d3.$1.f12.0000 \
        $InMetDir/$1/wrfout_d3.$1.f13.0000 \
        $InMetDir/$1/wrfout_d3.$1.f14.0000 \
        $InMetDir/$1/wrfout_d3.$1.f15.0000 \
        $InMetDir/$1/wrfout_d3.$1.f16.0000 \
        $InMetDir/$1/wrfout_d3.$1.f17.0000 \
        $InMetDir/$1/wrfout_d3.$1.f18.0000 \
        $InMetDir/$1/wrfout_d3.$1.f19.0000 \
        $InMetDir/$1/wrfout_d3.$1.f20.0000 \
        $InMetDir/$1/wrfout_d3.$1.f21.0000 \
        $InMetDir/$1/wrfout_d3.$1.f22.0000 \
        $InMetDir/$1/wrfout_d3.$1.f23.0000 \
        $InMetDir/$1/wrfout_d3.$1.f24.0000 \
        $InMetDir/$1/wrfout_d3.$1.f25.0000 \
        $InMetDir/$1/wrfout_d3.$1.f26.0000 \
        $InMetDir/$1/wrfout_d3.$1.f27.0000 \
        $InMetDir/$1/wrfout_d3.$1.f28.0000 \
        $InMetDir/$1/wrfout_d3.$1.f29.0000 \
        $InMetDir/$1/wrfout_d3.$1.f30.0000 \
        $InMetDir/$1/wrfout_d3.$1.f31.0000 \
        $InMetDir/$1/wrfout_d3.$1.f32.0000 \
        $InMetDir/$1/wrfout_d3.$1.f33.0000 )
echo $InMetFiles

#-----------------------------------------------------------------------
# Choose output format.
#   1 = Models-3 I/O API
#   2 = netCDF
#-----------------------------------------------------------------------

set IOFORM = 1

#4.3 -------------------------------------------------------------------
# Set CTM layers.  Should be in descending order starting at 1 and 
# ending with 0.  There is currently a maximum of 100 layers allowed.
# To use all of the layers from the input meteorology without
# collapsing (or explicitly specifying), set CTMLAYS = -1.0.
#-----------------------------------------------------------------------

#4.3 set CTMLAYS = "-1.0"

# Eta levels  for UW WRF files from David Ovens
# See www.atmos.washington.edu/wrfrt/info/
##Full sigma 
#   set CTMLAYS = " 1.0, 0.995, 0.99, 0.9841, 0.9772, 0.9702, 0.962,\
#0.9525, 0.9414, 0.9284, 0.9134, 0.896, 0.8759, 0.8527, 0.826, 0.7955,\
#0.7608, 0.7218, 0.6785, 0.6309, 0.5785, 0.5213, 0.4594, 0.3953, 0.336,\
#0.2832, 0.2363, 0.1951, 0.1595, 0.1291, 0.1031, 0.0806, 0.0612, 0.0449,\
#0.0312, 0.0194, 0.0091, 0.0 "

#-----------------------------------------------------------------------
# Determine whether or not static output (GRID) files will be created.
#-----------------------------------------------------------------------

set MKGRID = T

#-----------------------------------------------------------------------
# Set number of meteorology "boundary" points to remove on each of four
# horizontal sides of MCIP domain.  This affects the output MCIP domain
# dimensions by reducing meteorology domain by 2*BTRIM + 2*NTHIK + 1,
# where NTHIK is the lateral boundary thickness (in BDY files), and the
# extra point reflects conversion from grid points (dot points) to grid
# cells (cross points).  Setting BTRIM = 0 will use maximum of input
# meteorology.  To remove MM5 lateral boundaries, set BTRIM = 5.
#
# *** If windowing a specific subset domain of input meteorology, set
#     BTRIM = -1, and BTRIM will be ignored in favor of specific window
#     information in X0, Y0, NCOLS, and NROWS.
#-----------------------------------------------------------------------

set BTRIM = -1
#set BTRIM = 0

#-----------------------------------------------------------------------
# Define MCIP subset domain.  (Only used if BTRIM = -1.  Otherwise,
# the following variables will be set automatically from BTRIM and
# size of input meteorology fields.)
#   X0:     X-coordinate of lower-left corner of full MCIP "X" domain
#           (including MCIP lateral boundary) based on input MM5 domain.
#           X0 refers to the east-west dimension.  Minimum value is 1.
#   Y0:     Y-coordinate of lower-left corner of full MCIP "X" domain
#           (including MCIP lateral boundary) based on input MM5 domain.
#           Y0 refers to the north-south dimension.  Minimum value is 1.
#   NCOLS:  Number of columns in output MCIP domain (excluding MCIP
#           lateral boundaries).
#   NROWS:  Number of rows in output MCIP domain (excluding MCIP
#           lateral boundaries).
#-----------------------------------------------------------------------
# JKV Oct 2010, setting up a new 4-km AIRPACT domain matching the AIRPACT-3 12-km domain 
set X0    =  78  # Changed by JKV 101611
set Y0    =  3  # 
set NCOLS =  285 # 12-km used 95, 95*3 = 285
set NROWS =  258 # 12-km used 95, but 4-km is offset 

#-----------------------------------------------------------------------
# Set coordinates for cell for diagnostic prints on output domain.
# If coordinate is set to 0, domain center cell will be used.
#-----------------------------------------------------------------------

set LPRT_COL = 0
set LPRT_ROW = 0

#-----------------------------------------------------------------------
# Optional:  Set WRF Lambert conformal reference latitude.
#            (Handy for matching WRF grids to existing MM5 grids.)
#            If not set, MCIP will use average of two true latitudes.
# To "unset" this variable, set the script variable to "-999.0".
# Alternatively, if the script variable is removed here, remove it
# from the setting of the namelist (toward the end of the script).
#-----------------------------------------------------------------------

set WRF_LC_REF_LAT = 49.000

#=======================================================================
#=======================================================================
# Set up and run MCIP.
#   Should not need to change anything below here.
#=======================================================================
#=======================================================================

set PROG = mcip

echo Time of MCIP begin 
date

#-----------------------------------------------------------------------
# Make sure directories exist.
#-----------------------------------------------------------------------

if ( ! -d $InMetDir ) then
  echo "No such input directory $InMetDir"
  exit 1
endif

if ( ! -d $OutDir ) then
  echo "No such output directory...will try to create one"
  mkdir -p $OutDir
  if ( $status != 0 ) then
    echo "Failed to make output directory, $OutDir"
    exit 1
  endif
endif

if ( ! -d $ProgDir ) then
  echo "No such program directory $ProgDir"
  exit 1
endif

#4.3if ( $LSAT == 1 ) then
#4.3  if ( ! -d $InSatDir ) then
#4.3    echo "No such satellite input directory $InSatDir
#4.3    exit 1
#4.3  endif
#4.3endif

#-----------------------------------------------------------------------
# Make sure the input files exist.
#-----------------------------------------------------------------------

#4.3if ( $IfTer == "T" ) then
#4.3  if ( ! -f $InTerFile ) then
#4.3    echo "No such input file $InTerFile"
#4.3    exit 1
#4.3  endif
#4.3endif

if ( $IfGeo == "T" ) then
  if ( ! -f $InGeoFile ) then
    echo "No such input file $InGeoFile"
    exit 1
  endif
endif

foreach fil ( $InMetFiles )
  if ( ! -f $fil ) then
    echo "No such input file $fil"
    exit 1
  endif
end

#4.3if ( $LSAT == 1 ) then
#4.3  foreach fil ( $InSatFiles )
#4.3    if ( ! -f $fil ) then
#4.3      echo "No such input file $fil"
#4.3      exit 1
#4.3    endif
#4.3  end
#4.3endif

#-----------------------------------------------------------------------
# Make sure the executable exists.
#-----------------------------------------------------------------------

if ( ! -f $ProgDir/${PROG}.exe ) then
  echo "Could not find ${PROG}.exe"
  exit 1
endif

#-----------------------------------------------------------------------
# Create a work directory for this job.
#-----------------------------------------------------------------------

if ( ! -d $WorkDir ) then
  mkdir -p $WorkDir
  if ( $status != 0 ) then
    echo "Failed to make work directory, $WorkDir"
    exit 1
  endif
endif

cd $WorkDir

#-----------------------------------------------------------------------
# Set up script variables for input files.
#-----------------------------------------------------------------------

if ( $IfGeo == "T" ) then
  if ( -f $InGeoFile ) then
    set InGeo = $InGeoFile
  else
    set InGeo = "no_file"
  endif
else
  set InGeo = "no_file"
endif

set FILE_GD  = $OutDir/GRIDDESC
set FILE_HDR = $OutDir/mmheader  # .${APPL}

#-----------------------------------------------------------------------
# Create namelist with user definitions.
#-----------------------------------------------------------------------

set MACHTYPE = `uname`
if ( ( $MACHTYPE == "AIX" ) || ( $MACHTYPE == "Darwin" ) ) then
  set Marker = "/"
else
  set Marker = "&END"
endif

  # removed from middle of the next cat set 	file_hdr   = "$FILE_HDR"
cat > $WorkDir/namelist.${PROG} << !

 &FILENAMES
  file_gd    = "$FILE_GD"
  file_mm    = "$InMetFiles[1]",
!

if ( $#InMetFiles > 1 ) then
  @ nn = 2
  while ( $nn <= $#InMetFiles )
    cat >> $WorkDir/namelist.${PROG} << !
               "$InMetFiles[$nn]",
!
    @ nn ++
  end
endif

if ( $IfGeo == "T" ) then
cat >> $WorkDir/namelist.${PROG} << !
  file_geo   = "$InGeo"
!
endif

#if ( $IfTer == "T" ) then
#cat >> $WorkDir/namelist.${PROG} << !
#  file_ter   = "$InTer"
#!
#endif

#4.3if ( $LSAT == 1 ) then
#4.3  cat >> $WorkDir/namelist.${PROG} << !
#4.3  file_sat   = "$InSatFiles[1]",
#4.3!
#4.3  if ( $#InSatFiles > 1 ) then
#4.3    @ nn = 2
#4.3    while ( $nn <= $#InSatFiles )
#4.3      cat >> $WorkDir/namelist.${PROG} << !
#4.3               "$InSatFiles[$nn]",
#4.3!
#4.3      @ nn ++
#4.3    end
#4.3  endif
#4.3endif

#4.3 had makegrid   = .${MKGRID}. in next cat set.

cat >> $WorkDir/namelist.${PROG} << !
  ioform   = $IOFORM
 $Marker

 &USERDEFS
  lpv        =  $LPV
  lwout      =  $LWOUT
  luvbout    =  $LUVBOUT
  mcip_start = "$MCIP_START"
  mcip_end   = "$MCIP_END"
  intvl      =  $INTVL
  coordnam   = "$CoordName"
  grdnam     = "$GridName"
  btrim      =  $BTRIM
  lprt_col   =  $LPRT_COL
  lprt_row   =  $LPRT_ROW
  wrf_lc_ref_lat = $WRF_LC_REF_LAT
 $Marker

 &WINDOWDEFS
  x0         =  $X0
  y0         =  $Y0
  ncolsin    =  $NCOLS
  nrowsin    =  $NROWS
 $Marker

!

#-----------------------------------------------------------------------
# Set links to FORTRAN units.
#-----------------------------------------------------------------------

rm fort.*
if ( -f $FILE_GD ) rm -f $FILE_GD

#4.3 ln -s $FILE_HDR                  fort.2
ln -s $FILE_GD                   fort.4
ln -s $WorkDir/namelist.${PROG}  fort.8

#if ( $IfTer == "T" ) then
#  ln -s $InTerFile               fort.9
#endif

set NUMFIL = 0
foreach fil ( $InMetFiles )
  @ NN = $NUMFIL + 10
  ln -s $fil fort.$NN
  @ NUMFIL ++
end

#-----------------------------------------------------------------------
# Set output file names and other miscellaneous environment variables.
#-----------------------------------------------------------------------

setenv IOAPI_CHECK_HEADERS  T
setenv EXECUTION_ID         $PROG

setenv GRID_BDY_2D          $OutDir/GRIDBDY2D  # _${APPL}
setenv GRID_CRO_2D          $OutDir/GRIDCRO2D  #_${APPL}
setenv GRID_CRO_3D          $OutDir/GRIDCRO3D  #_${APPL}
setenv GRID_DOT_2D          $OutDir/GRIDDOT2D  #_${APPL}
setenv MET_BDY_3D           $OutDir/METBDY3D   #_${APPL}
setenv MET_CRO_2D           $OutDir/METCRO2D   #_${APPL}
setenv MET_CRO_3D           $OutDir/METCRO3D   #_${APPL}
setenv MET_DOT_3D           $OutDir/METDOT3D   #_${APPL}

#-----------------------------------------------------------------------
# Execute MCIP.
#-----------------------------------------------------------------------

$ProgDir/${PROG}.exe

if ( $status == 0 ) then
  rm fort.*
  exit 0
else
  echo "Error running $PROG"
  exit 1
endif

echo Time of MCIP end
date
exit(0)
