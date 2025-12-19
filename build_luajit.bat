@echo off
chcp 65001
echo Building luajit 32bit...
set curdir=%cd%
set VS2013_DIR="C:\Program Files (x86)\Microsoft Visual Studio 12.0"
set luasrc="LuaJIT\src"
set OUTPUT_DIR="release"
set lualib="%OUTPUT_DIR%\lua51.lib"


call %VS2013_DIR%\VC\vcvarsall.bat x86

echo Current Directory: %curdir%
echo Lua Source Directory: %luasrc%
echo Lua Library: %lualib%
echo ouput will be in %OUTPUT_DIR%OUTPUT_DIR

:: 设置输出目录
if not exist %OUTPUT_DIR% mkdir %OUTPUT_DIR%

echo ==================================
echo Building luajit...
echo ==================================
echo cleanup old files...
del /Q %OUTPUT_DIR%\luajit.* 2>nul
del /Q %OUTPUT_DIR%\lua51.* 2>nul

cd %luasrc%
call msvcbuild.bat
set MSVC_BUILD_RESULT=%ERRORLEVEL%

if %MSVC_BUILD_RESULT% NEQ 0 (
    echo "Build luajit failed!"
) else (
    echo "Build luajit succeeded!"
    xcopy /Y luajit.exe %curdir%\%OUTPUT_DIR% 2>nul
    xcopy /Y lua51.dll %curdir%\%OUTPUT_DIR% 2>nul
    xcopy /Y lua51.lib %curdir%\%OUTPUT_DIR% 2>nul
    xcopy /Y luajit.pdb %curdir%\%OUTPUT_DIR% 2>nul
)
echo "Build succeeded! DLLs are in %OUTPUT_DIR%"

cd /d %curdir%
pause
