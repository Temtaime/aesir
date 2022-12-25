module perfontain.managers.scene.renderdata;
import std, perfontain, perfontain.opengl.functions;

class SceneRenderData : RCounted
{
	this(Scene sc)
	{
		const lightsFull = PE.settings.lights == Lights.full && sc.lights;

		Texture texShadowsDepth;

		if (PE.settings.shadows)
		{
			auto creator = ProgramCreator(ProgramSource.depth);

			if (PE.shadows.textured)
			{
				creator.define(`TEXTURED`);
			}

			_shadowsDepthProg = creator.create;

			{
				auto s = PEsamplers.shadowMap;
				texShadowsDepth = new Texture(TEX_SHADOW_MAP, PE.shadows.texSize, s);

				_shadowsDepth = new RenderTarget(texShadowsDepth, null);
			}
		}

		{
			auto creator = ProgramCreator(ProgramSource.draw);

			if (PE.settings.lights)
			{
				creator.define(`LIGHTING_ENABLED`);
				creator.define(`LIGHT_DIR`, sc.lightDir);
				creator.define(`LIGHT_AMBIENT`, sc.ambient);
				creator.define(`LIGHT_DIFFUSE`, sc.diffuse);

				if (lightsFull)
					creator.define(`LIGHTING_FULL`);
			}

			if (PE.settings.fog)
			{
				creator.define(`USE_FOG`);
				creator.define(`FOG_FAR`, sc.fogFar);
				creator.define(`FOG_NEAR`, sc.fogNear);
				creator.define(`FOG_COLOR`, sc.fogColor);
			}

			debug
			{
			}
			else
				with (sc.fogColor)
					glClearColor(x, y, z, 0);

			if (PE.settings.shadows)
				creator.define(`SHADOWS_ENABLED`);

			_draw = creator.create;
		}

		if (texShadowsDepth)
		{
			_draw.add(ShaderTexture.shadows_depth, texShadowsDepth);
		}

		if (lightsFull)
		{
			_depth = ProgramCreator(ProgramSource.depth).create;
			_compute = ProgramCreator(ProgramSource.light_compute).create;

			VertexBuffer vbo = new VertexBuffer;
			{
				ubyte[] data;

				foreach (ref r; sc.lights)
				{
					auto v = Vector4(r.pos, r.range), u = Vector4(r.color, 0);

					data ~= v.toByte;
					data ~= u.toByte;
				}

				vbo.realloc(data);
			}

			_draw.add(ShaderBuffer.lights, vbo);
			_compute.add(ShaderBuffer.lights, vbo);

			{
				auto s = PEsamplers.shadowMap;

				{
					auto tex = new Texture(TEX_SHADOW_MAP, PEwindow._size, s);
					_lightsDepth = new RenderTarget(tex, null);

					_compute.add(ShaderTexture.lights_depth, tex);
				}

				_ind = new Texture(TEX_RED_UINT, PEwindow._size, s);
			}
		}
	}

	Texture lightsIndices() => _ind;
	RenderTarget lightsDepth() => _lightsDepth;

	Program progDraw() => _draw;
	Program progLightsDepth() => _depth;
	Program progLightsCompute() => _compute;

	Program progShadowsDepth() => _shadowsDepthProg;
	RenderTarget shadowsDepth() => _shadowsDepth;

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

		logger.msg!`Workgroup capacity: [ %u %u %u ], max invocations: %u`(x, y, z, maxInvocations);
		logger.msg!`Using blocks of %ux%1$u size`(k);

		return k;
	}

	__gshared ushort _block;

	RC!Texture _ind;
	RC!RenderTarget _lightsDepth, _shadowsDepth;
	RC!Program _draw, _compute, _depth, _shadowsDepthProg;
}
