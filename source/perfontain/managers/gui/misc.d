module perfontain.managers.gui.misc;

import std, perfontain;

enum COMBO_SCROLL_ITEMS_CNT = 8;

mixin template NuklearBase()
{
	mixin Nuklear;

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
		this(uint height)
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

		bool isWidgetHovered()
		{
			return !!nk_input_is_mouse_hovering_rect(&ctx.input, this.widget_bounds());
		}
	}

	static NuklearProxy nk;
}
