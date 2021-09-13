#    Copyright (c) 2010-2019, Delft University of Technology
#    All rigths reserved
#
#    This file is part of the Tudat. Redistribution and use in source and
#    binary forms, with or without modification, are permitted exclusively
#    under the terms of the Modified BSD license. You should have received
#    a copy of the license with this file. If not, please or visit:
#    http://tudat.tudelft.nl/LICENSE.
#
#    Note that this license only applies to this CMakeLists.txt file, not the
#    nrlmsise_00 library itself
#

# Specify minimum CMake version required to compile nrlmsise_00.
cmake_minimum_required(VERSION 3.4)

# Trick for recompiling changes for BUILD-TREE.
if (EXISTS "${CMAKE_BINARY_DIR}/CMakeCache.txt")
    file(REMOVE "${CMAKE_BINARY_DIR}/CMakeCache.txt")
endif ()

# Set cmake policy.
cmake_policy(SET CMP0069 NEW)

# Specific project name.
project(NRLMSISE00 VERSION 0.1 LANGUAGES C)

# Get lower string name of PROJECT_NAME for directory configuration.
string(TOLOWER ${PROJECT_NAME} PROJECT_NAME_LOWER)
string(TOUPPER ${PROJECT_NAME} PROJECT_NAME_UPPER)
set(POSITION_INDEPENDENT_CODE True)

# +============================================================================
# BUILD OPTIONS
#  Offer the user the choice of defining the build variation.
# +============================================================================
# Build static library instead of dynamic.
option(NRLMSISE00_BUILD_STATIC_LIBRARY "Build sofa as a static library, instead of dynamic." OFF)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -g -DINLINE")

if (WIN32)
    set(TKCOMPILEOPTIONS "/O2 /nologo")
    set(TKLINKOPTIONS "")
    if (NOT NRLMSISE00_BUILD_STATIC_LIBRARY)
        set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS 1)
    endif ()
elseif (UNIX AND NOT APPLE)
    set(TKCOMPILEOPTIONS "-std=c99 -m64 -O2 -fPIC")
    set(TKLINKOPTIONS "-Wl,--whole-archive -lm -Wl,--no-whole-archive -m64")
elseif (UNIX)
    #    set(TKCOMPILEOPTIONS "-m64 -c -std=c99 -fPIC -DNON_UNIX_STDIO")
    set(TKCOMPILEOPTIONS "-m64 -std=c99 -O2 -fPIC -DNON_UNIX_STDIO")
    set(TKLINKOPTIONS "-m64")
endif ()

set(NRLMSISE00_DEFINITIONS ${TKCOMPILEOPTIONS})
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${TKCOMPILEOPTIONS} ${TKLINKOPTIONS}")
message(STATUS "CMAKE_C_FLAGS: ${CMAKE_C_FLAGS}")

# +============================================================================
# INSTALL TREE CONFIGURATION (Project name independent)
#  Offer the user the choice of overriding the installation directories.
# +============================================================================
set(INSTALL_LIB_DIR "${CMAKE_INSTALL_PREFIX}/lib/" CACHE PATH "Installation directory for libraries")
set(INSTALL_BIN_DIR "${CMAKE_INSTALL_PREFIX}/bin/" CACHE PATH "Installation directory for executables")
set(INSTALL_INCLUDE_DIR "${CMAKE_INSTALL_PREFIX}/include/" CACHE PATH "Installation directory for header files")
set(INSTALL_DATA_DIR "${CMAKE_INSTALL_PREFIX}/data/" CACHE PATH "Installation directory for data files")
set(INSTALL_MAN_DIR "${CMAKE_INSTALL_PREFIX}/" CACHE PATH "Installation directory for man documentation")
set(INSTALL_TESTS_DIR "${CMAKE_BINARY_DIR}/tests/" CACHE PATH "Installation directory for tests (default=OFF)")
set(INSTALL_CMAKE_DIR "${INSTALL_LIB_DIR}/cmake/${PROJECT_NAME_LOWER}" CACHE PATH "Installation directory for cmake config files")

# Make relative paths absolute (needed later on)
foreach (p LIB BIN INCLUDE DATA CMAKE)
    set(var INSTALL_${p}_DIR)
    set(RELATIVE_INSTALL_${p}_DIR ${INSTALL_${p}_DIR})
    if (NOT IS_ABSOLUTE "${${var}}")
        set(${var} "${CMAKE_INSTALL_PREFIX}/${${var}}")
    endif ()
endforeach ()

# Find relative paths for cmake-config file. (for find_package)
file(RELATIVE_PATH rel_include_dir "${INSTALL_CMAKE_DIR}" "${INSTALL_INCLUDE_DIR}")
file(RELATIVE_PATH rel_lib_dir "${INSTALL_CMAKE_DIR}" "${INSTALL_LIB_DIR}")
file(RELATIVE_PATH rel_data_dir "${INSTALL_CMAKE_DIR}" "${INSTALL_DATA_DIR}")
file(RELATIVE_PATH rel_bin_dir "${INSTALL_CMAKE_DIR}" "${INSTALL_BIN_DIR}")
file(RELATIVE_PATH rel_man_dir "${INSTALL_CMAKE_DIR}" "${INSTALL_MAN_DIR}")

# Set relative paths for config.cmake.
foreach (p include lib data bin man)
    string(TOUPPER ${p} P)
    set(RELATIVE_INSTALL_${P}_DIR ${rel_${p}_dir})
endforeach ()

## +============================================================================
## CMAKE BUILD TREE CONFIGURATION
## +============================================================================
#set(${PROJECT_NAME_UPPER}_BINARY_LIB_DIR      "${CMAKE_BINARY_DIR}/lib/"                            CACHE PATH "Build directory for libraries")
#set(${PROJECT_NAME_UPPER}_BINARY_BIN_DIR      "${CMAKE_BINARY_DIR}/bin/"                            CACHE PATH "Build directory for executables")
#set(${PROJECT_NAME_UPPER}_BINARY_INCLUDE_DIR  "${CMAKE_BINARY_DIR}/include/"                        CACHE PATH "Build directory for header files")
#set(${PROJECT_NAME_UPPER}_BINARY_DATA_DIR     "${CMAKE_INSTALL_PREFIX}/data/${PROJECT_NAME_LOWER}/" CACHE PATH "Build directory for data files (default=OFF)")
#set(${PROJECT_NAME_UPPER}_BINARY_MAN_DIR      "${CMAKE_BINARY_DIR}/"                                CACHE PATH "Build directory for man documentation")
#set(${PROJECT_NAME_UPPER}_BINARY_TESTS_DIR    "${CMAKE_BINARY_DIR}/tests/"                          CACHE PATH "Build directory for tests")
#set(${PROJECT_NAME_UPPER}_BINARY_CMAKE_DIR    "${BINARY_LIB_DIR}/cmake/${PROJECT_NAME_LOWER}"       CACHE PATH "Build directory for cmake config files")

# Set the source and header files.
file(GLOB_RECURSE NRLMSISE00_HEADER_FILES
        ${CMAKE_CURRENT_SOURCE_DIR}/nrlmsise-00.h
        )

message(STATUS NRLMSISE00_SOURCE_FILES
        ${CMAKE_CURRENT_SOURCE_DIR}/nrlmsise-00.c
        ${CMAKE_CURRENT_SOURCE_DIR}/nrlmsise-00_data.c
        )

# Setup of library.
if (NRLMSISE00_BUILD_STATIC_LIBRARY)
    add_library(nrmsise00 STATIC "${NRLMSISE00_SOURCE_FILES}")
else ()
    add_library(nrmsise00 SHARED "${NRLMSISE00_SOURCE_FILES}")
endif ()

# Add headers to library target.
target_include_directories(nrmsise00 PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<INSTALL_INTERFACE:include/nrmsise00>
        )

# Setup of namespaced library.
add_library(NRLMSISE00::nrmsise00 ALIAS nrmsise00)

# Silence warnings.'
if (NOT MSVC)
#    set_property(TARGET nrmsise00 APPEND PROPERTY COMPILE_OPTIONS
#            "-Wno-implicit-int"
#            "-Wunused-result"
#            "-Wno-incompatible-pointer-types"
#            "-Wno-pointer-to-int-cast"
#            "-Wno-shift-op-parentheses"
#            "-Wno-logical-op-parentheses"
#            "-Wno-parentheses"
#            "-Wno-tautological-compare"
#            "-Wno-format"
#            "-Wno-unsequenced")
elseif (MSVC)
#    set_property(TARGET cspice APPEND PROPERTY COMPILE_OPTIONS
#            "-wd4267"
#            "-wd4554"
#            "-wd4723"
#            "-wd4244"
#            "-wd4273"
#            "-wd4477"
#            "-wd4996"
#            "-wd4311"
#            "-wd4013" # src\cspice\err.c(202): warning C4013: 'isatty' undefined; assuming extern returning int (due to fix)
#            "-wd4101" # src\cspice\inquire.c(16): warning C4101: 'n': unreferenced local variable
#            "-wd4018" # src\cspice\zzfcstring.c(354): warning C4018: '>=': signed/unsigned mismatch
#            )
endif (NOT MSVC)

set_target_properties(cspice
        PROPERTIES
        LINKER_LANGUAGE C
        ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
        LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
        )

# Add test
add_executable(test_nrlmsise_00 "${CMAKE_CURRENT_SOURCE_DIR}/nrlmsise-00_test.c")
target_link_libraries(test_nrlmsise_00 PUBLIC nrlmsise00)
set_target_properties(test_nrlmsise_00
        PROPERTIES
        LINKER_LANGUAGE C
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
        )
target_include_directories(test_nrlmsise_00 PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>  # <prefix>/include/mylib
        )
enable_testing()
add_test(test_nrlmsise_00 ${CMAKE_CURRENT_BINARY_DIR}/bin/test_nrlmsise_00)

# Installation of the library.
install(TARGETS nrlmsise00
        EXPORT nrlmsise00_export
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib
        RUNTIME DESTINATION bin
        )

# Set <project>_LIBRARIES for <project>-config.cmake.
set(NRLMSISE00_LIBRARIES NRLMSISE00::nrlmsise00)

# Add to parent scope if project is added via add_subdirectory().
if (NOT ${CMAKE_PROJECT_NAME} STREQUAL ${PROJECT_NAME})
    set(NRLMSISE00_LIBRARIES NRLMSISE00::nrlmsise00 PARENT_SCOPE)
endif ()

# Installation of the header files.
install(DIRECTORY include/ DESTINATION "${INSTALL_INCLUDE_DIR}")

install(DIRECTORY test/ DESTINATION "${INSTALL_INCLUDE_DIR}")

# Installation of the data files.
install(DIRECTORY data/ DESTINATION "${INSTALL_DATA_DIR}/${PROJECT_NAME_LOWER}")

# Add all targets to the build-tree export set
export(TARGETS nrlmsise00 NAMESPACE ${PROJECT_NAME}:: FILE "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME_LOWER}_export.cmake")

# Installation of the export modules.
install(EXPORT ${PROJECT_NAME_LOWER}_export NAMESPACE ${PROJECT_NAME}:: DESTINATION "${RELATIVE_INSTALL_CMAKE_DIR}")

# Export the package for use from the build-tree
# (this registers the build-tree with a global CMake-registry)
set(CMAKE_EXPORT_PACKAGE_REGISTRY ON)
export(PACKAGE ${PROJECT_NAME})

# +============================================================================
# PROJECT CONFIG
#  Add the targets, libraries and tests.
# +============================================================================
configure_file(
        "${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME_LOWER}-config.cmake.in"
        "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME_LOWER}-config.cmake" @ONLY
)

install(
        FILES "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME_LOWER}-config.cmake"
        DESTINATION "${INSTALL_CMAKE_DIR}"
)

# Take care of versioning.
include(CMakePackageConfigHelpers)
# NOTE: SameMinorVersion available only
# since CMake 3.11.
if (${CMAKE_VERSION} VERSION_LESS "3.11.0")
    write_basic_package_version_file("${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME_LOWER}-config-version.cmake" VERSION ${${PROJECT_NAME}_VERSION}
            COMPATIBILITY SameMajorVersion)
else ()
    write_basic_package_version_file("${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME_LOWER}-config-version.cmake" VERSION ${${PROJECT_NAME}_VERSION}
            COMPATIBILITY SameMinorVersion)
endif ()
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME_LOWER}-config-version.cmake" DESTINATION "${INSTALL_CMAKE_DIR}")

# +============================================================================
# CLEAN UP (Project name independent)
#  Cleanup in case project is not top level.
# +============================================================================
unset(INSTALL_LIB_DIR)
unset(INSTALL_BIN_DIR)
unset(INSTALL_INCLUDE_DIR)
unset(INSTALL_DATA_DIR)
unset(INSTALL_MAN_DIR)
unset(INSTALL_TESTS_DIR)
unset(INSTALL_CMAKE_DIR)

unset(RELATIVE_INSTALL_LIB_DIR)
unset(RELATIVE_INSTALL_BIN_DIR)
unset(RELATIVE_INSTALL_INCLUDE_DIR)
unset(RELATIVE_INSTALL_DATA_DIR)
unset(RELATIVE_INSTALL_MAN_DIR)
unset(RELATIVE_INSTALL_TESTS_DIR)
unset(RELATIVE_INSTALL_CMAKE_DIR)
