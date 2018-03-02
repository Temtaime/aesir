module ro.conv.gui;

import
		std.conv,
		std.range,
		std.array,
		std.format,
		std.string,
		std.algorithm,

		perfontain,

		ro.conv,

		rocl.gui,
		rocl.game;


enum Elements =
[
	`WIN_TOP`,
	`WIN_TOP_SPACER`,
	`WIN_BOTTOM`,
	`WIN_BOTTOM_SPACER`,
	`WIN_PART`,

	`BTN_PART`,
	`BTN_SPACER`,
	`BTN_HOVER_PART`,
	`BTN_HOVER_SPACER`,

	`CHECKBOX`,
	`CHECKBOX_CHECKED`,

	`SCROLL_ARROW`,
	`SCROLL_PART`,
	`SCROLL_SPACER`,

	`SELECT_ARROW`,

	`CHAT_PART`,
	`CHAT_SPACER`,

	`NPC_WIN`,

	`INV_ITEM`,
	`INV_TAB_ITEM`,
	`INV_TAB_EQUIP`,
	`INV_TAB_ETC`,

	`TOOLTIP_PART`,
	`TOOLTIP_SPACER`,
];

mixin(
{
	string r;

	foreach(i, e; Elements)
	{
		r ~= `enum ` ~ e ~ ` = ` ~ i.to!string ~ `;`;
		r ~= `ref ` ~ e ~ `_SZ() @property { return PE.gui.sizes[` ~ i.to!string ~ `]; }`;
	}

	return r;
}
());

final class GuiConverter : Converter
{
	override const(void)[] process()
	{
		auto arr = Elements
							.map!(a => a.toLower)
							.map!(a => new Image(PEfs.get(`data/gui/` ~ a ~ `.png`)))
							.array;

		RogFile res =
		{
			data: makeData(arr),
			sizes: arr.map!(a => Vector2s(a.w, a.h)).array
		};

		return res.binaryWrite;
	}

private:
	auto makeData(Image[] arr)
	{
		MeshInfo[] meshes;

		foreach(i, ref e; Elements)
		{
			SubMeshInfo sm =
			{
				tex: arr[i]
			};

			sm.data.indices = triangleOrderReversed ~ triangleOrder; // TODO: order ???
			sm.data.indices[3..6] += 1;

			// back side
			sm.data.indices ~= sm.data.indices
												.retro
												.array;

			auto vs =
			[
				Vector4(0, 0, 0, 0),
				Vector4(1, 0, 1, 0),
				Vector4(0, 1, 0, 1),
				Vector4(1, 1, 1, 1),
			];

			sm.data.vertices = vs.toByte;
			meshes ~= [ sm ].MeshInfo;
		}

		return new AtlasHolderCreator(meshes, RENDER_GUI).process;
	}
}

struct RogFile
{
	static immutable
	{
		char[3] bom = `ROG`;
		ubyte ver = 1;
	}

	HolderData data;

	@(`ubyte`, `validif`, `sizes.length == ` ~ Elements.length.to!string) Vector2s[] sizes;
}
