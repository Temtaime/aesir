module rocl.controls.icon;
import std, perfontain, rocl.messages, rocl.status;

// import
// 		std.utf,
// 		std.meta,
// 		std.conv,
// 		std.range,
// 		std.string,
// 		std.algorithm,

// 		perfontain,
// 		perfontain.opengl,

// 		ro.grf,
// 		ro.conv,
// 		ro.conv.gui,
// 		ro.conv.item,

// 		rocl.paths,

// 		rocl,
// 		rocl.game,
// 		rocl.status,
// 		rocl.controls,
// 		rocl.controls.skills,
// 		rocl.controls.status.equip,
// 		rocl.controls.status.stats,
// 		rocl.controls.status.bonuses,
// 		rocl.network.packets;

// class IconSkill : GUIElement
// {
// 	this(GUIElement p, string res, string path)
// 	{
// 		super(p, 24.Vector2s);

// 		try
// 		{
// 			auto data = convert!RoItem(res, path);

// 			TextureInfo tex =
// 			{
// 				TEX_DXT_5,
// 				[ TextureData(size, data.data) ]
// 			};

// 			auto e = new GUIImage(this, 0, 0, PEobjs.makeOb(tex));
// 			e.size = size;
// 		}
// 		catch(Exception e)
// 		{
// 			logger.error(`can't load an icon: %s`, e.msg);
// 		}
// 	}
// }

// abstract class HotkeyIcon : GUIElement
// {
// 	this(GUIElement w, string res, string path)
// 	{
// 		super(w, Vector2s.init, Win.captureFocus);

// 		new IconSkill(this, res, path);
// 		toChildSize;
// 	}

// 	~this()
// 	{
// 		if(_e)
// 		{
// 			_e.deattach;
// 		}
// 	}

// 	override void onPress(Vector2s, bool b)
// 	{
// 		// _mouse = b;

// 		// if(_e && !b)
// 		// {
// 		// 	auto u = _e;
// 		// 	_e = null;

// 		// 	{
// 		// 		auto w = PE.gui.current;

// 		// 		if(w is null)
// 		// 		{
// 		// 			drop;
// 		// 		}
// 		// 		else
// 		// 		{
// 		// 			foreach(z; w.byHierarchy)
// 		// 			{
// 		// 				if(auto r = cast(WinTrading)z)
// 		// 				{
// 		// 					if(auto im = cast(ItemIcon)u)
// 		// 					{
// 		// 						auto q = cast()im.m;// TODO: FIX

// 		// 						if(q.source == ITEM_INVENTORY)
// 		// 						{
// 		// 							if(!q.trading)
// 		// 							{
// 		// 								q.trading = q.amount;

// 		// 								ROnet.tradeItem(q.idx, q.amount);
// 		// 							}

// 		// 							//q.trade(q.amount);
// 		// 							//r.put(cast()q); // todo fix
// 		// 						}
// 		// 					}
// 		// 				}

// 		// 				if(cast(WinInventory)z)
// 		// 				{
// 		// 					if(auto im = cast(ItemIcon)u)
// 		// 					{
// 		// 						auto q = im.m;

// 		// 						if(q.source == ITEM_STORAGE)
// 		// 						{
// 		// 							ROnet.storeGet(q.idx, q.amount);
// 		// 						}
// 		// 					}

// 		// 					break;
// 		// 				}

// 		// 				if(cast(WinStorage)z)
// 		// 				{
// 		// 					if(auto im = cast(ItemIcon)u)
// 		// 					{
// 		// 						auto q = im.m;

// 		// 						if(q.source == ITEM_INVENTORY)
// 		// 						{
// 		// 							ROnet.storePut(q.idx, q.amount);
// 		// 						}
// 		// 					}

// 		// 					break;
// 		// 				}

// 		// 				if(auto e = cast(WinHotkeys)z)
// 		// 				{
// 		// 					if(e.add(u))
// 		// 					{
// 		// 						if(auto p = cast(WinHotkeys)parent)
// 		// 						{
// 		// 							ROnet.setHotkey(p.posToId(pos), PkHotkey.init);
// 		// 							deattach;
// 		// 						}

// 		// 						return;
// 		// 					}

// 		// 					break;
// 		// 				}
// 		// 			}
// 		// 		}
// 		// 	}

// 		// 	u.deattach;
// 		// }
// 	}

// 	override void onHover(bool b)
// 	{
// 		if(_mouse && !_e && !b)
// 		{
// 			_e = clone(PE.gui.root);

// 			_e.flags.topMost = true;
// 			//_e.flags.background = true;
// 		}

// 		if(b)
// 		{
// 			tooltip;
// 		}
// 	}

// 	override void onMoved()
// 	{
// 		if(_e)
// 		{
// 			_e.pos = PE.window.mpos - _e.size / 2;
// 		}

// 		//parent.onMoved;
// 	}

// 	override void onDoubleClick()
// 	{
// 		use;
// 	}

// 	void use();
// 	void drop() {}

// 	void tooltip();

// 	PkHotkey hotkey();
// 	HotkeyIcon clone(GUIElement w);
// private:
// 	HotkeyIcon _e;
// 	bool _mouse;
// }

// final class SkillIcon : HotkeyIcon
// {
// 	this(GUIElement w, const scope Skill s)
// 	{
// 		sk = s;

// 		super(w, s.name, skillPath(s.name));
// 	}

// 	override HotkeyIcon clone(GUIElement w)
// 	{
// 		return new SkillIcon(w, sk);
// 	}

// 	override PkHotkey hotkey()
// 	{
// 		return PkHotkey(true, sk.id, sk.lvl);
// 	}

// 	override void tooltip()
// 	{
// 		if(cast(WinHotkeys)parent)
// 		{
// 			new TextTooltip(ROdb.skill(sk.name));
// 		}
// 		else
// 		{
// 			new BigTooltip(ROdb.skilldesc(sk.name));
// 		}
// 	}

// 	override void use()
// 	{
// 		auto u = asRC(new Skiller(sk, 0));
// 		u.use;
// 	}

// 	const Skill sk;
// }

// final class ItemIcon : HotkeyIcon
// {
// 	this(GUIElement w, Item t)
// 	{
// 		{
// 			auto u = t.data.res;

// 			super(w, u, itemPath(u));
// 		}

// 		m = t;

// 		_rm = m.onRemove.add(_ => deattach);
// 		_rc = m.onCountChanged.add(_ => tooltip);
// 	}

// 	override void tooltip()
// 	{
// 		new TextTooltip(format(`%s : %u %s`, m.data.name, m.amount, MSG_PCS));
// 	}

// 	override PkHotkey hotkey()
// 	{
// 		return PkHotkey(false, m.id, 0);
// 	}

// 	override HotkeyIcon clone(GUIElement w)
// 	{
// 		return new ItemIcon(w, m);
// 	}

// 	override void use()
// 	{
// 		if(m.source == ITEM_INVENTORY)
// 		{
// 			m.action;
// 		}
// 	}

// 	override void drop()
// 	{
// 		if(m.source == ITEM_INVENTORY)
// 		{
// 			if(!m.equip2)
// 			{
// 				m.drop;
// 			}
// 		}
// 	}

// 	Item m;
// private:
// 	RC!ConnectionPoint _rc;
// 	RC!ConnectionPoint _rm;
// }

abstract class Icon
{
	this()
	{
		_widget = Widget(nk);
	}

	void draw();
protected:
	mixin Nuklear;
	mixin publicProperty!(Widget, `widget`);

	bool draw(Texture tex)
	{
		if (_widget)
		{
			auto space = _widget.space;
			auto canvas = _widget.canvas;

			//assert(space.w == 36, space.to!string);
			//assert(space.h == 36, space.to!string);

			auto img = nk_image_ptr(cast(void*)tex);

			if (_widget.mouseInside)
			{
				nk_fill_rect(canvas, space, 0, nk.ctx.style.selectable.pressed_active.data.color);

				nk_draw_image(canvas, nk_rect(space.x + 2, space.y + 2, 32, 32), &img, nk_color(255, 255, 255, 255));

				if (auto s = tooltip)
				{
					nk.tooltip(s);
				}
			}
			else
				nk_draw_image(canvas, nk_rect(space.x + 6, space.y + 6, 24, 24), &img, nk_color(255, 255, 255, 255));

			return true;
		}

		return false;
	}

	string tooltip();
}

final class ItemIcon : Icon
{
	this(Item m)
	{
		_m = m;
	}

	override void draw()
	{
		auto tex = RO.gui.iconCache.get(_m);

		if (super.draw(tex))
		{
			drawPcs;
		}
	}

protected:
	void drawPcs()
	{
		if (_m.amount == 1 || _m.source == ITEM_SHOP)
			return;

		auto space = _widget.space;
		auto text = _m.amount.to!string;

		auto w = nk.widthFor(text);
		auto r = nk_rect(space.x + space.w - w - 3, space.y + space.h - nk.ctx.style.font.height - 1, w, nk.ctx.style.font.height);

		foreach (x; -1 .. 2)
			foreach (y; -1 .. 2)
				if (x || y)
					nk_draw_text(_widget.canvas, nk_rect(r.x + x, r.y + y, r.w, r.h), text.ptr, cast(uint)text.length,
							nk.ctx.style.font, nk_color.init, nk_color(0, 0, 0, 255));

		nk_draw_text(_widget.canvas, r, text.ptr, cast(uint)text.length, nk.ctx.style.font, nk_color.init, nk_color(255, 255, 255, 255));
	}

	override string tooltip()
	{
		return format(`%s : %u %s`, _m.data.name, _m.amount, MSG_PCS);
	}

private:
	Item _m;
}

final class SkillIcon : Icon
{
	this(Skill sk)
	{
		_sk = sk;
	}

	override void draw()
	{
		auto tex = RO.gui.iconCache.get(_sk);

		if (super.draw(tex))
		{
			//drawPcs;
		}
	}

private:
	Skill _sk;

protected:
	override string tooltip()
	{
		return null;
	}
	// 	void drawPcs()
	// 	{
	// 		if (_m.amount == 1 || _m.source == ITEM_SHOP)
	// 			return;

	// 		auto space = _widget.space;
	// 		auto text = _m.amount.to!string;

	// 		auto w = nk.widthFor(text);
	// 		auto r = nk_rect(space.x + space.w - w - 3, space.y + space.h - nk.ctx.style.font.height - 1, w, nk.ctx.style.font.height);

	// 		foreach (x; -1 .. 2)
	// 			foreach (y; -1 .. 2)
	// 				if (x || y)
	// 					nk_draw_text(_widget.canvas, nk_rect(r.x + x, r.y + y, r.w, r.h), text.ptr, cast(uint)text.length,
	// 							nk.ctx.style.font, nk_color.init, nk_color(0, 0, 0, 255));

	// 		nk_draw_text(_widget.canvas, r, text.ptr, cast(uint)text.length, nk.ctx.style.font, nk_color.init, nk_color(255, 255, 255, 255));
	// 	}

	// 	override string tooltip()
	// 	{
	// 		return format(`%s : %u %s`, _m.data.name, _m.amount, MSG_PCS);
	// 	}

	// private:
	// 	Item _m;
}
