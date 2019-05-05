module perfontain.managers.gui.tooltip;

import
		perfontain;


class Tooltip : GUIElement
{
	this()
	{
		if(auto arr = PE.gui.root.find!Tooltip)
		{
			arr[0].deattach;
		}

		super(PE.gui.root, Vector2s.init, Win.topMost);

		_mv = PE.onMove.add(_ => move);
		_cs = PE.gui.onCurrentChanged.add(_ => deattach);
	}

protected:
	enum D = 4;

	void move()
	{
		pos = PE.window.mpos;

		if(pos.x + D + size.x > parent.size.x)
		{
			pos.x -= D + size.x;
		}
		else
		{
			pos.x += D;
		}

		if(pos.y - D - size.y < 0)
		{
			pos.y += D;
		}
		else
		{
			pos.y -= D + size.y;
		}
	}

private:
	RC!ConnectionPoint	_mv,
						_cs;
}

final:

class TextTooltip : Tooltip
{
	this(string s)
	{
		super();

		auto q = new GUIQuad(this, Color(0, 0, 0, 180));
		auto e = new GUIStaticText(this, s);

		q.size = e.size + Vector2s(8, 0);
		e.color = colorWhite;
		e.moveX(q, POS_CENTER);

		toChildSize;
		move;
	}
}
