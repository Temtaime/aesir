module perfontain.managers.gui.button;

import
		perfontain;


final class Button : GUIElement
{
	this(GUIElement e, ushort id, string s, Font f = null)
	{
		super(e);

		auto u = f ? f : PE.fonts.base;
		auto sz = PE.gui.sizes[_id = id];

		make(_mhs[0], s, u, 0);
		make(_mhs[1], s, u, FONT_BOLD);

		size = Vector2s(_mhs[1].sz.x + sz.x * 2, sz.y);
	}

	override void onSubmit()
	{
		if(enabled && onClick)
		{
			onClick();
		}
	}

	override void onPress(bool st)
	{
		if(enabled && onClick && !st && flags & WIN_HAS_MOUSE)
		{
			onClick();
		}

		_pressed = st; // TODO: ADD A FLAG
	}

	override void draw(Vector2s p) const
	{
		auto n = p + pos;

		doDraw(n, enabled && (flags & WIN_HAS_MOUSE || _pressed) ? _id + 2 : _id);

		{
			auto u = &_mhs[_pressed && enabled];
			drawImage(u.h, 0, n + (size - u.sz) / 2, colorBlack, u.sz);
		}
	}

	bool enabled = true;
	void delegate() onClick;
private:
	struct S
	{
		Vector2s sz;
		RC!MeshHolder h;
	}

	static make(ref S s, string t, Font f, ubyte flags = 0)
	{
		auto v = PEobjs.makeHolder(f.render(t, flags));

		s.h = v[0];
		s.sz = v[1];
	}

	void doDraw(Vector2s p, uint id) const
	{
		auto sz = PE.gui.sizes[id];
		auto c = enabled ? colorWhite : colorGray;

		// left
		drawImage(id, p, c, sz);

		// right
		drawImage(id, p + Vector2s(size.x - sz.x, 0), c, sz, DRAW_MIRROR_H);

		// spacer
		drawImage(id + 1, p + Vector2s(sz.x, 0), c, Vector2s(size.x - sz.x * 2, sz.y), DRAW_MIRROR_H);
	}

	S[2] _mhs;

	ushort _id;
	bool _pressed;
}
