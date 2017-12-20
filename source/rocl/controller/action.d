module rocl.controller.action;

import
		std.math,
		std.stdio,
		std.algorithm,

		perfontain,
		perfontain.math,

		rocl.game,
		rocl.paths,
		rocl.status,
		rocl.network,
		rocl.controls,
		rocl.entity.actor;


final class ActionController
{
	void enable()
	{
		_button = PE.onButton.add(&onButton);
	}

	void disable()
	{
		_button = null;
	}

	void onCharCreate()
	{
		with(ROgui) // TODO: REWRITE
		{
			removeCs;
			creation = new WinCreation;
		}
	}

	void onCharSelected()
	{
		with(ROnet)
		{
			send!Pk0066(st.ch);
		}
	}

	void charSelect(uint idx)
	{
		ROent.doActor(idx, &onActor);
	}

	void makeTip(Actor c, bool remake = false)
	{
		if(c)
		{
			auto z = c.ent.bbox * PE.scene.viewProject;
			auto pos = project(z.min + Vector3(z.size.x / 2, 0, 0), PE.window.size).xy.Vector2s;

			if(!_tip)
			{
				_tip = new GUIElement(PE.gui.root);
			}

			if(remake)
			{
				_tip.childs.clear;

				auto o = new GUIStaticText(_tip, c.cleanName, FONT_OUTLINED);
				o.color = colorWhite;

				{
					auto u = new GUIStaticText(_tip, c.cleanName);
					u.pos = Vector2s(2);
				}

				_tip.size = o.size;
			}

			_tip.pos = Vector2s(pos.x - _tip.size.x / 2, pos.y);
		}
		else if(_tip)
		{
			_tip.remove;
			_tip = null;
		}
	}

	void use(Skiller s)
	{
		_sk = s;
	}

private:
	void onActor(Actor a)
	{
		with(ROnet.st)
		{
			ch = cast(ubyte)a.bl;
			ROgui.createCharSelect(curChar);
		}
	}

	bool onButton(ubyte k, bool st)
	{
		if(k != MOUSE_LEFT || !st)
		{
			return false;
		}

		auto res = ROgui.isGame ? doAct || RO.items.pickUp || mapMove : doCS;

		if(_sk)
		{
			_sk = null;
		}

		return res;
	}

	bool doCS()
	{
		if(!ROgui.creation)
		{
			if(auto c = ROent.cur)
			{
				charSelect(c.bl);
				return true;
			}
		}

		return false;
	}

	bool doAct()
	{
		if(auto c = ROent.cur)
		{
			if(_sk)
			{
				if(!_sk.ground)
				{
					_sk.use(c.bl);
					return true;
				}
			}
			else
			{
				return c.act;
			}
		}

		return false;
	}

	bool mapMove()
	{
		auto r = PEscene.ray;
		r.dir /= 2;

		foreach(_; 0..300)
		{
			r.pos += r.dir;

			auto p = Vector2s(r.pos.x, -r.pos.z);
			auto h = ROres.heightOf(p.Vector2);

			if(abs(h - r.pos.y) < 0.5f)
			{
				if(_sk)
				{
					if(_sk.ground)
					{
						_sk.use(p);
						return true;
					}
				}
				else
				{
					ROnet.send!Pk08a8(RoPos(p));
					return true;
				}

				break;
			}
		}

		return false;
	}

	static projectPos(Vector3 pt, Vector3 p)
	{
		return project(
								pt * (PE.scene.camera._inversed * Matrix4.translate(p)),
								PE.scene.viewProject,
								PE.window.size
												);
	}

	GUIElement _tip;

	RC!Skiller _sk;
	RC!ConnectionPoint _button;
}
