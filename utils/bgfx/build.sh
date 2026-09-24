#!/bin/bash
set -euo pipefail

cleanup()
{
	cd bgfx/3rdparty

	#rm -rf glslang/StandAlone
	rm -rf glslang/glslang/OSDependent/Unix

	rm \
		spirv-cross/main.cpp \
		spirv-cross/spirv_cross_c.cpp

	rm \
		spirv-tools/source/mimalloc.cpp \
		spirv-tools/source/pch_source.cpp \
		spirv-tools/source/spirv_fuzzer_options.cpp \
		spirv-tools/source/util/timer.cpp

	cd -
}

if [ ! -d deps/bx ]
then
	for x in bx bimg bgfx
	do
		mkdir -p deps/$x
		wget -qO- https://github.com/bkaradzic/$x/archive/refs/heads/master.tar.gz | tar xz --strip-components=1 -C deps/$x
	done

	cd deps
	patch -p1 -i ../bgfx.patch
	cleanup
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
		shopt -s globstar

		DEFS+=(
			-D BGFX_CONFIG_RENDERER_DIRECT3D12=1
			-I bgfx/3rdparty/directx-headers/include/directx

			-D BGFX_CONFIG_RENDERER_VULKAN=1
			-D BGFX_CONFIG_RENDERER_OPENGL=33

			-D SHADERC_CONFIG_HAS_GLSLANG=1

			-D ENABLE_OPT=1
			-D ENABLE_HLSL=1
			-D SPIRV_CROSS_EXCEPTIONS_TO_ASSERTIONS

			-I bgfx/3rdparty/glslang
			-I bgfx/3rdparty/glslang/glslang/Public
			-I bgfx/3rdparty/glslang/glslang/Include

			-I bgfx/3rdparty/spirv-cross
			-I bgfx/3rdparty/spirv-cross/include

			-I bgfx/3rdparty/spirv-tools
			-I bgfx/3rdparty/spirv-tools/include
			-I bgfx/3rdparty/spirv-tools/include/generated
			-I bgfx/3rdparty/spirv-tools/source
			-I bgfx/3rdparty/spirv-headers/include

			bgfx/3rdparty/glslang/SPIRV/**/*.cpp
			bgfx/3rdparty/glslang/glslang/**/*.cpp
			bgfx/3rdparty/spirv-cross/*.cpp

			bgfx/3rdparty/spirv-tools/source/*.cpp
			bgfx/3rdparty/spirv-tools/source/opt/*.cpp
			bgfx/3rdparty/spirv-tools/source/val/*.cpp
			bgfx/3rdparty/spirv-tools/source/util/*.cpp
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

compile 1 debug/bgfx_x64.lib -O0 &
compile 0 release/bgfx_x64.lib -O3 -ffast-math &

for p in bgfx_shader bgfx_compute
do
	cp deps/bgfx/src/$p.sh ../../source/perfontain/shader/resource/$p.sh
done

wait
