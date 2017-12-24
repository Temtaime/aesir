module rocl.controls.trading;

import
		perfontain,

		rocl;


final class WinTrading : WinBasic
{
	this()
	{
		{
			name = `trading`;
			super(Vector2s(290, 360), MSG_DEALING_WITH);
		}
	}
}
