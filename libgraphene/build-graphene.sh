#!/bin/bash
set -ex


# get meson to find pkg-config when cross compiling
export PKG_CONFIG=$BUILD_PREFIX/bin/pkg-config

# need to find gobject-introspection-1.0 as a "native" (build) pkg-config dep
# meson uses PKG_CONFIG_PATH to search when not cross-compiling and
# PKG_CONFIG_PATH_FOR_BUILD when cross-compiling,
# so add the build prefix pkgconfig path to the appropriate variables
export PKG_CONFIG_PATH_FOR_BUILD=$BUILD_PREFIX/lib/pkgconfig
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$BUILD_PREFIX/lib/pkgconfig


if [ -z "$MESON_ARGS" ]; then
  # for some reason this is not set on Linux
  MESON_ARGS="--buildtype=release --prefix=${PREFIX} --libdir=lib"
fi

# _BSD_SOURCE must be set on old versions of Linux to expose some typedefs
export CPPFLAGS="-D_BSD_SOURCE=1 ${CPPFLAGS}"

meson_config_args=(
    --buildtype=release
    --backend=ninja
    -Dgtk_doc=false
    -Dgobject_types=true
    -Dinstalled_tests=false
    -Dlibdir=lib
    -Dintrospection=enabled
    --wrap-mode=nofallback
)

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == "1" ]]; then
  unset _CONDA_PYTHON_SYSCONFIGDATA_NAME
  (
    mkdir -p native-build

    export CC=$CC_FOR_BUILD
    export OBJC=$OBJC_FOR_BUILD
    export AR=($CC_FOR_BUILD -print-prog-name=ar)
    export NM=($CC_FOR_BUILD -print-prog-name=nm)
    export LDFLAGS=${LDFLAGS//$PREFIX/$BUILD_PREFIX}
    export PKG_CONFIG_PATH=${BUILD_PREFIX}/lib/pkgconfig

    # Unset them as we're ok with builds that are either slow or non-portable
    unset CFLAGS
    unset CPPFLAGS
    export host_alias=$build_alias
    export PKG_CONFIG_PATH=$BUILD_PREFIX/lib/pkgconfig
    export GIO_MODULE_DIR=$BUILD_PREFIX/lib/gio/modules

    meson setup native-build \
        "${meson_config_args[@]}" \
        --buildtype=release \
        --prefix=$BUILD_PREFIX \
        -Dlibdir=lib \
        --wrap-mode=nofallback

    # This script would generate the functions.txt and dump.xml and save them
    # This is loaded in the native build. We assume that the functions exported
    # by glib are the same for the native and cross builds
    export GI_CROSS_LAUNCHER=$BUILD_PREFIX/libexec/gi-cross-launcher-save.sh
    ninja -v -C native-build -j ${CPU_COUNT}
    ninja -C native-build install -j ${CPU_COUNT}
  )
  export GI_CROSS_LAUNCHER=$BUILD_PREFIX/libexec/gi-cross-launcher-load.sh
fi

# set the path to the modules explicitly, as they won't get found otherwise
export GIO_MODULE_DIR=$PREFIX/lib/gio/modules

meson setup builddir \
	${MESON_ARGS} \
	"${meson_config_args[@]}"
ninja -v -C builddir -j ${CPU_COUNT}
ninja -C builddir install -j ${CPU_COUNT}
