module perfontain.managers.gui.button;
import std, perfontain;

final class Button : GUIElement
{
	this(Layout p, string s, void delegate() f = null)
	{
		super(p);

		_text = s;
		onClick = f;
	}

	override void draw()
	{
		if (nk_button_text(ctx, _text.ptr, cast(int) _text.length) && onClick)
			onClick();
	}

	void delegate() onClick;
private:
	string _text;
}
