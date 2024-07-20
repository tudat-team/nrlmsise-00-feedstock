@echo off

REM Compile the NRLMSISE-00 library
echo Compiling NRLMSISE-00...
cl /c /O2 /nologo /EHsc /I"%LIBRARY_INC%" nrlmsise-00.c nrlmsise-00_data.c
if errorlevel 1 exit 1

REM Link the object files into a DLL
echo Linking NRLMSISE-00...
dir /b *.obj > temp.lst
link /DLL /OUT:nrlmsise-00.dll /IMPLIB:nrlmsise-00.lib @temp.lst
if errorlevel 1 exit 1

copy "nrlmsise-00.dll" %LIBRARY_BIN%
if errorlevel 1 exit 1

copy "nrlmsise-00.dll" %LIBRARY_LIB%
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
