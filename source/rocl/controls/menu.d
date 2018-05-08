module rocl.controls.menu;

import
		std.array,
		std.typecons,
		std.algorithm,

		perfontain,

		rocl,
		rocl.game,
		rocl.entity.actor;


final class MenuPopup : PopupSelect
{
	this(Player p)
	{
		auto arr =
		[
			tuple(new GUIStaticText(null, MSG_DEALING), () => trade(p))
		];

		onSelect = (a)
		{
			arr[a][1]();
		};

		super(arr.map!(a => cast(GUIElement)a[0]).array, Vector2s(-1));
	}

private:
	void trade(Player p)
	{
		ROnet.requestTrade(p.bl);
		//RO.gui.trading = new WinTrading;
	}
}
