module rocl.controls.chat;

import std, perfontain, ro.conv.gui, rocl.game, rocl.messages,
	perfontain.managers.font.splitter, std.uni : isWhite;

struct RoChat
{
	void draw()
	{
		auto sz = Vector2s(600, 200);
		auto pos = PE.window.size - sz;

		if (auto win = Window(MSG_CHAT, nk_rect(pos.x, pos.y, sz.x, sz.y)))
		{
			auto editHeight = nk.editHeight;

			{
				auto h = nk.window_get_content_region_size().y;
				h -= ctx.current.layout.footer_height; // TODO: SEEMS THERE'S ANOTHER METHOD OF CALCULATION USABLE HEIGHT

				h -= editHeight;
				h -= ctx.style.window.spacing.y;

				nk.layout_row_dynamic(h, 1);
			}

			if (auto group = Group(MSG_CHAT))
			{
				nk.layout_row_dynamic(0, 1);
				processChat;
			}

			if (_scroll) // TODO: WHAT'S A PROPER METHOD TO SCROLL ???
			{
				_scroll = false;
				nk.group_set_scroll(MSG_CHAT.toStringz, 0, 100_000);
			}

			with (LayoutRowTemplate(editHeight))
			{
				dynamic();
				static_(nk.buttonWidth(MSG_SUBMIT));
			}

			processEdit;
		}
	}

	void add(string s, Color c = colorTransparent)
	{
		_messages ~= colorSplit(s, c);

		if (_width)
			_cache ~= makeLines(_messages.back);

		_scroll = true;
	}

private:
	mixin NuklearBase;

	auto makeLines(CharColor[] line)
	{
		return StringSplitter(a => widthFor(a)).split(line, _width);
	}

	void processChat()
	{
		auto w = cast(ushort)nk.widget_size().x;

		if (_width != w)
		{
			_width = w;
			_cache = _messages.map!(a => makeLines(a)).join;
		}

		_cache.each!(a => nk.coloredText(a));
	}

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
	char[255] _text;

	ushort _width;
	CharColor[][] _cache, _messages;

	bool _scroll;
}
