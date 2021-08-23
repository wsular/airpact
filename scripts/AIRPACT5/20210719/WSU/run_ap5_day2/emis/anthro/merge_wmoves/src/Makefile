SHELL=/bin/sh

# Compiler and compiler options
# ======================================================================

FC        = pgf90
CC        = gcc
FFLAGS    =  -g -C -Mbounds -Mpreprocess -Mdclchk -byteswapio
LDINCLUDE = -I${NETCDF}/include \
            -I${IOAPI}/ioapi
LDFLAGS   = -L${IOAPI_LIB}
LDLIBS    = -lnetcdf  -lioapi  -lm #-lpgftnrtl -lpgc #-lg2c

## Executable
## ====================================================================

EXE:	juldate.f90
	$(FC) $(FFLAGS) $(LDFLAGS) $(LDINCLUDE) juldate.f -o juldate $(LDLIBS)

clean:
	rm -f juldate

