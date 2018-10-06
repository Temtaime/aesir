module perfontain.managers.objects;

import
		std.typecons,

		perfontain;


final class ObjectsManager
{
	this()
	{
		{
			ubyte[4] arr = 255;
			quad = makeHolder(new Image(1, 1, arr));
		}
	}

	auto makeOb(TextureInfo ti, float xs = 0)
	{
		HolderData od =
		{
			type: RENDER_GUI
		};

		od.meshes ~= HolderMesh([ HolderSubMesh(6) ]);
		od.textures ~= ti;

		with(od.data)
		{
			indices = triangleOrderReversed ~ triangleOrder;
			indices[3..6][] += 1;

			auto vs =
			[
				Vector4(0, 0, xs, 0),
				Vector4(1, 0, 1,  0),
				Vector4(0, 1, xs, 1),
				Vector4(1, 1, 1,  1)
			];

			vertices = vs.toByte;
		}

		return new MeshHolder(od);
	}

	auto makeHolder(in Image im, float xs = 0)
	{
		auto d = im[];

		auto data =
		[
			TextureData(Vector2s(im.w, im.h), d.toByte)
		];

		return makeOb(TextureInfo(TEX_RGBA, data), xs);
	}

	RC!MeshHolder quad;
}
