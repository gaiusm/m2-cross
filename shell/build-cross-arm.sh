#! /bin/bash

INSTALL_DIR=$HOME/opt-gcc-15/cross
mkdir -p ${INSTALL_DIR}

set -e
trap 'previous_command=$this_command; this_command=$BASH_COMMAND' DEBUG
trap 'echo FAILED COMMAND: $previous_command' EXIT

#-------------------------------------------------------------------------------------------
# This script will download packages for, configure, build and install a GCC cross-compiler.
# Customize the variables (INSTALL_DIR, TARGET, etc.) to your liking before running.
# If you get an error and need to resume the script from some point in the middle,
# just delete/comment the preceding lines before running it again.
#
# See: http://preshing.com/20141119/how-to-build-a-gcc-cross-compiler
#-------------------------------------------------------------------------------------------

rm -rf ${INSTALL_DIR}
mkdir -p ${INSTALL_DIR}

TARGET=aarch64-linux
USE_NEWLIB=0
LINUX_ARCH=arm64
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

if [ $USE_NEWLIB -ne 0 ]; then
    if [ ! -f newlib-master.zip ] ; then
	wget -nc -O newlib-master.zip https://github.com/bminor/newlib/archive/master.zip || true
	unzip -qo newlib-master.zip
    fi
else
    if [ ! -f $LINUX_KERNEL_VERSION.tar.xz ] ; then
	wget -nc https://www.kernel.org/pub/linux/kernel/v5.x/$LINUX_KERNEL_VERSION.tar.xz
    fi
    if [ ! -f $GLIBC_VERSION.tar.xz ] ; then
	wget -nc https://ftp.gnu.org/gnu/glibc/$GLIBC_VERSION.tar.xz
	if [ "$GLIBC_VERSION" = "glibc-2.34" ] ; then
	    echo "applying patch to glibc"
	    tar xf $GLIBC_VERSION.tar.xz
	    cp $1/patches/glibc-2.34/01-posix-warning.patch .
	    cd $GLIBC_VERSION
	    patch -p2 < ../01-posix-warning.patch
	    cd ..
	fi
    fi
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
../$BINUTILS_VERSION/configure --prefix=$INSTALL_DIR --target=$TARGET $CONFIGURATION_OPTIONS
make $PARALLEL_MAKE
make install
cd ..

# Step 2. Linux Kernel Headers
if [ $USE_NEWLIB -eq 0 ]; then
    cd $LINUX_KERNEL_VERSION
    make ARCH=$LINUX_ARCH INSTALL_HDR_PATH=$INSTALL_DIR/$TARGET headers_install
    cd ..
fi

# Step 3. C/C++ Compilers
mkdir -p build-gcc
cd build-gcc
rm -rf *
if [ $USE_NEWLIB -ne 0 ]; then
    NEWLIB_OPTION=--with-newlib
fi
../$GCC_VERSION/configure --prefix=$INSTALL_DIR --target=$TARGET --enable-languages=c,c++,m2 $CONFIGURATION_OPTIONS $NEWLIB_OPTION $GCC_CONFIGURATION_OPTIONS
make $PARALLEL_MAKE all-gcc
make install-gcc
cd ..

if [ $USE_NEWLIB -ne 0 ]; then
    # Steps 4-6: Newlib
    mkdir -p build-newlib
    cd build-newlib
    rm -rf *
    ../newlib-master/configure --prefix=$INSTALL_DIR --target=$TARGET $CONFIGURATION_OPTIONS
    make $PARALLEL_MAKE
    make install
    cd ..
else
    # Step 4. Standard C Library Headers and Startup Files
    mkdir -p build-glibc
    cd build-glibc
    rm -rf *
    ../$GLIBC_VERSION/configure --prefix=$INSTALL_DIR/$TARGET --build=$MACHTYPE --host=$TARGET --target=$TARGET --with-headers=$INSTALL_DIR/$TARGET/include $CONFIGURATION_OPTIONS libc_cv_forced_unwind=yes
    make install-bootstrap-headers=yes install-headers
    make $PARALLEL_MAKE csu/subdir_lib
    install csu/crt1.o csu/crti.o csu/crtn.o $INSTALL_DIR/$TARGET/lib
    $TARGET-gcc -nostdlib -nostartfiles -shared -x c /dev/null -o $INSTALL_DIR/$TARGET/lib/libc.so
    touch $INSTALL_DIR/$TARGET/include/gnu/stubs.h
    cd ..

    # Step 5. Compiler Support Library
    cd build-gcc
    make $PARALLEL_MAKE all-target-libgcc
    make install-target-libgcc
    cd ..

    # Step 6. Standard C Library & the rest of Glibc
    cd build-glibc
    make $PARALLEL_MAKE
    make install
    cd ..
fi

# Step 7. Standard C++ Library & the rest of GCC
cd build-gcc
make $PARALLEL_MAKE all
make install
cd ..

trap - EXIT
echo 'Success!'
