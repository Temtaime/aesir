module perfontain.managers.gui.misc;
import std, perfontain, std.digest.crc, std.uni : isWhite;

enum COMBO_SCROLL_ITEMS_CNT = 8;

mixin template NuklearStruct(string Dtor, bool Cond, bool DtorOnCond = true)
{
	//@disable this(this);

	static if (Cond)
		bool opCast(T : bool)() const
		{
			return _process;
		}

	static if (Dtor.length)
		 ~this()
		{
			static if (Cond && DtorOnCond)
				if (!_process)
					return;

			mixin(`nk.` ~ Dtor ~ `();`);
		}

	static if (Cond)
		private bool _process;
}

mixin template NuklearWrappers()
{
	final class Style
	{
		this(nk_user_font* font)
		{
			nk.style_push_font(font);
			_pop = &nk_style_pop_font;
		}

		this(float* e, float v)
		{
			nk.style_push_float(e, v);
			_pop = &nk_style_pop_float;
		}

		this(nk_vec2* e, nk_vec2 v)
		{
			nk.style_push_vec2(e, v);
			_pop = &nk_style_pop_vec2;
		}

		this(nk_style_item* e, nk_style_item v)
		{
			nk.style_push_style_item(e, v);
			_pop = &nk_style_pop_style_item;
		}

		this(nk_flags* e, nk_flags v)
		{
			nk.style_push_flags(e, v);
			_pop = &nk_style_pop_flags;
		}

		this(nk_color* e, nk_color v)
		{
			nk.style_push_color(e, v);
			_pop = &nk_style_pop_color;
		}

		~this()
		{
			_pop(&_ctx);
		}

	private:
		extern (C) int function(nk_context*) _pop;
	}

	final class Popup
	{
		mixin NuklearStruct!(`popup_end`, true);

		this(string name, nk_rect rect, uint flags = 0, bool static_ = true)
		{
			auto type = static_ ? NK_POPUP_STATIC : NK_POPUP_DYNAMIC;
			_process = !!nk.popup_begin(type, name.toStringz, flags, rect);
		}

		void close()
		{
			nk.popup_close();
		}
	}

	final class Group
	{
		mixin NuklearStruct!(`group_end`, true);

		this(string name, uint flags = 0)
		{
			_process = !!nk.group_begin(name.toStringz, flags);
		}
	}

	final class Widget
	{
		mixin NuklearStruct!(null, true);

		this()
		{
			const r = nk_widget(&space, ctx);

			canvas = nk.window_get_canvas();
			input = r == NK_WIDGET_VALID ? &ctx.input : null;

			_process = r != NK_WIDGET_INVALID;
		}

		const clicked(uint button)
		{
			return !!nk_input_has_mouse_click(input, button);
		}

		const mouseInside()
		{
			return !!nk_input_is_mouse_hovering_rect(input, space);
		}

		nk_rect space;
		nk_input* input;
		nk_command_buffer* canvas;
	}

	final class Combo
	{
		mixin NuklearStruct!(`combo_end`, true);

		this(string text)
		{
			_process = !!nk.combo_begin_text(text.ptr, cast(uint)text.length, size);
		}

		this(string text, Texture tex)
		{
			_process = !!nk.combo_begin_image_text(text.ptr,
					cast(uint)text.length, nk_image_ptr(cast(void*)tex), size);
		}

		bool item(string text)
		{
			return !!nk.combo_item_text(text.ptr, cast(uint)text.length, NK_TEXT_CENTERED);
		}

		bool item(string text, Texture tex)
		{
			return !!nk.combo_item_image_text(nk_image_ptr(cast(void*)tex),
					text.ptr, cast(uint)text.length, NK_TEXT_RIGHT);
		}

	private:
		auto size()
		{
			auto r = nk.widget_size();

			_height = r.y;
			_height -= _ctx.style.combo.content_padding.y * 2;
			_height += _ctx.style.contextual_button.padding.y * 2;

			return nk_vec2(r.x, _height * COMBO_SCROLL_ITEMS_CNT);
		}

		mixin publicProperty!(float, `height`);
	}

	final class LayoutRowTemplate
	{
		mixin NuklearStruct!(`layout_row_template_end`, false);

		this(float height)
		{
			nk.layout_row_template_begin(height);
		}

		void dynamic()
		{
			nk.layout_row_template_push_dynamic();
		}

		void variable(float width)
		{
			nk.layout_row_template_push_variable(width);
		}

		void static_(float width)
		{
			nk.layout_row_template_push_static(width);
		}
	}

	final class Tree
	{
		mixin NuklearStruct!(`tree_pop`, true);

		this(string File = __FILE__, uint Line = __LINE__)(string name,
				ubyte type = NK_TREE_TAB, ubyte flags = NK_MINIMIZED)
		{
			auto id = nk.uniqueId!(File, Line);

			_process = !!nk.tree_push_hashed(type, name.toStringz, flags,
					id.ptr, cast(uint)id.length, 0);
		}
	}

	final class Window
	{
		mixin NuklearStruct!(`end`, true, false);

		this(string name, nk_rect rect, uint flags = DEFAULT_FLAGS)
		{
			_process = !!nk.begin(name.toStringz, rect, flags);
		}

		enum DEFAULT_FLAGS = NK_WINDOW_TITLE | NK_WINDOW_BORDER
			| NK_WINDOW_MOVABLE | NK_WINDOW_SCALABLE | NK_WINDOW_MINIMIZABLE;
	}
}

final class NuklearContext
{
	mixin NuklearWrappers;

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

	bool button(string text)
	{
		return !!this.button_text(text.ptr, cast(uint)text.length);
	}

	bool button(string text, uint align_, nk_symbol_type symbol)
	{
		return !!this.button_symbol_text(symbol, text.ptr, cast(uint)text.length, align_);
	}

	void tooltip(string text)
	{
		nk_tooltip(&_ctx, text.toStringz);
	}

	bool tabSelector(string[] tabs, ref ubyte index,
			void delegate(ref LayoutRowTemplate) dg = null, void delegate() draw = null)
	{

		bool res, extra = dg && draw;

		scope s1 = new Style(&_ctx.style.button.rounding, 0);
		scope s2 = new Style(&_ctx.style.window.spacing, nk_vec2(0, 0));

		{
			scope r = new LayoutRowTemplate(0);

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
			scope s3 = new Style(&_ctx.style.button.normal, value);

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

		return cast(ushort)font.width(cast(nk_handle)font.userdata,
				font.height, text.ptr, cast(int)text.length);
	}

	void coloredText(CharColor[] line)
	{
		assert(line.length);

		if (auto widget = new Widget)
		{
			float x = 0, y = (widget.space.h - _ctx.style.font.height) / 2;

			foreach (g; line.chunkBy!((a, b) => a.color == b.color)
					.map!array)
			{
				auto c = g[0].color;
				auto str = g.map!(a => a.c).toUTF8;

				auto rect = nk_rect(widget.space.x + x, widget.space.y + y,
						widget.space.w, _ctx.style.font.height);
				auto color = nk_rgba(c.r, c.g, c.b, c.a);

				nk_draw_text(widget.canvas, rect, str.ptr, cast(uint)str.length,
						_ctx.style.font, _ctx.style.window.background, color);
				x += widthFor(str);
			}
		}
	}

	const buttonWidth(string text)
	{
		return widthFor(text) + (
				_ctx.style.button.rounding + _ctx.style.button.border + _ctx.style.button.padding.x)
			* 2;
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
		return !!nk_input_is_mouse_hovering_rect(&ctx.input, this.widget_bounds());
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

struct StringSplitter
{
	this(ushort delegate(string) calcWidth)
	{
		_calcWidth = calcWidth;
	}

	auto split(CharColor[] s, ushort width)
	{
		CharColor[][] res;

		for (skipWhitespaces(s); s.length; skipWhitespaces(s))
		{
			uint p;

			do
			{
				auto next = p;

				while (s[next].c.isWhite) // skip whitespaces between words
					next++;
				while (next != s.length && !s[next].c.isWhite) // iterate until end of the word
					next++;

				if (calcWidth(s[0 .. next]) > width)
				{
					if (!p)
					{
						while (calcWidth(s[0 .. p + 1]) <= width)
							p++;
						assert(p); // check if width can hold a single char
					}

					break;
				}

				p = next;
			}
			while (p != s.length && s[p].c != '\r' && s[p].c != '\n'); // eoi or newline

			res ~= s[0 .. p];
			s = s[p .. $];
		}

		return res;
	}

private:
	void skipWhitespaces(ref CharColor[] s)
	{
		while (s.length && s[0].c.isWhite)
			s.popFront;
	}

	auto calcWidth(CharColor[] s)
	{
		return _calcWidth(s.map!(a => a.c).toUTF8);
	}

	ushort delegate(string) _calcWidth;
}
