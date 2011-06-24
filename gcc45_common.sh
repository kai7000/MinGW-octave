
# Common functions & settings for building with mingw32 gcc-4.5.x

# ---------------------
#  Configuration
# ---------------------

# Prefix for installing dependency libraries
PREFIX=${PREFIX:-/usr/local/octmgw32}

# -----------------------
#  default configuration
# -----------------------
BIN_DIR=${BIN_DIR:-bin}
LIB_DIR=${LIB_DIR:-lib}
STATICLIB_DIR=${STATICLIB_DIR:-staticlib}
INC_DIR=${INC_DIR:-include}
SHARE_DIR=${SHARE_DIR:-share}
ETC_DIR=${ETC_DIR:-etc}
PKGCONFIG_DIR=${PKGCONFIG_DIR:-lib/pkgconfig}
LIC_DIR=${LIC_DIR:-license}

# -----------------------
#  default executables used
# -----------------------
WGET=${WGET:-wget}
WGET_FLAGS=-N
TAR=tar
MAKE=make
CP=${TOPDIR}/../copy-if-changed.sh
CP_FLAGS=-vp
RM=rm
RM_FLAGS=-v
STRIP=strip
STRIP_FLAGS=--strip-unneeded

# Set environment variables for GCC
LIBRARY_PATH=${PREFIX}/${LIB_DIR}
CPATH=${PREFIX}/${INC_DIR}
export LIBRARY_PATH CPATH



# == common subfunctions ==
#
#  Every function foo() has corresponding foo_pre() and foo_post()

# == download ==
download_core() {
  ( for a in $1; do ${WGET} ${WGET_FLAGS} "$a"; done )
}
download() {
  ( download_core "${URL}" )
}

# == create patch file ==
mkpatch_pre() { echo ; }
mkpatch()
{
   mkpatch_pre
   if [ ! -d ${SRCDIR_ORIG} ]; then
      echo Orig source directory ${SRCDIR_ORIG} does not exist. Call unpack_orig.
   else
      ( cd ${TOPDIR} && diff -urN -x '*.exe' -x '*.dll' -x '*.o' -x '*.a' -x '*.bak' -x '~' -x '.hg' -x '*.orig' -x '*.rej' ${DIFF_FLAGS} `basename ${SRCDIR_ORIG}` `basename ${SRCDIR}` > ${PATCHFILE} )
   fi
   mkpatch_post
}
mkpatch_post() { echo ; }

# == apply patch file to source code ==
applypatch_pre() { echo ; }
applypatch() {
  applypatch_pre
  if [ ! -e ${PATCHFILE} ]; then
     echo "== No patchfile available =="
  else
     ( cd ${SRCDIR} && patch -p 1 -u -i ../${PATCHFILE} )
  fi
  applypatch_post
}
applypatch_post() { echo ; }

# == make ==
#  Assume we already chdir'd to the build directory
make_common()
{
   # specific makefile specified?
   if [ ! -z "${MAKEFILE}" ]; then
      MAKE_FILE="-f $MAKEFILE";
   else
      MAKE_FILE=""
   fi
   
   LDFLAGS+=" -Wl,--enable-runtime-pseudo-reloc-v2";
   FLDFLAGS+=" -Wl,--enable-runtime-pseudo-reloc-v2";
   
   # call make
   if [ -e have_configure ]; then
      # we had a configure script setup all variable accordingly
      echo $MAKE $MAKE_FILE $MAKE_PARALLEL $MAKE_XTRA $*
      $MAKE $MAKE_FILE $MAKE_PARALLEL $MAKE_XTRA $*
   else
      # No configure script, simple makefile
      echo $MAKE \
      $MAKE_FILE \
      F77="gfortran -shared-libgcc" \
      CC="gcc -shared-libgcc" \
      ${LDFLAGS:+LDFLAGS="$LDFLAGS"} \
      ${FLDFLAGS:+FLDFLAGS="$FLDFLAGS"} \
      $MAKE_PARALLEL \
      $MAKE_XTRA $*
      
      $MAKE \
      $MAKE_FILE \
      F77="gfortran -shared-libgcc" \
      CC="gcc -shared-libgcc" \
      ${LDFLAGS:+LDFLAGS="$LDFLAGS"} \
      ${FLDFLAGS:+FLDFLAGS="$FLDFLAGS"} \
      $MAKE_PARALLEL \
      $MAKE_XTRA $*
   fi
}

# == build ==
build_pre()
{
   if [ ! -e ${BUILDDIR} ]; then 
      echo Build directory $BUILDDIR does not exist! Call mkdirs first.
      exit 1
   fi
}
build()
{
   build_pre
   ( cd ${BUILDDIR} && make_common )
   build_post
}
build_post() { echo ; }

# == unpack ==
unpack_pre()
{ 
   if [ -d ${TOPDIR}/${SRCDIR} ]; then 
      echo Removing ${TOPDIR}/${SRCDIR} ...
      rm -rf ${TOPDIR}/${SRCDIR}; 
   fi 
}
unpack()
{
  unpack_pre
  unpack_core
  unpack_post
}
unpack_post() { echo ; }

unpack_core()
{
   # allow unpack_core FOO.tar.gz
   if [ -z "$1" ]; then
      S=$TOPDIR/$SRCFILE
   else
      S=$1
   fi
   
   case $S in
     *.tar.gz|*.tgz)
       $TAR xzf $S
     ;;
     *.tar.bz2)
       $TAR xjf $S
     ;;
     *.tar.lzma)
       $TAR x --lzma -f $S
     ;;
     *.tar.xz)
       $TAR x --xz -f $S
     ;;
     *.zip)
       # zip requires bsdtar...
       bsdtar x -f $S
     ;;
     *)
       echo ERROR: Source file $S archive type not handled!
       exit 10
       ;;
   esac
}

unpack_add_ver()
{
   # some packages extract into the subdirectory solely containing
   # the package NAME, not a combination of NAME and VERSION
   #
   # for these, add the version specifically in here
   unpack_pre;
   
   rm -rf tmp
   ( mkdir tmp && cd tmp && unpack_core && mv $PKG ../$SRCDIR  && cd .. && rm -rf tmp )
   
   unpack_post;
}

# == unpack into SRCORIG directory ==
unpack_orig_pre()
{ 
   if [ -d ${TOPDIR}/${SRCDIR_ORIG} ]; then 
      echo Removing ${TOPDIR}/${SRCDIR_ORIG} ...
      rm -rf ${TOPDIR}/${SRCDIR_ORIG}; 
   fi 
}
unpack_orig()
{
  unpack_orig_pre
  ( mkdir -p ${TOPDIR}/tmp && cd ${TOPDIR}/tmp && unpack_core && mv ${SRCDIR} ${TOPDIR}/${SRCDIR_ORIG} && cd ${TOPDIR} && rm -rf tmp)
  unpack_orig_post
}
unpack_orig_post() { echo ; }

unpack_orig_add_ver()
{
   # some packages extract into the subdirectory solely containing
   # the package NAME, not a combination of NAME and VERSION
   #
   # for these, add the version specifically in here
   unpack_orig_pre;
   
   rm -rf tmp
   ( mkdir tmp && cd tmp && unpack_core && mv $PKG ../$SRCDIR_ORIG && cd .. && rm -rf tmp)
   
   rm -rf tmp
   
   unpack_orig_post;
}

# == configure ==
conf_pre() { echo ; }
conf_common()
{
   echo ../$SRCDIR/configure \
     --srcdir=../$SRCDIR \
     --prefix=$PREFIX \
     CC="gcc -shared-libgcc" \
     CXX="g++ -shared-libgcc" \
     F77="gfortran -shared-libgcc" \
     LDFLAGS="-Wl,--enable-runtime-pseudo-reloc-v2" \
     $CONFIGURE_XTRA_ARGS
   
   ( PATH=$PREFIX/bin:$PATH
     cd $BUILDDIR && ../$SRCDIR/configure \
     --srcdir=../$SRCDIR \
     --prefix=$PREFIX \
     CC="gcc -shared-libgcc" \
     CXX="g++ -shared-libgcc" \
     F77="gfortran -shared-libgcc" \
     LDFLAGS="-Wl,--enable-runtime-pseudo-reloc-v2" \
     $CONFIGURE_XTRA_ARGS
   )
   touch $BUILDDIR/have_configure
}
conf_post() { echo ; }

conf()
{
   conf_pre;
   conf_common;
   conf_post;
}

# == check ==
check_pre() { echo ; }
check()
{
  check_pre
  ( cd ${BUILDDIR} && make_common check );
  check_post
}
check_post() { echo ; }

# == mkdirs ==
mkdirs_pre()
{ 
   if [ -d ${BUILDDIR} ]; then 
      echo removing ${BUILDDIR} ...
      rm -rf ${BUILDDIR}
   fi
}
mkdirs()
{
   mkdirs_pre;
   ( cd ${TOPDIR} && mkdir -vp ${BUILDDIR}; )
   mkdirs_post;
}
mkdirs_post() { echo; }

# == substvars ==
substvars_pre() { echo ; }
substvars()
{
   echo Making $2 from $1 ...
   sed \
	-e "s+@SRCDIR@+${TOPDIR}/${SRCDIR}+" \
	-e "s+@TOPDIR@+${TOPDIR}+" \
	-e "s+@GCC_VER@+${GCC_VER}+" \
	-e "s+@GCC_SYS@+${GCC_SYS}+" \
	-e "s+@REL@+${REL}+" \
   $1 > $2
}
substvars_post() { echo ; }

# == install ==
install_pre()
{
  for a in $BIN_DIR $LIB_DIR $STATICLIB_DIR ${INC_DIR}${INC_SUBDIR:+/$INC_SUBDIR} $LIC_DIR $LIC_DIR/$PKG $ETC_DIR $SHARE_DIR $PKGCONFIG_DIR; do
     if [ ! -e $PREFIX/$a ]; then mkdir -vp $PREFIX/$a; fi
  done
}
install()
{
  install_pre
  ( cd ${BUILDDIR} && make_common install );
  install_post
}
install_post() { echo ; }
install_common()
{
   # Install pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${CP} ${CP_FLAGS} $BUILDDIR/$a $PREFIX/$PKGCONFIG_DIR
   done
   
   # Install headers
   for a in $HEADERS_INSTALL; do
      ${CP} ${CP_FLAGS} $SRCDIR/$a $PREFIX/${INC_DIR}${INC_SUBDIR:+/$INC_SUBDIR}/`basename $a`
   done
   for a in $HEADERS_BUILD_INSTALL; do
      ${CP} ${CP_FLAGS} $BUILDDIR/$a $PREFIX/${INC_DIR}${INC_SUBDIR:+/$INC_SUBDIR}/`basename $a`
   done
   
   # Install license file
   for a in $LICENSE_INSTALL; do
      ${CP} ${CP_FLAGS} $SRCDIR/$a $PREFIX/$LIC_DIR/$PKG
   done
}

# == uninstall ==
uninstall_pre() { echo ; }
uninstall()
{
  uninstall_pre
  ( cd ${BUILDDIR} && make_common uninstall );
  uninstall_post
}
uninstall_post()
{ 
   # Remove installation directories if empty
   for a in $BIN_DIR $LIB_DIR $STATICLIB_DIR ${INC_DIR}${INC_SUBDIR:+/$INC_SUBDIR} $INC_DIR $LIC_DIR/$PKG $LIC_DIR $ETC_DIR $SHARE_DIR $PKGCONFIG_DIR; do
      rmdir --ignore-fail-on-non-empty $PREFIX/$a 
   done
}
uninstall_common()
{
   # Uninstall headers
   for a in $HEADERS_INSTALL $HEADERS_BUILD_INSTALL; do
      ${RM} ${RM_FLAGS} $PREFIX/${INC_DIR}${INC_SUBDIR:+/$INC_SUBDIR}/`basename $a`
   done
   
   # Uninstall pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${RM} ${RM_FLAGS} $PREFIX/$PKGCONFIG_DIR/`basename $a`
   done
   
   # Uninstall license file
   for a in $LICENSE_INSTALL; do
      ${RM} ${RM_FLAGS} $PREFIX/$LIC_DIR/$PKG/`basename $a`
   done
}

# == modify libtool ==
modify_libtool_all()
{
   if [ -f $1 ]; then
      _libtool_removelibprefix $1;
      _libtool_removerelease $1;
      _libtool_removeversuffix $1;
   fi
}

modify_libtool_noversuffix()
{
   if [ -f $1 ]; then
      _libtool_removelibprefix $1;
      _libtool_removeversuffix $1;
   fi
}

modify_libtool_norelease()
{
   if [ -f $1 ]; then
      _libtool_removelibprefix $1;
      _libtool_removerelease $1;
   fi
}

modify_libtool_nolibprefix()
{
   if [ -f $1 ]; then
      _libtool_removelibprefix $1;
   fi
}

_libtool_removelibprefix()
{
   # remove the 'LIB' prefix of shared library names
   echo "  Removing 'LIB' prefix of shared library names..."
   sed -e '/^soname_spec/ s+"\\${libname}+"\\\`echo \\\${libname} | \\\$SED -e s/^lib//\\\`+' $1 > $1.mod && ${CP} ${CP_FLAGS} $1.mod $1
}

_libtool_removerelease()
{
   # remove the ${release} from shared library names
   echo "  Removing \${release} from shared library names..."
   sed -e '/^soname_spec/ s+\\`echo \\${release} | \\$SED -e s/\[.\]/-/g\\`++' $1 > $1.mod && ${CP} ${CP_FLAGS} $1.mod $1
}

_libtool_removeversuffix()
{
   # remove the ${versuffix} from shared library names
   echo "  Removing \${versuffix} from shared library names..."
   sed -e '/^soname_spec/ s+\\\${versuffix}++' $1 > $1.mod && ${CP} ${CP_FLAGS} $1.mod $1
}

# == package src & dev ==
pkg_pre() { echo; }
pkg()
{
   pkg_pre;
   
   mkdir -vp $PREFIX/dev
   mkdir -vp $PREFIX/src
   
   ( 
      OLDPREFIX=$PREFIX
      PREFIX=/usr/local/pkg/$PKG
      install;
      
      # create dev pkg
      DD=""
      for a in include share etc lib staticlib license; do
         filelist=`find $PREFIX/$a -type f`
         if [ ! -z "$filelist" ]; then DD+="$a "; fi
      done
      
      $TAR c --lzma -v -f $OLDPREFIX/dev/$FULLPKG-dev.tar.lzma -C $PREFIX $DD
   )
   
   # create src pkg
   $TAR c -j -v -f $PREFIX/src/$FULLPKG-src.tar.bz2 $SRCFILE $PATCHFILE build${VER:+-$VER}${REL:+-$REL}.sh ../gcc45_common.sh
   
   pkg_post;
}
pkg_post() { echo; }

# == MAIN ==
main() {
(
   echo "$1" "$2" "$3" "$4" "$5"
   
   until [[ $1 == "" ]];
   do
     
     arg=$1;
     
      case $arg in
       download|mkpatch|build|install|clean|uninstall|check|unpack|unpack_orig|conf|mkdirs|all|applypatch|install_strip|pkg)
         $arg
         export STATUS=$?
       ;;
     
       *)
         echo "Error: bad arguments"
         exit 1
       ;;
      esac
     
     shift
   done
)
}
