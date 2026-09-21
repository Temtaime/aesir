#!/bin/bash
set -euo pipefail

if [ ! -d deps/bgfx ]
then
    mkdir -p deps
    git clone --depth=1 https://github.com/bkaradzic/bx.git deps/bx
    git clone --depth=1 https://github.com/bkaradzic/bimg.git deps/bimg
    git clone --depth=1 https://github.com/bkaradzic/bgfx.git deps/bgfx
fi

if [ ! -d deps/Vulkan-Headers ]
then
    git clone --depth=1 https://github.com/KhronosGroup/Vulkan-Headers.git deps/Vulkan-Headers
fi

rm -rf deps/vulkan-local
mkdir -p deps/vulkan-local

cp -r deps/Vulkan-Headers/include/vk_video deps/vulkan-local/
cp -r deps/Vulkan-Headers/include/vulkan/* deps/vulkan-local/

do_clang()
{
    clang-cl -w -O3 -m64 -std:c++20 -msse4.1 -DBX_CONFIG_DEBUG=0 "$@"
}

##########

sed -i \
    's/__declspec(dllimport) bool  __stdcall IsDebuggerPresent()/__declspec(dllimport) int   __stdcall IsDebuggerPresent()/' \
    deps/bx/src/debug.cpp

# do_clang \
#     -I deps/bx/include \
#     -I deps/bx/include/compat/msvc \
#     -o bx.obj \
#     deps/bx/src/amalgamated.cpp

# do_clang \
#     -I deps/bx/include \
#     -I deps/bimg/include \
#     -DBIMG_CONFIG_DECODE_ASTC=0 \
#     -o bimg.obj \
#     deps/bimg/src/image.cpp

#########

do_clang \
    -I deps/bgfx/include \
    -I deps/bx/include \
    -I deps/bimg/include \
    -I deps/bgfx/3rdparty \
    -I deps \
    \
    -DBGFX_CONFIG_RENDERER_DIRECT3D11=1 \
    -DBGFX_CONFIG_RENDERER_DIRECT3D12=1 \
    -DBGFX_CONFIG_RENDERER_VULKAN=1 \
    \
    -DBIMG_CONFIG_DECODE_ASTC=0 \
    \
    -I deps/bx/include/compat/msvc \
    \
    deps/bimg/src/image.cpp \
    deps/bx/src/amalgamated.cpp \
    deps/bgfx/src/amalgamated.cpp \
    \
    -fuse-ld=llvm-lib \
    -o ../deps/bgfx_x64.lib


# llvm-lib -OUT:../deps/bgfx_x64.lib bx.obj bimg.obj bgfx.obj
# rm bx.obj bimg.obj bgfx.obj
