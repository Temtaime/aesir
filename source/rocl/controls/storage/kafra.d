module rocl.controls.storage.kafra;
import std.meta, std.conv, std.range, std.string, std.algorithm, perfontain,
	ro.db, ro.conv, ro.conv.gui, ro.conv.item, rocl, rocl.gui.misc, rocl.game,
	rocl.paths, rocl.status, rocl.status.helpers, rocl.network, rocl.controls,
	rocl.controls.storage, rocl.controls.storage;

final class WinKafra : ItemView
{
	void draw()
	{
		if (!_maxAmount)
			return;

		if (auto win = Window(MSG_STORAGE, nk_rect(300, 300, 350, 350),
				Window.DEFAULT_FLAGS & ~NK_WINDOW_MINIMIZABLE | NK_WINDOW_CLOSABLE))
		{
			drawImpl;
		}

		if (nk.window_is_hidden(MSG_STORAGE.toStringz))
		{
			remove;
			ROnet.storeClose;
		}
	}

	void remove()
	{
		_items.clear;
		_amount = _maxAmount = 0;
	}

	void amount(ushort cur, ushort max)
	{
		_amount = cur;
		_maxAmount = max;
	}

	void add(Item m)
	{
		_items ~= m;
	}

	@property isActive()
	{
		return !!_maxAmount;
	}

protected:
	override string info()
	{
		return format(`%u / %u`, _amount, _maxAmount);
	}

	override Item[] items()
	{
		return _items[];
	}

private:
	RCArray!Item _items;

	ushort _amount, _maxAmount;
}
