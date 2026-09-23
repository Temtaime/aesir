# bgfx Migration Plan

## Goal

Replace the ANGLE/OpenGL ES renderer with bgfx through the C99 API imported from `bgfx_c`, while preserving the current client behavior: scene and GUI rendering, textures, batching, lighting, shadow maps, fog, blending, scissor rectangles, and compute-based light culling.

## Current Status

- Windows uses native bgfx Direct3D 11 through the C99 API. The active SDL path creates no GL context and no longer configures ANGLE.
- bgfx owns dynamic vertex/index buffers, textures, samplers, framebuffers, programs, view submission, GUI, scene drawing, transparent draws, and shadow maps.
- Native bgfx shaders are generated and compiled by the retained runtime `shaderc.exe` path. Do not replace it until explicitly requested.
- Compute light culling is active. The light prepass keeps a D32F attachment for depth testing and writes `gl_FragCoord.z` into a color attachment for compute sampling: direct D32F sampling returned zero on the native D3D11 path.
- Light reconstruction uses native D3D coordinates: `vec3(uv.x * 2.0 - 1.0, 1.0 - uv.y * 2.0, depth)`.
- The legacy `lighting.c` model is active again: ambient, directional diffuse, four packed local-light indices, and inverse-square local-light falloff.
- Remaining parity work: fog verification, graphics settings, resize/fullscreen, gameplay scenes, Linux platform support, renderer capability fallback, texture readback, wireframe/MSAA behavior, and final removal of inactive legacy GL code.

## Remaining Legacy GL Work

Do not delete the following comments until their replacement is implemented and verified:

- `program/package.d`: generic GL program reflection, arbitrary uniforms, and SSBO bindings. Replace only if all remaining callers use explicit bgfx uniforms/textures/buffers.
- `sampler.d` and `managers/sampler.d`: map filtering, clamp/repeat, and anisotropy to `BGFX_SAMPLER_*` presets; initialize `main`, `noMipMap`, and `shadowMap` with those flags.
- `misc/package.d`: map every RO blend mode to bgfx state bits. The current path supports only no blending and alpha blending.
- `managers/state.d`: implement culling, wireframe, depth-mask, and MSAA as bgfx state/reset flags. Remove the GL state helper after callers use that mapping.
- `package.d`: replace GL capability queries with `bgfx_get_caps`, then apply the selected anisotropy/MSAA settings.
- `managers/scene/renderdata.d`: port fog shader defines and clear color. Remove the commented fog block after visual verification.
- `managers/texture/texture.d`: implement `Texture.toImage` with asynchronous `bgfx_read_texture`; remove the old readback reference only after callers are tested.
- `managers/gui/package.d`: pass `DrawInfo.scissor` to `bgfx_set_scissor` before GUI submission; only then remove the GL scissor/draw reference.
- `managers/window.d`: add native SDL window-handle support for Linux before calling the platform integration complete.

The project must remain buildable at every milestone. It is acceptable for it not to render or run correctly while the old OpenGL backend is disabled and before bgfx produces the first frame.

Use `import bgfx_c;` for bgfx. `utils/bgfx/bgfx_c.c` includes the official `bgfx/c99/bgfx.h`; ImportC exposes its C99 types and `bgfx_*` functions directly to D. Keep any C macro values needed by D as named C enum constants in that wrapper.

When an official `BGFX_*` macro is unavailable in D after `import bgfx_c`, add an enum alias in `utils/bgfx/bgfx_c.c` with a trailing underscore, for example `BGFX_BUFFER_ALLOW_RESIZE_ = BGFX_BUFFER_ALLOW_RESIZE`. Use that imported alias from D. Do not hardcode the macro's numeric value or recreate a D binding.

Shader sources must use only the native bgfx shader language and its official include files. If a required bgfx shader include or tool file is unavailable, stop and ask the user for its path. Do not replace it with GLSL, HLSL, custom compatibility macros, or backend-specific fallback syntax.

Never launch `perfontain.exe`. Do not perform runtime, visual, or smoke-test checks. After a buildable milestone, ask the user to run it and wait for their result before continuing runtime diagnosis.

## Milestones

1. **Disable the legacy OpenGL execution path** (complete for the active renderer)
   - Record the current initialization, frame loop, resource wrappers, shader sources, render passes, and direct GL users.
   - Remove ANGLE setup, GL-context creation, and `hookGL` from the active window path.
   - Comment out or replace raw GL execution with temporary compile-only compatibility code until each caller is migrated to bgfx.
   - Build after each group of changes; runtime rendering is not a requirement for this milestone.

2. **Build and platform integration** (Windows complete, Linux pending)
    - Use the checked-in C99 wrapper and `bgfx_x64` library.
   - Replace ANGLE environment setup and SDL GL-context creation with an SDL window suitable for bgfx platform data.
   - Implement bgfx startup, reset on resize, per-frame `bgfx_frame`, and orderly shutdown.
   - Verify an empty bgfx frame runs on Windows and Linux.

3. **Minimal frame** (complete)
   - Create a temporary renderer path that calls `bgfx_set_view_clear`, `bgfx_set_view_rect`, and `bgfx_touch` to clear one view to a fixed color.
   - Route window resize through `bgfx_reset`.
   - Make this the active renderer path; the legacy GL path remains disabled.

4. **Core resource layer** (substantially complete)
   - Replace `ArrayBuffer`, `VertexBuffer`, `IndexVertex`, `Texture`, `Sampler`, `RenderTarget`, and `Program` internals with bgfx handles and RAII destruction.
   - Replace the GL vertex-layout table with explicit bgfx vertex layouts for GUI and scene vertices.
   - Preserve `VMemAlloc` compaction and CPU-side mesh data, adapting buffer updates to bgfx dynamic-buffer rules.
   - Replace `PEstate` with per-view state and submit flags; retain its public intent only where callers still need it.

5. **Native shader pipeline** (runtime shaderc retained)
   - Replace runtime GLSL source generation/linking with offline `shaderc` compilation in the build/tooling workflow.
   - Port the shader preprocessor inputs and permutations to generated shader binaries for each target renderer.
   - Add one unlit textured scene shader and its GUI equivalent; load shader binaries through the resource system.
   - Render indexed scene geometry and GUI with the unlit path before adding advanced effects.

6. **Render passes and materials** (substantially complete)
   - Port opaque and transparent submission, depth/write/cull/blend state, scissor rectangles, and texture/sampler bindings.
   - Replace `DrawAllocator` multi-draw calls with ordered bgfx submissions and preserve batching where bgfx permits it.
   - Port render targets and the depth-only shadow pass to bgfx framebuffers/views.
   - Re-enable fog, directional lighting, and shadow sampling.

7. **Compute lighting and parity** (D3D11 compute complete, parity pending)
   - Port the light-culling compute shader, storage/image resources, dispatch, and synchronization to bgfx-supported APIs.
   - Define and test fallback behavior for renderers that do not support compute or required texture formats.
   - Exercise map viewer, gameplay scenes, GUI, resizing, fullscreen, all graphics settings, and both supported platforms.

8. **Remove OpenGL backend** (pending parity checks)
   - Delete `perfontain.opengl` and all remaining temporary compatibility code after feature-parity checks pass.
   - Remove ANGLE-specific setup and dependencies, update `AGENTS.md`, and document shader build prerequisites.

## Implementation Inventory

- `perfontain/package.d` owns the bgfx frame loop; `managers/scene/package.d` schedules shadow, light prepass, scene, GUI, and compute views.
- `vbo.d`, `managers/texture/texture.d`, `sampler.d`, `rendertarget.d`, and `program/package.d` own bgfx resources and destroy their handles through the C99 API.
- Scene geometry uses dynamic bgfx vertex/index buffers. `DrawAllocator` emits ordered per-submesh bgfx submissions.
- `bgfx.d` defines GUI and scene vertex layouts. Scene vertices are `position: vec3`, `normal: vec3`, and `texCoord0: vec2`.
- `RenderTarget` creates bgfx framebuffers. Views select those framebuffers and configure their rectangles/clear state.
- `shader/package.d` writes native bgfx sources and invokes `bin/bgfx/shaderc.exe` at runtime. This remains the supported shader workflow for now.
- `draw.c`, `depth.c`, `lighting.c`, and `light_compute.c` are native bgfx shader sources. The D3D11 light prepass uses a color depth copy because direct D32F sampling is invalid in the current path.
- `managers/window.d` creates a plain SDL window and exposes the Windows native handle for bgfx. It no longer creates an SDL GL context or configures ANGLE.
