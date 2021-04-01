module rocl.controls.chat;
import std, perfontain, ro.conv.gui, rocl.game, rocl.messages,
	perfontain.managers.font.splitter, rocl.controls.colorbox, std.uni : isWhite;

struct RoChat
{
	void draw()
	{
		auto sz = Vector2s(600, 200);
		auto pos = PE.window.size - sz;

		if (auto win = Window(nk, MSG_CHAT, nk_rect(pos.x, pos.y, sz.x, sz.y)))
		{
			auto editHeight = nk.editHeight;

			{
				auto h = nk.usableHeight;

				h -= editHeight;
				h -= nk.ctx.style.window.spacing.y;

				nk.layout_row_dynamic(h, 1);
			}

			_box.draw;

			if (_scroll) // TODO: WHAT'S A PROPER METHOD TO SCROLL ???
			{
				_scroll = false;
				nk.group_set_scroll(MSG_CHAT.toStringz, 0, 100_000);
			}

			with (LayoutRowTemplate(nk, editHeight))
			{
				dynamic();
				static_(nk.buttonWidth(MSG_SUBMIT));
			}

			processEdit;
		}
	}

	void add(string s, Color c = colorTransparent)
	{
		_box.add(s, c);
		_scroll = true;
	}

private:
	mixin Nuklear;

	void processEdit()
	{
		auto res = nk.edit_string(NK_EDIT_FIELD | NK_EDIT_SIG_ENTER, _text.ptr,
				&_len, cast(uint)_text.length, null);

		if (nk.button(MSG_SUBMIT) || (res & NK_EDIT_COMMITED))
		{
			auto s = _text[0 .. _len].assumeUnique.strip;

			if (s.length)
				ROnet.toChat(s);

			_len = 0;
		}
	}

	int _len;
	char[256] _text;

	bool _scroll;
	ColorBox _box;
}
