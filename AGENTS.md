
## Project

Æsir is a cross-platform MMORPG client and game engine written in D.

- `source/perfontain/` contains the engine: SDL windowing and input, OpenGL rendering, scenes, cameras, nodes, meshes, shaders, GUI, audio, file system, and resource managers.
- `source/rocl/` contains client logic: RO configuration and file system, map and resource loading, entities, UI, controllers, status, and network packets.
- `source/ro/` implements game resource formats and converters: GRF archives, maps, sprites, strings, and database data.
- `source/app.d` is the entry point: it creates `RoFileSystem`, initializes `PE` and `RO`, then runs the client.
- `source/perfontain/package.d` defines the `Engine` singleton (`PE`) and main loop: event processing, timers, scene rendering, and GUI rendering.
- `source/rocl/game.d` defines the `Game` singleton (`RO`): it reads `aesir.json`, creates the engine, runs the GUI or map viewer (`--viewer`), and processes networking and entities.
- Build with DUB (`dub.json`); artifacts and runtime data live in `bin/`, and third-party native libraries live in `utils/deps/`.

## Source conventions

These rules incorporate `.github/copilot-instructions.md` and apply to all source changes.

1. Prefix private struct/class fields with `_`.
2. Prefer compact error checks such as `foo() || throwError!`foo failed`();` and `auto code = foo(); code && throwError!`foo failed, error is %d`(code);`. Include relevant context when useful; otherwise keep messages short.
3. Use `logger` methods rather than `writeln`; choose `info`, `info2`, `info3`, `dbg`, `warn`, `error`, or `fatal` appropriately.
4. Prefer backtick string literals. Use double quotes only when escape sequences are needed.
5. Omit parentheses when calling zero-argument functions.
6. Use English only in source files.
7. Logging and exception messages start lowercase, preserve all-caps abbreviations such as `IP`, `MTU`, `HTTP`, and `TLS`, do not end in a period, and use ` ...` for long-running work.
8. Do not add parentheses around `&&` or `||` expressions only for precedence: `&&` already binds more tightly.

## OpenGL rendering

1. The renderer targets OpenGL ES 3.1 through ANGLE (`OPENGL_VERSION = 31` and `SDL_GL_CONTEXT_PROFILE_ES`). Do not add desktop-OpenGL-only APIs or GLSL assumptions without a compatible ANGLE/GLES path.
2. Use the engine resource wrappers instead of managing GL object IDs at call sites: `ArrayBuffer` for VAOs, `VertexBuffer` for VBOs/EBOs and SSBOs, `Texture`, `Sampler`, `RenderTarget`, and `Program`. They are `RCounted` and delete their GL object in the destructor.
3. Keep direct GL entry points inside the existing wrapper layer. When a new entry point is necessary, add its dynamic loading in `opengl/functions.d`, its debug trace/error-check wrapper, release alias, and exact function declaration. Do not bypass `hookGL` with a separately resolved symbol.
4. Build indexed geometry through `IndexVertex` and `VMemAlloc`, not ad-hoc per-mesh GL buffers. `IndexVertex.bind` lazily creates and configures its VAO: bind the VAO before `VertexBuffer.enable`, then bind both the vertex VBO and index EBO. The EBO binding is VAO state.
5. Vertex layouts are defined exclusively by `renderLoc` and `vertexSize` in `render/types.d`. `VertexBuffer.enable` configures tightly packed float attributes from that layout; extend the layout and this setup together if a new vertex format is required.
6. Preserve index conventions: indices are `uint`, uploaded as `GL_ELEMENT_ARRAY_BUFFER`, drawn as `GL_UNSIGNED_INT`, and multi-draw offsets are byte offsets (`index.start * 4`). Prefer the existing `DrawAllocator` batching and `glMultiDrawElementsANGLE` path over individual draw calls.
7. Change persistent pipeline state through `PEstate` (`culling`, `msaa`, `blendingMode`, `depthMask`, and `viewPort`), rather than raw `glEnable`, `glDisable`, `glBlendFuncSeparate`, `glDepthMask`, or `glViewport` calls. Restore any temporary state with `scope (exit)`.
8. Bind render targets through `RenderTarget.bind`/`unbind`; set the viewport and force the depth mask before clearing via the scene `clear` path. A render target owns its attachments, validates framebuffer completeness on construction, and requires all attachment sizes to match.
9. Bind shaders with `Program.bind`, assign textures and SSBOs using `Program.add`, and set uniforms with `Program.send`. Texture binding must use `Texture.bind(unit)` so the associated `Sampler` and active texture unit remain synchronized.
10. Use immutable texture allocation (`glTexStorage2D`) and sampler objects for sampling parameters. Do not introduce texture-parameter state on individual textures unless the texture/sampler abstraction is extended deliberately.
11. After a compute shader writes data consumed by later rendering, issue the appropriate `glMemoryBarrier`; the current image-write path uses `GL_SHADER_IMAGE_ACCESS_BARRIER_BIT`.
12. In debug builds, GL wrappers call `glGetError` after every wrapped call. Keep new rendering code on those wrappers so errors retain file and line context.
