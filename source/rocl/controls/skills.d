module rocl.controls.skills;

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


final:

class WinSkills : WinBasic2
{
	this()
	{
		{
			super(MSG_SKILLS, `skills`);

			if(pos.x < 0)
			{
				pos = Vector2s(0, PE.window.size.y - size.y);
			}
		}

		/*_sc = new Scrolled(this, Vector2s(280, 36), 4);
		_sc.pos = Vector2s(10, 20);*/

		_ss = new SkillSelector;
	}

	void update(Skill s) // TODO: REMAKE THIS SHIT
	{
		/*auto idx = s.idx;
		auto r = cast(SkillItem)_sc.rows[idx];

		auto e = new SkillItem(r.parent, _ss, s, r.size.x);

		e.idx = r.idx;
		e.pos = r.pos;

		e.show(r.visible);

		_sc.rows[idx] = e;

		if(e.idx == _ss.selected)
		{
			onSkill(idx);
			PE.gui.updateMouse;
		}*/
	}

	void add(Skill s)
	{
		/*auto e = new SkillItem(null, _ss, s, _sc.elemWidth);
		e.idx = cast(uint)_sc.rows.length;*/

		//_sc.add(e, true);
	}

private:
	class SkillSelector : Selector
	{
		this()
		{
			super(null, false);
		}

		override void select(int idx)
		{
			onSkill(cast(ubyte)idx);
		}
	}

	void onSkill(ubyte idx)
	{
		while(childs.back !is _sc)
		{
			childs.popBack;
		}

		auto s = RO.status.skills[idx];

		{
			ushort x;

			if(s.lvl && s.type)
			{
				auto a = new Button(this, MSG_USE);
				a.pos = Vector2s(size.x - a.size.x - 5, size.y - a.size.y - 4);

				a.onClick =
				{
					auto u = asRC(new Skiller(s, 0));
					u.use;
				};

				x = cast(ushort)(a.size.x + 4);
			}

			if(s.upgradable)
			{
				auto a = new Button(this, MSG_LEARN);
				a.pos = Vector2s(size.x - a.size.x - 5 - x, size.y - a.size.y - 4);

				a.onClick =
				{
					ROnet.upSkill(s.id);
				};
			}
		}
	}

	Scrolled _sc;
	SkillSelector _ss;
}

class SkillItem : Selectable
{
	this(GUIElement p, Selector s, in Skill sk, ushort w)
	{
		super(s);

		{
			auto e = new SkillIcon(this, sk);

			if(!sk.lvl)
			{
				//e.color = Color(200, 200, 200, 200);
			}

			e.pos = Vector2s(6);
		}

		{
			auto n = new GUIStaticText(this, ROdb.skill(sk.name));
			n.pos = Vector2s(36, (36 - n.size.y * 2) / 2);

			if(sk.lvl)
			{
				auto y = n.pos.y + n.size.y;

				if(sk.type)
				{
					auto z = PE.fonts.base.widthOf(`◄ 10 / 10 ►`);

					{
						auto u = new GUIStaticText(this, `◄`);
						u.pos = Vector2s(36, y);
					}

					{
						auto u = new GUIStaticText(this, format(` %u / %u `, sk.lvl, sk.lvl));
						u.pos = Vector2s(36 + (z - u.size.x) / 2, y);
					}

					{
						auto u = new GUIStaticText(this, `►`);
						u.pos = Vector2s(36 + z - u.size.x, y);
					}

					{
						auto u = new GUIStaticText(this, format(`%u SP`, sk.sp));
						u.pos = Vector2s(36 + z + 16, y);
					}
				}
				else
				{
					auto u = new GUIStaticText(this, sk.lvl.to!string);
					u.pos = Vector2s(36, y);
				}
			}
		}

		size = Vector2s(w, 36);
	}
}

class TargetSelector : GUIElement
{
	this()
	{
		super(PE.gui.root);

		size = parent.size;
		flags = Win.topMost;
	}

	override void draw(Vector2s p) const
	{
		drawQuad(p + pos, size, Color(0, 0, 0, 110));
	}
}

class BigTooltip : Tooltip
{
	this(string s)
	{
		FontInfo fi =
		{
			maxWidth: 640
		};

		toStaticTexts(s, -1, colorBlack, fi).joiner.each!(a => a.attach(this));

		toChildSize;
		pad(TOOLTIP_PART_SZ.x);

		super();
	}

	override void draw(Vector2s p) const
	{
		auto n = p + pos;
		auto t = TOOLTIP_PART_SZ;

		drawQuad(n + t, size - t * 2);

		drawImage(TOOLTIP_PART, n, colorWhite, t);
		drawImage(TOOLTIP_PART, n + Vector2s(size.x - t.x, 0), colorWhite, t, DRAW_MIRROR_H);
		drawImage(TOOLTIP_PART, n + Vector2s(0, size.y - t.x), colorWhite, t, DRAW_MIRROR_V);
		drawImage(TOOLTIP_PART, n + size - t, colorWhite, t, DRAW_MIRROR_V | DRAW_MIRROR_H);

		drawImage(TOOLTIP_SPACER, n + Vector2s(t.x, 0), colorWhite, Vector2s(size.x - t.x * 2, t.x));
		drawImage(TOOLTIP_SPACER, n + Vector2s(0, t.x), colorWhite, Vector2s(size.y - t.x * 2, t.x), DRAW_ROTATE);
		drawImage(TOOLTIP_SPACER, n + Vector2s(size.x - t.x, t.x), colorWhite, Vector2s(size.y - t.x * 2, t.x), DRAW_ROTATE);
		drawImage(TOOLTIP_SPACER, n + Vector2s(t.x, size.y - t.x), colorWhite, Vector2s(size.x - t.x * 2, t.x));

		super.draw(p);
	}
}
