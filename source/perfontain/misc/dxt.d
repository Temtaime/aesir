module perfontain.misc.dxt;

import
		std.range,
		std.algorithm,
		std.parallelism,

		stb.dxt,
		stb.image,

		perfontain;


auto dxtTranspType(in Image im)
{
	enum D = 10;

	return im[].any!(a => a.a > D && a.a < 255 - D) ? TEX_DXT_5 : TEX_DXT_5;
}

auto makeTexInfo(in Image im, bool mipmaps = true)
{
	return makeTexInfo(im, im.dxtTranspType, mipmaps);
}

auto makeTexInfo(in Image im, ubyte t, bool mipmaps = true)
{
	TextureInfo res = { t };

	auto useDXT = t <= TEX_DXT_5;
	auto arr = mipmaps ? im.toMipmaps : (&im)[0..1];

	res.levels = arr
					.map!(a => TextureData(Vector2s(a.w, a.h), useDXT ? a.dxtCompress(t == TEX_DXT_5) : a[].toByte))
					.array;

	return res;
}
