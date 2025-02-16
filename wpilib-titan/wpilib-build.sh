#!/bin/bash
# Includes some stuff from https://github.com/conda-forge/opencv-feedstock/blob/main/recipe/build.sh

mkdir build-cmake
cd build-cmake

extra_cmake_args=(
    -D BUILD_SHARED_LIBS=ON
    -D WITH_CSCORE=OFF # cscore requires OpenCV
    -D WITH_EXAMPLES=OFF
    -D WITH_GUI=OFF
    -D WITH_JAVA=OFF
    -D WITH_NTCORE=ON
    -D WITH_SIMULATION_MODULES=OFF
    -D WITH_TESTS=OFF
    -D WITH_WPILIB=OFF # wpilib is big and might be annoying to build
    -D WITH_WPIMATH=ON
    -D WITH_PROTOBUF=OFF
)

extra_cmake_args+=(
    "-DProtobuf_PROTOC_EXECUTABLE=$BUILD_PREFIX/bin/protoc"
)

cmake -GNinja ${CMAKE_ARGS} "${extra_cmake_args[@]}" \
    -DCMAKE_PREFIX_PATH="$PREFIX" \
    -DCMAKE_INSTALL_PREFIX="$PREFIX" \
    ..

ninja
ninja install


