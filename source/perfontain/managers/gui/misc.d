module perfontain.managers.gui.misc;

import std, perfontain;

mixin template NuklearBase()
{
	mixin Nuklear;

	struct LayoutRowTemplate
	{
		this(uint height)
		{
			nk_layout_row_template_begin(ctx, height);
		}

		void dynamic()
		{
			nk_layout_row_template_push_dynamic(ctx);
		}

		void variable(float width)
		{
			nk_layout_row_template_push_variable(ctx, width);
		}

		void static_(float width)
		{
			nk_layout_row_template_push_static(ctx, width);
		}

		~this()
		{
			nk_layout_row_template_end(ctx);
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
				nk_tree_pop(ctx);
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
			nk_end(ctx);
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
	}

	static NuklearProxy nk;
}
