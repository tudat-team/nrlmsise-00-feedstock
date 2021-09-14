#!/usr/bin/env bash

cp $RECIPE_DIR/CMakeLists.txt ./
cp $RECIPE_DIR/nrlmsise00-config.cmake.in ./

mkdir include
mkdir include/nrlmsise00
cp nrlmsise-00.h include/nrlmsise00/

mkdir build
cd build

cmake \
  -DCMAKE_CXX_STANDARD=17 \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DNRLMSISE00_BUILD_STATIC_LIBRARY=0 \
..

make -j2

ctest --verbose

make install
