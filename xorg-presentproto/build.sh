#! /bin/bash

tar xjf xorg-presentproto-*
cd presentproto-*

set -e
IFS=$' \t\n' # workaround for conda 4.2.13+toolchain bug

# Adopt a Unix-friendly path if we're on Windows (see bld.bat).
[ -n "$PATH_OVERRIDE" ] && export PATH="$PATH_OVERRIDE"

# On Windows we want $LIBRARY_PREFIX in both "mixed" (C:/Conda/...) and Unix
# (/c/Conda) forms, but Unix form is often "/" which can cause problems.
if [ -n "$LIBRARY_PREFIX_M" ] ; then
    mprefix="$LIBRARY_PREFIX_M"
    if [ "$LIBRARY_PREFIX_U" = / ] ; then
        uprefix=""
    else
        uprefix="$LIBRARY_PREFIX_U"
    fi
else
    mprefix="$PREFIX"
    uprefix="$PREFIX"
fi

# On Windows we need to regenerate the configure scripts.
if [ -n "$CYGWIN_PREFIX" ] ; then
    am_version=1.15 # keep sync'ed with meta.yaml
    export ACLOCAL=aclocal-$am_version
    export AUTOMAKE=automake-$am_version
    autoreconf_args=(
        --force
        --install
        -I "$mprefix/share/aclocal"
        -I "$BUILD_PREFIX_M/Library/usr/share/aclocal"
    )
    autoreconf "${autoreconf_args[@]}"
fi

export PKG_CONFIG_LIBDIR=$uprefix/lib/pkgconfig:$uprefix/share/pkgconfig
configure_args=(
    --prefix=$mprefix
    --disable-dependency-tracking
    --disable-silent-rules
)
./configure "${configure_args[@]}"
make -j$CPU_COUNT
make install
make check

# remove all docs