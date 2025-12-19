@echo off
chcp 65001
echo "Building lua ext libs"
set curdir=%cd%
set VS2013_DIR="C:\Program Files (x86)\Microsoft Visual Studio 12.0"
set luasrc="%curdir%\LuaJIT\src"
set lualib="%curdir%\release\lua51.lib"
set OUTPUT_DIR="%curdir%\release"


call %VS2013_DIR%\VC\vcvarsall.bat x86

echo Current Directory: %curdir%
echo Lua Source Directory: %luasrc%
echo Lua Library: %lualib%
echo ouput will be in %OUTPUT_DIR%OUTPUT_DIR

:: 设置输出目录
if not exist %OUTPUT_DIR% mkdir %OUTPUT_DIR%

echo ==================================
echo Building md5sum...
echo ==================================
:: 清理旧文件
del /Q %OUTPUT_DIR%\md5.dll %OUTPUT_DIR%\md5.lib %OUTPUT_DIR%\md5.exp %OUTPUT_DIR%\core.dll %OUTPUT_DIR%\core.lib %OUTPUT_DIR%\core.exp 2>nul
:: 创建md5目录用于存放core.dll
if not exist %OUTPUT_DIR%\md5 mkdir %OUTPUT_DIR%\md5 2>nul
:: 编译 md5.c 生成 core.dll
cl /LD %curdir%\submodules\md5\src\md5.c %curdir%\submodules\md5\src\md5lib.c %curdir%\submodules\md5\src\compat-5.2.c ^
   /I %luasrc% ^
   %lualib% ^
   /Fe:%OUTPUT_DIR%\md5\core.dll ^
   /Fo:%OUTPUT_DIR%\ ^
   %curdir%\submodules\md5\src\md5.def
if %ERRORLEVEL% NEQ 0 (
    echo "Build md5.dll failed!"
) else (
    copy  /Y %curdir%\submodules\md5\src\md5.lua %OUTPUT_DIR%\lua\md5.lua
    echo "Build md5.dll succeeded!"
)

echo ==================================
echo Building luafilesystem...
echo ==================================
:: 编译 lfs.c 生成 lfs.dll
cl /LD %curdir%\submodules\luafilesystem\src\lfs.c ^
   /I %luasrc% ^
   %lualib% ^
   /Fe:%OUTPUT_DIR%\lfs.dll ^
   /Fo:%OUTPUT_DIR%\lfs.obj

if %ERRORLEVEL% NEQ 0 (
    echo "Build lfs.dll failed!"
) else (
    echo "Build lfs.dll succeeded!"
)

echo ==================================
echo Building lua-rapidjson...
echo ==================================
set rapidjson_dir=%curdir%\submodules\lua-rapidjson
cd /d %rapidjson_dir%
cmake -H. -Bbuild -G "Visual Studio 12 2013" ^
  -DLUA_INCLUDE_DIR=%luasrc% ^
  -DLUA_LIBRARIES=%lualib%
cmake --build build --config Release
if %ERRORLEVEL% NEQ 0 (
    echo "Build rapidjson.dll failed!"
) else (
    echo "Build rapidjson.dll succeeded!"
    xcopy /Y %rapidjson_dir%\build\Release\rapidjson.dll %OUTPUT_DIR%\
)

echo "Build rapidjson completed! DLLs are in %OUTPUT_DIR%"


echo ==================================
echo Building luacjson...
echo ==================================
:: 编译 lua_cjson.c 生成 lua_cjson.dll
set luacjson_dir=%curdir%\submodules\lua-cjson
cd /d %luacjson_dir%
cl /LD lua_cjson.c strbuf.c fpconv.c ^
   /I %luasrc% ^
   %lualib% ^
   /Fe:%OUTPUT_DIR%\cjson.dll

if %ERRORLEVEL% NEQ 0 (
    echo "Build cjson.dll failed!"
) else (
    echo "Build cjson.dll succeeded!"
)

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

echo ==================================
echo Build lua-protobuf...
echo ==================================
set lua_protobuf_dir=%curdir%\submodules\lua-protobuf
cd /d %lua_protobuf_dir%
@REM cl /O2 /LD /Fepb.dll /I Lua53\include /DLUA_BUILD_AS_DLL pb.c Lua53\lib\lua53.lib
cl /O2 /LD /Fe:%OUTPUT_DIR%\pb.dll /I %luasrc% /DLUA_BUILD_AS_DLL pb.c %lualib%
if %ERRORLEVEL% NEQ 0 (
    echo "Build pb.dll failed!"
) else (
    echo "Build pb.dll succeeded!"
)

echo ==================================
echo Build lua socket...
echo ==================================
set lua_socket_dir=%curdir%\submodules\luasocket\src
cd /d %lua_socket_dir%
cmake -H. -Bbuild -G "Visual Studio 12 2013" ^
  -DLUA_INCLUDE_DIR=%luasrc% ^
  -DLUA_LIBRARIES=%lualib%
cmake --build build --config Release

if %ERRORLEVEL% NEQ 0 (
    echo "Build luasocket.dll failed!"
) else (
    echo "Build luasocket.dll succeeded!"
    xcopy /Y %lua_socket_dir%\build\Release\socket.dll %OUTPUT_DIR%\
    xcopy /Y %lua_socket_dir%\build\Release\mime.dll %OUTPUT_DIR%\
)

echo "Build succeeded! DLLs are in %OUTPUT_DIR%"

cd /d %curdir%
pause

