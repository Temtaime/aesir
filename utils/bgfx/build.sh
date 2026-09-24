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

compile()
{
	local IS_DEBUG=$1; shift
	local NAME=$1; shift

	cd deps

	local DEFS=(
		-D BGFX_CONFIG_RENDERER_DIRECT3D11=1
	)

	if (( IS_DEBUG ))
	then
		DEFS+=(
			-D BGFX_CONFIG_RENDERER_DIRECT3D12=1
			-I bgfx/3rdparty/directx-headers/include/directx

			-D BGFX_CONFIG_RENDERER_VULKAN=1
			-D BGFX_CONFIG_RENDERER_OPENGL=33

			-D SHADERC_CONFIG_HAS_GLSLANG=1
			-I bgfx/3rdparty/spirv-cross
			-I bgfx/3rdparty/glslang/glslang/Public
			-I bgfx/3rdparty/glslang
			-I bgfx/3rdparty/spirv-tools/include
			-I bgfx/3rdparty/spirv-tools/include/generated
			-I bgfx/3rdparty/spirv-tools
			-I bgfx/3rdparty/spirv-headers/include
			bgfx/3rdparty/glslang/glslang/CInterface/glslang_c_interface.cpp
			bgfx/3rdparty/glslang/glslang/MachineIndependent/*.cpp
			bgfx/3rdparty/glslang/glslang/MachineIndependent/preprocessor/*.cpp
			# bgfx/3rdparty/spirv-cross/*.cpp
			# bgfx/3rdparty/spirv-tools/source/val/*.cpp
			# bgfx/3rdparty/spirv-tools/source/opt/*.cpp
		)
	else
		DEFS+=(
			-D NDEBUG
		)
	fi

	clang -w -m64 -std=c++20 -march=x86-64-v2 \
		\
		$@ \
		\
		${DEFS[@]} \
		-D BX_CONFIG_DEBUG=$IS_DEBUG \
		\
		-I bx/include \
		-I bimg/include \
		\
		-I bgfx/include \
		-I bgfx/3rdparty \
		-I bgfx/3rdparty/khronos \
		\
		-D BIMG_CONFIG_DECODE_ASTC=0 \
		\
		-I bx/include/compat/msvc \
		\
		bimg/src/image.cpp \
		bx/src/amalgamated.cpp \
		bgfx/src/amalgamated.cpp \
		\
		bgfx/tools/shaderc/*.cpp \
		\
		-fuse-ld=llvm-lib \
		\
		-o ../../deps/$NAME
}

compile 1 debug/bgfx_x64.lib -O2 &
compile 0 release/bgfx_x64.lib -O3 -ffast-math &

for p in bgfx_shader bgfx_compute
do
	cp deps/bgfx/src/$p.sh ../../source/perfontain/shader/resource/$p.sh
done

wait
