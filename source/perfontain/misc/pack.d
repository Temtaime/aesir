module perfontain.misc.pack;

import
		std.algorithm,

		perfontain;


struct stbrp_rect
{
	int id;

	ushort w, h;
	ushort x, y;

	int was_packed;
}

final class TexPacker
 {
 	this(stbrp_rect[] rects)
 	{
 		{
 			uint
 					context,
 					node;

 			stbrp_struct_sizes(&context, &node);

	 		_nodes = new ubyte[node * TEX_MAX];
	 		_context = new ubyte[context];
	 	}

 		_rects = rects;
 	}

	auto process()
	{
		trySize(0, TEX_MAX, false);
		trySize(0, _size.y, true);

		return _size;
	}

private:
	enum TEX_MAX = 16384;

	void trySize(short start, short end, bool onlyY)
	{
		auto a = cast(short)((end + start) / 2);
		auto b = cast(short)((end + start + 1) / 2);

		if(!onlyY)
		{
			_size.x = a;
		}

		_size.y = a;

		if(canPack)
		{
			if(start != end)
			{
				trySize(start, a, onlyY);
			}
		}
		else
		{
			trySize(b, end, onlyY);
		}
	}

	bool canPack()
	{
		stbrp_init_target(_context.ptr, _size.x, _size.y, _nodes.ptr, TEX_MAX);
		return !!stbrp_pack_rects(_context.ptr, _rects.ptr, cast(uint)_rects.length);
	}

	stbrp_rect[] _rects;

	ubyte[]
				_nodes,
				_context;

	Vector2s _size;
}

extern(C)
{
	void stbrp_struct_sizes(uint *, uint *);

	int stbrp_pack_rects(void *, stbrp_rect *, uint);
	void stbrp_init_target(void *, uint, uint, void *, uint);
}
