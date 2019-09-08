module perfontain.managers.gui.element;

import
		std,

		stb.image,

		perfontain,

		perfontain.misc,
		perfontain.misc.dxt,
		perfontain.misc.draw,

		perfontain.opengl,
		perfontain.signals;


enum Win
{
	none,

	hidden			= 1 << 0,
	focused			= 1 << 1,
	pressed			= 1 << 2,
	moveable		= 1 << 3,
	captureFocus	= 1 << 4,
	topMost			= 1 << 5,
	hasMouse		= 1 << 6,
	hasInput		= 1 << 7,
	enabled			= 1 << 8,
}

enum : ubyte
{
	POS_MIN,
	POS_MAX,

	POS_BELOW,
	POS_ABOVE,

	POS_CENTER,
}

class GUIElement : RCounted
{
	this(GUIElement p, Vector2s sz = Vector2s.init, Win f = Win.none, string n = null)
	{
		if(p)
		{
			attach(p);
		}

		assert(!flags);
		assert(!name.length);
		assert(!size.x && !size.y);

		name = n;
		size = sz;
		flags = f;
	}

	~this()
	{
		if(parent is PE.gui.root && name.length)
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
			//assert(u.end.x <= size.x);
			//assert(u.end.y <= size.y);

			e.draw(p);
		}
	}

	void tryPose()
	{
		assert(parent is PE.gui.root && name.length);

		if(auto w = name in PE.settings.wins)
		{
			pos = w.pos;

			if(end.x <= parent.size.x && end.y <= parent.size.y)
			{
				return;
			}
		}

		poseDefault;
	}

	void poseDefault()
	{
		pos = Vector2s.init;
	}

	bool onWheel(Vector2s)
	{
		return false;
	}

	void onMove(Vector2s) {}
	void onMoved() {}
	void onResize() {}
	void onShow(bool) {}
	void onFocus(bool) {}
	void onHover(bool) {}
	void onPress(Vector2s, bool) {}
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
		swap(arr.find!(a => a is this)[0], arr.back);
	}

	void toChildSize()
	{
		size = childs[].calcSize;

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
		size = parent.size;
		onResize;
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

	void center()
	{
		move(POS_CENTER, 0, POS_CENTER);
	}

	void moveX(ubyte m, int d = 0)
	{
		moveFunc(0, parent, m, d);
	}

	void moveY(ubyte m, int d = 0)
	{
		moveFunc(1, parent, m, d);
	}

	void move(ubyte xm, int xd, ubyte ym, int yd = 0)
	{
		moveX(xm, xd);
		moveY(ym, yd);
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

	const absEnd()
	{
		return absPos + size;
	}

	void focus(bool v = true)
	{
		PE.gui.doFocus(v ? this : null);
	}

	void input(bool v = true)
	{
		PE.gui.doInput(v ? this : null);
	}

	/*void add(GUIElement[] arr)
	{
		arr.each!(a => a.attach(this));
	}*/

	inout firstParent(T)()
	{
		return cast(T)byHierarchy.find!(a => cast(T)a).front;
	}

	auto find(T)()
	{
		return childs[].filter!(a => cast(T)a).array;
	}

	void removeChilds()
	{
		while(childs.length)
		{
			auto c = childs.back;

			assert(c.parent is this);
			c.deattach;
		}
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

	override string toString() const
	{
		return typeid(this).toString ~ (name ? '(' ~ name ~ ')' : null);
	}

	const dumpPath()
	{
		auto h = byHierarchy;
		return h.empty ? toString : format(`%(%s -> %)`, h.array.retro);
	}

	string name;

	GUIElement parent;
	RCArray!GUIElement childs;

	BitFlags!Win flags;

	Vector2s	pos,
				size;
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

	const drawImage(in MeshHolder mh, uint id, Vector2s p, Color c = colorWhite, Vector2s sz = Vector2s.init, ubyte mode = 0)
	{
		DrawInfo d;

		d.mh = cast()mh;
		d.id = cast(ushort)id;

		d.color = c;
		d.flags = DI_NO_DEPTH;
		d.blendingMode = blendingNormal;

		{
			Vector2s v = sz.x ? sz : size;

			if(mode)
			{
				auto u = Vector3(0.5, 0.5, 0);

				d.matrix *= Matrix4.translate(-u);

				d.matrix *= Matrix4.scale(Vector3(
													mode & DRAW_MIRROR_H ? -1 : 1,
													mode & DRAW_MIRROR_V ? -1 : 1,
													1
																					));

				if(mode & DRAW_ROTATE)
				{
					if(sz.x)
					{
						swap(v.x, v.y);
					}

					d.matrix *= Matrix4.rotate(Vector3(0, 0, 90 * TO_RAD));
				}

				d.matrix *= Matrix4.translate(u);
			}

			d.matrix *=	Matrix4.scale(Vector3(v, 0));
			d.matrix *= Matrix4.translate(Vector3(p, 0));

			debug
			{
				if(!v.x || !v.y)
				{
					logger.error(`drawing with zero size: %s`, dumpPath);
				}

				foreach(e; byHierarchy.array.retro)
				{
					if(e.pos.x < 0 || e.pos.y < 0)
					{
						logger.error(`negative position: %s`, e.dumpPath);
						break;
					}

					if(e.end.x > e.parent.size.x || e.end.y > e.parent.size.y)
					{
						logger.error(`out of parent: %s`, e.dumpPath);
						break;
					}
				}

				auto	q = p - absPos,
						z = q + v;

				if(q.x < 0 || q.y < 0 || z.x > size.x || z.y > size.y)
				{
					logger.error(`drawing out of rect: %s`, dumpPath);
				}
			}
		}

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

			if(flags.captureFocus)
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
		assert(e);
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
