@echo off
chcp 65001
echo "Building lua lpeg lib"
set curdir=%cd%
set VS2013_DIR="C:\Program Files (x86)\Microsoft Visual Studio 12.0"
set luasrc="%curdir%\LuaJIT\src"
set lualib="%curdir%\release\lua51.lib"
set OUTPUT_DIR="%curdir%\release"

call %VS2013_DIR%\VC\vcvarsall.bat x86

echo Current Directory: %curdir%
echo Lua Source Directory: %luasrc%
echo Lua Library: %lualib%
echo output will be in %OUTPUT_DIR%

:: 设置输出目录
if not exist %OUTPUT_DIR% mkdir %OUTPUT_DIR%

echo ==================================
echo Build lua  lpeg...
echo ==================================
set lpeg_dir=%curdir%\submodules\lpeg
cd /d %lpeg_dir%
cmake -H. -Bbuild -G "Visual Studio 12 2013" ^
  -DLUA_INCLUDE_DIR=%luasrc% ^
  -DLUA_LIBRARY=%lualib%
cmake --build build --config Release

if %ERRORLEVEL% NEQ 0 (
    echo "Build lpeg.dll failed!"
    ) else (
    echo "Build lpeg.dll succeeded!"
    xcopy /Y %lpeg_dir%\Release\lpeg.dll %OUTPUT_DIR%\
    xcopy /Y %lpeg_dir%\re.lua %OUTPUT_DIR%\lua\
)

echo "Build lpeg completed! DLLs are in %OUTPUT_DIR%"

cd /d %curdir%
pause