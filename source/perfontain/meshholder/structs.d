module perfontain.meshholder.structs;

import
		perfontain;


struct HolderData
{
	const atlased()
	{
		return textures.length == 1;
	}

	ubyte type;
	SubMeshData data;

	@(`ushort`)
	{
		HolderMesh[] meshes;
		TextureInfo[] textures;
	}
}

struct HolderSubMesh
{
	uint
			len,
			start;

	ushort tex;
}

struct HolderMesh
{
	@(`ubyte`) HolderSubMesh[] subs;
}
