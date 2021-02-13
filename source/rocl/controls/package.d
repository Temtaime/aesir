module rocl.controls;
import std.meta, std.stdio, std.range, std.algorithm, perfontain, ro.conv.gui,
	rocl, rocl.gui, rocl.game;

public import rocl.controls.npc, rocl.controls.base, rocl.controls.bars,
	rocl.controls.icon, rocl.controls.menu, rocl.controls.shops,
	rocl.controls.login, rocl.controls.status, rocl.controls.skills,
	rocl.controls.hotkeys, rocl.controls.trading, rocl.controls.settings,
	rocl.controls.creation, rocl.controls.charinfo, rocl.controls.inventory;

enum
{
	WPOS_START = 15,
	WPOS_SPACING = 18,
}

//deprecated
class WinBasic : GUIElement
{
	this()
	{
	}

	this(Vector2s sz, string s, bool bottom = true)
	{
		// super(PE.gui.root, size, Win.moveable | Win.captureFocus);

		// {
		// 	auto t = new GUIStaticText(this, s);
		// 	t.pos = Vector2s(WPOS_START, 0);
		// }

		// _bottom = bottom;
	}

private:
	bool _bottom;
}

//deprecated

// final class WinInfo : WinBasic2
// {
// 	this(string s, bool withCancel = false)
// 	{
// 		super(MSG_INFO, `info`);

// 		{
// 			auto e = new ScrolledText(main, Vector2s(280, 4));

// 			e.autoBottom = false;
// 			e.add(s);
// 		}

// 		adjust;
// 		center;

// 		new Button(bottom, MSG_OK);
// 		ok.moveY(bottom, POS_CENTER);

// 		if(withCancel)
// 		{
// 			new Button(bottom, MSG_CANCEL);
// 			cancel.move(bottom, POS_MAX, -5, bottom, POS_CENTER);

// 			ok.moveX(cancel, POS_BELOW, -5);
// 		}
// 		else
// 		{
// 			ok.onClick = { deattach; };
// 			ok.moveX(bottom, POS_MAX, -5);
// 		}

// 		ok.focus;
// 	}

// 	mixin MakeChildRef!(Button, `ok`, 2, 0);
// 	mixin MakeChildRef!(Button, `cancel`, 2, 1);
// }
