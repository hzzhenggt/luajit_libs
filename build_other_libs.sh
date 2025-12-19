#!/bin/bash
set -e
set -o pipefail

echo "Building lua ext libs for Debian9"

CURDIR=$(pwd)
LUASRC=others/LuaJIT-2.0.0-beta11/src
LUALIB=others/LuaJIT-2.0.0-beta11/src/libluajit.so
OUTPUT_DIR="$CURDIR/release"

mkdir -p "$OUTPUT_DIR/lua"

echo "Current Directory: $CURDIR"
echo "Lua Source Directory: $LUASRC"
echo "Lua Library: $LUALIB"
echo "Output will be in $OUTPUT_DIR"

#######################################
# md5
#######################################
echo "=================================="
echo "Building md5..."
echo "=================================="
mkdir -p "$OUTPUT_DIR/md5"
gcc -fPIC -shared \
    "$CURDIR/submodules/md5/src/md5.c" \
    "$CURDIR/submodules/md5/src/md5lib.c" \
    "$CURDIR/submodules/md5/src/compat-5.2.c" \
    -I"$LUASRC" \
    -o "$OUTPUT_DIR/md5/core.so" \
    "$LUALIB" || echo "Build md5.so failed!"
cp "$CURDIR/submodules/md5/src/md5.lua" "$OUTPUT_DIR/lua/md5.lua"

#######################################
# luafilesystem
#######################################
echo "=================================="
echo "Building luafilesystem..."
echo "=================================="
gcc -fPIC -shared \
    "$CURDIR/submodules/luafilesystem/src/lfs.c" \
    -I"$LUASRC" \
    -o "$OUTPUT_DIR/lfs.so" \
    "$LUALIB" || echo "Build lfs.so failed!"

#######################################
# lua-rapidjson
#######################################
echo "=================================="
echo "Building lua-rapidjson..."
echo "=================================="
RAPIDJSON_DIR="$CURDIR/submodules/lua-rapidjson"
mkdir -p "$RAPIDJSON_DIR/build"
cd "$RAPIDJSON_DIR"
cmake -H. -Bbuild \
  -DLUA_INCLUDE_DIR="$LUASRC" \
  -DLUA_LIBRARIES="$LUALIB"
make -C build
cp build/rapidjson.so "$OUTPUT_DIR/" || echo "Build rapidjson.so failed!"
cd "$CURDIR"

#######################################
# lua-cjson
#######################################
echo "=================================="
echo "Building lua-cjson..."
echo "=================================="
LUACJSON_DIR="$CURDIR/submodules/lua-cjson"
cd "$LUACJSON_DIR"
gcc -fPIC -shared lua_cjson.c strbuf.c fpconv.c \
    -I"$LUASRC" \
    -o "$OUTPUT_DIR/cjson.so" \
    "$LUALIB" || echo "Build cjson.so failed!"
cd "$CURDIR"

#######################################
# lpeg
#######################################
echo "=================================="
echo "Building lpeg..."
echo "=================================="
LPEG_DIR="$CURDIR/submodules/lpeg"
cd "$LPEG_DIR"
make linux \
    LUADIR="$LUASRC" \
    DLLFLAGS="-shared -fPIC -L$LUALIB"
cp lpeg.so "$OUTPUT_DIR/" || echo "Build lpeg.so failed!"
cp re.lua "$OUTPUT_DIR/lua/" || true
cd "$CURDIR"

#######################################
# lua-protobuf
#######################################
echo "=================================="
echo "Building lua-protobuf..."
echo "=================================="
LUA_PROTOBUF_DIR="$CURDIR/submodules/lua-protobuf"
cd "$LUA_PROTOBUF_DIR"
gcc -O2 -fPIC -shared pb.c \
    -I"$LUASRC" \
    -L"$LUALIB" \
    -o "$OUTPUT_DIR/pb.so" || echo "Build pb.so failed!"
cp protoc.lua "$OUTPUT_DIR/lua/" || true
cd "$CURDIR"

#######################################
# luasocket
#######################################
echo "=================================="
echo "Building luasocket..."
echo "=================================="
LUA_SOCKET_DIR="$CURDIR/submodules/luasocket/src"
mkdir -p "$LUA_SOCKET_DIR/build"
cd "$LUA_SOCKET_DIR"

make \
  LUAINC_linux="$LUASRC" \
  LUALIB_linux="$LUALIB" \
  CC="gcc -fPIC" \
  linux
cp *.so $OUTPUT_DIR

cd "$CURDIR"

echo "=================================="
echo "Build succeeded! SOs are in $OUTPUT_DIR"
