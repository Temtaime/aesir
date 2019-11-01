module perfontain.managers.texture.texture;

import
		std.range,
		std.algorithm,

		perfontain,
		perfontain.opengl,
		perfontain.misc.dxt,

		stb.dxt;

public import
				perfontain.managers.texture.types;


final class Texture : RCounted
{
	this(in TextureInfo ti)
	{
		this(ti.t, ti.levels);
	}

	this(ubyte t, Vector2s sz)
	{
		auto data = TextureData(sz, null);
		this(t, data.sliceOne);
	}

	~this()
	{
		PE.textures.remove(this);

		if(_handle)
		{}
		else
		{
			PEstate._texLayers.each!((ref a) => cas(a.tex, id, 0));
		}

		glDeleteTextures(1, &id);
	}

	const toImage()
	{
		assert(type > TEX_DXT_5);

		auto t = textureTypes[type];
		auto arr = new float[size.x * size.y];

		glGetTextureImageEXT(id, GL_TEXTURE_2D, 0, t[1], t[2], arr.ptr);

		if(type == TEX_SHADOW_MAP)
		{
			auto res = arr.filter!(a => !a.valueEqual(1f)).reduce!(min, max);

			auto
					mi = res[0],
					ma = res[1];

			auto k = 1 / (ma - mi);
			auto p = cast(ubyte *)arr.ptr;

			foreach(f; arr)
			{
				if(!f.valueEqual(1f))
				{
					f = (f - mi) * k;
				}

				p[0..3][] = cast(ubyte)(f * 255);
				p[3] = 255;

				p += 4;
			}
		}

		return new Image(size.x, size.y, arr);
	}

	const isResident()
	{
		return glIsTextureHandleResidentARB(_handle);
	}

	@property resident(bool b) const
	{
		assert(isResident != b);

		if(b)
		{
			glMakeTextureHandleResidentARB(_handle);
		}
		else
		{
			glMakeTextureHandleNonResidentARB(_handle);
		}

		//assert(isResident == b);
	}

	const bind(ubyte idx)
	{
		auto p = &PEstate._texLayers[idx];

		if(set(p.samp, _samp._id))
		{
			glBindSampler(idx, _samp._id);
		}

		if(set(p.tex, id))
		{
			glBindTextureUnit(idx, id);
		}
	}

	const
	{
		uint id;

		ubyte type;
		Vector2s size;
	}

private:
	mixin publicProperty!(ulong, `handle`);

	this(ubyte t, in TextureData[] levels)
	{
		type = t;

		_samp = t == TEX_SHADOW_MAP
									? PEsamplers.shadowMap
									: (levels.length == 1 ? PEsamplers.noMipMap : PEsamplers.main);

		auto tex = &levels.front;
		size = tex.sz;

		{
			uint v;
			glCreateTextures(GL_TEXTURE_2D, 1, &v);
			id = v;
		}

		auto ts = textureTypes[t];

		glTextureStorage2D(id, cast(uint)levels.length, ts[0], size.x, size.y);

		if(t <= TEX_DXT_5)
		{
			foreach(i, ref m; levels)
			{
				assert(m.data.ptr);
				assert(m.data.length == dxtTextureSize(m.sz.x, m.sz.y, type == TEX_DXT_5));

				glCompressedTextureSubImage2D(id, cast(uint)i, 0, 0, m.sz.x, m.sz.y, ts[0], cast(uint)m.data.length, m.data.ptr);
			}
		}
		else
		{
			assert(levels.length == 1);

			if(auto p = tex.data.ptr)
			{
				glTextureSubImage2D(id, 0, 0, 0, size.x, size.y, ts[1], ts[2], p);
			}
		}

		if(GL_ARB_bindless_texture && t != TEX_SHADOW_MAP)
		{
			_handle = glGetTextureSamplerHandleARB(id, _samp._id);
		}
	}

	const Sampler _samp;
}
