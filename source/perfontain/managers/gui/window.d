module perfontain.managers.gui.window;
import std, perfontain;

class GUIWindow : RCounted
{
	mixin Nuklear;

	this(string id, Vector2s sz)
	{
		name = id;
		size = sz;

		PE.gui.add(this);

		flags |= NK_WINDOW_TITLE;
		flags |= NK_WINDOW_BORDER;
		flags |= NK_WINDOW_MOVABLE;
		flags |= NK_WINDOW_SCALABLE;
		flags |= NK_WINDOW_MINIMIZABLE;

		hide;
	}

	void remove()
	{
		PE.gui.remove(this);
	}

	void draw()
	{
		if (nk_begin(ctx, name.toStringz, nk_rect(50, 50, size.x, size.y), flags))
			_layouts.each!(a => a.process);
		nk_end(ctx);
	}

	void show(bool show = true)
	{
		flags &= ~NK_WINDOW_HIDDEN;
		if (!show)
			flags |= NK_WINDOW_HIDDEN;
	}

	void hide()
	{
		show(false);
	}

	uint flags;
	string name;
	Vector2s size;
protected:
	void addLayout(Layout e)
	{
		_layouts ~= e;
	}

	@property curLayout()
	{
		return _layouts.back;
	}

private:
	RCArray!Layout _layouts;
}
