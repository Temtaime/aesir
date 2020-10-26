module perfontain.managers.gui.element;

import std, stb.image, perfontain, perfontain.misc, perfontain.misc.dxt,
	perfontain.misc.draw, perfontain.opengl, perfontain.signals, nuklear;

enum Win
{
	none,

	hidden = 1 << 0,
	focused = 1 << 1,
	pressed = 1 << 2,
	moveable = 1 << 3,
	captureFocus = 1 << 4,
	topMost = 1 << 5,
	hasMouse = 1 << 6,
	hasInput = 1 << 7,
	enabled = 1 << 8,
}

enum : ubyte
{
	POS_MIN,
	POS_MAX,

	POS_BELOW,
	POS_ABOVE,

	POS_CENTER,
}

class InvisibleWindow : GUIWindow
{
	this(Vector2s sz)
	{
		super(null, sz);

		flags = NK_WINDOW_NOT_INTERACTIVE | NK_WINDOW_BACKGROUND;
	}

	override void draw()
	{
		/*auto bg = ctx.style.window.fixed_background;
		//ctx.style.window.fixed_background = nk_style_item_hide();

		nk_style_push_float(ctx, &ctx.style.window.border, 0);
		nk_style_push_vec2(ctx, &ctx.style.text.padding, nk_vec2_(0, 0));
		nk_style_push_vec2(ctx, &ctx.style.window.padding, nk_vec2_(0, 0));
		super.draw;
		nk_style_pop_vec2(ctx);
		nk_style_pop_vec2(ctx);
		nk_style_pop_float(ctx);

		ctx.style.window.fixed_background = bg;*/

	}
}

struct PopupText
{
	string msg;
	Vector2s pos;
	bool fill;
}

class GUIElement : RCounted
{
	mixin Nuklear;

	static widthFor(string text)
	{
		auto font = ctx.style.font;
		return cast(ushort) font.width(cast(nk_handle) font.userdata,
				font.height, text.ptr, cast(int) text.length);
	}

	this(Layout p = null, Vector2s sz = Vector2s.init, Win f = Win.none, string n = null)
	{
		parent = p;
		//assert(parent);

		if (parent)
			parent.childs ~= this;

		assert(!flags);
		assert(!name.length);
		assert(!size.x && !size.y);

		name = n;
		size = sz;
		flags = f;
	}

	~this()
	{
		// if (parent is PE.gui.root && name.length)
		// {
		// 	PE.settings.wins[name] = WindowData(pos);
		// }

		// PE.gui.onDie(this);
	}

	final process()
	{
		const arr = styles;

		arr.each!(a => a.push);
		draw;
		arr.retro.each!(a => a.pop);
	}

	void draw()
	{
		// foreach (e; childs[].filter!(a => a.visible))
		// {
		// 	//assert(u.end.x <= size.x);
		// 	//assert(u.end.y <= size.y);
		// 	e.draw;
		// }
	}

	void tryPose()
	{
		// assert(parent is PE.gui.root && name.length);

		// if (auto w = name in PE.settings.wins)
		// {
		// 	pos = w.pos;

		// 	if (end.x <= parent.size.x && end.y <= parent.size.y)
		// 	{
		// 		return;
		// 	}
		// }

		// poseDefault;
	}

	void poseDefault()
	{
		pos = Vector2s.init;
	}

	bool onWheel(Vector2s)
	{
		return false;
	}

	void onMove(Vector2s)
	{
	}

	void onMoved()
	{
	}

	void onResize()
	{
	}

	void onShow(bool)
	{
	}

	void onFocus(bool)
	{
	}

	void onHover(bool)
	{
	}

	void onPress(Vector2s, bool)
	{
	}

	void onDoubleClick()
	{
	}

	void onSubmit()
	{
	}

	void onKey(uint, bool)
	{
	}

	void onText(string)
	{
	}

	Style[] styles;
final:

	void toChildSize()
	{
		//size = childs[].calcSize;

		/*foreach(c; childs[].filter!(a => a.flags & Win.parentSize))
		{
			if(c.flags.parentWidth)
			{
				c.size.x = size.x;
			}

			if(c.flags.parentHeight)
			{
				c.size.y = size.y;
			}

			c.onResize;
		}*/
	}

	void toParentSize()
	{
		//size = parent.size;
		onResize;
	}

	void pad(Vector2s p)
	{
		size += p * 2;
		//childs[].each!(a => a.pos += p);
	}

	void pad(ushort n)
	{
		pad(n.Vector2s);
	}

	void poseBetween(GUIElement a, GUIElement b, bool resize = true)
	{

	}

	void center()
	{
		move(POS_CENTER, 0, POS_CENTER);
	}

	void moveX(ubyte m, int d = 0)
	{
	}

	void moveY(ubyte m, int d = 0)
	{
	}

	void move(ubyte xm, int xd, ubyte ym, int yd = 0)
	{
		moveX(xm, xd);
		moveY(ym, yd);
	}

	void moveX(GUIElement e, ubyte m, int d = 0)
	{
	}

	void moveY(GUIElement e, ubyte m, int d = 0)
	{
	}

	void move(GUIElement x, ubyte xm, int xd, GUIElement y, ubyte ym, int yd = 0)
	{
		moveX(x, xm, xd);
		moveY(y, ym, yd);
	}

	const end()
	{
		return pos + size;
	}

	void focus(bool v = true)
	{
		//PE.gui.doFocus(v ? this : null);
	}

	void input(bool v = true)
	{
		//PE.gui.doInput(v ? this : null);
	}

	/*void add(GUIElement[] arr)
	{
		arr.each!(a => a.attach(this));
	}*/

	inout firstParent(T)()
	{
		return cast(T) byHierarchy.find!(a => cast(T) a).front;
	}

	auto find(T)()
	{
		return childs[].filter!(a => cast(T) a).array;
	}

	void removeChilds()
	{

	}

	string name;

	Layout parent;

	BitFlags!Win flags;

	Vector2s pos, size;
protected:
	enum
	{
		DRAW_MIRROR_H = 1,
		DRAW_MIRROR_V = 2,
		DRAW_ROTATE = 4,
	}
}
