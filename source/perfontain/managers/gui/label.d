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

		nk_text_colored(ctx, _text.ptr, cast(int) _text.length, NK_TEXT_LEFT,
				nk_rgb(color.r, color.g, color.b));
		//nk_text_wrap_colored(ctx, _text.ptr, cast(int) _text.length, nk_rgb(color.r, color.g, color.b));
	}

	string _text;
	auto color = colorWhite;
}

struct FontInfo // TODO: REPLACE OTHER USAGES
{
	Font font;
	short maxWidth = short.max;
	ubyte flags;
}
