module rocl.controls.login;
import std, perfontain, rocl;

final class WinLogin : RCounted
{
	void draw()
	{
		if (_adding || accounts.empty)
			drawAddAccount;
		else
			drawAccountSelection;
	}

private:
	mixin Nuklear;

	@property ref accounts()
	{
		return PE.settings.accounts;
	}

	void drawFields()
	{
		nk.layout_row_dynamic(nk.editHeight, 2);

		nk.label(MSG_USERNAME ~ ':', NK_TEXT_CENTERED);
		nk.edit_string(NK_EDIT_FIELD, _user.ptr, &_userLen, cast(uint)_user.length, null);

		nk.label(MSG_PASSWORD ~ ':', NK_TEXT_CENTERED);
		nk.edit_string(NK_EDIT_FIELD, _pass.ptr, &_passLen, cast(uint)_pass.length, null);
	}

	auto make(string title, ushort height)
	{
		auto ws = PE.window.size;
		auto sz = Vector2s(300, height);

		auto rect = nk_rect((ws.x - sz.x) / 2, ws.y * 2 / 3 - sz.y / 2, sz.x, sz.y);

		return Window(nk, title, rect,
				Window.DEFAULT_FLAGS & ~NK_WINDOW_MINIMIZABLE | NK_WINDOW_CLOSABLE);
	}

	void drawAddAccount()
	{
		if (auto win = make(MSG_ADDING, 150))
		{
			drawFields;

			nk.layout_row_dynamic(0, 2);
			nk.spacing(1);

			if (nk.button(MSG_ADD) && _userLen)
			{
				auto user = _user[0 .. _userLen].idup;
				auto pass = _pass[0 .. _passLen].idup;

				_userLen = 0;
				_passLen = 0;

				_adding = false;
				accounts ~= ElementType!(typeof(accounts))(user, pass);
			}
		}

		if (nk.window_is_hidden(MSG_ADDING.toStringz))
		{
			if (_adding)
				_adding = false;
			else
				PE.quit;
		}
	}

	void drawAccountSelection()
	{
		if (auto win = make(MSG_LOGIN, 120))
		{
			nk.layout_row_dynamic(nk.comboHeight, 2);

			nk.label(MSG_USERNAME ~ ':', NK_TEXT_CENTERED);

			if (auto combo = Combo(nk, accounts[_selected].user))
			{
				nk.layout_row_dynamic(combo.height, 1);

				if (nk.button(MSG_ADD))
					_adding = true;

				enum X = `x`;

				with (LayoutRowTemplate(nk, combo.height))
				{
					dynamic;
					static_(nk.buttonWidth(X));
				}

				foreach (i, acc; accounts)
				{
					if (combo.item(acc.user))
						_selected = cast(ubyte)i;

					if (nk.button(X))
						accounts = accounts.remove(i);
				}
			}

			nk.spacing(1);

			if (nk.button(MSG_OK))
			{
				auto acc = accounts[_selected];
				RO.gui.login = null; // TODO: rewrite

				ROnet.login(acc.user, acc.pass);
				return;
			}
		}

		if (nk.window_is_hidden(MSG_LOGIN.toStringz))
			PE.quit;
	}

	bool _adding;
	ubyte _selected;

	char[24] _user, _pass;
	int _userLen, _passLen;
}
