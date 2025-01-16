#!/bin/bash

mkdir build
cd build

extra_cmake_args=(
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_LIBDIR=lib
    -DCMAKE_VERBOSE_MAKEFILE=ON
    -DGTEST_CREATE_SHARED_LIBRARY=1
    -DBUILD_SHARED_LIBS=ON
)

cmake -GNinja ${CMAKE_ARGS} "${extra_cmake_args[@]}" \
    -DCMAKE_PREFIX_PATH="$PREFIX" \
    -DCMAKE_INSTALL_PREFIX="$PREFIX" \
    "$SRC_DIR"

ninja
ninja install
