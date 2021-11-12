module perfontain.managers.gui.misc;
import std, perfontain, std.digest.crc, std.uni : isWhite;

public import perfontain.managers.gui.misc.structs, perfontain.managers.gui.misc.splitter;

final class NuklearContext
{
	auto opDispatch(string name, A...)(A args)
	{
		return mixin(`nk_` ~ name)(ctx, args);
	}

	void label(string text, uint align_ = NK_TEXT_LEFT)
	{
		label(text, align_, _ctx.style.text.color);
	}

	void label(string text, uint align_, nk_color color)
	{
		this.text_colored(text.ptr, cast(int)text.length, align_, color);
	}

	bool checkbox(string text, bool v)
	{
		return this.checkbox_text(text.ptr, cast(uint)text.length, &v);
	}

	bool button(string text)
	{
		return this.button_text(text.ptr, cast(uint)text.length);
	}

	bool button(string text, uint align_, nk_symbol_type symbol)
	{
		return this.button_symbol_text(symbol, text.ptr, cast(uint)text.length, align_);
	}

	void tooltip(string text)
	{
		nk_tooltip(&_ctx, text.toStringz);
	}

	bool tabSelector(string[] tabs, ref ubyte index, void delegate(ref LayoutRowTemplate) dg = null, void delegate() draw = null)
	{

		bool res, extra = dg && draw;

		auto s1 = Style(this, &_ctx.style.button.rounding, 0);
		auto s2 = Style(this, &_ctx.style.window.spacing, nk_vec2(0, 0));

		{
			auto r = LayoutRowTemplate(this, 0);

			with (r)
			{
				foreach (t; tabs)
					static_(widthFor(t) + _ctx.style.button.padding.x * 3); // TODO: WHY 3 ????

				if (extra)
					dg(r);
			}
		}

		foreach (idx, t; tabs)
		{
			auto value = idx == index ? _ctx.style.button.active : _ctx.style.button.normal;
			auto s3 = Style(this, &_ctx.style.button.normal, value);

			if (button(t))
			{
				res = true;
				index = cast(ubyte)idx;
			}
		}

		if (extra)
			draw();

		return res;
	}

	const widthFor(string text)
	{
		auto font = _ctx.style.font;

		return cast(ushort)font.width(cast(nk_handle)font.userdata, font.height, text.ptr, cast(int)text.length);
	}

	void coloredText(CharColor[] line)
	{
		assert(line.length);

		if (auto widget = Widget(nk))
		{
			float x = 0, y = (widget.space.h - _ctx.style.font.height) / 2;

			foreach (g; line.chunkBy!((a, b) => a.color == b.color)
					.map!array)
			{
				auto c = g[0].color;
				auto str = g.map!(a => a.c).toUTF8;

				auto rect = nk_rect(widget.space.x + x, widget.space.y + y, widget.space.w, _ctx.style.font.height);
				auto color = nk_rgba(c.r, c.g, c.b, c.a);

				nk_draw_text(widget.canvas, rect, str.ptr, cast(uint)str.length, _ctx.style.font, _ctx.style.window.background, color);
				x += widthFor(str);
			}
		}
	}

	const buttonWidth(string text)
	{
		return widthFor(text) + (_ctx.style.button.rounding + _ctx.style.button.border + _ctx.style.button.padding.x) * 2;
	}

	const editHeight()
	{
		return fontHeight + (_ctx.style.edit.padding.y + _ctx.style.edit.border) * 2;
	}

	const comboHeight()
	{
		return fontHeight + _ctx.style.combo.button.padding.y * 2;
	}

	const fontHeight()
	{
		return _ctx.style.font.height;
	}

	const maxColumns(uint elem)
	{
		auto n = nk.window_get_content_region_size().x / (elem + _ctx.style.window.spacing.x);
		return max(cast(uint)n, 1);
	}

	const usableHeight()
	{
		return nk.window_get_content_region_size().y - _ctx.current.layout.footer_height; // TODO: SEEMS THERE'S ANOTHER METHOD OF CALCULATION USABLE HEIGHT
	}

	const rowHeight()
	{
		return _ctx.current.layout.row.min_height;
	}

	bool isWidgetHovered()
	{
		return nk_input_is_mouse_hovering_rect(&ctx.input, this.widget_bounds());
	}

	static uniqueId(string File = __FILE__, uint Line = __LINE__)()
	{
		enum ID = File ~ ':' ~ Line.to!string;
		enum R = `NK_ID_` ~ ID.crc32Of.crcHexString;

		return R;
	}

	@property ctx() inout
	{
		return &_ctx;
	}

private:
	@property nk() inout
	{
		return cast()this;
	}

	nk_context _ctx;
}
