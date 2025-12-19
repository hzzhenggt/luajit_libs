#!/bin/bash
set -e
set -o pipefail

echo "Building LuaJIT 64bit on Debian9..."

CURDIR=$(pwd)
LUASRC="$CURDIR/LuaJIT/src"
OUTPUT_DIR="$CURDIR/release"

mkdir -p "$OUTPUT_DIR"

echo "Current Directory: $CURDIR"
echo "Lua Source Directory: $LUASRC"
echo "Output will be in $OUTPUT_DIR"

echo "=================================="
echo "Cleaning old files..."
echo "=================================="
rm -f "$OUTPUT_DIR"/luajit* "$OUTPUT_DIR"/lua51*

echo "=================================="
echo "Building LuaJIT..."
echo "=================================="
cd "$LUASRC"

# LuaJIT 自带 Makefile，直接 make 就行
make clean
make BUILDMODE=dynamic CFLAGS=-fPIC
make install PREFIX=$OUTPUT_DIR
cd "$CURDIR"

echo "=================================="
echo "Build succeeded! Files are in $OUTPUT_DIR/bin and $OUTPUT_DIR/lib"
