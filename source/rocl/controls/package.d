module rocl.controls;

import
		std.meta,
		std.stdio,
		std.range,
		std.algorithm,

		perfontain,

		ro.conv.gui,

		rocl.gui,
		rocl.game;

public import
				rocl.controls.npc,
				rocl.controls.base,
				rocl.controls.bars,
				rocl.controls.icon,
				rocl.controls.menu,
				rocl.controls.shops,
				rocl.controls.status,
				rocl.controls.skills,
				rocl.controls.hotkeys,
				rocl.controls.trading,
				rocl.controls.settings,
				rocl.controls.creation,
				rocl.controls.charinfo,
				rocl.controls.inventory;


enum
{
	WPOS_START		= 15,
	WPOS_SPACING	= 18,
}

class WinBasic : GUIElement
{
	this(Vector2s sz, string s, bool bottom = true)
	{
		super(PE.gui.root);

		size = sz;
		flags = WIN_MOVEABLE;

		{
			auto t = new GUIStaticText(this, s);
			t.pos = Vector2s(WPOS_START, 0);
		}

		_bottom = bottom;
	}

	override void draw(Vector2s p) const
	{
		auto np = p + pos;

		auto
				tp = WIN_TOP_SZ,
				bt = WIN_BOTTOM_SZ;

		// left top
		drawImage(WIN_TOP, np, colorWhite, tp);

		// right top
		drawImage(WIN_TOP, np + Vector2s(size.x - tp.x, 0), colorWhite, tp, DRAW_MIRROR_H);

		// center top
		drawImage(WIN_TOP_SPACER, np + Vector2s(tp.x, 0), colorWhite, Vector2s(size.x - tp.x * 2, tp.y));

		// addition part
		drawImage(WIN_PART, np + Vector2s(4), colorWhite, WIN_PART_SZ);

		if(_bottom)
		{
			auto vp = np + Vector2s(0, size.y - bt.y);

			// left bottom
			drawImage(WIN_BOTTOM, vp, colorWhite, bt);

			// right bottom
			drawImage(WIN_BOTTOM, vp + Vector2s(size.x - bt.x, 0), colorWhite, bt, DRAW_MIRROR_H);

			// center bottom
			drawImage(WIN_BOTTOM_SPACER, vp + Vector2s(bt.x, 0), colorWhite, Vector2s(size.x - bt.x * 2, bt.y));
		}

		// center
		drawQuad(np + Vector2s(0, tp.y), size - Vector2s(0, tp.y + (_bottom ? bt.y : 0)), colorWhite);

		// CHILDS
		super.draw(p);
	}

private:
	bool _bottom;
}

class WinBasic2 : GUIElement
{
	this(string s, string n = null, bool bottom = true)
	{
		super(PE.gui.root, WIN_MOVEABLE, n);

		new GUIElement(this);
		top.size.y = WIN_TOP_SZ.y;

		{
			auto e = new GUIStaticText(top, s);
			e.move(top, POS_MIN, WPOS_START, top, POS_CENTER);
		}

		new GUIElement(this);
		main.moveY(top, POS_ABOVE);

		if(bottom)
		{
			auto e = new GUIElement(this);
			e.size.y = WIN_BOTTOM_SZ.y;
		}
	}

	void adjust()
	{
		auto sz = main.size;

		top.size.x = sz.x;
		size = Vector2s(sz.x, top.size.y + sz.y);

		if(bottom)
		{
			size.y += bottom.size.y;

			bottom.size.x = sz.x;
			bottom.moveY(this, POS_MAX);
		}
	}

	override void draw(Vector2s p) const
	{
		auto np = p + pos;

		auto
				tp = WIN_TOP_SZ,
				bt = WIN_BOTTOM_SZ;

		// left top
		drawImage(WIN_TOP, np, colorWhite, tp);

		// right top
		drawImage(WIN_TOP, np + Vector2s(size.x - tp.x, 0), colorWhite, tp, DRAW_MIRROR_H);

		// center top
		drawImage(WIN_TOP_SPACER, np + Vector2s(tp.x, 0), colorWhite, Vector2s(size.x - tp.x * 2, tp.y));

		// addition part
		drawImage(WIN_PART, np + Vector2s(4), colorWhite, WIN_PART_SZ);

		if(bottom)
		{
			auto vp = np + Vector2s(0, size.y - bt.y);

			// left bottom
			drawImage(WIN_BOTTOM, vp, colorWhite, bt);

			// right bottom
			drawImage(WIN_BOTTOM, vp + Vector2s(size.x - bt.x, 0), colorWhite, bt, DRAW_MIRROR_H);

			// center bottom
			drawImage(WIN_BOTTOM_SPACER, vp + Vector2s(bt.x, 0), colorWhite, Vector2s(size.x - bt.x * 2, bt.y));
		}

		// center
		drawQuad(np + Vector2s(0, tp.y), size - Vector2s(0, tp.y + (bottom ? bt.y : 0)), colorWhite);

		// CHILDS
		super.draw(p);
	}

protected:
	mixin MakeChildRef!(GUIElement, `top`, 0);
	mixin MakeChildRef!(GUIElement, `main`, 1);
	mixin MakeChildRef!(GUIElement, `bottom`, 2);
}
