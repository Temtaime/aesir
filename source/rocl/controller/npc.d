module rocl.controller.npc;

import
		std.array,
		std.stdio,
		std.algorithm,

		perfontain,

		rocl,
		rocl.gui,
		rocl.game,
		rocl.network,
		rocl.controls;


final class NpcController
{
	void mes(string s, uint npc)
	{
		_npc = npc;
		_select = false;

		if(_clear)
		{
			_clear = false;
			//win.text.clear;
		}

		win.text.add(s);
	}

	void next()
	{
		auto b = win.makeButton(MSG_NEXT);

		b.onClick =
		{
			ROnet.npcNext(_npc);

			_clear = true;
			win.childs.popBack;
		};
	}

	void close()
	{
		if(_npc)
		{
			if(_select)
			{
				deattach;
			}
			else
			{
				auto b = win.makeButton(MSG_CLOSE);

				b.onClick =
				{
					ROnet.npcClose(_npc);
					deattach;
				};
			}
		}
	}

	void select(string s)
	{
		auto w = new WinNpcSelect(win, s.stripRight(':').split(':'));

		w.onSelect = (idx)
		{
			ROnet.npcSelect(_npc, idx);
			w.deattach;
		};

		_select = true;
	}

private:
	auto win()
	{
		if(!_win)
		{
			_win = new WinNpcDialog;
		}

		return _win;
	}

	void deattach()
	{
		assert(_win);

		_win.deattach;

		_npc = 0;
		_win = null;
	}

	uint _npc;

	bool
			_clear,
			_select;

	WinNpcDialog _win;
}
