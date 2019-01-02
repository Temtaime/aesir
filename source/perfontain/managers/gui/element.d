module perfontain.managers.gui.element;

import
		std.utf,
		std.range,
		std.stdio,
		std.ascii,
		std.array,
		std.traits,
		std.typecons,
		std.string,
		std.regex,
		std.encoding,
		std.algorithm,

		stb.image,

		perfontain,

		perfontain.misc,
		perfontain.misc.dxt,
		perfontain.misc.draw,

		perfontain.opengl,
		perfontain.signals;


enum WinFlags
{
	none,

	hidden			= 0x1,
	focused			= 0x2,
	pressed			= 0x4,

	moveable		= 0x8,
	background		= 0x10,
	topMost			= 0x20,

	hasMouse		= 0x40,
	hasInput		= 0x80,
}

enum : ubyte
{
	POS_MIN,
	POS_MAX,

	POS_BELOW,
	POS_ABOVE,

	POS_CENTER,
}

// TODO: MOVE TO ANOTHER PKG
template MakeChildRef(T, string Name, Idx...)
{
	mixin(`inout(T) ` ~ Name ~ `() inout
	{
		GUIElement e = cast()this;

		foreach(i; Idx)
		{
			if(i >= e.childs.length)
			{
				return null;
			}

			e = e.childs[i];
		}

		return cast(inout(T))e;
	}`);
}

class GUIElement : RCounted
{
	this(GUIElement p, Vector2s sz = Vector2s.init, WinFlags f = WinFlags.none, string n = null)
	{
		if(p)
		{
			parent = p;
			parent.childs ~= this;
		}

		if(sz.x)
		{
			size = sz;
		}

		if(f)
		{
			flags = f;
		}

		if(n)
		{
			name = n;
			pos.x = -1;

			if(auto w = name in PE.settings.wins)
			{
				auto v = w.pos;
				auto u = v + size;

				if(v.x >= 0 && v.y >= 0 && u.x <= PEwindow.size.x && u.y <= PEwindow.size.y)
				{
					pos = v;
				}
			}
		}
	}

	~this()
	{
		if(name.length)
		{
			PE.settings.wins[name] = WindowData(pos);
		}

		PE.gui.onDie(this);
	}

	void draw(Vector2s p) const
	{
		p += pos;

		foreach(e; childs[].filter!(a => a.visible))
		{
			auto u = e.pos + e.size;

			//assert(u.x <= size.x);
			//assert(u.y <= size.y);

			e.draw(p);
		}
	}

	bool onWheel(Vector2s)
	{
		return false;
	}

	void onMove() {}

	void onShow(bool) {}
	void onFocus(bool) {}
	void onHover(bool) {}
	void onPress(bool) {}
	void onDoubleClick() {}

	void onSubmit() {}
	void onKey(uint, bool) {}

	void onText(string) {}
final:
	auto byHierarchy()
	{
		return HierarchyRange!(typeof(this))(this);
	}

	const byHierarchy()
	{
		return HierarchyRange!(typeof(this))(cast()this);
	}

	void bringToTop()
	{
		auto arr = parent.childs[];

		auto idx = arr.countUntil!(a => a is this);
		arr.remove(idx);

		arr[$ - 1] = this;
	}

	void toChildSize()
	{
		size.x = childs[].map!(a => cast(short)(a.pos.x + a.size.x)).fold!max(short(0));
		size.y = childs[].map!(a => cast(short)(a.pos.y + a.size.y)).fold!max(short(0));
	}

	void pad(Vector2s p)
	{
		size += p * 2;
		childs[].each!(a => a.pos += p);
	}

	void pad(ushort n)
	{
		pad(n.Vector2s);
	}

	void poseBetween(GUIElement a, GUIElement b, bool resize = true)
	{
		if(a.pos.x == b.pos.x)
		{
			poseFunc(0, a, b, resize);
		}
		else if(a.pos.y == b.pos.y)
		{
			poseFunc(1, a, b, resize);
		}
		else
		{
			assert(false);
		}
	}

	void moveX(GUIElement e, ubyte m, int d = 0)
	{
		moveFunc(0, e, m, d);
	}

	void moveY(GUIElement e, ubyte m, int d = 0)
	{
		moveFunc(1, e, m, d);
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

	const absPos()
	{
		return byHierarchy.fold!((a, b) => a + b.pos)(Vector2s.init);
	}

	void focus(bool b = true)
	{
		PE.gui.doFocus(b ? this : null);
	}

	void input(bool b = true)
	{
		PE.gui.doInput(b ? this : null);
	}

	void center()
	{
		pos = ((parent ? parent.size : PEwindow.size) - size) / 2;
	}

	void remove()
	{
		deattach;
	}

	void deattach()
	{
		if(isRcAlive)
		{
			attach(null);
		}
	}

	void attach(GUIElement p)
	{
		acquire;

		if(parent)
		{
			parent.childs.remove(this);
		}

		if(p)
		{
			p.childs ~= this;
		}

		parent = p;
		release;
	}

	auto showOrHide()
	{
		if(flags.hidden)
		{
			show;
			focus;
		}
		else
		{
			hide;
		}
	}

	void show(bool v = true)
	{
		flags.hidden = !v;
	}

	void hide()
	{
		show(false);
	}

	const visible()
	{
		return !flags.hidden;
	}

	/// member variables

	string name;

	GUIElement parent;
	RCArray!GUIElement childs;

	Vector2s	pos,
				size;

	BitFlags!WinFlags flags;
protected:
	enum
	{
		DRAW_MIRROR_H	= 1,
		DRAW_MIRROR_V	= 2,
		DRAW_ROTATE		= 4,
	}

	static sizeFor(uint idx)
	{
		return PE.gui.sizes[idx];
	}

	const drawQuad(Vector2s p, Vector2s sz, Color c = colorWhite)
	{
		drawImage(PEobjs.quad, 0, p, c, sz);
	}

	const drawImage(uint id, Vector2s p, Color c = colorWhite, Vector2s sz = Vector2s.init, ubyte flags = 0)
	{
		drawImage(PE.gui.holder, id, p, c, sz, flags);
	}

	const drawImage(in MeshHolder mh, uint id, Vector2s p, Color c = colorWhite, Vector2s sz = Vector2s.init, ubyte flags = 0)
	{

		DrawInfo d;

		d.mh = cast()mh;
		d.id = cast(ushort)id;
		d.flags = DI_NO_DEPTH;

		{
			Vector2s v = sz.x ? sz : size;

			if(flags & (DRAW_MIRROR_H | DRAW_MIRROR_V | DRAW_ROTATE))
			{
				auto u = Vector2(0.5);

				d.matrix *= Matrix4.translate(Vector3(-u, 0));

				d.matrix *= Matrix4.scale(Vector3(
													flags & DRAW_MIRROR_H ? -1 : 1,
													flags & DRAW_MIRROR_V ? -1 : 1,
													1
																					));

				if(flags & DRAW_ROTATE)
				{
					if(sz.x)
					{
						swap(v.x, v.y);
					}

					d.matrix *= Matrix4.rotate(Vector3(0, 0, 90 * TO_RAD));
				}

				d.matrix *= Matrix4.translate(Vector3(u, 0));
			}

			debug
			{
				if(size.x)
				{
					auto
							q = p - absPos,
							z = q + v;

					//writefln(`%s %s %s %s %s`, q, z, pos, size, absPos);

					assert(!parent || q.x >= 0 && q.y >= 0 && z.x <= size.x && z.y <= size.y, format(`%s + %s > %s`, q, v, size));
				}
			}

			d.matrix *=	Matrix4.scale(Vector3(v, 0));
			d.matrix *= Matrix4.translate(Vector3(p, 0));
		}

		d.color = c;
		d.blendingMode = blendingNormal;

		PE.render.toQueue(d);
	}

package:
	GUIElement winByPos(Vector2s p)
	{
		p -= pos;

		if(visible && p.x >= 0 && p.y >= 0 && p.x < size.x && p.y < size.y)
		{
			foreach(c; childs[].retro)
			{
				if(auto r = c.winByPos(p))
				{
					return r;
				}
			}

			if(!flags.background)
			{
				return this;
			}
		}

		return null;
	}

private:
	struct HierarchyRange(T)
	{
		const empty()
		{
			return !_e.parent;
		}

		void popFront()
		{
			assert(!empty);
			_e = _e.parent;
		}

		T front()
		{
			assert(!empty);
			return _e;
		}

	private:
		GUIElement _e;
	}

	void centrize(ubyte idx, uint zone, uint start = 0)
	{
		assert(size[idx] <= zone);

		pos[idx] = cast(short)(start + (zone - size[idx]) / 2);
	}

	void moveFunc(ubyte idx, GUIElement e, ubyte q, int d)
	{
		e = e ? e : parent; // TODO: REFACTOR
		auto notParent = !(e is parent);

		final switch(q)
		{
		case POS_MIN:
			pos[idx] = cast(short)d;

			if(notParent)
			{
				pos[idx] += e.pos[idx];
			}

			break;

		case POS_MAX:
			pos[idx] = cast(short)(e.size[idx] - size[idx] + d);

			if(notParent)
			{
				pos[idx] += e.pos[idx];
			}

			break;

		case POS_BELOW:
			assert(notParent);

			pos[idx] = cast(short)(e.pos[idx] - size[idx] + d);
			break;

		case POS_ABOVE:
			assert(notParent);

			pos[idx] = cast(short)(e.end[idx] + d);
			break;

		case POS_CENTER:
			centrize(idx, e.size[idx], d);

			if(notParent)
			{
				pos[idx] += e.pos[idx];
			}

			break;
		}
	}

	void poseFunc(ubyte idx, GUIElement a, GUIElement b, bool resize)
	{
		assert(a.size[idx] == b.size[idx]);

		ubyte idx2 = idx ? 0 : 1;
		auto z = b.pos[idx2] - a.end[idx2];

		if(resize)
		{
			size[idx] = a.size[idx];
			size[idx2] = cast(short)z;

			moveFunc(idx2, a, POS_ABOVE, 0);
		}
		else
		{
			centrize(idx, a.size[idx], a.pos[idx]);
			centrize(idx2, z, a.end[idx2]);
		}
	}
}
