module perfontain.managers.gui;


import
		std.utf,
		std.range,
		std.stdio,
		std.ascii,
		std.array,
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

public import
				perfontain.managers.gui.tab,
				perfontain.managers.gui.text,
				perfontain.managers.gui.misc,
				perfontain.managers.gui.basic,
				perfontain.managers.gui.scroll,
				perfontain.managers.gui.select,
				perfontain.managers.gui.images,
				perfontain.managers.gui.element,
				perfontain.managers.gui.tooltip;


final class GUIManager
{
	this()
	{
		_prog = ProgramCreator(`gui`).create;

		PE.onKey.permanent(&onKey);
		PE.onMove.permanent(&onMove);
		PE.onWheel.permanent(&onWheel);
		PE.onButton.permanent(&onButton);
		PE.onResize.permanent(&onResize);
		PE.onDoubleClick.permanent(&onDoubleClick);

		root = new GUIElement(null, PE.window.size);
	}

	@property current()
	{
		return _cur;
	}

	void updateMouse()
	{
		onMove(PE.window.mpos);
	}

	void draw()
	{
		alias F = (a, b) => a.flags.topMost < b.flags.topMost;

		root.childs[].sort!(F, SwapStrategy.stable);
		root.draw(Vector2s.init);

		PE.render.doDraw(_prog, RENDER_GUI, _proj, null, false);
	}

	Signal!(void, GUIElement) onCurrentChanged;

	RC!GUIElement root;
	RC!MeshHolder holder;

	Vector2s[] sizes;
package:
	void onDie(GUIElement e)
	{
		if(_cur is e)
		{
			_cur.onHover(false);
			onCurrentChanged(_cur = null);
		}

		if(_focus)
		{
			auto v = _focus.byHierarchy;

			while(!v.empty)
			{
				auto u = v.front;
				v.popFront;

				if(u is e)
				{
					e.onFocus(false);
					_focus = v.empty ? null : v.front;
					break;
				}
			}
		}

		if(_inp is e)
		{
			_inp = null;
			_text = null;
		}
	}

	void doInput(GUIElement e)
	{
		if(_inp)
		{
			_text = null;
			_inp.flags.hasInput = false;
		}

		if(e)
		{
			e.flags.hasInput = true;
			_text = new TextInput(&e.onText);
		}

		_inp = e;
	}

	void doFocus(GUIElement e) // TODO: ELEMENT REMOVES PARENT OR CHILD ???
	{
		if(_focus is e)
		{
			return;
		}

		GUIElement[16]	o,
						n;

		if(_focus)
		{
			_focus.byHierarchy.enumerate.each!(a => o[a.index] = a.value);
		}

		if(e)
		{
			e.byHierarchy.enumerate.each!(a => n[a.index] = a.value);
		}

		_focus = e;

		auto so = o[0..o[].countUntil(null)];
		auto sn = n[0..n[].countUntil(null)];

		so.reverse();
		sn.reverse();

		if(sn.length)
		{
			sn[0].bringToTop;
		}

		auto v = commonPrefix!((a, b) => a is b)(so, sn).count;

		so[v..$].retro.each!(a => focus(a, false));
		sn[v..$].each!(a => focus(a, true));
	}

private:
	void onMove(Vector2s p)
	{
		if(_moveSub.x < 0)
		{
			auto prev = _cur;
			_cur = root.winByPos(PE.window.mpos);

			if(_cur !is prev)
			{
				if(prev)
				{
					prev.flags.hasMouse = false;
					prev.onHover(false);
				}

				onCurrentChanged(_cur);

				if(_cur)
				{
					_cur.flags.hasMouse = true;
					_cur.onHover(true);
				}
			}

			if(_cur)
			{
				_cur.onMove(PE.window.mpos - _cur.absPos);
			}
		}
		else
		{
			p -= _moveSub;

			with(_cur.parent)
			{
				p = p.zipMap!((a, b) => clamp(a, short.init, b))(size - _cur.size);

				if(_cur.pos != p)
				{
					_cur.pos = p;
					_cur.onMoved;
				}
			}
		}
	}

	bool onWheel(Vector2s p)
	{
		if(_cur)
		{
			if(_cur.byHierarchy.any!(a => a.onWheel(p)))
			{
				updateMouse;
			}

			return true;
		}

		return false;
	}

	bool onDoubleClick(ubyte k)
	{
		if(k == MOUSE_LEFT && _cur)
		{
			_cur.onDoubleClick;
			return true;
		}

		return false;
	}

	bool onButton(ubyte k, bool st) // TODO: FIX PRESS EVENT ON NON FOCUSED WINDOWS
	{
		if(k == MOUSE_LEFT)
		{
			if(st)
			{
				doFocus(_cur);
			}

			if(_focus)
			{
				if(st && _focus.flags.moveable)
				{
					_moveSub = PE.window.mpos - _focus.pos;
				}
				else
				{
					_moveSub.x = -1;
				}

				_focus.flags.pressed = st;
				_focus.onPress(PE.window.mpos - _focus.absPos, st);

				return true;
			}
		}

		return false;
	}

	bool onKey(SDL_Keycode k, bool st)
	{
		if(k == SDLK_RETURN || k == SDLK_KP_ENTER)
		{
			if(!st && _focus)
			{
				_focus.onSubmit;
				return true;
			}
		}
		else if(_inp)
		{
			_inp.focus;
			_inp.onKey(k, st);

			return true;
		}

		return false;
	}

	void onResize(Vector2s sz)
	{
		root.size = sz;
		_proj = Matrix4.makeOrthogonal(0, sz.x, sz.y, 0, 1, -1);

		foreach(c; root.childs)
		{
			if(c.end.x > sz.x || c.end.y > sz.y)
			{
				c.poseDefault;
			}
		}
	}

	void focus(GUIElement e, bool b)
	{
		e.flags.focused = b;
		e.onFocus(b);
	}

	RC!Program _prog;
	RC!TextInput _text;

	GUIElement
				_cur,
				_inp,
				_focus;

	Matrix4 _proj;
	Vector2s _moveSub = -1.Vector2s;
}
