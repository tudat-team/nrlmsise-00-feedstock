copy "%RECIPE_DIR%\CMakeLists.txt" .
copy "%RECIPE_DIR%\nrlmsise00-config.cmake.in" .

mkdir include
mkdir include/nrlmsise00
copy nrlmsise-00.h include/nrlmsise00/

mkdir build
cd build


:: generator could be "%CMAKE_GEN%" for vs2017 or "NMake Makefiles" for clang

cmake ^
    -G "%CMAKE_GEN%" ^
    -DCMAKE_PREFIX_PATH=$PREFIX ^
    -DCMAKE_INSTALL_PREFIX=$PREFIX ^
    -DNRLMSISE00_BUILD_STATIC_LIBRARY=0 ^
    ..
if errorlevel 1 exit 1

cmake --build . --config RelWithDebInfo --target install
if errorlevel 1 exit 1

ctest --verbose
if errorlevel 1 exit 1
