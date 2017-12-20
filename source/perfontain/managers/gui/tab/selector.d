module perfontain.managers.gui.tab.selector;

import
		std.algorithm,

		perfontain;


final class TabSelector : GUIElement
{
	this(TabWindow w)
	{
		super(w);
	}

	override void onPress(bool b)
	{
		if(b)
		{
			auto w = cast(TabWindow)parent;
			w.onChange(cast(ubyte)w.selectors.countUntil!(a => a is this));
		}
	}
}
