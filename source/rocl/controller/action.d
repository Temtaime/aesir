module rocl.controller.action;

import std.math, std.stdio, std.algorithm, perfontain, perfontain.math,

	rocl.game, rocl.paths, rocl.status, rocl.network, rocl.controls,
	rocl.messages, rocl.entity.actor;

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
		RO.gui.removeCharSelect;
		//RO.gui.createCreation;
	}

	void onCharSelected()
	{
		with (ROnet)
		{
			send!Pk0066(st.ch);
		}
	}

	void charSelect(uint idx)
	{
		ROent.doActor(idx, &onActor);
	}

	void use(Skiller s)
	{
		_sk = s;
	}

private:
	void onActor(Actor a)
	{
		with (ROnet.st)
		{
			ch = cast(ubyte)a.bl;
			RO.gui.createCharSelect(curChar);
		}
	}

	bool onButton(ubyte k, bool st)
	{
		if (k == MOUSE_RIGHT)
		{
			if (auto c = ROent.cur)
			{
				if (auto p = cast(Player)c)
				{
					/*if(p is ROent.self || ROent.self is null)
					{
						return false;
					}*/

					if (!st)
					{
						//new MenuPopup(p);
					}

					return true;
				}
			}

			return false;
		}

		if (k != MOUSE_LEFT || !st)
		{
			return false;
		}

		auto res = RO.gui.isGame ? doAct || RO.items.pickUp || mapMove : doCS;

		if (_sk)
		{
			_sk = null;
		}

		return res;
	}

	bool doCS()
	{
		if (true) // (!RO.gui.creation)
		{
			if (auto c = ROent.cur)
			{
				charSelect(c.bl);
				return true;
			}
		}

		return false;
	}

	bool doAct()
	{
		if (auto c = ROent.cur)
		{
			if (_sk)
			{
				if (!_sk.ground)
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

		foreach (_; 0 .. 300)
		{
			r.pos += r.dir;

			auto p = Vector2s(r.pos.x, -r.pos.z);
			auto h = ROres.heightOf(p.Vector2);

			if (abs(h - r.pos.y) < 0.5f)
			{
				if (_sk)
				{
					if (_sk.ground)
					{
						_sk.use(p);
						return true;
					}
				}
				else
				{
					ROnet.moveTo(RoPos(p));
					return true;
				}

				break;
			}
		}

		return false;
	}

	static projectPos(Vector3 pt, Vector3 p)
	{
		return project(pt * (PE.scene.camera._inversed * Matrix4.translate(p)),
				PE.scene.viewProject, PE.window.size);
	}

	//GUIElement _tip;

	RC!Skiller _sk;
	RC!ConnectionPoint _button;
}
