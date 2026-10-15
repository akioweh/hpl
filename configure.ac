AC_PREREQ([2.69])

AC_INIT(hpl, 2.3, hpl@icl.utk.edu)
AC_CONFIG_SRCDIR([include/hpl.h])
AC_CONFIG_HEADERS([include/hplconfig.h])

AC_CONFIG_MACRO_DIR([m4])

AX_PROG_CC_MPI([], [], [AC_MSG_ERROR([MPI C compiler not found; set CC or MPICC to an MPI compiler wrapper])])

AC_PROG_RANLIB

AC_PROG_INSTALL

AM_INIT_AUTOMAKE([subdir-objects])

AM_PROG_AR

HPL_BLAS([], [AC_MSG_ERROR([BLAS not found for the selected interface; set BLAS_CFLAGS and BLAS_LIBS or use --with-blas=FLAGS])])

AC_CHECK_HEADER([mpi.h], [], AC_MSG_ERROR([MPI not found]))

AC_CONFIG_FILES([Makefile src/Makefile testing/Makefile])

AC_OUTPUT
