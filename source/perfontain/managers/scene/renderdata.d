module perfontain.managers.scene.renderdata;
import std, perfontain, perfontain.opengl.functions;

class SceneRenderData : RCounted
{
	this(Scene sc)
	{
		{
			auto creator = ProgramCreator(ProgramSource.light_depth);

			_depth = creator.create;
		}

		{
			auto creator = ProgramCreator(ProgramSource.draw);

			creator.define(`LIGHT_DIR`, sc.lightDir);
			creator.define(`LIGHT_AMBIENT`, sc.ambient);
			creator.define(`LIGHT_DIFFUSE`, sc.diffuse);

			_draw = creator.create;

			ubyte[] buf;

			foreach (ref r; sc.lights)
			{
				auto v = Vector4(r.pos, r.range), u = Vector4(r.color, 0);

				buf ~= v.toByte;
				buf ~= u.toByte;
			}

			_draw.ssbo(`pe_lights`, buf, false);
		}

		{
			auto creator = ProgramCreator(ProgramSource.light_compute);

			_compute = creator.create;

			ubyte[] buf;

			foreach (ref r; sc.lights)
			{
				auto v = Vector4(r.pos, r.range);
				buf ~= v.toByte;
			}

			_compute.ssbo(`pe_lights`, buf, false);
		}

		auto s = PEsamplers.shadowMap;

		_lightsDepth = new RenderTarget;

		{
			auto tex = new Texture(TEX_SHADOW_MAP, PEwindow._size, s);
			_lightsDepth.add(GL_DEPTH_ATTACHMENT, tex);

			_compute.add(ShaderTexture.depth, tex);
		}

		_ind = new Texture(TEX_RED_UINT, PEwindow._size, s);

		_draw.add(ShaderTexture.lights, _ind);

		_lightsDepth.finish;
	}

	Texture lightsIndices() => _ind;
	RenderTarget lightsDepth() => _lightsDepth;

	Program progDraw() => _draw;
	Program progLightsDepth() => _depth;
	Program progLightsCompute() => _compute;

	ushort computeBlock() => _block ? _block : (_block = blockSize);
private:
	ushort blockSize()
	{
		int x, y, z, maxInvocations;

		glGetIntegeri_v(GL_MAX_COMPUTE_WORK_GROUP_SIZE, 0, &x);
		glGetIntegeri_v(GL_MAX_COMPUTE_WORK_GROUP_SIZE, 1, &y);
		glGetIntegeri_v(GL_MAX_COMPUTE_WORK_GROUP_SIZE, 2, &z);
		glGetIntegerv(GL_MAX_COMPUTE_WORK_GROUP_INVOCATIONS, &maxInvocations);

		ushort k = 1;

		for (ushort next = 2, limit = cast(ushort)min(x, y); next <= limit && next * next <= maxInvocations; next *= 2)
		{
			k = next;
		}

		logger.msg!`Max invocations: %u`(maxInvocations);
		logger.msg!`Workgroup capacity: [ %u %u %u ]`(x, y, z);

		logger.msg!`Using blocks of %ux%1$u size`(k);
		return k;
	}

	__gshared ushort _block;

	RC!Texture _ind;
	RC!RenderTarget _lightsDepth;

	RC!Program _draw, _compute, _depth;
}
