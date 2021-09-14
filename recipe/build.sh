#!/usr/bin/env bash

mkdir build
cd build

mv "%RECIPE_DIR%\CMakeLists.txt" ./

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
