#!/bin/bash

mkdir build
cd build

extra_cmake_args=(
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_LIBDIR=lib
    -DBUILD_SHARED_LIBS=ON
    -DENABLE_CCACHE=OFF
    -DBUILD_WITH_OPENMP=OFF
    -DFORCE_RSUSB_BACKEND=ON
    -DBUILD_PYTHON_BINDINGS:bool=true
    -DPYTHON_INSTALL_DIR="$SP_DIR"
    -DPYTHON_EXECUTABLE="$PREFIX/bin/python"
    # -DBUILD_EXAMPLES=OFF
    # -DBUILD_UNIT_TESTS=OFF
    -DCHECK_FOR_UPDATES=OFF
    -DCMAKE_VERBOSE_MAKEFILE=ON                                          
)

cmake -GNinja ${CMAKE_ARGS} "${extra_cmake_args[@]}" \
    -DCMAKE_PREFIX_PATH="$PREFIX" \
    -DCMAKE_INSTALL_PREFIX="$PREFIX" \
    "$SRC_DIR"

ninja
ninja install
