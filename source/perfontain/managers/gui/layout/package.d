module perfontain.managers.gui.layout;
import std, perfontain;

public import perfontain.managers.gui.layout.tab;

class Layout : RCounted
{
	mixin Nuklear;

	final process()
	{
		styles.each!(a => a.push);
		draw;
		styles.retro.each!(a => a.pop);
	}

	void draw()
	{
		childs.each!(a => a.process);
	}

	Style[] styles;
	RCArray!GUIElement childs;
}

abstract class RowTemplateLayout : Layout
{
	this(uint height)
	{
		_height = height;
	}

	override void draw()
	{
		nk_layout_row_template_begin(ctx, _height);
		make;
		nk_layout_row_template_end(ctx);
		super.draw;
	}

protected:
	void make();

	void dynamic()
	{
		nk_layout_row_template_push_dynamic(ctx);
	}

	void variable(float width)
	{
		nk_layout_row_template_push_variable(ctx, width);
	}

	void static_(float width)
	{
		nk_layout_row_template_push_static(ctx, width);
	}

private:
	uint _height;
}

class RowLayout : Layout
{
	this(bool dynamic, uint height, uint[] widths...)
	{
		_height = height;
		_widths = widths;
		_dynamic = dynamic;
	}

	override void draw()
	{
		assert(childs.length == _widths.length);

		nk_layout_row_begin(ctx, _dynamic ? NK_DYNAMIC : NK_STATIC, _height,
				cast(uint) _widths.length);

		foreach (i, v; _widths)
		{
			nk_layout_row_push(ctx, v);
			childs[i].process;
		}

		nk_layout_row_end(ctx);
	}

private:
	uint[] _widths;
	uint _height;
	bool _dynamic;
}

class DynamicRowLayout : Layout
{
	this(uint cols, uint height = 0)
	{
		_cols = cols;
		_height = height;
	}

	override void draw()
	{
		nk_layout_row_dynamic(ctx, _height, _cols);
		super.draw;
	}

private:
	uint _cols, _height;
}

class StaticRowLayout : Layout
{
	this(uint cols, uint width, uint height = 0)
	{
		_cols = cols;
		_width = width;
		_height = height;
	}

	override void draw()
	{
		auto c = _cols ? _cols : max(cast(uint)(nk_window_get_content_region_size(ctx)
				.x / (_width + ctx.style.window.spacing.x)), 1);

		nk_layout_row_static(ctx, _height, _width, c);
		super.draw;
	}

private:
	uint _cols, _height, _width;
}
