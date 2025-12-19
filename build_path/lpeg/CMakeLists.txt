cmake_minimum_required(VERSION 3.0)
project(lpeg C)

# 源文件
set(FILES
    lpvm.c
    lpcap.c
    lptree.c
    lpcode.c
    lpprint.c
    lpcset.c
)

# 允许用户通过 -DLUA_INCLUDE_DIR 和 -DLUA_LIBRARY 传入路径
if(NOT LUA_INCLUDE_DIR)
    message(FATAL_ERROR "Please set LUA_INCLUDE_DIR (e.g. -DLUA_INCLUDE_DIR=%luasrc%)")
endif()

if(NOT LUA_LIBRARY)
    message(FATAL_ERROR "Please set LUA_LIBRARY (e.g. -DLUA_LIBRARY=%lualib%)")
endif()

# 包含 LuaJIT 头文件
include_directories(${LUA_INCLUDE_DIR})

# 生成 DLL
add_library(lpeg SHARED ${FILES} lpeg.def)

# 链接 Lua 库
target_link_libraries(lpeg ${LUA_LIBRARY})

# 输出目录 (保持和批处理一致)
set_target_properties(lpeg PROPERTIES PREFIX ""
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}
    ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}
    DEFINE_SYMBOL LPEG_EXPORTS
)

# 编译选项
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O2 -DNDEBUG -std=c99")
