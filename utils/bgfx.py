from pathlib import Path
import re

defines = Path("utils/bgfx/deps/bgfx/include/bgfx/defines.h").read_text(errors="ignore")

symbols = sorted({
    symbol
    for path in Path("source").rglob("*.d")
    for symbol in re.findall(r"BGFX_\w+", path.read_text(errors="ignore"))
    if re.search(rf"\b{re.escape(symbol)}\b", defines)
})

def exports(kind):
    return "\n".join(f"EXPORT_{kind}({symbol})" for symbol in symbols)

Path("utils/bgfx/bgfx_c.c").write_text(f"""\
#define EXPORT_END(x) const typeof(x) _d_##x = x;
#define EXPORT_BEGIN(x) const typeof(_d_##x) x = _d_##x;

{exports("BEGIN")}

#include <bgfx/defines.h>
#include <bgfx/c99/bgfx.h>

{exports("END")}
""")
