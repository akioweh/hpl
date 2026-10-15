dnl Link only: configuration must also work on cross-compiled HPC systems.
AC_DEFUN([_HPL_BLAS_LINK], [
  AS_IF([test "x$with_blas_interface" = xcblas], [
    AC_LINK_IFELSE([AC_LANG_PROGRAM([[#include <cblas.h>]], [[
      double a = 1.0;
      cblas_dgemm(CblasColMajor, CblasNoTrans, CblasNoTrans,
                  1, 1, 1, 1.0, &a, 1, &a, 1, 0.0, &a, 1);
    ]])], [hpl_blas_ok=yes], [hpl_blas_ok=no])
  ], [
    AC_LINK_IFELSE([AC_LANG_PROGRAM([[extern void dgemm_(void);]],
                                   [[dgemm_();]])],
                   [hpl_blas_ok=yes], [hpl_blas_ok=no])
  ])
])

AC_DEFUN([HPL_BLAS], [
  AC_ARG_VAR([BLAS_LIBS], [BLAS linker flags (empty for compiler-provided BLAS)])
  AC_ARG_VAR([BLAS_CFLAGS], [BLAS header/compiler flags])
  AC_ARG_VAR([PKG_CONFIG], [pkg-config command, or false to disable metadata lookup])
  AC_ARG_WITH([blas],
    [AS_HELP_STRING([--with-blas=FLAGS], [explicit BLAS linker flags])], [
      AS_CASE([$withval], [yes|no],
        [AC_MSG_ERROR([--with-blas requires linker flags; use --with-blas='' for compiler-provided BLAS])])
      BLAS_LIBS=$withval
    ])
  AC_ARG_WITH([blas-interface],
    [AS_HELP_STRING([--with-blas-interface=f77|cblas], [BLAS interface (default: f77)])],
    [], [with_blas_interface=f77])
  AS_CASE([$with_blas_interface], [f77|cblas], [],
    [AC_MSG_ERROR([BLAS interface must be f77 or cblas])])
  HPL_BLAS_DEFS=
  AS_IF([test "x$with_blas_interface" = xcblas],
        [HPL_BLAS_DEFS=-DHPL_CALL_CBLAS])

  hpl_save_LIBS=$LIBS
  hpl_save_CPPFLAGS=$CPPFLAGS
  CPPFLAGS="$CPPFLAGS $BLAS_CFLAGS"
  AS_VAR_SET_IF([BLAS_LIBS], [
    AC_MSG_CHECKING([for $with_blas_interface BLAS with supplied flags])
    LIBS="$BLAS_LIBS $hpl_save_LIBS"
    _HPL_BLAS_LINK
    AC_MSG_RESULT([$hpl_blas_ok])
  ], [
    dnl First let compiler wrappers provide BLAS (e.g. Cray LibSci).
    AC_MSG_CHECKING([for $with_blas_interface BLAS supplied by the compiler])
    _HPL_BLAS_LINK
    AC_MSG_RESULT([$hpl_blas_ok])
    BLAS_LIBS=
    AS_IF([test "x$hpl_blas_ok" = xno], [
      AS_IF([test -z "$PKG_CONFIG"], [AC_PATH_TOOL([PKG_CONFIG], [pkg-config])])
      AS_IF([test -n "$PKG_CONFIG" && $PKG_CONFIG --exists openblas], [
        hpl_pkg_cflags=`$PKG_CONFIG --cflags openblas`
        hpl_pkg_libs=`$PKG_CONFIG --libs openblas`
        CPPFLAGS="$hpl_save_CPPFLAGS $BLAS_CFLAGS $hpl_pkg_cflags"
        LIBS="$hpl_pkg_libs $hpl_save_LIBS"
        AC_MSG_CHECKING([for $with_blas_interface BLAS using pkg-config openblas])
        _HPL_BLAS_LINK
        AC_MSG_RESULT([$hpl_blas_ok])
        AS_IF([test "x$hpl_blas_ok" = xyes], [
          BLAS_CFLAGS="$BLAS_CFLAGS $hpl_pkg_cflags"
          BLAS_LIBS=$hpl_pkg_libs
        ])
      ])
    ])
    CPPFLAGS="$hpl_save_CPPFLAGS $BLAS_CFLAGS"
    dnl Retain fallbacks for installations without pkg-config metadata.
    for hpl_libs in '-lopenblas -lm' '-lf77blas -latlas' \
      '-Wl,--start-group -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -Wl,--end-group -lpthread -lm' \
      '-lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lpthread -lm' \
      '-lacml -lm' '-framework Accelerate' '-framework vecLib' \
      '-lessl' '-lnvblas' '-lblis' '-lblas'; do
      AS_IF([test "x$hpl_blas_ok" = xyes], [break])
      LIBS="$hpl_libs $hpl_save_LIBS"
      AC_MSG_CHECKING([for $with_blas_interface BLAS in $hpl_libs])
      _HPL_BLAS_LINK
      AC_MSG_RESULT([$hpl_blas_ok])
      AS_IF([test "x$hpl_blas_ok" = xyes], [BLAS_LIBS=$hpl_libs])
    done
  ])
  LIBS=$hpl_save_LIBS
  CPPFLAGS=$hpl_save_CPPFLAGS
  AC_SUBST([BLAS_LIBS])
  AC_SUBST([BLAS_CFLAGS])
  AC_SUBST([HPL_BLAS_DEFS])
  AS_IF([test "x$hpl_blas_ok" = xyes], [$1], [$2])
])
