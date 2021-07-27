module perfontain.meshholder;

import std, perfontain;

final class MeshHolder : RCounted
{
	this(ubyte type, in SubMeshData data)
	{
		_iv = PE.render.drawAlloc[type].iv;
		reg = _iv.alloc(data);
	}

	this(in HolderData v)
	{
		this(v.type, v.data);

		texs = v.textures.map!(a => new Texture(a)).array;

		meshes = v.meshes;
	}

	~this()
	{
		_iv.dealloc(reg);
	}

	const
	{
		RegionIV reg;
	}

	RCArray!Texture texs;
	const(HolderMesh)[] meshes;

	const size()
	{
		assert(texs.length == 1);
		return texs[0].size;
	}

private:
	IndexVertex _iv;
}
