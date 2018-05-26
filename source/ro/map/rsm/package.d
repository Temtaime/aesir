module ro.map.rsm;

import
		std.conv,
		std.math,
		std.stdio,
		std.array,
		std.range,
		std.algorithm,
		std.exception,

		perfontain,
		perfontain.misc,

		ro.grf,
		ro.map,
		ro.conv,
		ro.conv.map,
		ro.map.rsm.structs;


struct RsmObject
{
	MeshInfo mesh;
	Matrix4 trans;

	RsmObject[] childs;
	FrameOrientation[] oris;
}

struct RsmConverter
{
	this(string name)
	{
		_rsm = PEfs.read!RsmFile(`data/model/` ~ name);
	}

	auto process()
	{
		auto n = _rsm.main.charsToString;

		_main = cast(int)_rsm
								.meshes
								.countUntil!((ref a) => a.name.charsToString == n);

		_main >= 0 || throwError(`cannot find main mesh`);

		auto m = &_rsm.meshes[_main];
		auto r = processMesh(*m, Matrix4.init);

		r.mesh.subs.length || throwError(`empty main mesh`);
		return r;
	}

private:
	alias VT = Vertex[][uint];

	auto makeVertices(ref in RsmMesh mesh)
	{
		VT vertices;

		//mesh.writeln;

		foreach(ref s; mesh.surs)
		{
			Vertex[3] tmp;

			foreach(i, vi; s.sv)
			{
				tmp[i].p = mesh.vertices[vi];
				tmp[i].t = mesh.texsInfo[s.tv[i]].t;
			}

			uint tid = mesh.texIds[s.texId];
			vertices[tid] ~= tmp;

			if(s.twoSided)
			{
				swap(tmp.front, tmp.back);
				vertices[tid] ~= tmp;
			}
		}

		return vertices;
	}

	auto makeSubs(VT vertices)
	{
		SubMeshInfo[] subs;

		foreach(tid, va; vertices)
		{
			SubMeshInfo sm =
			{
				tex: RomConverter.imageOf(`data/texture/` ~ _rsm.texs[tid].name.convertName)
			};

			with(sm.data)
			{
				vertices = va.toByte;
				indices = makeIndices(cast(uint)va.length / 3);

				clear;
			}

			subs ~= sm;
		}

		//subs.length || throwError(`no submeshes for a mesh`);
		return subs;
	}

	auto calcMatrices(ref in RsmMesh mesh, ref in Matrix4 pm)
	{
		struct Res
		{
			Matrix4		main,
						trans,
						boxTrans;
		}

		Res s;

		// main
		s.main = Matrix4(mesh.matrix);
		s.main *= Matrix4.translate(mesh.translate1); // TODO: !only

		auto scale = Matrix4.scale(mesh.scale);
		auto rot = Matrix4.rotateVector(mesh.axisVector, mesh.angle);
		auto tr = Matrix4.translate(mesh.translate2);

		if(mesh.frames.length && 0) // TODO: FIXME ?
		{
			s.main *= scale;
		}
		else
		{
			s.trans = scale;
		}

		// trans
		if(!mesh.frames.length)
		{
			s.trans *= rot;
		}

		s.trans *= tr;

		// box
		s.boxTrans = scale;
		s.boxTrans *= rot;
		s.boxTrans *= tr;

		s.boxTrans *= pm;
		return s;
	}

	RsmObject processMesh(ref RsmMesh mesh, in Matrix4 pm)
	{
		auto id = meshId(mesh);

		!_meshes.canFind(id) || throwError(`animated mesh cycle`);
		_meshes ~= id;

		auto vertices = makeVertices(mesh);
		auto ms = calcMatrices(mesh, pm);

		foreach(vs; vertices)
		{
			vs.each!((ref b) => b.p *= ms.main);
		}

		{
			auto m = ms.main * ms.boxTrans;
			_box += BBox(mesh.vertices.map!(a => a.p * m));
		}

		RsmObject res =
		{
			oris: mesh.frames,
			trans: ms.trans
		};

		res.mesh.subs = makeSubs(vertices);

		{
			auto name = mesh.name.charsToString;

			if(name != mesh.parent.charsToString)
			{
				res.childs = _rsm.meshes
										.filter!((ref a) => a.parent.charsToString == name && meshId(a) != _main)
										.map!((ref a) => processMesh(a, ms.boxTrans)) // ms.trans ???
										.array;

				while(true) with(res)
				{
					auto idx = childs.countUntil!((ref a) => !a.mesh.subs.length);

					if(idx < 0)
					{
						break;
					}

					!childs[idx].childs.length || throwError(`empty child with childs`);
					childs = childs.remove(idx);
				}
			}
		}

		if(id == _main)
		{
			res.trans *= Matrix4.translate(-Vector3(_box.center.x, _box.max.y, _box.center.z));
		}

		_meshes.popBack;
		return res;
	}

	auto meshId(ref in RsmMesh m)
	{
		auto r = cast(uint)(&m - _rsm.meshes.ptr);

		assert(r < _rsm.meshes.length);
		return r;
	}

	BBox _box;
	RsmFile _rsm;

	int _main;
	uint[] _meshes;
}
