module perfontain.managers.gui.misc;

import std, perfontain, std.uni : isWhite;

enum COMBO_SCROLL_ITEMS_CNT = 8;

mixin template NuklearStruct(string Dtor, bool Cond, bool DtorOnCond = true)
{
	@disable this(this);

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

mixin template NuklearBase()
{
	import std;

	mixin Nuklear;

	struct Style
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
			if (_pop)
				_pop(ctx);
		}

		@disable this(this);
	private:
		extern (C) int function(nk_context*) _pop;
	}

	struct Group
	{
		mixin NuklearStruct!(`group_end`, true);

		this(string name, uint flags = NK_WINDOW_BORDER)
		{
			_process = !!nk.group_begin(name.toStringz, flags);
		}
	}

	struct Widget
	{
		mixin NuklearStruct!(null, true);

		static create()
		{
			nk_rect space;
			const r = nk_widget(&space, ctx);

			Widget res = {
				canvas: nk.window_get_canvas(), space: space, input: r == NK_WIDGET_VALID
					? &ctx.input : null, _process: r != NK_WIDGET_INVALID
			};
			return res;
		}

		nk_rect space;
		nk_input* input;
		nk_command_buffer* canvas;
	}

	struct Combo
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
			_height -= ctx.style.combo.content_padding.y * 2;
			_height += ctx.style.contextual_button.padding.y * 2;

			return nk_vec2(r.x, _height * COMBO_SCROLL_ITEMS_CNT);
		}

		mixin publicProperty!(float, `height`);
	}

	struct LayoutRowTemplate
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

	struct Tree
	{
		mixin NuklearStruct!(`tree_pop`, true);

		this(string File = __FILE__, uint Line = __LINE__)(string name, ubyte type = NK_TREE_TAB, ubyte flags = NK_MINIMIZED)
		{
			_process = !!nk_tree_push_hashed(ctx, type, name.toStringz,
					flags, File.ptr, File.length, Line);
		}
	}

	struct Window
	{
		mixin NuklearStruct!(`end`, true, false);

		this(string name, nk_rect rect, uint flags = DEFAULT_FLAGS)
		{
			_process = !!nk.begin(name.toStringz, rect, flags);
		}

		enum DEFAULT_FLAGS = NK_WINDOW_TITLE | NK_WINDOW_BORDER
			| NK_WINDOW_MOVABLE | NK_WINDOW_SCALABLE | NK_WINDOW_MINIMIZABLE;
	}

	struct NuklearProxy
	{
		auto opDispatch(string name, A...)(A args)
		{
			return mixin(`nk_` ~ name)(ctx, args);
		}

		void label(string text, uint align_ = NK_TEXT_LEFT, nk_color color = ctx.style.text.color)
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
			nk_tooltip(ctx, text.toStringz);
		}

		void tabSelector(string[] tabs, ref ubyte index,
				void delegate(ref LayoutRowTemplate) dg = null, void delegate() draw = null)
		{
			bool extra = dg && draw;

			auto s1 = Style(&ctx.style.button.rounding, 0);
			auto s2 = Style(&ctx.style.window.spacing, nk_vec2(0, 0));

			{
				auto r = LayoutRowTemplate(0);

				with (r)
				{
					foreach (t; tabs)
						static_(widthFor(t) + ctx.style.button.padding.x * 3); // TODO: WHY 3 ????

					if (extra)
						dg(r);
				}
			}

			foreach (idx, t; tabs)
			{
				auto s3 = idx == index ? Style(&ctx.style.button.normal, ctx.style.button.active)
					: Style.init;

				if (button(t))
					index = cast(ubyte)idx;
			}

			if (extra)
				draw();
		}

		void coloredText(CharColor[] line)
		{
			assert(line.length);

			if (auto widget = Widget.create)
			{
				float x = 0;

				foreach (g; line.chunkBy!((a, b) => a.color == b.color)
						.map!array)
				{
					auto c = g[0].color;
					auto str = g.map!(a => a.c).toUTF8;

					auto rect = nk_rect(widget.space.x + x, widget.space.y,
							widget.space.w, ctx.style.font.height);
					auto color = nk_rgba(c.r, c.g, c.b, c.a);

					nk_draw_text(widget.canvas, rect, str.ptr, cast(uint)str.length,
							ctx.style.font, ctx.style.window.background, color);
					x += widthFor(str);
				}
			}
		}

		const buttonWidth(string text)
		{
			return widthFor(text) + (
					ctx.style.button.rounding + ctx.style.button.border + ctx
					.style.button.padding.x) * 2;
		}

		const editHeight()
		{
			return ctx.style.font.height + (ctx.style.edit.padding.y + ctx.style.edit.border) * 2;
		}

		const maxColumns(uint elem)
		{
			auto n = nk.window_get_content_region_size().x / (elem + ctx.style.window.spacing.x);
			return max(cast(uint)n, 1);
		}

		bool isWidgetHovered()
		{
			return !!nk_input_is_mouse_hovering_rect(&ctx.input, this.widget_bounds());
		}
	}

	static NuklearProxy nk;
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
