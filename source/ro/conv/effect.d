module ro.conv.effect;
import std.uni, std.digest.md, std.math, std.array, std.stdio, std.algorithm, perfontain, perfontain.misc,
	perfontain.mesh, perfontain.math, ro.grf, ro.conf, ro.map, ro.str, ro.conv;

class AafConverter : Converter!AafFile
{
	this(string name)
	{
		_str = PEfs.read!StrFile(`data/texture/effect/` ~ name ~ `.str`);

		foreach (ref r; _str.layers)
		{
			r.anims.sort!((a, b) => a.frame < b.frame, SwapStrategy.stable);
		}

		super(name.md5Of);
	}

	override AafFile process()
	{
		AafFile res;
		StrFramePart[][] frames;

		foreach (key; 0 .. _str.maxKey)
		{
			StrFramePart[] arr;

			foreach (ref r; _str.layers)
			{
				StrAnimation p;

				if (calcAnim(r, key, p))
				{
					Vertex[4] vs;

					vs[0].p = Vector3(p.xy[0], p.xy[4], 0);
					vs[1].p = Vector3(p.xy[1], p.xy[5], 0);
					vs[2].p = Vector3(p.xy[3], p.xy[7], 0);
					vs[3].p = Vector3(p.xy[2], p.xy[6], 0);

					Matrix4 m;
					p.pos -= 320;

					m = Matrix4.rotate(0, 0, p.angle / 1024 * 360 * TO_RAD);
					m *= Matrix4.translate(p.pos.x, p.pos.y, 0);
					m *= Matrix4.scale(SPRITE_PROP, -SPRITE_PROP, 1);

					foreach (i, ref v; vs)
					{
						v.p *= m;
						v.t = [Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(1, 1)][i]; // p.uv[i];
					}

					Color c;

					foreach (i, ref v; c.tupleof)
					{
						v = cast(ubyte)clamp(cast(uint)p.color[i], 0, 255);
					}

					auto tex = RoPath(`data/texture/effect/`, r.texs[cast(uint)p.animTex].name);

					auto mode = packModes(cast(ubyte)p.srcAlpha, cast(ubyte)p.dstAlpha);

					if (!arr.length || arr.back.c != c || arr.back.mode != mode)
					{
						arr ~= StrFramePart(c, mode);
					}

					arr.back.mesh.add(this, tex, vs.toInts);
				}
			}

			//auto k = arr.length;

			{
				StrFramePart[] tmp;

				foreach (ref p; arr)
				{
					if (tmp.length)
					{
						auto b = &tmp.back;

						if (b.mesh == p.mesh && b.mode == p.mode)
						{
							b.c += p.c;
							continue;
						}
					}

					tmp ~= p;
				}

				arr = tmp;
			}

			//writefln(`draw calls : %s`, arr.map!(a => a.mode).array.sort().uniq.array.length);

			//if(k != arr.length)
			//	writefln(`%s -> %s`, k, arr.length);

			frames ~= arr;
		}

		MeshInfo[] meshes;

		{
			auto ms = frames.map!(a => a.map!(b => b.mesh).array).join.sort().uniq.array;

			foreach (arr; frames)
			{
				AafFrame f;

				foreach (ref p; arr)
				{
					auto idx = cast(short)ms.countUntil(p.mesh);
					assert(idx >= 0);

					f.anims ~= AafAnim(p.c, idx, p.mode);
				}

				res.frames ~= f;
			}

			foreach (ref m; ms)
			{
				SubMeshInfo[] ss;

				foreach (ref s; m.subs)
				{
					SubMeshInfo sm = {tex: s.tex};

					auto vertices = s.vss.intsToType!Vertex;

					foreach (i; 0 .. cast(uint)vertices.length / 4)
					{
						uint[6] ds;

						ds[0 .. 3] = triangleOrderReversed[];
						ds[3 .. $] = triangleOrder[] + 1;

						ds[] += i * 4;

						{
							auto n = calcNormal(vertices[ds[0]].p, vertices[ds[1]].p, vertices[ds[2]].p);

							if (n.z < 0)
							{
								ds[].reverse(); // TODO: WATTA HELL ???
							}
						}

						sm.data.indices ~= ds;
					}

					sm.data.vertices = vertices.toByte;
					ss ~= sm;
				}

				meshes ~= ss.MeshInfo;
			}
		}

		assert(_str.fps < 256);
		res.fps = cast(ubyte)_str.fps;

		//meshes.length.writeln;

		res.data = new AtlasHolderCreator(meshes, RENDER_SCENE, MH_DXT).process; //HolderCreator(meshes, RENDER_GUI, MH_ATLAS).process;
		return res;
	}

private:
	bool calcAnim(in StrLayer r, uint key, ref StrAnimation p)
	{
		short fromId = -1, toId = -1, lastSource, lastFrame;

		foreach (i, ref a; r.anims)
		{
			assert(a.frame >= 0);

			if (a.frame <= key)
			{
				final switch (a.type)
				{
				case 0:
					fromId = cast(short)i;
					break;
				case 1:
					toId = cast(short)i;
				}
			}

			lastFrame = max(lastFrame, cast(short)a.frame);

			if (!a.type)
			{
				lastSource = max(lastSource, cast(short)a.frame);
			}
		}

		// nothing to render
		if (fromId < 0 || (toId < 0 && lastFrame < key))
		{
			return false;
		}

		auto from = &r.anims[fromId];
		float delta = key - from.frame;

		p.srcAlpha = from.srcAlpha;
		p.dstAlpha = from.dstAlpha;

		p.pos = from.pos;
		p.angle = from.angle;
		p.color = from.color;

		p.uv = from.uv;
		p.xy = from.xy;

		p.animTex = from.animTex;

		// static frame (or frame that can't be updated)
		/*if(toId != fromId + 1 || r.anims[toId].frame != from.frame)
			return toId < 0 || lastSource > from.frame;*/

		if (toId != fromId + 1 || toId >= 0 && r.anims[toId].frame != from.frame)
		{
			// No other source
			if (toId >= 0 && lastSource <= from.frame)
			{
				return false;
			}

			return true;
		}

		auto to = &r.anims[toId];

		p.uv[] += to.uv[] * delta;
		p.xy[] += to.xy[] * delta;

		p.pos += to.pos * delta;
		p.angle += to.angle * delta;
		p.color += to.color * delta;

		switch (to.animType)
		{
		case 1: // normal
			p.animTex = from.animTex + to.animTex * delta;
			break;

		case 2: // stop at end
			p.animTex = min(from.animTex + to.delay * delta, r.texs.length - 1);
			break;

		case 3: // repeat
			p.animTex = (from.animTex + to.delay * delta) % r.texs.length;
			break;

		case 4: // play reverse infinitly
			p.animTex = (from.animTex - to.delay * delta) % r.texs.length;
			break;

		default: // bug fix
			p.animTex = 0;
		}

		return true;
	}

	struct StrFramePart
	{
		Color c;
		ubyte mode;

		StrMesh mesh;
	}

	struct StrSubMesh
	{
		Image tex;
		int[] vss;
	}

	struct StrMesh
	{
		const opCmp(in StrMesh m)
		{
			if (subs.length != m.subs.length)
				return cast(int)subs.length - cast(int)m.subs.length;

			foreach (i, ref s; subs)
			{
				auto o = &m.subs[i];

				if (s.tex !is o.tex)
					return cast(long)cast(void*)s.tex - cast(long)cast(void*)o.tex < 0 ? -1 : 1;

				auto r = s.vss.cmp(o.vss);

				if (r)
					return r;
			}

			return 0;
		}

		void add(AafConverter conv, RoPath s, int[] vs)
		{
			auto im = conv.imageOf(s);
			auto idx = cast(int)subs.countUntil!(a => a.tex is im);

			if (idx < 0)
			{
				subs ~= StrSubMesh(im, vs);
			}
			else
			{
				subs[idx].vss ~= vs;
			}
		}

		StrSubMesh[] subs;
	}

	StrFile _str;
}

private:

struct StrFile
{
	static immutable
	{
		char[4] bom = `STRM`;
		uint ver = 0x94;
	}

	uint fps, maxKey, layersCount;

	@(Skip!(_ => 16), ArrayLength!(e => e.that.layersCount)) StrLayer[] layers;
}

struct StrLayer
{
	@(ArrayLength!uint) StrTexture[] texs;
	@(ArrayLength!uint) StrAnimation[] anims;
}

struct StrTexture
{
	@(ArrayLength!(_ => 128), ZeroTerminated) const(ubyte)[] name; // VERIFY LENGTH
}

struct StrAnimation
{
	int frame;
	uint type;

	Vector2 pos;
	float[8] uv, xy;

	float animTex;
	uint animType;

	float delay;
	float angle; // angle / (1024 / 360)

	Vector4 color;
	uint srcAlpha, dstAlpha, mtpReset;
}
