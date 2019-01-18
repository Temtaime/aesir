module perfontain.misc.draw;

import
		core.stdc.stdlib,

		perfontain,
		perfontain.opengl;


final class DrawAllocator : RCounted
{
	this(ubyte type)
	{
		iv = new IndexVertex(type);
	}

	void draw(Program pg, in DrawInfo[] nodes, uint submeshes)
	{
		_drawnNodes = cast(uint)nodes.length;
		_drawnTriangles = 0;

		pg.bind;
		iv.bind;

		if(GL_ARB_shader_draw_parameters)
		{
			uint k;

			auto counts = ScopeArray!uint(submeshes);
			auto starts = ScopeArray!size_t(submeshes);

			foreach(ref n; nodes)
			{
				auto mh = n.mh;
				auto reg = mh.reg;

				auto off = reg.index.start;
				auto subs = mh.meshes[n.id].subs;

				assert(GL_ARB_bindless_texture || subs.length == 1);

				foreach(ref sm; subs)
				{
					counts[k] = sm.len;
					starts[k++] = off + sm.start * 4;

					_drawnTriangles += sm.len / 3;
				}
			}

			assert(k == submeshes);
			glMultiDrawElements(GL_TRIANGLES, counts[].ptr, GL_UNSIGNED_INT, cast(void**)starts[].ptr, submeshes);
		}
		else
		{
			foreach(i, ref n; nodes)
			{
				pg.send(`pe_object_id`, cast(uint)i);

				auto mh = n.mh;
				auto sm = mh.meshes[n.id].subs.ptr;

				_drawnTriangles += sm.len / 3;

				glDrawElements(GL_TRIANGLES, sm.len, GL_UNSIGNED_INT, cast(void*)(mh.reg.index.start + sm.start * 4));
			}
		}
	}

	RC!IndexVertex iv;
private:
	mixin publicProperty!(uint, `drawnNodes`);
	mixin publicProperty!(uint, `drawnTriangles`);
}
