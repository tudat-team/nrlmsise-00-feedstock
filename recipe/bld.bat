@echo off

REM Compile the NRLMSISE-00 library
echo Compiling NRLMSISE-00...
cl /c /O2 /nologo /EHsc /I"%LIBRARY_INC%" nrlmsise-00.c nrlmsise-00_data.c
if errorlevel 1 exit 1

REM Link the object files into a DLL
echo Linking NRLMSISE-00...
link /DLL /OUT:%LIBRARY_BIN%\nrlmsise-00.dll /IMPLIB:%LIBRARY_LIB%\nrlmsise-00.lib nrlmsise-00.obj nrlmsise-00_data.obj
if errorlevel 1 exit 1

REM Copy header files to the include directory
echo Copying headers...
copy *.h %LIBRARY_INC%\nrlmsise-00
if errorlevel 1 exit 1

echo NRLMSISE-00 build completed successfully.
goto end

:error
echo Build failed with error %ERRORLEVEL%.
exit /b %ERRORLEVEL%

:end
@echo on
