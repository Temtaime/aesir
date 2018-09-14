module ro.conv.gui;

import
		std.experimental.all,

		perfontain,

		ro.conv,

		rocl.gui,
		rocl.game;


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

	@(`ubyte`, `validif`, `sizes.length == ` ~ EnumMembers!GUI.length) Vector2s[] sizes;
}
