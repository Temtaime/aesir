module perfontain.meshholder.atlas;

import std.range, std.algorithm, perfontain, stb.rectpack, stb.rectpack.binding;

final class AtlasHolderCreator : HolderCreator
{
	this(in MeshInfo[] meshes, ubyte type, ubyte flags = 0)
	{
		super(meshes, type, flags);
	}

protected:
	override void makeData(ref HolderData res)
	{
		makeAtlasTexture(res);

		foreach (ref m; _meshes)
			with (res)
			{
				auto start = cast(uint)data.indices.length;
				processSubMeshes(data, m);

				auto sm = HolderSubMesh(cast(uint)data.indices.length - start, start);
				meshes ~= [sm].HolderMesh;
			}
	}

private:
	enum ATLAS_PAD = 2; // doubled, so it's 4

	void processSubMeshes(ref SubMeshData data, in MeshInfo m)
	{
		foreach (ref s; m.subs)
		{
			auto len = data.indices.length;

			data.indices ~= s.data.indices;
			data.indices[len .. $][] += cast(uint)data.vertices.length / _vsize;

			auto vs = s.data.vertices.as!float.chunks(_vsize / 4);

			foreach (v; vs)
			{
				auto c = calcCoords(s.tex, *cast(Vector2*)&v[$ - 2]);

				data.vertices ~= v[0 .. $ - 2].toByte;
				data.vertices ~= c.toByte;
			}
		}
	}

	void makeAtlasTexture(ref HolderData f)
	{
		Vector2s sz;

		auto rgb = !(_flags & MH_DXT);
		auto data = new stbrp_rect[_texs.length];

		{
			uint sq;
			auto func = rgb ? (int a) => cast(ushort)a : (int a) => alignTo(cast(ushort)a, 4);

			foreach (i, ref s; data)
			{
				s.id = cast(uint)i;

				s.w = func(_texs[i].w + ATLAS_PAD * 2);
				s.h = func(_texs[i].h + ATLAS_PAD * 2);

				sq += s.w * s.h;
			}

			sz = Vector2s(TexturePacker(data).process.expand);
			logger.info!`texture atlas usage is %.4g, size is %ux%u`(sq / float(sz.x * sz.y), sz.x, sz.y);
		}

		auto atlas = new Image(sz.x, sz.y, null);

		foreach (r, im; zip(data, _texs.indexed(data.map!(a => a.id))))
		{
			assert(rgb || !(r.x & 3) && !(r.y & 3));

			auto u = r.x + ATLAS_PAD, v = r.y + ATLAS_PAD;

			atlas.blit(im, u, v);

			// left line
			ATLAS_PAD.iota.each!(a => atlas.blit(im.subImage(0, 0, 1, im.h), r.x + a, v));

			// right line
			iota(r.w - im.w - ATLAS_PAD).each!(a => atlas.blit(im.subImage(im.w - 1, 0, 1, im.h), u + im.w + a, v));

			// top
			ATLAS_PAD.iota.each!(a => atlas.blit(atlas.subImage(r.x, v, r.w, 1), r.x, r.y + a));

			// bottom
			iota(r.h - im.h - ATLAS_PAD).each!(a => atlas.blit(atlas.subImage(r.x, v + im.h - 1, r.w, 1), r.x, v + im.h + a));

			Vector4 q;

			q.x = float(u) / sz.x;
			q.y = float(v) / sz.y;

			q.z = float(im.w) / sz.x;
			q.w = float(im.h) / sz.y;

			_coords[im] = q;
		}

		debug
		{
			atlas.saveToFile(`atlas.png`);
		}

		add(f, atlas, false);
	}

	auto calcCoords(in Image tex, Vector2 t)
	{
		auto v = _coords[tex];

		t.x = v.x + v.z * clamp(t.x, 0, 1);
		t.y = v.y + v.w * clamp(t.y, 0, 1);

		return t;
	}

	Vector4[const Image] _coords;
}
