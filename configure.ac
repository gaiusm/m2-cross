
AC_INIT([m2-cross], [2.0])

AC_PREREQ(2.69)
AM_INIT_AUTOMAKE([])

AC_PROG_AWK
AC_PROG_CPP
AC_PROG_CXX
AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_MAKE_SET

AC_CONFIG_SRCDIR([version.c])
AC_CONFIG_MACRO_DIR([m4])

AC_ARG_ENABLE([armpi],
[  --enable-armpi    Cross compiler for Raspberry Pi],
[case "${enableval}" in
  yes) armpi=true ;;
    no)  armpi=false ;;
      *) AC_MSG_ERROR([bad value ${enableval} for --enable-armpi]) ;;
      esac],[armpi=false])
      AM_CONDITIONAL([ARMPI], [test x$armpi = xtrue])

AC_ARG_ENABLE([avr328p],
[  --enable-avr328p    Cross compiler for Atmega328p],
[case "${enableval}" in
  yes) avr328p=true ;;
    no)  avr328p=false ;;
      *) AC_MSG_ERROR([bad value ${enableval} for --enable-avr328p]) ;;
      esac],[avr328p=false])
      AM_CONDITIONAL([AVR328P], [test x$avr328p = xtrue])

AC_MSG_CHECKING([checking to see that you have set a supported target])
if test x${enable_avr328p} = xyes; then
   AC_MSG_RESULT([(avr328p)... yes])
elif test x${enable_armpi} = xyes; then
   AC_MSG_RESULT([(armpi)... yes])
else
   AC_MSG_ERROR([you must specify either --enable-avr328p or --enable-armpi])
fi

AC_SUBST([avr328p])
AC_SUBST([armpi])

dnl create these files
AC_CONFIG_FILES([Makefile])

AC_OUTPUT
