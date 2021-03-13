module ro.conv.item;
import std.conv, std.digest.md, std.range, std.array, std.format, std.string,
	std.algorithm, perfontain, stb.dxt, ro.conv, rocl.gui, rocl.game, ro.paths;

final class ItemConverter : Converter!RoItem
{
	this(string name)
	{
		auto path = RoPathMaker.itemIcon(name);
		_im = new Image(ROfs.get(path));

		super(name.md5Of);
	}

protected:
	override RoItem process()
	{
		_im.clean;

		RoItem res;
		res.data[] = _im.dxtCompress(true);

		return res;
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

	ubyte[dxtTextureSize(24, 24, true)] data;
}
