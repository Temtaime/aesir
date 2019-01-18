module perfontain.managers.gui.tooltip;

import
		perfontain;



class Tooltip : GUIElement
{
	this()
	{
		super(PE.gui.root, Vector2s.init, Win.topMost);

		_mv = PE.onMove.add(_ => move);
		_cs = PE.gui.onCurrentChanged.add(_ => deattach);
	}

protected:
	void move()
	{
		pos = PE.window.mpos;

		auto d = Vector2s(4, -size.y - 4);

		foreach(i; 0..2)
		{
			auto r = pos[i] + d[i];
			pos[i] += r >= 0 && r + size[i] <= parent.size[i] ? d[i] : -d[i];
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
		new GUIStaticText(this, s).color = colorWhite;

		toChildSize;
		pad(Vector2s(4, 0));

		move;
	}

	override void draw(Vector2s p) const
	{
		drawQuad(p + pos, size, Color(0, 0, 0, 180));
		super.draw(p);
	}
}
