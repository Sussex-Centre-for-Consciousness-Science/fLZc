# NOTE 1: Standalone binary executables are placed in the `bin' directory. Matlab
# mex binaries are placed in the `../matlab/mex' directory.
#
# NOTE 2: For the build to work, you will need to set an environmental variable
# called MATLAB_PATH which points to the root path of your Matlab installation;
# then build with
#
#     make
#
# NOTE 3: The maintainer binary executables (see NBIN) are not compiled by default,
# as they are mostly for the benefit of the maintainer. Build with
#
#     make maint
#
# The executables will have to be run (on Linux, MacOS[?]) with
#
#     LD_LIBRARY_PATH=$MATLAB_PATH/bin/glnxa64 bin/<executable>
#
# or, alternatively,
#
#     export LD_LIBRARY_PATH=$MATLAB_PATH/bin/glnxa64
#
# before running. (I tried to hard-link the library path, but failed miserably;
# despite many, many hours down various hideous rabbit-holes, I cannot get
# -Wl, rpath= ... to work. Thanks, Matlab :-/)
#
# This palaver targets Linux, but may well work on MacOS too; Windows probably
# requires more hoopla; the maintainer would appreciate any feedback on this.

ifdef ComSpec
	OS = WIN
else
	UNAME = $(shell uname)
	ifeq ($(UNAME),Linux)
		OS = LINUX
	else
		ifeq ($(UNAME),Darwin)
			OS = MAC
		else
			OS = UNKNOWN
		endif
	endif
endif

# Linux
ifeq ($(OS),LINUX)
	BINEXT  =
	OBJEXT  = o
endif

# Darwin
ifeq ($(OS),MAC)
	BINEXT  =
	OBJEXT  = o
endif

# Windows
ifeq ($(OS),WIN)
	BINEXT  = .exe
	OBJEXT  = obj
endif

CC     = gcc
BINDIR = bin

MEX      = mex
MEXEXT   = $(shell mexext)
MEXDIR   = ../matlab/mex
MEXINC   = $(MATLAB_PATH)/extern/include

REPDEP = sed -i -e '1s,\($*\)\.o[ :]*,\1.o \.$*.d: ,' \.$*.d

# "library" source

CSRC = mt64.c utils.c LZ76c.c  LZ78c.c
COBJ = $(patsubst %.c, .%.$(OBJEXT), $(CSRC))
CDEP = $(patsubst %.o, %.d, $(COBJ))

# test source

TSRC = LZ76c_test.c LZ76c_benchmark.c LZ78c_test.c LZ78c_benchmark.c
TOBJ = $(patsubst %.c, .%.$(OBJEXT), $(TSRC))
TDEP = $(patsubst %.o, %.d, $(TOBJ))
TBIN = $(patsubst %.c, $(BINDIR)/%$(BINEXT), $(TSRC))

# mainainer source

NSRC = LZ76c_randmv.c LZ78c_randmv.c
NBIN = $(patsubst %.c, $(BINDIR)/%$(BINEXT), $(NSRC))

# Matlab (mex) source

MSRC = LZ76c_mex.c LZ78c_mex.c
MBIN = $(patsubst %.c, $(MEXDIR)/%.$(MEXEXT), $(MSRC))

MFLAGS = -std=c99 -march=native
WFLAGS = -Wall -Wextra -Wconversion -pedantic-errors
#DFLAGS = -D_POSIX_C_SOURCE=200809L -D_DEFAULT_SOURCE
DFLAGS = -D_POSIX_C_SOURCE=200809L -D_DEFAULT_SOURCE -DNDEBUG

ifeq ($(OS),WIN)
	OFLAGS = -O3
	MEXCFLAGS = COMPFLAGS
	DFLAGS := $(DFLAGS) -DWIN
	RM = del /F /Q
	RTBIN = $(subst /,\,$(TBIN))
	RNBIN = $(subst /,\,$(NBIN))
	RMBIN = $(subst /,\,$(MBIN))
	LDFLAGS = $(OFLAGS)
else
	OFLAGS = -O3 -flto
	MEXCFLAGS = CFLAGS
	RM = rm -f
	RTBIN = $(TBIN)
	RNBIN = $(NBIN)
	RMBIN = $(MBIN)
	LDFLAGS = $(OFLAGS) -lm
endif

GCCFLAGS = $(MFLAGS) $(OFLAGS) $(WFLAGS) $(DFLAGS)
MEXFLAGS = -O -R2018a

.PHONY: all clean diag

all: $(TBIN) $(MBIN)

test: $(TBIN)

mex: $(MBIN)

maint: $(NBIN)

clean:
	$(RM) $(COBJ) $(TOBJ) $(CDEP) $(TDEP) $(RTBIN) $(RNBIN) $(RMBIN)

$(COBJ): .%.o: %.c
	$(CC) -c -MMD -MP $(GCCFLAGS) -I$(MEXINC) $< -o $@
	@$(REPDEP)

$(TOBJ): $(COBJ)
$(TOBJ): .%.o: %.c
	$(CC) -c -MMD -MP $(GCCFLAGS) -I$(MEXINC) $< -o $@
	@$(REPDEP)

$(TBIN): bin/%: .%.o
	$(CC) $(COBJ) $< $(LDFLAGS) -o $@

# to avoid a world of pain, mex these with -client engine

$(NBIN): $(COBJ)
$(NBIN): $(BINDIR)/%: %.c
	$(MEX) -client engine $(MEXFLAGS) $(MEXCFLAGS)="\$$CFLAGS $(GCCFLAGS)" -outdir $(BINDIR) $(COBJ) $<

$(MBIN): $(COBJ)
$(MEXDIR)/%.$(MEXEXT): %.c
	$(MEX) $(MEXFLAGS) $(MEXCFLAGS)="\$$CFLAGS $(GCCFLAGS) -static" $(LIBS) -outdir $(MEXDIR) $(COBJ) $<

-include $(CDEP)
-include $(TDEP)

diag:
	@echo
	@echo "*** OS        = " $(OS) [$(ComSpec)]
	@echo
	@echo "*** CSRC      = " $(CSRC)
	@echo "*** COBJ      = " $(COBJ)
	@echo "*** CDEP      = " $(CDEP)
	@echo
	@echo "*** TSRC      = " $(TSRC)
	@echo "*** TOBJ      = " $(TOBJ)
	@echo "*** TDEP      = " $(TDEP)
	@echo "*** TBIN      = " $(TBIN)
	@echo
	@echo "*** NSRC      = " $(NSRC)
	@echo "*** NBIN      = " $(NBIN)
	@echo
	@echo "*** MSRC      = " $(MSRC)
	@echo "*** MBIN      = " $(MBIN)
	@echo
	@echo "*** CC        = " $(CC)
	@echo "*** GCCFLAGS  = " $(GCCFLAGS)
	@echo "*** LDFLAGS   = " $(LDFLAGS)
	@echo
	@echo "*** MEXFLAGS  = " $(MEXFLAGS)
	@echo "*** MEXCFLAGS = " $(MEXCFLAGS)
	@echo "*** MEXEXT    = " $(MEXEXT)
	@echo "*** MEXDIR    = " $(MEXDIR)
	@echo "*** MEX       = " $(MEX) $(MEXFLAGS) $(MEXCFLAGS)="\$$CFLAGS $(GCCFLAGS) -static" $(LIBS) -outdir $(MEXDIR)
	@echo
