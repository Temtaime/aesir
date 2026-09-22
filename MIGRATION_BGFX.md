# bgfx Migration Plan

## Goal

Replace the ANGLE/OpenGL ES renderer with bgfx through `bindbc.bgfx`, while preserving the current client behavior: scene and GUI rendering, textures, batching, lighting, shadow maps, fog, blending, scissor rectangles, and compute-based light culling.

The project must remain buildable at every milestone. It is acceptable for it not to render or run correctly while the old OpenGL backend is disabled and before bgfx produces the first frame.

When translating bgfx C++ examples, initialize D structs that use a zero-argument C++ constructor with `0` as their required D argument.

Use the checked-in `bindbc.bgfx` C++ bindings exclusively. Do not add C99 declarations or call the `bgfx_*` API directly; fix binding or library ABI mismatches at their source.

Do not launch the application or perform runtime, visual, or smoke-test checks autonomously. After a buildable milestone, ask the user to run it and wait for their result before continuing runtime diagnosis.

## Milestones

1. **Disable the legacy OpenGL execution path** (in progress)
   - Record the current initialization, frame loop, resource wrappers, shader sources, render passes, and direct GL users.
   - Remove ANGLE setup, GL-context creation, and `hookGL` from the active window path.
   - Comment out or replace raw GL execution with temporary compile-only compatibility code until each caller is migrated to bgfx.
   - Build after each group of changes; runtime rendering is not a requirement for this milestone.

2. **Build and platform integration**
   - Add the `bindbc-bgfx` dependency and select the required binding/library versions.
   - Replace ANGLE environment setup and SDL GL-context creation with an SDL window suitable for bgfx platform data.
   - Implement bgfx startup, reset on resize, per-frame `bgfx_frame`, and orderly shutdown.
   - Verify an empty bgfx frame runs on Windows and Linux.

3. **Minimal frame**
   - Create a temporary renderer path that calls `bgfx_set_view_clear`, `bgfx_set_view_rect`, and `bgfx_touch` to clear one view to a fixed color.
   - Route window resize through `bgfx_reset`.
   - Make this the active renderer path; the legacy GL path remains disabled.

4. **Core resource layer**
   - Replace `ArrayBuffer`, `VertexBuffer`, `IndexVertex`, `Texture`, `Sampler`, `RenderTarget`, and `Program` internals with bgfx handles and RAII destruction.
   - Replace the GL vertex-layout table with explicit bgfx vertex layouts for GUI and scene vertices.
   - Preserve `VMemAlloc` compaction and CPU-side mesh data, adapting buffer updates to bgfx dynamic-buffer rules.
   - Replace `PEstate` with per-view state and submit flags; retain its public intent only where callers still need it.

5. **Offline shader pipeline**
   - Replace runtime GLSL source generation/linking with offline `shaderc` compilation in the build/tooling workflow.
   - Port the shader preprocessor inputs and permutations to generated shader binaries for each target renderer.
   - Add one unlit textured scene shader and its GUI equivalent; load shader binaries through the resource system.
   - Render indexed scene geometry and GUI with the unlit path before adding advanced effects.

6. **Render passes and materials**
   - Port opaque and transparent submission, depth/write/cull/blend state, scissor rectangles, and texture/sampler bindings.
   - Replace `DrawAllocator` multi-draw calls with ordered bgfx submissions and preserve batching where bgfx permits it.
   - Port render targets and the depth-only shadow pass to bgfx framebuffers/views.
   - Re-enable fog, directional lighting, and shadow sampling.

7. **Compute lighting and parity**
   - Port the light-culling compute shader, storage/image resources, dispatch, and synchronization to bgfx-supported APIs.
   - Define and test fallback behavior for renderers that do not support compute or required texture formats.
   - Exercise map viewer, gameplay scenes, GUI, resizing, fullscreen, all graphics settings, and both supported platforms.

8. **Remove OpenGL backend**
   - Delete `perfontain.opengl` and all remaining temporary compatibility code after feature-parity checks pass.
   - Remove ANGLE-specific setup and dependencies, update `AGENTS.md`, and document shader build prerequisites.

## Initial Inventory

- The current renderer creates an OpenGL ES 3.1 context through ANGLE in `managers/window.d`, then loads entry points with `hookGL`.
- The frame loop is in `perfontain/package.d`; scene clearing, framebuffer selection, rendering, and compute dispatch are in `managers/scene/package.d`.
- Resource wrappers live in `vao.d`, `vbo.d`, `managers/texture/texture.d`, `sampler.d`, `rendertarget.d`, and `program/package.d`.
- Geometry is allocated through `IndexVertex` and `VMemAlloc`; `DrawAllocator` batches index draws with `glMultiDrawElementsANGLE`.
- The project already links `bgfx_x64`; local generated sources expose it through `import bindbc.bgfx` in `source/bindbc/bgfx/` and `source/bgfx/`.
- `dub build` succeeds before the migration changes, with pre-existing deprecation warnings only.
- The active window path now creates a plain SDL window and no longer configures ANGLE, creates an SDL GL context, or calls `hookGL`. Engine-level GPU queries and depth-test toggles are also disabled; running the client is intentionally unsupported until bgfx initialization is added.
- `bgfx::init` is exported by `bgfx_x64.lib` as `?init@bgfx@@YA_NAEBUInit@1@@Z`. The local generator emitted an incompatible parameter mangling for `Init` and `SwapChain`; their checked-in binding declarations now use the library's C++ names. No C99 API is used.
- The active minimal path creates a bgfx main swap chain from the SDL `HWND`, resets it on `SDL_WINDOWEVENT_SIZE_CHANGED`, clears view 0 to `0xFF00_FFFF`, touches that view, and calls `bgfx.frame`. It remains alive for five seconds in an automated smoke test.
- Legacy OpenGL setup and client startup remain disabled as source comments. They are retained as the migration checklist and must not be removed before feature parity.
