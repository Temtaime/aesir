module perfontain.managers.texture.texture;

import bgfx_c, std.range, std.algorithm, perfontain, perfontain.misc.dxt, stb.dxt;

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

	this(ubyte t, Vector2s sz, Sampler s, ulong extraFlags = 0)
	{
		auto data = TextureData(sz, null);
		this(t, data.sliceOne, s, extraFlags);
	}

	~this()
	{
		PE.textures.remove(this);

		//PEstate._texLayers.each!((ref a) => cas(a.tex, id, 0));

		bgfx_destroy_texture(_handle);
	}

	Image toImage() const
	{
		/* Legacy OpenGL readback retained until asynchronous bgfx readback is implemented.
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
		*/
		assert(0, `bgfx texture readback is not implemented`);
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
		/*
		glBindImageTexture(idx, id, level, false, 0, mode, textureTypes[type].front);
		*/
	}

	const bind(ubyte idx)
	{
		// A bgfx texture is bound with its sampler uniform by Program during submission.
	}

	const
	{
		ubyte type;
		Vector2s size;
	}

	bgfx_texture_handle_t handle() const => _handle;
	uint samplerFlags() const => _samp ? _samp._flags : 0;

private:
	this(ubyte t, in TextureData[] levels, Sampler s, ulong extraFlags = 0)
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

		ulong flags;
		if (t == TEX_SHADOW_MAP)
			flags = BGFX_TEXTURE_RT;
		else if (t == TEX_RED_UINT && !(extraFlags & BGFX_TEXTURE_READ_BACK))
			flags = BGFX_TEXTURE_COMPUTE_WRITE;
		flags |= extraFlags;

		_handle = bgfx_create_texture_2d(size.x, size.y, levels.length > 1, 1, textureFormats[t], flags, null, 0);

		foreach (i, ref m; levels)
		{
			if (m.data.ptr)
			{
				if (t <= TEX_DXT_5)
					assert(m.data.length == dxtTextureSize(m.sz.x, m.sz.y, type == TEX_DXT_5));

				bgfx_update_texture_2d(_handle, 0, cast(ubyte)i, 0, 0, m.sz.x, m.sz.y, bgfx_copy(m.data.ptr, cast(uint)m.data.length), ushort
						.max);
			}
		}
	}

	const Sampler _samp;
	bgfx_texture_handle_t _handle;
}
