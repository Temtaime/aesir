module rocl.controls.storage;
import std, perfontain, rocl.status, rocl.messages, rocl.controls, perfontain.managers.gui.misc;

public import rocl.controls.storage.inventory, rocl.controls.storage.kafra;

abstract class ItemView : RCounted
{
protected:
	mixin Nuklear;

	string info();
	Item[] items();

	void onIconDraw(in Widget, Item)
	{
	}

	void drawImpl()
	{
		drawSelector;
		drawTab;
	}

private:
	void drawSelector()
	{
		auto s = info;
		auto tabs = [MSG_ITM, MSG_EQP, MSG_ETC];

		nk.tabSelector(tabs, _tab, (ref a) => a.variable(nk.widthFor(s)), () => nk.label(s, NK_TEXT_RIGHT));
	}

	void drawTab()
	{
		auto s1 = Style(nk, &nk.ctx.style.window.spacing, nk_vec2(0, 0));

		enum SZ = 36;
		nk.layout_row_static(SZ, SZ, nk.maxColumns(SZ));

		foreach (e; items.filter!(a => a.tab == _tab))
		{
			scope r = new ItemIcon(e);
			r.draw;

			onIconDraw(r.widget, e);
		}
	}

	ubyte _tab;
}
