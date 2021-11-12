module perfontain.managers.gui.misc.structs;
import std, perfontain, std.digest.crc, perfontain.managers.gui.misc;

mixin template NuklearStruct(string Dtor, bool Cond, bool DtorOnCond = true)
{
	@disable this();
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

			mixin(`_nk.` ~ Dtor ~ `();`);
		}

	private
	{
		NuklearContext _nk;

		static if (Cond)
			bool _process;
	}
}

struct Style
{
	this(NuklearContext nk, nk_user_font* font)
	{
		nk.style_push_font(font);
		_pop = { nk_style_pop_font(nk.ctx); };
	}

	this(NuklearContext nk, float* e, float v)
	{
		nk.style_push_float(e, v);
		_pop = { nk_style_pop_float(nk.ctx); };
	}

	this(NuklearContext nk, nk_vec2* e, nk_vec2 v)
	{
		nk.style_push_vec2(e, v);
		_pop = { nk_style_pop_vec2(nk.ctx); };
	}

	this(NuklearContext nk, nk_style_item* e, nk_style_item v)
	{
		nk.style_push_style_item(e, v);
		_pop = { nk_style_pop_style_item(nk.ctx); };
	}

	this(NuklearContext nk, nk_flags* e, nk_flags v)
	{
		nk.style_push_flags(e, v);
		_pop = { nk_style_pop_flags(nk.ctx); };
	}

	this(NuklearContext nk, nk_color* e, nk_color v)
	{
		nk.style_push_color(e, v);
		_pop = { nk_style_pop_color(nk.ctx); };
	}

	~this()
	{
		_pop();
	}

private:
	void delegate() _pop;
}

struct Popup
{
	mixin NuklearStruct!(`popup_end`, true);

	this(NuklearContext nk, string name, nk_rect rect, uint flags = 0, bool static_ = true)
	{
		auto type = static_ ? NK_POPUP_STATIC : NK_POPUP_DYNAMIC;

		_nk = nk;
		_process = nk.popup_begin(type, name.toStringz, flags, rect);
	}

	void close()
	{
		_nk.popup_close();
	}
}

struct Group
{
	mixin NuklearStruct!(`group_end`, true);

	this(NuklearContext nk, string name, uint flags = 0)
	{
		_nk = nk;
		_process = nk.group_begin(name.toStringz, flags);
	}
}

struct Widget
{
	mixin NuklearStruct!(null, true);

	this(NuklearContext nk)
	{
		auto ctx = nk.ctx;
		const r = nk_widget(&space, ctx);

		canvas = nk.window_get_canvas();
		input = r == NK_WIDGET_VALID ? &ctx.input : null;

		_nk = nk;
		_process = r != NK_WIDGET_INVALID;
	}

	const clicked(nk_buttons button)
	{
		return nk_input_has_mouse_click(input, button);
	}

	const mouseInside()
	{
		return nk_input_is_mouse_hovering_rect(input, space);
	}

	nk_rect space;
	nk_input* input;
	nk_command_buffer* canvas;
}

struct Combo
{
	mixin NuklearStruct!(`combo_end`, true);

	this(NuklearContext nk, string text)
	{
		_nk = nk;
		_process = nk.combo_begin_text(text.ptr, cast(uint)text.length, size);
	}

	this(NuklearContext nk, string text, Texture tex)
	{
		_nk = nk;
		_process = nk.combo_begin_image_text(text.ptr, cast(uint)text.length, nk_image_ptr(cast(void*)tex), size);
	}

	bool item(string text)
	{
		return _nk.combo_item_text(text.ptr, cast(uint)text.length, NK_TEXT_CENTERED);
	}

	bool item(string text, Texture tex)
	{
		return _nk.combo_item_image_text(nk_image_ptr(cast(void*)tex), text.ptr, cast(uint)text.length, NK_TEXT_RIGHT);
	}

private:
	mixin publicProperty!(float, `height`);

	auto size()
	{
		auto ctx = _nk.ctx;
		auto rect = _nk.widget_size();

		_height = rect.y;
		_height -= ctx.style.combo.content_padding.y * 2;
		_height += ctx.style.contextual_button.padding.y * 2;

		return nk_vec2(rect.x, _height * COMBO_SCROLL_ITEMS_CNT);
	}

	enum COMBO_SCROLL_ITEMS_CNT = 8;
}

struct LayoutRowTemplate
{
	mixin NuklearStruct!(`layout_row_template_end`, false);

	this(NuklearContext nk, float height)
	{
		_nk = nk;
		nk.layout_row_template_begin(height);
	}

	void dynamic()
	{
		_nk.layout_row_template_push_dynamic();
	}

	void variable(float width)
	{
		_nk.layout_row_template_push_variable(width);
	}

	void static_(float width)
	{
		_nk.layout_row_template_push_static(width);
	}
}

struct Tree
{
	mixin NuklearStruct!(`tree_pop`, true);

	this(string File = __FILE__, uint Line = __LINE__)(NuklearContext nk, string name, nk_tree_type type = NK_TREE_TAB,
			nk_collapse_states flags = NK_MINIMIZED)
	{
		auto id = nk.uniqueId!(File, Line);

		_nk = nk;
		_process = nk.tree_push_hashed(type, name.toStringz, flags, id.ptr, cast(uint)id.length, 0);
	}
}

struct Window
{
	mixin NuklearStruct!(`end`, true, false);

	this(NuklearContext nk, string name, nk_rect rect, uint flags = DEFAULT_FLAGS)
	{
		_nk = nk;
		_process = nk.begin(name.toStringz, rect, flags);
	}

	enum DEFAULT_FLAGS = NK_WINDOW_TITLE | NK_WINDOW_BORDER | NK_WINDOW_MOVABLE | NK_WINDOW_SCALABLE | NK_WINDOW_MINIMIZABLE;
}
