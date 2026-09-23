#!/bin/bash
set -euo pipefail

if [ ! -d deps/bgfx ]
then
    mkdir -p deps
    git clone --depth=1 https://github.com/bkaradzic/bx.git deps/bx
    git clone --depth=1 https://github.com/bkaradzic/bimg.git deps/bimg
    git clone --depth=1 https://github.com/bkaradzic/bgfx.git deps/bgfx
fi

do_clang()
{
    clang -w -O3 -ffast-math -m64 -std=c++20 -march=x86-64-v2 -DBX_CONFIG_DEBUG=0 "$@"
}

##########

sed -i \
    's/__declspec(dllimport) bool  __stdcall IsDebuggerPresent()/__declspec(dllimport) int __stdcall IsDebuggerPresent()/' \
    deps/bx/src/debug.cpp

#########

do_clang \
    -I deps/bx/include \
    -I deps/bimg/include \
    \
    -I deps/bgfx/include \
    -I deps/bgfx/3rdparty \
    -I deps/bgfx/3rdparty/khronos \
    \
    -D BGFX_CONFIG_RENDERER_DIRECT3D11=1 \
    -D BGFX_CONFIG_RENDERER_DIRECT3D12=1 \
    -D BGFX_CONFIG_RENDERER_VULKAN=1 \
    -D BGFX_CONFIG_RENDERER_OPENGL=33 \
    \
    -D BIMG_CONFIG_DECODE_ASTC=0 \
    \
    -I deps/bx/include/compat/msvc \
    \
    deps/bimg/src/image.cpp \
    deps/bx/src/amalgamated.cpp \
    deps/bgfx/src/amalgamated.cpp \
    \
    deps/bgfx/tools/shaderc/*.cpp \
    \
    -fuse-ld=llvm-lib \
    -o ../deps/bgfx_x64.lib
