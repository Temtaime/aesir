module perfontain.managers.gui.tooltip;

import
		perfontain;



class Tooltip : GUIElement
{
	this()
	{
		super(PE.gui.root, Vector2s.init, Win.topMost);

		{
			if(_cur)
			{
				_cur.remove;
			}

			_cur = this;
		}

		_mv = PE.onMove.add(_ => move);
		_cs = PE.gui.onCurrentChanged.add(_ => remove);

		move;
	}

	~this()
	{
		_cur = null;
	}

private:
	void move()
	{
		pos = PE.window.mpos;
		pos.x += 4;

		auto y = cast(short)(pos.y - size.y - 4);

		if(size.y > parent.size.y || y < 0)
		{
			pos.y += 4;
		}
		else
		{
			pos.y = y;
		}
	}

	__gshared Tooltip _cur;

	RC!ConnectionPoint
						_mv,
						_cs;
}

final:

class TextTooltip : Tooltip
{
	this(string s)
	{
		new GUIStaticText(this, s).color = colorWhite;

		toChildSize;
		pad(Vector2s(4, 0));

		super();
	}

	override void draw(Vector2s p) const
	{
		drawQuad(p + pos, size, Color(0, 0, 0, 180));
		super.draw(p);
	}
}
