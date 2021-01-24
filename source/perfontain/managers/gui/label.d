module perfontain.managers.gui.label;
import std, perfontain;

class GUIStaticText : GUIElement
{
	this(Layout p, string text, FontInfo fi = FontInfo.init, ubyte mode = 0)
	{
		super(p);

		_text = text;
	}

	override void draw()
	{
		// {
		// 	auto p = parent;
		// 	while (p.parent && !cast(GUIWindow) p)
		// 		p = p.parent;

		// 	cast(GUIWindow) p || throwError(_text);
		// }

		nk_text_colored(ctx, _text.ptr, cast(int)_text.length, align_,
				nk_rgb(color.r, color.g, color.b));
		//nk_text_wrap_colored(ctx, _text.ptr, cast(int) _text.length, nk_rgb(color.r, color.g, color.b));
	}

	auto color = colorWhite;
	auto align_ = NK_TEXT_LEFT;
private:
	string _text;
}

struct FontInfo // TODO: REPLACE OTHER USAGES
{
	Font font;
	short maxWidth = short.max;
	ubyte flags;
}
