# m2-cross
Build gcc, g++ and gm2 as cross compiler for ARM aarch64 and Atmel microprocessors.

This repository contains a shell script to build GNU Modula-2 as a
cross compiler and it also contains some tiny bare metal example programs
which will run on a Raspberry Pi-4.  It also contains a tiny program
which will run on the Atmel 328p.

Much of the information here can be found in other projects, the
emphasis with this repository is the ability use Modula-2 via a cross
compiler and to also show how Modula-2 can be used in a bare metal
context.

Build for the Atmel microprocessors
===================================

$ mkdir build
$ cd build
$ ../m2-cross/configure --enable-avr328p --prefix=$HOME/opt/gcc-15-cross
$ make
$ make install
$ make check

Build for the ARM aarch64
=========================

$ mkdir build
$ cd build
$ ../m2-cross/configure --enable-armpi --prefix=$HOME/opt/gcc-15-cross
$ make
$ make install
$ make check
