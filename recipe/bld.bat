@echo off

REM Define library and include paths based on the Conda environment
set LIBRARY_PATH=%LIBRARY_BIN%
set INCLUDE_PATH=%LIBRARY_INC%\nrlmsise-00
set SRC_DIR=%SRC_DIR%

REM Create necessary directories if they don't exist
if not exist %LIBRARY_PATH% mkdir %LIBRARY_PATH%
if not exist %INCLUDE_PATH% mkdir %INCLUDE_PATH%

REM Compile the NRLMSISE-00 library
cd %SRC_DIR%
echo Compiling NRLMSISE-00...
cl /c /O2 /nologo /EHsc /I"%INCLUDE_PATH%" nrlmsise-00.c nrlmsise-00_data.c
if errorlevel 1 exit 1

REM Link the object files into a DLL
echo Linking NRLMSISE-00...
link /DLL /OUT:%LIBRARY_PATH%\nrlmsise-00.dll /IMPLIB:%LIBRARY_LIB%\nrlmsise-00.lib nrlmsise-00.obj nrlmsise-00_data.obj
if errorlevel 1 exit 1

REM Copy header files to the include directory
echo Copying headers...
copy *.h %INCLUDE_PATH%
if errorlevel 1 exit 1

echo NRLMSISE-00 build completed successfully.
goto end

:error
echo Build failed with error %ERRORLEVEL%.
exit /b %ERRORLEVEL%

:end
@echo on
