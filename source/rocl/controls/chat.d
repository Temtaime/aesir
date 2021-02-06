module rocl.controls.chat;

import std, perfontain, ro.conv.gui, rocl.game, rocl.messages,
	perfontain.managers.font.splitter, std.uni : isWhite;

struct RoChat
{
	void draw()
	{
		if (auto win = Window(MSG_CHAT, nk_vec2(600, 200)))
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

				auto s = "Lorem ipsum dolor sit amet, ^ff0000consectetur adipiscing ^00ff00elit, sed do ^0000ffeiusmod tempor incididunt^ffffff ut labore et dolore magna aliqua.\r\nUt enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";

				auto ss = StringSplitter(a => widthFor(a));

				auto k = nk.widget_size();
				auto res = ss.split(colorSplit(s), cast(short)k.x);

				foreach (line; res)
					nk.coloredText(line);
			}

			with (LayoutRowTemplate(editHeight))
			{
				dynamic();
				static_(nk.buttonWidth(MSG_SUBMIT));
			}

			{
				auto res = nk.edit_string(NK_EDIT_FIELD | NK_EDIT_SIG_ENTER,
						data.ptr, &len, cast(uint)data.length, null);

				if (nk.button(MSG_SUBMIT) || (res & NK_EDIT_COMMITED))
				{
					logger(`got it %s`, data[0 .. len].assumeUnique);
				}
			}
		}
	}

	int len;
	char[255] data;

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
	mixin NuklearBase;
}
