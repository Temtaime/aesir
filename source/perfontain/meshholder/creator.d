module perfontain.meshholder.creator;

import
		std.range,
		std.algorithm,

		perfontain;

public import
		perfontain.meshholder.atlas,
		perfontain.meshholder.bindless;


enum
{
	MH_DXT = 1,
}

HolderCreator makeHolderCreator(in MeshInfo[] meshes, ubyte type, ubyte flags)
{
	if(PE.settings.useBindless)
	{
		return new BindlessHolderCreator(meshes, type, flags);
	}
	else
	{
		return new AtlasHolderCreator(meshes, type, flags);
	}
}

abstract class HolderCreator
{
	this(in MeshInfo[] meshes, ubyte type, ubyte flags)
	{
		_type = type;
		_meshes = meshes;

		_flags = flags;
		_vsize = _type.vertexSize;
	}

	final process()
	{
		HolderData res =
		{
			type: _type
		};

		foreach(m; _meshes)
		{
			assert(m.subs.length);

			foreach(ref s; m.subs)
			{
				assert(s.data.vertices.length);

				if(!(s.tex in _texIndex))
				{
					_texIndex[s.tex] = cast(ushort)_texIndex.length;
				}
			}
		}

		assert(_texIndex.length);
		makeData(res);

		if(_type == RENDER_SCENE) with(res)
		{
			foreach(i, ref m; meshes)
			{
				auto p = &m.subs.back;

				auto	a = m.subs.front.start,
						b = p.start + p.len;

				data.makeNormals(a, b, _meshes[i].ns);
			}

			res.data.minimize;
		}

		return res;
	}

protected:
	void makeData(ref HolderData);

	void add(ref HolderData res, in Image im, bool mipmaps)
	{
		res.textures ~= im.makeTexInfo(_flags & MH_DXT ? im.dxtTranspType : TEX_RGBA, mipmaps);
	}

	const
	{
		MeshInfo[] _meshes;

		ubyte	_type,
				_flags,
				_vsize;
	}

	ushort[const Image] _texIndex;
}
