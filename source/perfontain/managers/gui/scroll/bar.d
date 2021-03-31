module perfontain.managers.gui.scroll.bar;

import
		std,

		perfontain;


final:

class Scrollbar //: GUIElement
{
	this(){}
	// this(Scrolled sc)
	// {
	// 	super(sc, Vector2s.init, Win.captureFocus);

	// 	auto up = new GUIImage(this, SCROLL_ARROW);
	// 	size = Vector2s(up.size.x, sc.size.y);

	// 	auto down = new GUIImage(this, SCROLL_ARROW, DRAW_MIRROR_V);
	// 	down.moveY(POS_MAX);

	// 	up.action({ sc.onWheel(1.Vector2s); });
	// 	down.action({ sc.onWheel(-1.Vector2s); });

	// 	new class GUIElement
	// 	{
	// 		this()
	// 		{
	// 			super(this.outer, Vector2s.init, Win.captureFocus);

	// 			poseBetween(up, down);
	// 			new Scrollpart(this);
	// 		}

	// 		override void onPress(Vector2s p, bool v)
	// 		{
	// 			if(v)
	// 			{
	// 				part.pos.y = cast(short)clamp(p.y - part.size.y / 2, 0, size.y - part.size.y);
	// 				part.onMoved;
	// 			}
	// 		}

	// 		mixin MakeChildRef!(Scrollpart, `part`, 0);
	// 	};
	// }
}
