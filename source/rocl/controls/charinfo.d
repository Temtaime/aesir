module rocl.controls.charinfo;

import perfontain, perfontain.math, rocl.game, rocl.controls, rocl.entity.visual;

final class CharInfo : RCounted
{
	this(Entity e)
	{
		_ent = e;
	}

	~this()
	{
		// if(_hp)
		// {
		// 	_hp.deattach;
		// }

		removeMsg;
		removeCast;
	}

	void damageSkill(uint num)
	{
		// if(_skTimer && !_skTimer.removed)
		// {
		// 	_skTimer.exec;
		// }

		// _skTimer = RO.gui.values.show(_ent.pos, num);
	}

	void doCast(uint dur, bool enemy)
	{
		removeCast;

		if (dur)
		{
			//_cast = new CastBar(dur);

			update;
			_ent.act(Action.skill, enemy ? Action.readyFight : Action.idle, cast(ushort)dur);

			removeCast;
			_castTimer = PE.timers.add(&removeCast, dur, TM_ONCE);
		}
	}

	void msg(string s, Color c = colorWhite)
	{
		// removeMsg;

		// {
		// 	_msg = new GUIQuad(PE.gui.root, Color(0, 0, 0, 110));

		// 	{
		// 		auto e = new GUIStaticText(_msg, s);

		// 		e.color = c;
		// 		e.pos = Vector2s(5, 2);

		// 		_msg.size = e.size + Vector2s(10, 4);
		// 	}

		// 	update;
		// }

		// removeMsg;
		// _msgTimer = PE.timers.add(&removeMsg, 5_000, TM_ONCE);
	}

	void update()
	{
		auto z = _ent.bbox * PE.scene.viewProject;

		// if(_msg || _cast)
		// {
		// 	auto pos = project(z.max - Vector3(z.size.x / 2, 0, 0), PE.window.size).xy.Vector2s;

		// 	if(_cast)
		// 	{
		// 		_cast.pos = pos - Vector2s(_cast.size.x / 2, _cast.size.y);
		// 		pos.y -= _cast.size.y + 1;
		// 	}

		// 	if(_msg)
		// 	{
		// 		_msg.pos = pos - Vector2s(_msg.size.x / 2, _msg.size.y);
		// 	}
		// }

		if (_skTimer && _skTimer.removed)
		{
			_skTimer = null;
		}

		// if (_hp)
		// {
		// 	auto pos = project(z.min + Vector3(z.size.x / 2, 0, 0), PE.window.size).xy.Vector2s;

		// 	if (_hp)
		// 	{
		// 		_hp.pos = pos + Vector2s(_hp.size.x / -2, _hp.size.y);
		// 	}
		// }
	}

	@property hp(uint v)
	{
		makeHpBar;
		_hp.hp = v;
	}

	@property sp(uint v)
	{
		makeHpBar;
		_hp.sp = v;
	}

	@property maxHp(uint v)
	{
		makeHpBar;
		_hp.maxHp = v;
	}

	@property maxSp(uint v)
	{
		makeHpBar;
		_hp.maxSp = v;
	}

private:
	void makeHpBar()
	{
		if (!_hp)
		{
			_hp = new HpBar;
		}
	}

	void removeCast()
	{
		if (_castTimer)
		{
			// _cast.deattach;
			// _cast = null;

			_castTimer.removed = true;
			_castTimer = null;
		}
	}

	void removeMsg()
	{
		if (_msgTimer)
		{
			//_msg.deattach;
			//_msg = null;

			_msgTimer.removed = true;
			_msgTimer = null;
		}
	}

	Entity _ent;
	HpBar _hp;

	// GUIElement
	// 			_msg,
	// 			_cast;

	Timer* _skTimer, _msgTimer, _castTimer;
}
