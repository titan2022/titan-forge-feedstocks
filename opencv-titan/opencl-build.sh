#!/bin/bash
# Includes some stuff from https://github.com/conda-forge/opencv-feedstock/blob/main/recipe/build.sh

mkdir build
cd build

extra_cmake_args=(
    -D CMAKE_BUILD_TYPE=RELEASE
    -D OPENCV_EXTRA_MODULES_PATH="$(realpath ../opencv_contrib/modules)"
    -D WITH_OPENCL=ON
    -D ENABLE_FAST_MATH=ON
    -D WITH_QT=ON
    -D WITH_OPENMP=ON
    -D BUILD_TIFF=ON
    -D WITH_FFMPEG=ON
    -D WITH_GSTREAMER=ON
    -D WITH_TBB=ON
    -D WITH_V4L=ON
    -D BUILD_TBB=OFF
    -D BUILD_TESTS=OFF
    -D WITH_EIGEN=OFF
    -D WITH_PROTOBUF=ON
    -D OPENCV_ENABLE_NONFREE=ON
    -D INSTALL_C_EXAMPLES=OFF
    -D INSTALL_PYTHON_EXAMPLES=OFF
    -D OPENCV_GENERATE_PKGCONFIG=ON
    -D BUILD_EXAMPLES=OFF
    -DOPENCV_ENABLE_PKG_CONFIG=1                                          
    -DOPENCV_PYTHON_PIP_METADATA_INSTALL=ON                               
    -DOPENCV_PYTHON_PIP_METADATA_INSTALLER:STRING="conda"                 
    -DBUILD_opencv_python3=1                                              
    -DPYTHON3_EXECUTABLE="${PYTHON}"                                        
    -DPYTHON3_INCLUDE_DIR="${INC_PYTHON}"                                   
    -DPYTHON3_NUMPY_INCLUDE_DIRS="$(python -c 'import numpy;print(numpy.get_include())')  "
    -DPYTHON3_LIBRARY="${LIB_PYTHON}"                                       
    -DPYTHON3_PACKAGES_PATH="${SP_DIR}"                              
    -DOPENCV_PYTHON3_INSTALL_PATH="${SP_DIR}"                               
    -DBUILD_opencv_python2=0                                              
)


# if [[ "${target_platform}" != "${build_platform}" ]]; then
extra_cmake_args+=("-DProtobuf_PROTOC_EXECUTABLE=$BUILD_PREFIX/bin/protoc")
extra_cmake_args+=("-DQT_HOST_PATH=${BUILD_PREFIX}")
# fi

cmake -GNinja ${CMAKE_ARGS} "${extra_cmake_args[@]}" \
    -DCMAKE_PREFIX_PATH="$PREFIX" \
    -DCMAKE_INSTALL_PREFIX="$PREFIX" \
    "$SRC_DIR/opencv"

# -D WITH_V4L=ON
# -D WITH_LIBV4L=ON

ninja
ninja install


