module perfontain.managers.render;

import
		std.array,
		std.typecons,
		std.algorithm,

		core.stdc.stdlib,

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

	auto alloc()
	{
		if(_arr.length == _used)
		{
			_arr.length += 128;
		}

		return &(_arr[_used++] = DrawInfo.init);
	}

	void doDraw(Program pg, ubyte tp, ref const(Matrix4) viewProj, RenderTarget rt, bool doSort = true)
	{
		_tp = tp;
		_pg = pg;
		_rt = rt;
		_viewProj = &viewProj;

		auto sub = _arr[0.._used];

		if(sub.length)
		{
			if(doSort)
			{
				sub.sort!((ref a, ref b) => DrawInfo.cmp!true(a, b), SwapStrategy.stable);
			}

			if(GL_ARB_bindless_texture)
			{
				process!(DrawInfo.cmp!false)(sub);
			}
			else
			{
				process!(DrawInfo.cmp!true)(sub);
			}

			_used = 0;
		}
	}

	RCArray!DrawAllocator drawAlloc;
private:
	void process(alias F)(in DrawInfo[] index)
	{
		for(auto start = index.ptr, cur = start + 1; true; cur++)
		{
			bool end = cur > &index.back;

			if(end || F(*start, *cur) != F(*cur, *start))
			{
				auto sub = start[0..cur - start];

				{
					PEstate.depthMask = !(start.flags & DI_NO_DEPTH);
					PEstate.blendingMode = start.blendingMode;

					drawNodes(sub);
				}

				if(end)
				{
					break;
				}

				start = cur;
			}
		}
	}

	enum
	{
		DATA_MODEL		= 1,
		DATA_COLOR		= 2,
		DATA_NORMAL		= 4,
		DATA_LIGHTS		= 8,
		DATA_SM_MAT		= 16,
	}

	const calcFlags()
	{
		ubyte r;

		if(!_rt)
		{
			if(_tp == RENDER_SCENE)
			{
				if(PE.settings.shadows)
				{
					if(PE.shadows.normals)
					{
						r |= DATA_NORMAL;
					}

					r |= DATA_MODEL | DATA_SM_MAT;
				}

				if(PE.settings.lights)
				{
					if(PE.scene.hasLights)
					{
						r |= DATA_LIGHTS | DATA_MODEL;
					}

					r |= DATA_NORMAL;
				}
			}

			r |= DATA_COLOR;
		}

		return r;
	}

	void drawNodes(in DrawInfo[] nodes)
	{
		uint subs;

		{
			auto fs = calcFlags;
			auto start = fs & DATA_SM_MAT ? 64 : 0;

			auto len = _pg.minLen(`pe_transforms`) - start + 15;
			len = len / 16 * 16;

			auto tmp = ScopeArray!ubyte(len * nodes.length + start);

			if(fs & DATA_SM_MAT)
			{
				tmp[0..64][] = PE.shadows.matrix.toByte;
			}

			foreach(uint i, ref n; nodes)
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

			foreach(uint i, ref n; nodes)
			{
				auto m = &n.mh;

				foreach(ref sm; m.meshes[n.id].subs)
				{
					auto tex = m.texs[sm.tex];
					auto h = tex.handle;

					PE.textures.use(tex);

					tmp[k..k + 8][] = h.toByte;
					tmp[k + 8..k + 12][] = i.toByte;
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

		if(flags & DATA_MODEL)
		{
			add(di.matrix);
		}

		if(flags & DATA_NORMAL)
		{
			add(di.matrix.inversed.transpose);
		}

		if(flags & DATA_COLOR)
		{
			add(di.color.toVec);
		}

		if(flags & DATA_LIGHTS)
		{
			add(di.lightStart);
			add(di.lightEnd);
		}

		arr[p..$] = 0;

		//log(`%s %s`, arr.length, (p + 15) / 16 * 16);

		assert(arr.length == (p + 15) / 16 * 16);
	}

	// used only when draw called
	ubyte _tp;
	Program _pg;
	RenderTarget _rt;
	const(Matrix4) *_viewProj;

	// DI allocator
	uint _used;
	DrawInfo[] _arr;
}
