cmake_minimum_required(VERSION 2.8)
project(luasocket)
#LUA_INCLUDE_DIR
#LUA_LIBRARIES

include_directories(${LUA_INCLUDE_DIR})

# -----------------------------
# socket.dll 源文件 (Windows 平台)
# -----------------------------
set(SOCKET_SRC
    luasocket.c
    timeout.c
    buffer.c
    io.c
    auxiliar.c
    compat.c
    options.c
    inet.c
    wsocket.c   # Windows socket
    except.c
    select.c
    tcp.c
    udp.c
)

add_library(socket MODULE ${SOCKET_SRC})
target_link_libraries(socket ${LUA_LIBRARIES} ws2_32.lib)
set_target_properties(socket PROPERTIES
    OUTPUT_NAME "socket"
    PREFIX ""
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/../output"
)

# 添加自定义命令，在构建时将 socket.dll 复制到输出目录
add_custom_command(
    TARGET socket POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_FILE:socket> ${CMAKE_SOURCE_DIR}/../output/socket.dll
)

# -----------------------------
# mime.dll 源文件 (只需要 mime.c + compat.c)
# -----------------------------
set(MIME_SRC
    mime.c
    compat.c
)

add_library(mime MODULE ${MIME_SRC})
target_link_libraries(mime ${LUA_LIBRARIES})
set_target_properties(mime PROPERTIES
    OUTPUT_NAME "mime"
    PREFIX ""
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/../output"
)

# -----------------------------
# 安装 Lua 脚本
# -----------------------------
set(LUA_SCRIPTS
    http.lua
    url.lua
    tp.lua
    ftp.lua
    headers.lua
    smtp.lua
    ltn12.lua
    socket.lua
    mime.lua
)

# 确保输出目录存在
file(MAKE_DIRECTORY "${CMAKE_SOURCE_DIR}/../output/lua")

# 添加自定义命令，在构建时将 mime.dll 和 Lua 脚本文件复制到输出目录
add_custom_command(
    TARGET mime POST_BUILD
    # 复制 mime.dll 到输出目录
    COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_FILE:mime> ${CMAKE_SOURCE_DIR}/../output/mime.dll
    # 复制 Lua 脚本文件到输出目录
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_SOURCE_DIR}/http.lua ${CMAKE_SOURCE_DIR}/../output/lua/http.lua
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_SOURCE_DIR}/url.lua ${CMAKE_SOURCE_DIR}/../output/lua/url.lua
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_SOURCE_DIR}/tp.lua ${CMAKE_SOURCE_DIR}/../output/lua/tp.lua
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_SOURCE_DIR}/ftp.lua ${CMAKE_SOURCE_DIR}/../output/lua/ftp.lua
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_SOURCE_DIR}/headers.lua ${CMAKE_SOURCE_DIR}/../output/lua/headers.lua
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_SOURCE_DIR}/smtp.lua ${CMAKE_SOURCE_DIR}/../output/lua/smtp.lua
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_SOURCE_DIR}/ltn12.lua ${CMAKE_SOURCE_DIR}/../output/lua/ltn12.lua
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_SOURCE_DIR}/socket.lua ${CMAKE_SOURCE_DIR}/../output/lua/socket.lua
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_SOURCE_DIR}/mime.lua ${CMAKE_SOURCE_DIR}/../output/lua/mime.lua
)

# 安装目标（可选）
install(FILES ${LUA_SCRIPTS} DESTINATION "${CMAKE_SOURCE_DIR}/../output/lua")
