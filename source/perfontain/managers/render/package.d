module perfontain.managers.render;
import std, perfontain, perfontain.opengl, perfontain.misc.draw;

public import perfontain.managers.render.drawinfo;

final class RenderManager
{
	this()
	{
		_transforms = new VertexBuffer(-1, VBO_DYNAMIC);

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

		if (_infos.length)
		{
			auto ss = _infos[];

			if (doSort)
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

		foreach (ref v, cnt; _infos[].group!((a, b) => F(a, b) == F(b, a)))
		{
			auto arr = index[0 .. cnt];
			index += cnt;

			PEstate.depthMask = !(v.flags & DI_NO_DEPTH);
			PEstate.blendingMode = v.blendingMode;

			drawNodes(arr);
		}
	}

	uint writeTransforms(in DrawInfo[] nodes)
	{
		uint subs;

		auto fs = _pg.flags;
		auto start = fs & PROG_DATA_SM_MAT ? 64 : 0;

		auto len = _pg.minLen(`pe_transforms`) - start + 15;
		len &= ~15;

		auto tmp = ScopeArray!ubyte(len * nodes.length + start);

		if (fs & PROG_DATA_SM_MAT)
		{
			tmp[0 .. 64][] = PE.shadows.matrix.toByte;
		}

		foreach (i, ref n; nodes)
		{
			auto sub = tmp[start + i * len .. $][0 .. len].toByte;

			write(n, sub, fs);
			subs += n.mh.meshes[n.id].subs.length;
		}

		auto data = tmp[];

		_transforms.realloc(data);
		_transforms.bind(ShaderBuffer.transforms); // force rebind to correct calculate buffer size in the shader

		return subs;
	}

	void drawNodes(in DrawInfo[] nodes) // one program and mesh holder
	{
		auto subs = writeTransforms(nodes);
		bool bind = _rt is null || PE.scene.shadowPass && PE.shadows.textured;

		drawAlloc[_tp].draw(_pg, nodes, subs, bind);
	}

	void write(in DrawInfo di, ubyte[] arr, ubyte flags)
	{
		uint p;

		auto add(T)(in T v)
		{
			uint a = T.sizeof <= 4 ? 4 : 16, n = (p + a - 1) / a * a;

			arr[p .. n] = 0;
			arr[n .. n + T.sizeof] = v.toByte;

			p = n;
			p += T.sizeof;
		}

		add(di.matrix * *_viewProj);

		if (flags & PROG_DATA_MODEL)
			add(di.matrix);

		if (flags & PROG_DATA_NORMAL)
			add(di.matrix.inversed.transpose);

		if (flags & PROG_DATA_COLOR)
			add(di.color.toVec);

		if (flags & PROG_DATA_SCISSOR)
			add(di.scissor.Vector4i);

		arr[p .. $] = 0;

		assert(arr.length == (p + 15) / 16 * 16);
	}

	RC!VertexBuffer _transforms;

	// used only when draw called
	ubyte _tp;
	Program _pg;
	RenderTarget _rt;

	const(Matrix4)* _viewProj;

	Array!DrawInfo _infos;
}
