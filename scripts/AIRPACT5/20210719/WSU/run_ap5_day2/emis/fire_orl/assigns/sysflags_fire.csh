#!/bin/csh -fx

#  %W% %P% %G% %U%

#  Determine operating system for compiling SMOKE

source $SMK_HOME/scripts/platform

if ( $status != 0 ) then
    exit( $status )
endif

source $SMK_SUBSYS/edss_tools/setup/set_dirs.scr
source $SMK_SUBSYS/filesetapi/Setup

# Make directories for library, object files, and executables
setenv    SMK_BIN "$SMKROOT/$SMOKE_EXE"
setenv    IOAPIDIR $SMK_SUBSYS/ioapi/$SMOKE_EXE
setenv    NETCDFDIR $SMK_SUBSYS/netcdf/$SMOKE_EXE
if( ! -e $SMK_BIN ) mkdir -p $SMK_BIN
if( ! -e $MD_SRC/$SMOKE_EXE ) mkdir -p $MD_SRC/$SMOKE_EXE
if( ! -e $IOAPIDIR ) mkdir -p $IOAPIDIR
if( ! -e $NETCDFDIR ) mkdir -p $NETCDFDIR

if ( $?M6_FFLAGS ) then
else
   echo "ERROR: The platform file in SMKHOME/scripts has not been"
   echo "       updated to include the M6_FFLAGS compiler variable"
   exit( 1 )
endif

setenv LIBS_COMPILE " "
switch ( $SMOKE_EXE )
  case IRIXn32f90:
  case IRIX6f90:
  case IRIXn64f90:
    setenv FFLAGS   "$FFLAG -I${IOINC} -I${INC} -I${MD_SRC}/${SMOKE_EXE} -I${ETDSRC}/${SMOKE_EXE} -I${FS_ROOT} -I${FS_BIN}"
    setenv DBGFLAGS "$DBGFLAG -I${IOINC} -I${INC} -I${MD_SRC}/${SMOKE_EXE} -I${ETDSRC}/${SMOKE_EXE} -I${FS_ROOT} -I${FS_BIN}"
    setenv LDIRS    "-L${SMK_BIN} -L${TOOLS_BIN} -L${FS_BIN} -L${IOAPIDIR} -L${NETCDFDIR}"
    setenv LIBS_SYS    "-lsmoke -lfileset -ledsstools -lioapi -lnetcdf -lmp"
    setenv LIBS_DEBUG_SYS "-lsmoke.debug -lfileset.debug -ledsstools.debug -lioapi.debug -lnetcdf.debug -lmp"
    breaksw
  case SunOS5f90:
#   NOTE: -Bstatic caused problems with ENVYN (perhaps because not
#         using I/O API compiled with f90 ?)
    setenv FFLAGS   "$FFLAG  -M${MD_SRC}/${SMOKE_EXE} -M${ETDSRC}/${SMOKE_EXE}  -M${FS_BIN} -I${IOINC} -I${INC} -I${FS_ROOT}"
    setenv DBGFLAGS "$DBGFLAG -M${MD_SRC}/${SMOKE_EXE} -M${ETDSRC}/${SMOKE_EXE} -M${FS_BIN} -I${IOINC} -I${INC} -I${FS_ROOT} "
    setenv LDIRS    "-L${SMK_BIN} -L${TOOLS_BIN} -L${FS_BIN} -L${IOAPIDIR} -L${NETCDFDIR}"
    setenv LIBS_SYS     "-lsmoke -lfileset -ledsstools -lioapi -lnetcdf"
    setenv LIBS_DEBUG_SYS "-lsmoke.debug -lfileset.debug -ledsstools.debug -lioapi.debug -lnetcdf.debug"
    breaksw
case HP_UX11f90:
    setenv FFLAGS   "$FFLAG  -I${IOINC} -I${INC} -I${MD_SRC}/${SMOKE_EXE} -I${ETDSRC}/${SMOKE_EXE} -I${FS_ROOT} -I${FS_BIN}"
    setenv DBGFLAGS "$DBGFLAG -I${IOINC} -I${INC} -I${MD_SRC}/${SMOKE_EXE} -I${ETDSRC}/${SMOKE_EXE} -I${FS_ROOT} -I${FS_BIN}"
    setenv LDIRS    "+U77 -Wl,-L,${SMK_BIN},${TOOLS_BIN},${FS_BIN},${IOAPIDIR},${NETCDFDIR}"
    setenv LIBS_SYS     "-lsmoke -lfileset -ledsstools -lioapi -lnetcdf"
    setenv LIBS_DEBUG_SYS "-lsmoke.debug -lfileset.debug -ledsstools.debug -lioapi.debug -lnetcdf.debug"
    breaksw
case AIX4n64f90:
case AIX4f90:
    setenv FFLAGS   "$FFLAG -I${IOINC} -I${INC} -I${MD_SRC}/${SMOKE_EXE}" -I${ETDSRC}/${SMOKE_EXE} -I${FS_ROOT} -I${FS_BIN}"
    setenv DBGFLAGS "$DBGFLAG -I${IOINC} -I${INC} -I${MD_SRC}/${SMOKE_EXE}" -I${ETDSRC}/${SMOKE_EXE} -I${FS_ROOT} -I${FS_BIN}"

    setenv LDIRS    "-L${SMK_BIN} -L${TOOLS_BIN} -L${FS_BIN} -L${IOAPIDIR} -L${NETCDFDIR} -lxlsmp"
    setenv LIBS_SYS     "-lsmoke -lfileset -ledsstools -lioapi -lnetcdf"
    setenv LIBS_DEBUG_SYS "-lsmoke.debug -lfileset.debug -ledsstools.debug -lioapi.debug -lnetcdf.debug"
    breaksw
case Linux2_alpha:
    setenv FFLAGS   "$FFLAG -I${IOINC} -I${INC} -I${MD_SRC}/${SMOKE_EXE} -I${ETDSRC}/${SMOKE_EXE} -I${FS_ROOT} -I${FS_BIN}"
    setenv DBGFLAGS "$DBGFLAG -I${IOINC} -I${INC} -I${MD_SRC}/${SMOKE_EXE} -I${ETDSRC}/${SMOKE_EXE} -I${FS_ROOT} -I${FS_BIN}"
    setenv LDIRS    "-L${SMK_BIN} -L${TOOLS_BIN} -L${FS_BIN} -L${IOAPIDIR} -L${NETCDFDIR}"
    setenv LIBS_SYS     "-lsmoke -lfileset -ledsstools -lioapi -lnetcdf"
    setenv LIBS_DEBUG_SYS "-lsmoke.debug -lfileset.debug -ledsstools.debug -lioapi.debug -lnetcdf.debug"
    breaksw
case Linux2_x86ifc:
    setenv FFLAGS   "$FFLAG -I${ETINC} -I${IOINC} -I${INC} -I${FS_ROOT} -I${MD_SRC}/${SMOKE_EXE} -I${ETDSRC}/${SMOKE_EXE} -I${FS_BIN}"
    setenv DBGFLAGS "$DBGFLAG -I${ETINC} -I${IOINC} -I${INC} -I${FS_ROOT} -I${MD_SRC}/${SMOKE_EXE} -I${ETDSRC}/${SMOKE_EXE} -I${FS_BIN}"
    setenv LDIRS    "-static -L${SMK_BIN} -L${TOOLS_BIN} -L${FS_BIN} -L${IOAPIDIR} -L${NETCDFDIR}"
    setenv LIBS_SYS     "-lsmoke -lfileset -ledsstools -lioapi -lnetcdf"
    setenv LIBS_DEBUG_SYS "-lsmoke.debug -lfileset.debug -ledsstools.debug -lioapi.debug -lnetcdf.debug"
    setenv LIBS_COMPILE ""
    breaksw
case  Linux2_x86pg:
    setenv FFLAGS   "$FFLAG  -module ${MD_SRC}/${SMOKE_EXE} -module ${ETDSRC}/${SMOKE_EXE} -module ${FS_BIN} -I${ETINC} -I${IOINC} -I${INC} -I${MD_SRC}/${SMOKE_EXE} -I${ETDSRC}/${SMOKE_EXE} -I${FS_ROOT} -I${FS_BIN}"
    setenv DBGFLAGS "$DBGFLAG  -module ${MD_SRC}/${SMOKE_EXE} -module ${ETDSRC}/${SMOKE_EXE} -module ${FS_BIN} -I${ETINC} -I${IOINC} -I${INC} -I${MD_SRC}/${SMOKE_EXE} -I${ETDSRC}/${SMOKE_EXE} -I${FS_ROOT} -I${FS_BIN}"
    setenv LDIRS    "-L${SMK_BIN} -L${TOOLS_BIN} -L${FS_BIN} -L${IOAPIDIR} -L${NETCDFDIR}"
    setenv LIBS_SYS     "-lsmoke -lfileset -ledsstools -lioapi -lnetcdf"
    setenv LIBS_DEBUG_SYS "-lsmoke.debug -lfileset.debug -ledsstools.debug -lioapi.debug -lnetcdf.debug"
    breaksw
case  Linux2_x86_64pg:
    setenv FFLAGS   "$FFLAG  -module ${MD_SRC}/${SMOKE_EXE} -module ${ETDSRC}/${SMOKE_EXE} -module ${FS_BIN} -I${ETINC} -I${IOINC} -$
    setenv DBGFLAGS "$DBGFLAG  -module ${MD_SRC}/${SMOKE_EXE} -module ${ETDSRC}/${SMOKE_EXE} -module ${FS_BIN} -I${ETINC} -I${IOINC}$
    setenv LDIRS    "-L${SMK_BIN} -L${TOOLS_BIN} -L${FS_BIN} -L${IOAPIDIR} -L${NETCDFDIR}"
    setenv LIBS_SYS     "-lsmoke -lfileset -ledsstools -lioapi -lnetcdf"
    setenv LIBS_DEBUG_SYS "-lsmoke.debug -lfileset.debug -ledsstools.debug -lioapi.debug -lnetcdf.debug"
    breaksw
default:
    echo "The sysflags file in the ASSIGNS directory does not have compiler"
    echo "    settings for executable format "$SMOKE_EXE
    echo "Pleae edit the sysflags file and add this exectuable format and the"
    echo "    appropriate compiler settings."
    exit( 2 )
endsw

switch ( $SMOKE_EXE )
case Linux2_x86ifc:
    setenv M6_FFLAGS "$M6_FFLAG -I${ETINC} -I${IOINC} -I${INC} -I${FS_ROOT} -I${MD_SRC}/${SMOKE_EXE}"
    breaksw
default:
    setenv M6_FFLAGS "$FFLAGS"
endsw

echo " "
echo "Host name:             "`hostname`
echo "Platform type:         $SMOKE_EXE"
echo "Main SMOKE directory:  $SMKROOT"
echo "Executable directory:  $SMK_BIN"
echo "Data directory:        $SMKDAT"
echo " "
