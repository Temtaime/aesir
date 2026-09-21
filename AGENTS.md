
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
