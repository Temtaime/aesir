module perfontain.managers.render;

import
		std,

		perfontain,
		perfontain.opengl,
		perfontain.misc.draw;

public import
				perfontain.managers.render.drawinfo;


final class RenderManager
{
	this()
	{
		drawAlloc ~= new DrawAllocator(RENDER_GUI);
		drawAlloc ~= new DrawAllocator(RENDER_SCENE);
	}

	void toQueue(ref DrawInfo di)
	{
		_infos ~= di;
	}

	void doDraw(Program pg, ubyte tp, ref const(Matrix4) viewProj, RenderTarget rt, bool doSort = true)
	{
		_tp = tp;
		_pg = pg;
		_rt = rt;
		_viewProj = &viewProj;

		if(_infos.length)
		{
			auto ss = _infos[];

			if(doSort)
			{
				ss.sort!((a, b) => DrawInfo.cmp(a, b), SwapStrategy.stable);
			}

			process!(DrawInfo.cmp);
			_infos.clear;
		}
	}

	RCArray!DrawAllocator drawAlloc;
private:
	void process(alias F)()
	{
		auto index = &_infos[0];

		foreach(ref v, cnt; _infos[].group!((a, b) => F(a, b) == F(b, a)))
		{
			auto arr = index[0..cnt];
			index += cnt;

			PEstate.depthMask = !(v.flags & DI_NO_DEPTH);
			PEstate.blendingMode = v.blendingMode;

			drawNodes(arr);
		}
	}

	void drawNodes(in DrawInfo[] nodes)
	{
		uint subs;

		{
			auto fs = _pg.flags;
			auto start = fs & PROG_DATA_SM_MAT ? 64 : 0;

			auto len = _pg.minLen(`pe_transforms`) - start + 15;
			len &= ~15;

			auto tmp = ScopeArray!ubyte(len * nodes.length + start);

			if(fs & PROG_DATA_SM_MAT)
			{
				tmp[0..64][] = PE.shadows.matrix.toByte;
			}

			foreach(i, ref n; nodes)
			{
				auto sub = tmp[start + i * len..$][0..len].toByte;

				write(n, sub, fs);
				subs += n.mh.meshes[n.id].subs.length;
			}

			_pg.ssbo(`pe_transforms`, tmp[]);
		}

		if(GL_ARB_bindless_texture)
		{
			uint k;
			auto tmp = ScopeArray!ubyte(subs * 16);

			foreach(i, ref n; nodes)
			{
				auto m = &n.mh;
				auto r = cast(uint)i;

				foreach(ref sm; m.meshes[n.id].subs)
				{
					auto tex = m.texs[sm.tex];
					auto h = tex.handle;

					PE.textures.use(tex);

					tmp[k..k + 8][] = h.toByte;
					tmp[k + 8..k + 12][] = r.toByte;
					tmp[k + 12..k + 16][] = 0;

					k += 16;
				}
			}

			assert(k == tmp.length);

			_pg.ssbo(`pe_submeshes`, tmp[]);
		}
		else if(!_rt || PE.shadows.textured)
		{
			nodes[0].mh.texs[0].bind(0);
		}

		drawAlloc[_tp].draw(_pg, nodes, subs);
	}

	void write(ref in DrawInfo di, ubyte[] arr, ubyte flags)
	{
		uint p;

		auto add(T)(in T v)
		{
			uint
					a = T.sizeof <= 4 ? 4 : 16,
					n = (p + a - 1) / a * a;

			arr[p..n] = 0;
			arr[n..n + T.sizeof] = v.toByte;

			p = n;
			p += T.sizeof;
		}

		add(di.matrix * *_viewProj);

		if(flags & PROG_DATA_MODEL)
		{
			add(di.matrix);
		}

		if(flags & PROG_DATA_NORMAL)
		{
			add(di.matrix.inversed.transpose);
		}

		if(flags & PROG_DATA_COLOR)
		{
			add(di.color.toVec);
		}

		if(flags & PROG_DATA_LIGHTS)
		{
			add(di.lightStart);
			add(di.lightEnd);
		}

		arr[p..$] = 0;

		assert(arr.length == (p + 15) / 16 * 16);
	}

	// used only when draw called
	ubyte _tp;
	Program _pg;
	RenderTarget _rt;

	const(Matrix4) *_viewProj;

	Array!DrawInfo _infos;
}
