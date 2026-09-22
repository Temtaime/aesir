module perfontain.managers.texture.types;
import bgfx_c, perfontain, stb.dxt;

enum : ubyte
{
	TEX_DXT_1,
	TEX_DXT_3,
	TEX_DXT_5,

	TEX_RGBA,
	TEX_SHADOW_MAP,
	TEX_RGBA_BYTE,
	TEX_RED_UINT,

	TEX_MAX
}

struct TextureData
{
	Vector2s sz;
	@(ArrayLength!(e => e.parent.dataLen(e.that.sz))) const(ubyte)[] data;
}

struct TextureInfo
{
	const dataLen(Vector2s sz)
	{
		return t == TEX_RGBA ? sz.x * sz.y * 4 : dxtTextureSize(sz.x, sz.y, t == TEX_DXT_5);
	}

	ubyte t;
	@(ArrayLength!ubyte) TextureData[] levels;
}

package:

static immutable bgfx_texture_format_t[TEX_MAX] textureFormats = [
	BGFX_TEXTURE_FORMAT_BC1, BGFX_TEXTURE_FORMAT_BC2,
	BGFX_TEXTURE_FORMAT_BC3, BGFX_TEXTURE_FORMAT_RGBA8,
	BGFX_TEXTURE_FORMAT_D32F, BGFX_TEXTURE_FORMAT_RGBA8U,
	BGFX_TEXTURE_FORMAT_R32U,
];
