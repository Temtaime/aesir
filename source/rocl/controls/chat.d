module rocl.controls.chat;

import std, perfontain, ro.conv.gui, rocl.game;

final class RoChat : GUIWindow
{
	this(bool online = true)
	{
		super(`chat`, Vector2s(200, 200));

		//_group = new Group_(this);

		// {
		// 	auto q = new GUIQuad(this, Color(0, 0, 0, 110));

		// 	new ScrolledText(this, Vector2s(660, 5));

		// 	sc.pos = 4.Vector2s;
		// 	size = q.size = 8.Vector2s + sc.size;
		// }

		// {
		// 	auto l = new GUIImage(this, CHAT_PART);
		// 	auto r = new GUIImage(this, CHAT_PART, DRAW_MIRROR_H);
		// 	auto s = new GUIImage(this, CHAT_SPACER);

		// 	new GUIEditText(this);

		// 	size.y += l.size.y;

		// 	l.moveY(POS_MAX);
		// 	r.move(POS_MAX, 0, POS_MAX);
		// 	s.moveY(POS_MAX);

		// 	s.poseBetween(l, r);

		// 	edit.size.x = s.size.x;
		// 	edit.move(s, POS_MIN, 0, l, POS_CENTER);
		// }

		// edit.onEnter = (a)
		// {
		// 	if(a.length)
		// 	{
		// 		ROnet.toChat(a);
		// 		return true;
		// 	}
		// 	else
		// 	{
		// 		edit.flags.enabled = disabled;
		// 	}

		// 	return false;
		// };

		// tryPose;
		// edit.focus;
	}

	void add(string s, Color c = colorTransparent)
	{
		//sc.add(s, c);
		//new GUIStaticText(_group, s).color = c;
	}

	const disabled()
	{
		return true; // !edit.flags.enabled;
	}

private:
	//Group_ _group;
	//mixin MakeChildRef!(ScrolledText, `sc`, 1);
	//mixin MakeChildRef!(GUIEditText, `edit`, 5);
}
