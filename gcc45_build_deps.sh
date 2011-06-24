#!/usr/bin/sh

#  BUILD DEPENDENCIES FOR OCTAVE/MINGW32
#  This script successivly builds the dependencies 
#  required for a Octave 3.x build with gcc-4.5.0

if [ -z "$1" ]; then ACTION=all; else ACTION="$*"; fi
echo ACTION = "${ACTION}";

REL=5

VER_ZLIB=1.2.5-$REL

VER_BLAS=$REL
VER_CBLAS=$REL
VER_LAPACK=3.2.1-$REL
VER_ARPACK=96-$REL
VER_QRUPDATE=1.1.1-$REL
VER_SUITESPARSE=3.2.0-$REL

VER_HDF5=1.8.4-patch1-$REL

VER_EXPAT=2.0.1-$REL
VER_NCURSES=5.7-$REL
VER_FFTW3=3.2.2-$REL
VER_PCRE=8.00-$REL
VER_REGEX=2.5.1-$REL
VER_LESS=436-$REL

VER_JPEG=8b-$REL
VER_TIFF=3.9.2-$REL
VER_PNG=1.2.43-$REL
VER_FREETYPE=2.3.12-$REL
VER_FONTCONFIG=2.8.0-$REL
VER_FLTK=1.1.10-$REL

VER_WMF=0.2.8.4-$REL
VER_BZIP2=1.0.5-$REL
VER_GRAPHICSMAGICK=1.3.12-$REL

VER_GMP=5.0.1-$REL
VER_GLPK=4.43-$REL

VER_ICONV=1.13-$REL
VER_GETTEXT=0.17-$REL
VER_GLIB=2.24.0-$REL
VER_PKGCONFIG=0.23-$REL

VER_TEXINFO=4.13a-$REL

# Mind the dependency of libraries:
# CBLAS depends on BLAS
# LAPACK depends on BLAS
# ARPACK depends on LAPACK and BLAS
# SUITESPARSE depends on BLAS and LAPACK

# GLPK dependes on GMP
# GSL depends on BLAS
# SED depends on REGEX
# LESS depends on PCRE
# READLINE depends on NCURSES
# many packages depend on ZLIB
# LIBFONTCONFIG depends on EXPAT
# LIBGD depends on LIBFREETYPE, LIBFONTCONFIG, LIBJPEG, LIBPNG
# PCRE checks for BZIP2 and READLINE
# WMF depends on FREETYPE and ZLIB
# IMAGEMAGICK depends on BZIP, ZLIB, WMF, JPEG, PNG, FREETYPE
# GINAC depends on CLN and GMP and uses pkg-config


( cd zlib && build-${VER_ZLIB}.sh ${ACTION} );

( cd blas && build-${VER_BLAS}.sh ${ACTION} );
( cd cblas && build-${VER_CBLAS}.sh ${ACTION} );
( cd lapack && build-${VER_LAPACK}.sh ${ACTION} );
( cd arpack && build-${VER_ARPACK}.sh ${ACTION} );
( cd qrupdate && build-${VER_QRUPDATE}.sh ${ACTION} );
( cd suitesparse && build-${VER_SUITESPARSE}.sh ${ACTION} );

( cd hdf5 && build-${VER_HDF5}.sh ${ACTION} );

( cd expat && build-${VER_EXPAT}.sh ${ACTION} );
( cd libncurses && build-${VER_NCURSES}.sh ${ACTION} );
( cd fftw3 && build-${VER_FFTW3}.sh ${ACTION} );
( cd pcre && build-${VER_PCRE}.sh ${ACTION} );
( cd regex && build-${VER_REGEX}.sh ${ACTION} );
( cd less && build-${VER_LESS}.sh ${ACTION} );

( cd libjpeg && build-${VER_JPEG}.sh ${ACTION} );
( cd libtiff && build-${VER_TIFF}.sh ${ACTION} );
( cd libpng && build-${VER_PNG}.sh ${ACTION} );
( cd libfreetype && build-${VER_FREETYPE}.sh ${ACTION} );
( cd libfontconfig && build-${VER_FONTCONFIG}.sh ${ACTION} );
( cd fltk && build-${VER_FLTK}.sh ${ACTION} );

( cd wmf && build-${VER_WMF}.sh ${ACTION} );
( cd bzip2 && build-${VER_BZIP2}.sh ${ACTION} );
( cd graphicsmagick && build-${VER_GRAPHICSMAGICK}.sh ${ACTION} );

( cd gmp && build-${VER_GMP}.sh ${ACTION} );
( cd glpk && build-${VER_GLPK}.sh ${ACTION} );

( cd iconv && build-${VER_ICONV}.sh ${ACTION} );
( cd gettext && build-${VER_GETTEXT}.sh ${ACTION} );
( cd glib && build-${VER_GLIB}.sh ${ACTION} );
( cd pkg-config && build-${VER_PKGCONFIG}.sh ${ACTION} );

( cd texinfo && build-${VER_TEXINFO}.sh ${ACTION} );
