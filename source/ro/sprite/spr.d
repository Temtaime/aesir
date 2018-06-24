module ro.sprite.spr;

import
		std.range,
		std.stdio,
		std.algorithm,

		stb.image,

		perfontain.math.matrix,
		perfontain.misc,

		utils.except;

struct ImageOffset
{
	Image im;
	short x, y;
}

struct ImageInfo
{
	ushort pals;
	ImageOffset[] images;
}

auto toInfo(ref in SprFile f)
{
	auto res = ImageInfo(f.pCnt);

	foreach(ref i; f.pImages)
	{
		const(Color)[] data;

		if(f.ver == 0x200)
		{
			data = f.palette[].indexed(i.data).array;
		}
		else
		{
			for(auto p = i.data.ptr, e = p + i.data.length; p != e; p++)
			{
				if(*p)
				{
					data ~= f.palette[*p];
				}
				else
				{
					++p != e || throwError(`RLE count expected`);
					data ~= f.palette.front.repeat(*p).array;
				}
			}

			data.length == i.size.x * i.size.y || throwError(`RLE encoding error`);
		}

		res.images ~= ImageOffset(new Image(i.size.x, i.size.y, data));
	}

	foreach(ref i; f.rImages)
	{
		auto im = new Image(i.size.x, i.size.y, i.data);

		im[].each!((ref a) => reverse(a.toByte));

		res.images ~= ImageOffset(im);
	}

	foreach(i, ref v; res.images) // TODO: VERIFY
	{
		/*auto b = v.im.borderlessParam(&colorTransparent, 0, 0);

		v.x = cast(short)(b.x + (b.w - v.im.w) / 2);
		v.y = cast(short)(b.y + (b.h - v.im.h) / 2);

		v.im = v.im.copy(b.expand);*/
		v.im.normalizeTransparentPixels;
	}

	return res;
}

//private:

struct SprRGBA
{
	Vector2s size;
	@(`length`, `size.x * size.y * 4`) ubyte[] data;
}

struct SprPalette
{
	Vector2s size;

	@(`ignoreif`, `STRUCT.ver == 0x200`, `default`, `cast(ushort)(size.x * size.y)`) ushort len;
	@(`length`, `len`) ubyte[] data;
}

struct SprFile
{
	static immutable char[2] bom = `SP`;
	@(`validif`, `ver == 0x200 || ver == 0x201`) ushort ver;

	ushort pCnt, rCnt;

	@(`length`, `pCnt`) SprPalette[] pImages;
	@(`length`, `rCnt`) SprRGBA[] rImages;

	Color[256] palette;
}
