module ro.conv.item;

import
		std.conv,
		std.range,
		std.array,
		std.format,
		std.string,
		std.algorithm,

		perfontain,

		ro.conv,

		rocl.gui,
		rocl.game;


final class ItemConverter : Converter
{
	this(string name)
	{
		_im = new Image(PEfs.get(`data/texture/유저인터페이스/item/` ~ name ~ `.bmp`));
	}

	override const(void)[] process()
	{
		_im.clean;

		RoItem res;
		res.data[] = compressDXT(_im, TEX_DXT_5);

		return res.binaryWrite;
	}

private:
	Image _im;
}

struct RoItem
{
	static immutable
	{
		char[3] bom = `ROI`;
		ubyte ver = 1;
	}

	ubyte[texDataLen(Vector2s(24), TEX_DXT_5)] data;
}
