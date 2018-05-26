module perfontain.meshholder;

import
		std.experimental.all,

		perfontain;


final class MeshHolder : RCounted
{
	this(ref in HolderData v)
	{
		_iv = PE.render.drawAlloc[v.type].iv;

		texs = v
					.textures
					.map!(a => new Texture(a))
					.array;

		meshes = v.meshes;
		reg = _iv.alloc(v.data);
	}

	~this()
	{
		_iv.dealloc(reg);
	}

	const
	{
		RegionIV reg;

		HolderMesh[] meshes;
		RCArray!Texture texs;
	}

private:
	IndexVertex _iv;
}
