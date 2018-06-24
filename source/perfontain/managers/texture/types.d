module perfontain.managers.texture.types;

import
		perfontain,
		perfontain.opengl,

		stb.dxt;


enum : ubyte
{
	TEX_DXT_1,
	TEX_DXT_3,
	TEX_DXT_5,

	TEX_RGBA,
	TEX_SHADOW_MAP,
}

struct TextureData
{
	Vector2s sz;
	@(`length`, `PARENT.dataLen(sz)`) const(ubyte)[] data;
}

struct TextureInfo
{
	const dataLen(Vector2s sz)
	{
		return t == TEX_RGBA ? sz.x * sz.y * 4 : dxtTextureSize(sz.x, sz.y, t == TEX_DXT_5);
	}

	ubyte t;
	@(`ubyte`) TextureData[] levels;
}

package:

static immutable uint[][5] textureTypes =
[
	[ GL_COMPRESSED_RGBA_S3TC_DXT1_EXT ],
	[ GL_COMPRESSED_RGBA_S3TC_DXT3_EXT ],
	[ GL_COMPRESSED_RGBA_S3TC_DXT5_EXT ],

	[ GL_RGBA8, GL_RGBA, GL_UNSIGNED_INT_8_8_8_8_REV ],
	[ GL_DEPTH_COMPONENT32F, GL_DEPTH_COMPONENT, GL_FLOAT ],
];
