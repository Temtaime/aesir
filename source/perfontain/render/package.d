module perfontain.render;

import perfontain, perfontain.misc.vmem;

struct RegionIV
{
	const(AllocRegion)* index, vertex;
}

final class IndexVertex : RCounted
{
	this(ubyte type)
	{
		_ia = new VMemAlloc(-1);
		_va = new VMemAlloc(type);
	}

	void bind()
	{
		if (_vao)
			_vao.bind;
		else
		{
			_vao = new ArrayBuffer;
			_vao.bind;

			_va.vbo.enable;
			_ia.vbo.enable;
		}
	}

	void unbind()
	{
		_vao.unbind;
	}

	auto alloc(in SubMeshData sd)
	{
		auto index = _ia.alloc(sd.indices.toByte);
		auto vertex = _va.alloc(sd.vertices.toByte);

		vertex.onMove = { index.value = vertex.start / _va.vbo.alignment; _ia.update(index); };

		vertex.onMove();
		_va.update(vertex);

		return RegionIV(index, vertex);
	}

	auto dealloc(in RegionIV r)
	{
		_ia.free(r.index);
		_va.free(r.vertex);
	}

	const type()
	{
		return _va.vbo.type;
	}

private:
	RC!VMemAlloc _ia, _va;

	RC!ArrayBuffer _vao;
}
