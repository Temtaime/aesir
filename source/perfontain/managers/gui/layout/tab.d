module perfontain.managers.gui.layout.tab;
import std, perfontain;

final class TabLayout : RowLayout
{
	this(string[] tabs, void delegate(ushort) dg)
	{
		super(false, 0,
				tabs.map!(a => cast(uint)(GUIElement.widthFor(a) + ctx.style.button.padding.x * 3)) // TODO: WHY 3 ????
				.array);

		foreach (idx, text; tabs)
		{
			auto wrap = {
				auto v = cast(ushort) idx;
				auto b = new Button(this, text, () => click(v));

				if (!v)
					stylize(b);
			};

			wrap();
		}

		styles ~= new Style(&ctx.style.window.spacing, nk_vec2(0, 0));
		styles ~= new Style(&ctx.style.button.rounding, 0);

		_onChange = dg;
	}

private:
	mixin publicProperty!(ushort, `index`);

	void stylize(Button b)
	{
		b.styles ~= new Style(&ctx.style.button.normal, ctx.style.button.active);
	}

	void click(ushort idx)
	{
		btn(_index).styles = null;
		stylize(btn(_index = idx));

		_onChange(_index);
	}

	auto btn(ushort idx)
	{
		return cast(Button) childs[idx];
	}

	void delegate(ushort) _onChange;
}
