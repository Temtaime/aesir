module rocl.controls.login;
import std, perfontain, rocl;

final class WinLogin : RCounted
{
	void draw()
	{
		//overview(ctx);

		if (_adding || accounts.empty)
			drawAddAccount;
		else
			drawAccountSelection;
	}

private:
	mixin NuklearBase;

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

		return Window(title, rect, Window.DEFAULT_FLAGS & ~NK_WINDOW_MINIMIZABLE);
	}

	void drawAddAccount()
	{
		if (auto win = make(MSG_ADDING, 150))
		{
			drawFields;
			nk.layout_row_dynamic(0, 2);

			if (nk.button(MSG_QUIT))
				_adding = false;

			if (nk.button(MSG_ADD) && _userLen && _passLen)
			{
				auto user = _user[0 .. _userLen].idup;
				auto pass = _pass[0 .. _passLen].idup;

				accounts ~= ElementType!(typeof(accounts))(user, pass);
			}
		}
	}

	void drawAccountSelection()
	{
		if (auto win = make(MSG_LOGIN, 140))
		{
			nk.layout_row_dynamic(nk.comboHeight, 2);

			nk.label(MSG_USERNAME ~ ':', NK_TEXT_CENTERED);
			auto sz = nk.widget_size();

			auto cnt = cast(uint)accounts.length;
			auto items = accounts.map!(a => cast(const(char)*)a[0].toStringz).array.ptr;

			nk.combobox(items, cnt, &_account, cast(uint)sz.y, nk_vec2(sz.x, 200));
			nk.spacing(1);

			if (nk.button(MSG_ADD))
				_adding = true;

			if (nk.button(MSG_QUIT))
			{
				PE.quit;
			}

			if (nk.button(MSG_OK))
			{

			}
		}
	}

	int _account;
	bool _adding;

	char[24] _user, _pass;
	int _userLen, _passLen;
}
