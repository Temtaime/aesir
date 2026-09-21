
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
