module perfontain.misc.dxt;

import
		std.range,
		std.algorithm,
		std.parallelism,

		ciema,

		perfontain;


auto dxtTranspType(in Image im)
{
	enum D = 10;

	return im[].any!(a => a.a > D && a.a < 255 - D) ? TEX_DXT_5 : TEX_DXT_5;
}

uint texDataLen(Vector2s sz, ubyte t)
{
	ubyte k;

	if(t == TEX_RGBA)
	{
		k = 4;
	}
	else
	{
		sz += Vector2s(3);
		sz /= 4;

		k = t == TEX_DXT_1 ? 8 : 16;
	}

	return sz.x * sz.y * k;
}

auto makeTexInfo(in Image im, bool mipmaps = true)
{
	return makeTexInfo(im, im.dxtTranspType, mipmaps);
}

auto makeTexInfo(in Image im, ubyte t, bool mipmaps = true)
{
	TextureInfo res = { t };

	auto curIm = cast()im;
	auto useDXT = t <= TEX_DXT_5;

	while(true)
	{
		auto data = useDXT ? curIm.compressDXT(t) : curIm[].toByte;

		res.levels ~= TextureData(
									Vector2s(curIm.w, curIm.h),
									data
											);

		if(!mipmaps || (curIm.w == 1 && curIm.h == 1))
		{
			break;
		}

		auto
				w = max(curIm.w / 2, 1),
				h = max(curIm.h / 2, 1);

		curIm = curIm.resize(w, h);
	}

	return res;
}

//private:

auto compressDXT(in Image im, ubyte type)
{
	enum N = 512;

	auto res = new ubyte[texDataLen(Vector2s(im.w, im.h), type)];
	auto isDxt5 = type != TEX_DXT_1;

	auto
			sz = isDxt5 ? 4 : 2,
			line = (im.w + 3) / 4;

	auto
			xe = im.w - 1,
			ye = im.h - 1;

	auto prod = cartesianProduct(
									iota((im.w + N - 1) / N),
									iota((im.h + N - 1) / N)
																);

	foreach(c; prod.parallel(4))
	{
		auto
				cx = c[0],
				cy = c[1],

				ex = min(im.w, (cx + 1) * N),
				ey = min(im.h, (cy + 1) * N);

		for(auto y = cy * N; y < ey; y += 4)
		for(auto x = cx * N; x < ex; x += 4)
		{
			Color[4][4] block = void;

			foreach(k; 0..4)
			{
				auto v = min(y + k, ye);

				foreach(u; 0..4)
				{
					block[k][u] = im[min(x + u, xe), v];
				}
			}

			stb_compress_dxt_block(res.ptr + (y * line + x) * sz, block.ptr, isDxt5, STB_DXT_DITHER | STB_DXT_HIGHQUAL);
		}
	}

	return res;
}

private:

enum
{
	STB_DXT_DITHER		= 1,
	STB_DXT_HIGHQUAL	= 2,
}

extern(C) void stb_compress_dxt_block(void *, in void *, uint, uint mode);
