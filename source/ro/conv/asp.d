module ro.conv.asp;
import std.conv, std.digest.md, std.math, std.path, std.file, std.stdio, std.range, std.string, std.algorithm,
	stb.image, perfontain, perfontain.nodes.sprite, perfontain.math.matrix, ro.grf, ro.conf, ro.conv, ro.sprite.spr,
	ro.sprite.act, ro.sprite.svg, rocl.game;

struct AspFile
{
	static immutable
	{
		char[3] bom = `ASP`;
		ubyte ver = 12;
	}

	Sprite spr;
	HolderData data;
}

final class AspConverter : Converter!AspFile
{
	this(RoPath name, RoPath palette, ubyte offset)
	{
		_name = name;
		_offset = offset;
		_palette = palette;

		super(RoPath(name, '\n', palette).data.md5Of);
	}

protected:
	override AspFile process()
	{
		{
			_act = ROfs.read!ActFile(RoPath(_name, `.act`));
			auto spr = ROfs.read!SprFile(RoPath(_name, `.spr`));

			if (_palette)
			{
				auto p = ROfs.get(RoPath(`data/palette/머리/머리`, _palette, `.pal`));

				if (p.length == 1024)
				{
					spr.palette = p.as!Color;
				}
			}

			spr.palette.front = colorTransparent;
			spr.palette[1 .. $].each!((ref c) => c.a = 255);

			_info = spr.toInfo;
		}

		Sprite spr = {
			events: _act.sounds.map!(a => SpriteEvent(a.path)).array, actions: _act.acts.enumerate.map!(a => makeAction(a.value,
					cast(uint)a.index)).array
		};

		AspFile res;

		res.data = new AtlasHolderCreator(_meshes, RENDER_SCENE, MH_DXT).process;
		res.spr = spr;

		return res;
	}

private:
	auto makeAction(in ActAction ac, uint idx)
	{
		SpriteAction res = {
			delay: cast(ushort)(_act.delays.length ? _act.delays[idx] * 25 : 150), frames: ac.frames.map!(a => makeFrame(a)).array
		};

		return res;
	}

	auto makeFrame(in ActFrame fr)
	{
		BBox box;
		SpriteFrame res;

		ushort idx = _offset;
		MeshInfo[Color] mc;

		foreach (ref s; fr.parts.filter!(a => a.idx >= 0))
		{
			auto v = _info.imageOf(s);

			Matrix4 m;
			bool mirror = s.flags & 1;

			{
				float mf = mirror ? -1 : 1;

				m = Matrix4.scale(v.im.w * s.sx, v.im.h * s.sy, 0);
				m *= Matrix4.rotate(0, 0, s.rot * TO_RAD * mf);
				m *= Matrix4.translate((s.x + v.x) * mf, s.y + v.y, idx++ * -0.01);
				m *= Matrix4.scale(-SPRITE_PROP * mf, -SPRITE_PROP, 1);
			}

			SubMeshInfo sub = {tex: v.im};

			with (sub.data)
			{
				foreach (i; 0 .. 2)
				{
					auto x = -0.5f * (-1) ^^ i;

					foreach (j; 0 .. 2)
					{
						auto y = -0.5f * (-1) ^^ j;

						auto e = Vertex(Vector3(x, y, 0) * m, Vector3.init, Vector2(i, j));
						vertices ~= e.toByte;
					}
				}

				indices = triangleOrder ~ triangleOrderReversed;
				indices[3 .. $] += 1;

				if (mirror)
				{
					reverse(indices);
				}

				box += BBox(asVertexes);
			}

			if (auto mesh = s.color in mc)
			{
				mesh.subs ~= sub;
			}
			else
			{
				mc[s.color] = [sub].MeshInfo;
			}
		}

		res.size = Vector4(box.min.xy, box.max.xy);

		foreach (c, ref m; mc)
		{
			res.images ~= SpriteImage(cast(ushort)_meshes.length, c);
			_meshes ~= m;
		}

		fr.eventId < cast(int)_act.sounds.length || throwError!`invalid event id = %d, max is %u`(fr.eventId, _act.sounds.length);

		res.event = cast(byte)max(-1, fr.eventId);
		res.extra = fr.hasExtra ? Vector2(fr.extra.pos) * -SPRITE_PROP : Vector2(_offset ? float.init : 0);

		return res;
	}

	RoPath _name, _palette;

	ActFile _act;
	ImageInfo _info;

	ubyte _offset;
	MeshInfo[] _meshes;
}
