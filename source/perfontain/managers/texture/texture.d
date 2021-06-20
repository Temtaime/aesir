module perfontain.managers.texture.texture;

import std.range, std.algorithm, perfontain, perfontain.opengl, perfontain.misc.dxt, stb.dxt;

public import perfontain.managers.texture.types;

final class Texture : RCounted
{
	this(in TextureInfo ti)
	{
		this(ti.t, ti.levels, null);
	}

	this(ubyte t, Vector2s sz)
	{
		auto data = TextureData(sz, null);
		this(t, data.sliceOne, null);
	}

	this(ubyte t, Vector2s sz, Sampler s)
	{
		auto data = TextureData(sz, null);
		this(t, data.sliceOne, s);
	}

	~this()
	{
		PE.textures.remove(this);

		//PEstate._texLayers.each!((ref a) => cas(a.tex, id, 0));

		glDeleteTextures(1, &id);
	}

	const toImage()
	{
		assert(type > TEX_DXT_5);

		auto t = textureTypes[type];
		auto arr = new float[size.x * size.y];

		// FIXME
		glBindTexture(GL_TEXTURE_2D, id);
		glGetTexImageANGLE(GL_TEXTURE_2D, 0, t[1], t[2], arr.ptr);

		assert(type == TEX_RGBA);

		if (type == TEX_SHADOW_MAP)
		{
			auto res = arr.filter!(a => !a.valueEqual(1f))
				.reduce!(min, max);

			auto mi = res[0], ma = res[1];

			auto k = 1 / (ma - mi);
			auto p = cast(ubyte*)arr.ptr;

			foreach (f; arr)
			{
				if (!f.valueEqual(1f))
				{
					f = (f - mi) * k;
				}

				p[0 .. 3][] = cast(ubyte)(f * 255);
				p[3] = 255;

				p += 4;
			}
		}

		return new Image(size.x, size.y, arr);
	}

	const isResident()
	{
		return false; //glIsTextureHandleResidentARB(_handle);
	}

	@property resident(bool b) const
	{
		assert(isResident != b);

		if (b)
		{
			//glMakeTextureHandleResidentARB(_handle);
		}
		else
		{
			//glMakeTextureHandleNonResidentARB(_handle);
		}

		//assert(isResident == b);
	}

	const imageBind(ubyte idx, uint mode, ubyte level = 0)
	{
		glBindImageTexture(idx, id, level, false, 0, mode, textureTypes[type].front);
	}

	const bind(ubyte idx)
	{
		//if (set(p.samp, _samp._id))
		{
			glBindSampler(idx, _samp._id);
		}

		//if (set(p.tex, id))
		{
			glActiveTexture(GL_TEXTURE0 + idx);
			glBindTexture(GL_TEXTURE_2D, id);

			//glBindTextureUnit(idx, id);
		}
	}

	const
	{
		uint id;

		ubyte type;
		Vector2s size;
	}

private:
	this(ubyte t, in TextureData[] levels, Sampler s)
	{
		type = t;

		if (s is null)
		{
			_samp = t == TEX_SHADOW_MAP ? PEsamplers.shadowMap : (levels.length == 1 ? PEsamplers.noMipMap : PEsamplers.main);
		}
		else
			_samp = s;

		auto tex = &levels.front;
		size = tex.sz;

		{
			uint v;
			glGenTextures(1, &v);
			id = v;
		}

		// int bound;
		// glGetIntegerv(GL_TEXTURE_BINDING_2D, &bound);
		glBindTexture(GL_TEXTURE_2D, id);
		// scope (exit)
		// 	glBindTexture(GL_TEXTURE_2D, bound);

		auto ts = textureTypes[t];

		if (t <= TEX_DXT_5)
		{
			glTexStorage2D(GL_TEXTURE_2D, cast(uint)levels.length, ts[0], size.x, size.y);

			foreach (i, ref m; levels)
			{
				assert(m.data.ptr);
				assert(m.data.length == dxtTextureSize(m.sz.x, m.sz.y, type == TEX_DXT_5));

				glCompressedTexSubImage2D(GL_TEXTURE_2D, cast(uint)i, 0, 0, m.sz.x, m.sz.y, ts[0], cast(uint)m.data.length, m.data.ptr);
			}
		}
		else
		{
			assert(levels.length == 1);

			glTexStorage2D(GL_TEXTURE_2D, 1, ts[0], size.x, size.y);

			if (auto p = tex.data.ptr)
			{
				glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, size.x, size.y, ts[1], ts[2], p);
			}
			//else
			//	glTexImage2D(GL_TEXTURE_2D, 0, ts[0], size.x, size.y, 0, ts[1], ts[2], null);
		}
	}

	const Sampler _samp;
}
