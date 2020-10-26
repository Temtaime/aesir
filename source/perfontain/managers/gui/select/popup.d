module perfontain.managers.gui.select.popup;

import
		std.array,
		std.algorithm,

		perfontain;


// abstract class PopupSelect : GUIElement
// {
// 	this(GUIElement[] arr, Vector2s sz)
// 	{
// 		super(PE.gui.root);

// 		if(sz.x < 0)
// 		{
// 			sz.x = arr.map!(a => a.size.x).fold!max;
// 		}

// 		if(sz.y < 0)
// 		{
// 			sz.y = arr.map!(a => a.size.y).fold!max;
// 		}

// 		pos = PE.window.mpos;
// 		size = Vector2s(sz.x + 4, sz.y * arr.length);

// 		{
// 			/*auto sc = new class Selector
// 			{
// 				override void select(int idx)
// 				{
// 					onSelect(cast(short)idx);
// 					deattach;
// 				}
// 			};

// 			foreach(i, c; arr)
// 			{
// 				auto v = allocateRC!SelectableItem(this, sc);

// 				{
// 					auto e = allocateRC!GUIElement(v);
// 					e.pos.x = 2;

// 					e.childs ~= c;
// 				}

// 				v.idx = cast(uint)i;
// 				v.size = Vector2s(size.x, c.size.y);

// 				v.pos.y = cast(short)(i * sz.y);
// 			}*/
// 		}

// 		focus;
// 	}


// 	override void onFocus(bool b)
// 	{
// 		if(!b)
// 		{
// 			deattach;
// 		}
// 	}

// 	void delegate(int) onSelect;
// }
