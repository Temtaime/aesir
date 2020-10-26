module perfontain.managers.gui.select.box;

import std, perfontain;

immutable borderColor = Color(200, 200, 200, 255);

final:

class TextCombo : GUIElement
{
	this(Layout p, string[] values, uint selected)
	{
		super(p);

		_selected = selected;
		_values = values.map!toStringz.array;
	}

	override void draw()
	{
		auto r = nk_widget_size(ctx);

		auto cur = nk_combo(ctx, cast(const(char)**) _values.ptr,
				cast(uint) _values.length, _selected, cast(int) r.y, nk_vec2(r.x, r.y * 8));

		if (_selected != cur)
			onChange(_selected = cur);
	}

	void delegate(uint) onChange;
private:
	mixin publicProperty!(uint, `selected`);

	immutable(char)*[] _values;
}
