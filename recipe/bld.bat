@echo on

REM Setup
set LIBNAME=nrlmsise-00.dll
set EXTRA_FLAGS=-shared

REM Compile source code
cd %SRC_DIR%
%CC% %CFLAGS% %CPPFLAGS% %LDFLAGS% -I. -c nrlmsise-00.c nrlmsise-00_data.c
%CC% %EXTRA_FLAGS% -o %LIBNAME% nrlmsise-00.obj nrlmsise-00_data.obj -lm

REM Copy the library and header files to the Conda environment
mkdir %PREFIX%\lib
mkdir %PREFIX%\include\nrlmsise-00
copy %LIBNAME% %PREFIX%\lib\
copy *.h %PREFIX%\include\nrlmsise-00\
