
AM_CPPFLAGS = -I$(top_srcdir)/include $(BLAS_CFLAGS) $(HPL_BLAS_DEFS)

xhpl_LDADD = ../src/libhpl.a $(BLAS_LIBS) -lm

# Keep the default input beside the out-of-source executable.
all-local: HPL.dat
HPL.dat: $(srcdir)/ptest/HPL.dat
	$(AM_V_GEN)cp $(srcdir)/ptest/HPL.dat $@
CLEANFILES = HPL.dat

dist_pkgdata_DATA = ptest/HPL.dat

bin_PROGRAMS = xhpl

xhpl_SOURCES =  \
matgen/HPL_jumpit.c matgen/HPL_rand.c matgen/HPL_setran.c matgen/HPL_xjumpm.c \
matgen/HPL_lmul.c matgen/HPL_ladd.c \
pmatgen/HPL_pdmatgen.c \
ptest/HPL_pddriver.c ptest/HPL_pdinfo.c ptest/HPL_pdtest.c \
ptimer/HPL_ptimer.c ptimer/HPL_ptimer_cputime.c ptimer/HPL_ptimer_walltime.c
