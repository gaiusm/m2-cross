#! /bin/bash

SRC_DIR=$1
INSTALL_DIR=$2
echo "build_cross_avr: INSTALL_DIR = ${INSTALL_DIR}"

mkdir -p ${INSTALL_DIR}

set -e
trap 'previous_command=$this_command; this_command=$BASH_COMMAND' DEBUG
trap 'echo FAILED COMMAND: $previous_command' EXIT

#-------------------------------------------------------------------------------------------
# This script will download packages for, configure, build and install a GCC cross-compiler.
#-------------------------------------------------------------------------------------------

TARGET=avr
USE_NEWLIB=0
CONFIGURATION_OPTIONS="--disable-multilib --disable-libsanitizer" # --disable-threads --disable-shared
PARALLEL_MAKE=-j12
BINUTILS_VERSION=binutils-2.35.2
GCC_VERSION=git
LINUX_KERNEL_VERSION=linux-5.10.46
GLIBC_VERSION=glibc-2.34
MPFR_VERSION=mpfr-3.1.6
GMP_VERSION=gmp-6.0.0a
MPC_VERSION=mpc-1.0.3
ISL_VERSION=isl-0.18
CLOOG_VERSION=cloog-0.18.1
# GCC_CONFIGURATION_OPTIONS="-march=armv8-a+crc -mcpu=cortex-a72"
export PATH=$INSTALL_DIR/bin:$PATH

# Download packages
export http_proxy=$HTTP_PROXY https_proxy=$HTTP_PROXY ftp_proxy=$HTTP_PROXY
wget -nc https://ftp.gnu.org/gnu/binutils/$BINUTILS_VERSION.tar.gz
if [ "${GCC_VERSION}" = "git" ] ; then
    if [ ! -f gcc-git.tar.gz ] ; then
	git clone git://gcc.gnu.org/git/gcc.git gcc-git
	cd gcc-git
	# git checkout branchname
	echo "*** Note that this script downloads GCC prerequisites ***"
	./contrib/download_prerequisites
	cd ..
	tar zcf gcc-git.tar.gz gcc-git
    fi
else
    wget -nc https://ftp.gnu.org/gnu/gcc/$GCC_VERSION/$GCC_VERSION.tar.gz
fi

if [ ! -f avr-libc-git.tar.gz ] ; then
    git clone https://github.com/avrdudes/avr-libc
    tar zcf avr-libc.tar.gz avr-libc
fi

if [ ! -f $MPFR_VERSION.tar.xz ] ; then
    wget -nc https://ftp.gnu.org/gnu/mpfr/$MPFR_VERSION.tar.xz
fi
if [ ! -f $GMP_VERSION.tar.xz ] ; then
    wget -nc https://ftp.gnu.org/gnu/gmp/$GMP_VERSION.tar.xz
fi
if [ ! -f $MPC_VERSION.tar.gz ] ; then
    wget -nc https://ftp.gnu.org/gnu/mpc/$MPC_VERSION.tar.gz
fi
if [ ! -f $ISL_VERSION.tar.bz2 ] ; then
    wget -nc ftp://gcc.gnu.org/pub/gcc/infrastructure/$ISL_VERSION.tar.bz2
fi
if [ ! -f $CLOOG_VERSION.tar.gz ] ; then
    wget -nc ftp://gcc.gnu.org/pub/gcc/infrastructure/$CLOOG_VERSION.tar.gz
fi

# Extract everything
for f in *.tar.gz; do
    name=$(basename $f .tar.gz)
    if [ ! -d $name ] ; then
       tar xf $f
    fi
done
for f in *.tar.bz2; do
    name=$(basename $f .tar.bz2)
    if [ ! -d $name ] ; then
       tar xf $f
    fi
done
for f in *.tar.xz; do
    name=$(basename $f .tar.xz)
    if [ ! -d $name ] ; then
       tar xf $f
    fi
done

# Make symbolic links
if [ "$GCC_VERSION" = "git" ] ; then
    GCC_VERSION=gcc-git
fi

cd $GCC_VERSION
ln -sf `ls -1d ../mpfr-*/` mpfr
ln -sf `ls -1d ../gmp-*/` gmp
ln -sf `ls -1d ../mpc-*/` mpc
ln -sf `ls -1d ../isl-*/` isl
ln -sf `ls -1d ../cloog-*/` cloog
cd ..

# Step 1. Binutils
mkdir -p build-binutils
cd build-binutils
rm -rf *
../$BINUTILS_VERSION/configure --prefix=$INSTALL_DIR --target=avr --disable-nls
make $PARALLEL_MAKE
make install
cd ..

# Step 2. C/C++/M2 Compilers

mkdir -p build-gcc
cd build-gcc
rm -rf *
../$GCC_VERSION/configure --prefix=$INSTALL_DIR \
			  --target=avr --enable-languages=c,c++,m2 \
                          --disable-nls --disable-libssp --disable-libcc1 \
                          --with-gnu-as --with-gnu-ld --with-dwarf2
make $PARALLEL_MAKE
make install
cd ..

# Step 3. Install avr-libc

mkdir -p build-avrlibc
cd build-avrlibc
rm -rf *
../avr-libc/configure --prefix=$INSTALL_DIR --build=x86_64-pc-linux-gnu --host=avr
make
make install

trap - EXIT
echo 'Success!'
