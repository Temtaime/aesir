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
		rocl.controls.skills,
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
			logger.error(`can't load an icon: %s`, e.msg);
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
						if(auto r = cast(WinTrading)z)
						{
							if(auto im = cast(ItemIcon)u)
							{
								auto q = cast()im.m;// TODO: FIX

								if(q.source == ITEM_INVENTORY)
								{
									if(!q.trading)
									{
										q.trading = q.amount;

										ROnet.tradeItem(q.idx, q.amount);
									}

									//q.trade(q.amount);
									//r.put(cast()q); // todo fix
								}
							}
						}

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

						if(auto e = cast(WinHotkeys)z)
						{
							if(e.add(u))
							{
								if(auto p = cast(WinHotkeys)parent)
								{
									ROnet.setHotkey(p.posToId(pos), PkHotkey.init);
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

	override void onHover(bool b)
	{
		if(_mouse && !_e && !b)
		{
			_e = clone(PE.gui.root);

			_e.flags.topMost = true;
			//_e.flags.background = true;
		}

		if(b)
		{
			tooltip;
		}
	}

	override void onMove()
	{
		if(_e)
		{
			_e.pos = PE.window.mpos - _e.size / 2;
		}

		parent.onMove;
	}

	override void onDoubleClick()
	{
		use;
	}

	void use();
	void drop() {}

	void tooltip();

	PkHotkey hotkey();
	HotkeyIcon clone(GUIElement w);
private:
	HotkeyIcon _e;
	bool _mouse;
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

	override void tooltip()
	{
		if(cast(WinHotkeys)parent)
		{
			new TextTooltip(ROdb.skill(sk.name));
		}
		else
		{
			new BigTooltip(ROdb.skilldesc(sk.name));
		}
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
	this(GUIElement w, Item t)
	{
		{
			auto u = t.data.res;

			super(w, u, itemPath(u));
		}

		m = t;

		_rm = m.onRemove.add(_ => remove);
		_rc = m.onCountChanged.add(_ => tooltip);
	}

	override void tooltip()
	{
		auto s = format(`%s%s`, m.data.name, m.amount > 1 ? format(` : %u %s`, m.amount, MSG_PCS) : null);
		new TextTooltip(s);
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

	Item m;
private:
	RC!ConnectionPoint _rc;
	RC!ConnectionPoint _rm;
}
