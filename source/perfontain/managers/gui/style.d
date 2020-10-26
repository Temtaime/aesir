module perfontain.managers.gui.style;
import perfontain;

final class Style
{
	mixin Nuklear;

	this(nk_user_font* font)
	{
		_push = () => nk_style_push_font(ctx, font);
		_pop = &nk_style_pop_font;
	}

	this(float* e, float v)
	{
		_push = () => nk_style_push_float(ctx, e, v);
		_pop = &nk_style_pop_float;
	}

	this(nk_vec2* e, nk_vec2 v)
	{
		_push = () => nk_style_push_vec2(ctx, e, v);
		_pop = &nk_style_pop_vec2;
	}

	this(nk_style_item* e, nk_style_item v)
	{
		_push = () => nk_style_push_style_item(ctx, e, v);
		_pop = &nk_style_pop_style_item;
	}

	this(nk_flags* e, nk_flags v)
	{
		_push = () => nk_style_push_flags(ctx, e, v);
		_pop = &nk_style_pop_flags;
	}

	this(nk_color* e, nk_color v)
	{
		_push = () => nk_style_push_color(ctx, e, v);
		_pop = &nk_style_pop_color;
	}

	const push()
	{
		const res = _push();
		assert(res);
	}

	const pop()
	{
		const res = _pop(ctx);
		assert(res);
	}

private:
	int delegate() _push;
	extern (C) int function(nk_context*) _pop;
}
