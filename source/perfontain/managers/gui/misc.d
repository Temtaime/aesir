module perfontain.managers.gui.misc;

import std, perfontain, std.uni : isWhite;

enum COMBO_SCROLL_ITEMS_CNT = 8;

mixin template NuklearBase()
{
	mixin Nuklear;

	struct Group
	{
		this(string name, uint flags = NK_WINDOW_BORDER)
		{
			_process = !!nk.group_begin(name.toStringz, flags);
		}

		~this()
		{
			if (_process)
				nk.group_end();
		}

		bool opCast(T : bool)() const
		{
			return _process;
		}

	private:
		bool _process;
	}

	struct Widget
	{
		static create()
		{
			Widget res;

			res.canvas = nk.window_get_canvas();
			const r = nk_widget(&res.space, ctx);

			if (r == NK_WIDGET_INVALID)
				res.canvas = null;
			else if (r == NK_WIDGET_VALID)
				res.input = &ctx.input;

			return res;
		}

		bool opCast(T : bool)() const
		{
			return !!canvas;
		}

		nk_rect space;
		nk_input* input;
		nk_command_buffer* canvas;
	}

	struct Combo
	{
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

		bool opCast(T : bool)() const
		{
			return _process;
		}

		~this()
		{
			if (_process)
				nk.combo_end();
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

		bool _process;
		mixin publicProperty!(float, `height`);
	}

	struct LayoutRowTemplate
	{
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

		~this()
		{
			nk.layout_row_template_end();
		}
	}

	struct Tree
	{
		this(string File = __FILE__, uint Line = __LINE__)(string name)
		{
			_process = !!nk_tree_push_hashed(ctx, NK_TREE_TAB, name.toStringz,
					NK_MINIMIZED, File.ptr, File.length, Line);
		}

		bool opCast(T : bool)() const
		{
			return _process;
		}

		~this()
		{
			if (_process)
				nk.tree_pop();
		}

	private:
		bool _process;
	}

	struct Window
	{
		this(string name, nk_vec2 size,
				uint flags = NK_WINDOW_TITLE | NK_WINDOW_BORDER
				| NK_WINDOW_MOVABLE | NK_WINDOW_SCALABLE | NK_WINDOW_MINIMIZABLE)
		{
			_process = !!nk.begin(name.toStringz, nk_rect(50, 50, size.x, size.y), flags);
		}

		bool opCast(T : bool)() const
		{
			return _process;
		}

		~this()
		{
			nk.end();
		}

	private:
		bool _process;
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

		bool isWidgetHovered()
		{
			return !!nk_input_is_mouse_hovering_rect(&ctx.input, this.widget_bounds());
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
