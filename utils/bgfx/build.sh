#!/bin/bash
set -euo pipefail

if [ ! -d deps/bx ]
then
	for x in bx bimg bgfx
	do
		mkdir -p deps/$x
		wget -qO- https://github.com/bkaradzic/$x/archive/refs/heads/master.tar.gz | tar xz --strip-components=1 -C deps/$x
	done

	cd deps
	patch -p1 -i ../bgfx.patch
	cd ..
fi

clang -w -O3 -ffast-math -m64 -std=c++20 -march=x86-64-v2 \
	\
	-D BX_CONFIG_DEBUG=0 \
	-D BGFX_CONFIG_RENDERER_DIRECT3D11=1 \
	-D BGFX_CONFIG_RENDERER_DIRECT3D12=1 \
	-D BGFX_CONFIG_RENDERER_VULKAN=1 \
	-D BGFX_CONFIG_RENDERER_OPENGL=33 \
	\
	-I deps/bx/include \
	-I deps/bimg/include \
	\
	-I deps/bgfx/include \
	-I deps/bgfx/3rdparty \
	-I deps/bgfx/3rdparty/khronos \
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
