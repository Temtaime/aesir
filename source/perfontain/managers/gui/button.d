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
		auto res = symbol ? nk_button_symbol_text(ctx, symbol, _text.ptr,
				cast(uint)_text.length, align_) : nk_button_text(ctx, _text.ptr,
				cast(uint)_text.length);

		if (res && onClick)
			onClick();
	}

	void delegate() onClick;

	auto align_ = NK_TEXT_LEFT;
	auto symbol = NK_SYMBOL_NONE;
private:
	string _text;
}
