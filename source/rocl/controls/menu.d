module rocl.controls.menu;

import
		perfontain,

		rocl,
		rocl.game;


final class MenuPopup : PopupSelect
{
	this()
	{
		onSelect = &select;

		GUIElement[] arr =
		[
			new GUIStaticText(null, MSG_DEALING),
		];

		super(arr, Vector2s(-1));
	}

private:
	void select(int idx)
	{
		final switch(idx)
		{
		case 0:
			ROgui.trading = new WinTrading;
		}
	}
}
