module perfontain.managers.gui.select.box;
import std, perfontain;

enum COMBO_SCROLL_ITEMS = 8;

class Combo : GUIElement
{
	this(Layout p)
	{
		super(p);
	}

	uint selected;
	bool delegate(uint) onChange;
private:
	//mixin publicProperty!(uint, `selected`);

	void select(size_t idx)
	{
		auto n = cast(uint) idx;

		if (selected != n && (onChange is null || onChange(n)))
			selected = n;
	}
}

final:

class TextCombo : Combo
{
	this(Layout p, string[] values, uint selected)
	{
		super(p);

		selected = selected;
		_values = values.map!toStringz.array;
	}

	override void draw()
	{
		auto r = nk_widget_size(ctx);
		auto cur = nk_combo(ctx, cast(const(char)**) _values.ptr,
				cast(uint) _values.length, selected, cast(int) r.y, nk_vec2(r.x,
					r.y * COMBO_SCROLL_ITEMS));

		if (selected != cur)
			onChange(selected = cur);

		// if (nk_combo_begin_label(ctx, items[selected], size))
		// {
		// 	nk_layout_row_dynamic(ctx, (float) item_height, 1);
		// 	for (i = 0; i < count; ++i)
		// 	{
		// 		if (nk_combo_item_label(ctx, items[i], NK_TEXT_LEFT))
		// 			selected = i;
		// 	}
		// 	nk_combo_end(ctx);
		// }
	}

private:
	immutable(char)*[] _values;
}

class ImageCombo : Combo
{
	this(Layout p)
	{
		super(p);
	}

	~this()
	{
		clear;
	}

	override void draw()
	{
		auto r = nk_widget_size(ctx);

		auto height = r.y;
		height -= ctx.style.combo.content_padding.y * 2;
		height += ctx.style.contextual_button.padding.y * 2;

		if (title(_arr[selected].expand, nk_vec2(r.x, height * COMBO_SCROLL_ITEMS)))
		{
			nk_layout_row_dynamic(ctx, height, 1);

			foreach (i, tp; _arr)
				if (item(tp.expand))
					select(i);

			nk_combo_end(ctx);
		}
	}

	void add(string text, Texture image)
	{
		if (image)
			image.acquire;
		_arr ~= tuple(text, image);
	}

	void clear()
	{
		_arr.map!(a => a[1])
			.filter!(a => !!a)
			.each!(a => a.release);
		_arr = null;
		selected = 0;
	}

private:
	bool title(string s, Texture t, nk_vec2 size)
	{
		if (t)
			return !!nk_combo_begin_image_text(ctx, s.ptr, cast(uint) s.length,
					nk_image_ptr(cast(void*) t), size);
		return !!nk_combo_begin_text(ctx, s.ptr, cast(uint) s.length, size);
	}

	bool item(string s, Texture t)
	{
		if (t)
			return !!nk_combo_item_image_text(ctx, nk_image_ptr(cast(void*) t),
					s.ptr, cast(uint) s.length, NK_TEXT_RIGHT);
		return !!nk_combo_item_text(ctx, s.ptr, cast(uint) s.length, NK_TEXT_CENTERED);
	}

	Tuple!(string, Texture)[] _arr;
}
