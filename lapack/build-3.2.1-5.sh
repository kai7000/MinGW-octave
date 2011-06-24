#! /usr/bin/sh

# Name of package
PKG=lapack
# Version of Package
VER=3.3.1
# Release of (this patched) package
REL=1
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file(s)
SRCFILE=${PKG}.tgz
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL(s) of source code file(s)
URL="http://www.netlib.org/lapack/lapack.tgz"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory source code is extraced to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use (optional)
MAKEFILE=
# Any extra flags to pass make to
MAKE_XTRA="FFLAGS=-O3"

# Header files to install
HEADERS_INSTALL=
HEADERS_BUILD_INSTALL=

# install subdirectory below $PREFIX/$INC_DIR (if any)
INC_SUBDIR=

# License file(s) to install
LICENSE_INSTALL="LICENSE"

# Additional DIFF Flags for generating diff file
DIFF_FLAGS="-x *.def"

# load common functions
source ../gcc45_common.sh

# Directory the lib is built in (set this *after* loading gcc45_common.sh)
BUILDDIR=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}"

# == override resp. specify build actions ==

mkdirs_post() 
{ 
   # directory makefile is located
   mkdir -vp ${BUILDDIR}/SRC
   mkdir -vp ${BUILDDIR}/INSTALL
}

conf()
{
   conf_pre;
   
   substvars ${SRCDIR}/make.inc ${BUILDDIR}/make.inc
   ${CP} ${CP_FLAGS} ${SRCDIR}/makefile         ${BUILDDIR}/makefile
   ${CP} ${CP_FLAGS} ${SRCDIR}/INSTALL/makefile ${BUILDDIR}/INSTALL/makefile
   ${CP} ${CP_FLAGS} ${SRCDIR}/SRC/makefile     ${BUILDDIR}/SRC/makefile
   
   conf_post;
}


build() 
{
   ( cd ${BUILDDIR} && make_common lapacklib )
   ( cd ${BUILDDIR} && make_common shlib )
}

install()
{
   install_pre;
   
   # Install library, import library and static library
   ${CP} ${CP_FLAGS} ${BUILDDIR}/lapack.dll      $PREFIX/$BIN_DIR
   ${CP} ${CP_FLAGS} ${BUILDDIR}/liblapack.dll.a $PREFIX/$LIB_DIR
   ${CP} ${CP_FLAGS} ${BUILDDIR}/liblapack.a     $PREFIX/$STATICLIB_DIR
   
   install_common;
   install_post;
}

install_strip()
{
   install;
   $STRIP $STRIP_FLAGS $PREFIX/$BIN_DIR/lapack.dll
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   ${RM} ${RM_FLAGS} $PREFIX/$BIN_DIR/lapack.dll
   ${RM} ${RM_FLAGS} $PREFIX/$LIB_DIR/liblapack.dll.a
   ${RM} ${RM_FLAGS} $PREFIX/$STATICLIB_DIR/liblapack.a
   
   uninstall_common;
   uninstall_post;
}

check()
{
   check_pre;
   
   ( cd ${BUILDDIR} && make -f ${MAKEFILE} test )
   ( cd ${BUILDDIR} && make -f ${MAKEFILE} testdll )
   
   check_post;
}

all() {
  download
  unpack
  applypatch
  mkdirs
  conf
  build
  install
}

main $*
