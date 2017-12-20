module rocl.controls.icon;

import
		std.utf,
		std.meta,
		std.conv,
		std.range,
		std.string,
		std.algorithm,

		perfontain,
		perfontain.opengl,

		ro.grf,
		ro.conv,
		ro.conv.gui,
		ro.conv.item,

		rocl.paths,

		rocl,
		rocl.game,
		rocl.status,
		rocl.controls,
		rocl.controls.status.equip,
		rocl.controls.status.stats,
		rocl.controls.status.bonuses,
		rocl.network.packets;


class IconSkill : GUIElement
{
	this(string res, string path)
	{
		super(null);

		try
		{
			auto data = convert!RoItem(res, path);

			TextureInfo tex =
			{
				TEX_DXT_5,
				[ TextureData(Vector2s(24), data.data) ]
			};

			_mh = PEobjs.makeOb(tex);
		}
		catch(Exception e)
		{
			log.error(`can't load an icon: %s`, e.msg);
		}

		size = Vector2s(24);
	}

	override void draw(Vector2s p) const
	{
		if(_mh)
		{
			drawImage(_mh, 0, p + pos, color);
		}

		super.draw(p);
	}

	Color color = colorWhite;
private:
	RC!MeshHolder _mh;
}

abstract class HotkeyIcon : GUIElement
{
	this(GUIElement w, string res, string path)
	{
		super(w);

		childs ~= new IconSkill(res, path);
		size = childs.front.size;
	}

	~this()
	{
		if(_e)
		{
			_e.remove;
		}
	}

	void bind(Hotkey *h)
	{
		_p = PE.hotkeys.add(h, false);
	}

	override void onPress(bool b)
	{
		_mouse = b;

		if(_e && !b)
		{
			auto u = _e;
			_e = null;

			{
				auto w = PE.gui.current;

				if(w is null)
				{
					drop;
				}
				else
				{
					foreach(z; w.byHierarchy)
					{
						if(cast(WinInventory)z)
						{
							if(auto im = cast(ItemIcon)u)
							{
								auto q = im.m;

								if(q.source == ITEM_STORAGE)
								{
									ROnet.storeGet(q.idx, q.amount);
								}
							}

							break;
						}
						if(cast(WinStorage)z)
						{
							if(auto im = cast(ItemIcon)u)
							{
								auto q = im.m;

								if(q.source == ITEM_INVENTORY)
								{
									ROnet.storePut(q.idx, q.amount);
								}
							}

							break;
						}
						else if(auto e = cast(WinHotkeys)z)
						{
							if(e.add(u))
							{
								if(auto p = cast(WinHotkeys)parent)
								{
									auto q = p.fromPos(pos);

									ROnet.setHotkey(q.y * 9 + q.x, PkHotkey.init);
									remove;
								}

								return;
							}

							break;
						}
					}
				}
			}

			u.remove;
		}
	}

	void retip()
	{
		if(_tip)
		{
			_tip.remove;
			_tip = new TextTip(` ` ~ tip ~ ` `);
		}
	}

	override void onHover(bool b)
	{
		if(_mouse && !_e && !b)
		{
			_e = clone(PE.gui.root);
			_e.flags |= WIN_BACKGROUND | WIN_TOP_MOST;
		}

		if(b)
		{
			if(auto s = tip)
			{
				_tip = new TextTip(` ` ~ s ~ ` `);
			}
		}
		else if(_tip)
		{
			_tip.remove;
			_tip = null;
		}
	}

	override void onMove()
	{
		if(_e)
		{
			_e.pos = PE.window.mpos - _e.size / 2;
		}

		if(_tip)
		{
			_tip.pos = PE.window.mpos - Vector2s(-4, _tip.size.y + 4);
		}

		parent.onMove;
	}

	override void onDoubleClick()
	{
		use;
	}

	void use();
	void drop() {}

	string tip();

	PkHotkey hotkey();
	HotkeyIcon clone(GUIElement w);
private:
	HotkeyIcon _e;
	RC!ConnectionPoint _p;

	bool _mouse;
	GUIElement _tip;
}

final class SkillIcon : HotkeyIcon
{
	this(GUIElement w, in Skill s)
	{
		sk = s;

		super(w, s.name, skillPath(s.name));
	}

	override HotkeyIcon clone(GUIElement w)
	{
		return new SkillIcon(w, sk);
	}

	override PkHotkey hotkey()
	{
		return PkHotkey(true, sk.id, sk.lvl);
	}

	override string tip()
	{
		return cast(WinHotkeys)parent ? ROdb.skill(sk.name) : null;
	}

	override void use()
	{
		auto u = asRC(new Skiller(sk, 0));
		u.use;
	}

	const Skill sk;
}

final class ItemIcon : HotkeyIcon
{
	this(GUIElement w, in Item t)
	{
		m = t;

		{
			auto u = t.data.res;

			super(w, u, itemPath(u));
		}
	}

	override string tip()
	{
		return format(`%s%s`, m.data.name, m.amount > 1 ? format(` : %u %s`, m.amount, MSG_PCS) : null);
	}

	override PkHotkey hotkey()
	{
		return PkHotkey(false, m.id, 0);
	}

	override HotkeyIcon clone(GUIElement w)
	{
		return new ItemIcon(w, m);
	}

	override void use()
	{
		if(m.source == ITEM_INVENTORY)
		{
			m.action;
		}
	}

	override void drop()
	{
		if(m.source == ITEM_INVENTORY)
		{
			if(!m.equip2)
			{
				m.drop;
			}
		}
	}

	const Item m;
}
