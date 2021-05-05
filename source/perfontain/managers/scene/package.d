module perfontain.managers.scene;

import std.math, std.stdio, std.array, std.typecons, std.algorithm, stb.image,

	perfontain, perfontain.math, perfontain.misc, perfontain.misc.draw,
	perfontain.misc.vmem, perfontain.opengl, perfontain.math.frustum, perfontain.managers.shadow;

public import perfontain.render.types, perfontain.managers.scene.structs;

final class SceneManager
{
	this()
	{
		PE.onMove.permanent(&traceRay); // TODO: REMOVE

		PE.settings.fogChange.permanent(_ => onUpdate);
		PE.settings.lightsChange.permanent(_ => onUpdate);

		glClearColor(1, 0, 1, 0);
	}

	~this()
	{
		scene = null;
	}

	void onUpdate()
	{
		_prog = null;
	}

	@property
	{
		CameraBase camera()
		{
			return _camera;
		}

		void camera(CameraBase camera)
		{
			_camera = camera;
			PE.window.cursor = _camera.cursor;
		}

		Scene scene()
		{
			return _scene;
		}

		void scene(Scene sc)
		{
			_prog = null;
			_scene = sc;
		}

		auto ray()
		{
			return Tuple!(Vector3, `pos`, Vector3, `dir`)(_ray.front, _ray.back);
		}

		bool hasLights()
		{
			return _scene.lights.length && level == Lights.full;
		}

		ref viewProject() const
		{
			return _vp;
		}
	}

	Matrix4 proj;
private:
	static level()
	{
		return PE.settings.lights;
	}

	void compile()
	{
		auto full = hasLights;

		{
			auto creator = ProgramCreator(`draw`);

			{
				auto s = PE.shadows;

				if (PE.settings.shadows)
				{
					creator.define(`SHADOWS_ENABLED`);
				}

				if (s.normals || level)
				{
					creator.define(`LIGHT_DIR`, _scene.lightDir);
				}

				if (s.normals)
				{
					creator.define(`SHADOWS_USE_NORMALS`);
				}
			}

			if (level)
			{
				creator.define(`LIGHTING_ENABLED`);

				creator.define(`LIGHT_AMBIENT`, _scene.ambient);
				creator.define(`LIGHT_DIFFUSE`, _scene.diffuse);

				if (full)
				{
					creator.define(`LIGHTING_FULL`);
				}
			}

			if (PE.settings.fog)
			{
				creator.define(`USE_FOG`);
				creator.define(`FOG_FAR`, _scene.fogFar);
				creator.define(`FOG_NEAR`, _scene.fogNear);
				creator.define(`FOG_COLOR`, _scene.fogColor);
			}

			_prog = creator.create;
		}

		if (full)
		{
			ubyte[] buf;

			foreach (ref r; _scene.lights)
			{
				auto v = Vector4(r.pos, r.range), u = Vector4(r.color, 0);

				buf ~= v.toByte;
				buf ~= u.toByte;
			}

			_prog.ssbo(`pe_lights`, buf, false);
			_prog.ssbo(`pe_lights_raw`, _scene.lightIndices.map!(a => int(a)).array, false);
		}
	}

package(perfontain):

	//const lightsReallyFull() { return _lights == LIGHTS_FULL && _scene.lights.length; }

	RC!Program _geometry;
	RC!RenderTarget _gbuffer;
	RC!Texture _ind;

	void makePrepass()
	{
		{
			auto creator = ProgramCreator(`geometry`);

			_geometry = creator.create;
		}

		{
			auto creator = ProgramCreator(`draw`);

			creator.define(`LIGHT_DIR`, _scene.lightDir);
			creator.define(`LIGHT_AMBIENT`, _scene.ambient);
			creator.define(`LIGHT_DIFFUSE`, _scene.diffuse);

			_prog = creator.create;

			ubyte[] buf;

			foreach (ref r; _scene.lights)
			{
				auto v = Vector4(r.pos, r.range), u = Vector4(r.color, 0);

				buf ~= v.toByte;
				buf ~= u.toByte;
			}

			_prog.ssbo(`pe_lights`, buf, false);
			//_prog.send(`posMap`, 0);
			//_prog.send(`colorMap`, 1);
			//_prog.send(`normalMap`, 2);
		}

		{
			auto creator = ProgramCreator(`light`);

			_comp = creator.create;

			ubyte[] buf;

			foreach (ref r; _scene.lights)
			{
				auto v = Vector4(r.pos, r.range);
				buf ~= v.toByte;
			}

			_comp.ssbo(`pe_lights`, buf, false);
		}

		auto s = PEsamplers.shadowMap;

		_gbuffer = new RenderTarget;

		auto tex = new Texture(TEX_SHADOW_MAP, PEwindow._size, s);
		_gbuffer.add(GL_DEPTH_ATTACHMENT, tex);

		_ind = new Texture(TEX_RED_UINT, PEwindow._size, s);

		_gbuffer.finish;
	}

	RC!Program _comp;

	void draw()
	{
		glDisable(GL_BLEND);
		glEnable(GL_DEPTH_TEST);
		glDepthMask(true);

		if (_scene)
		{
			if (!_geometry)
			{

				makePrepass;
			}
		}

		draw(_geometry, _gbuffer, _camera.view * proj);

		if (false)
		{
			int maxX, maxY, maxZ, maxItemsPerGroup;

			glGetIntegeri_v(GL_MAX_COMPUTE_WORK_GROUP_SIZE, 0, &maxX);
			glGetIntegeri_v(GL_MAX_COMPUTE_WORK_GROUP_SIZE, 1, &maxY);
			glGetIntegeri_v(GL_MAX_COMPUTE_WORK_GROUP_SIZE, 2, &maxZ);
			glGetIntegerv(GL_MAX_COMPUTE_WORK_GROUP_INVOCATIONS, &maxItemsPerGroup);

			logger(`%s %s %s %s`, maxX, maxY, maxZ, maxItemsPerGroup);
		}

		{
			//auto t = TimeMeter(`processing lights`);
			//uint query;
			//glGenQueries(1, &query);
			//glBeginQuery(GL_TIME_ELAPSED_EXT, query);

			_comp.bind;

			//_ind.bind(0);
			glBindImageTexture(0, _ind.id, 0, false, 0, GL_WRITE_ONLY, GL_R32UI);

			_comp.send(`proj_view_inversed`, (camera.view * proj).inversed);
			_gbuffer.attachments[0].bind(0);
			//glBindImageTexture(1, _gbuffer.attachments[0].id, 0, false, 0, GL_WRITE_ONLY, GL_R32F);

			enum N = 32;

			Vector2s sz = _ind.size;
			sz += N - 1;
			sz /= N;

			glDispatchCompute(sz.x, sz.y, 1);

			glMemoryBarrier(GL_TEXTURE_FETCH_BARRIER_BIT);

			/*glEndQuery(GL_TIME_ELAPSED_EXT);

			while (true)
			{
				int done;

				glGetQueryObjectivEXT(query, GL_QUERY_RESULT_AVAILABLE, &done);

				if (done)
					break;
			}

			ulong time;
			glGetQueryObjectui64vEXT(query, GL_QUERY_RESULT, &time);

			logger(`%u ms`, time / 1000000);*/

			//glMemoryBarrier(GL_SHADER_IMAGE_ACCESS_BARRIER_BIT);
		}

		//_comp.unbind;

		_ind.bind(1);

		//_ind.bind(0);
		//_ind.toImage.saveToFile(`res_gg.png`);
		//PE.quit;

		//auto t2 = TimeMeter(`processing draw`);

		draw(_prog, null, _camera.view * proj);
	}

	void draw2()
	{
		if (_scene)
		{
			if (!_prog)
				compile;
		}

		draw(_prog, null, _camera.view * proj);
	}

	void draw(Program pg, RenderTarget rt, in Matrix4 vp)
	{
		_vp = vp;
		_culler = FrustumCuller(vp);

		{
			auto flags = GL_DEPTH_BUFFER_BIT; //GL_DEPTH_BUFFER_BIT;

			if (rt)
			{
				rt.bind;
			}
			else
			{
				flags |= GL_COLOR_BUFFER_BIT;
			}

			//PEstate.viewPort = rt ? rt._tex.size : PEwindow._size;
			PEstate.viewPort = PEwindow._size;
			PEstate.depthMask = true; // enable to clear depth buffer

			glClear(flags);
		}

		if (_scene)
		{
			DrawInfo di;
			_scene.node.draw(&di);

			PE.render.doDraw(pg, RENDER_SCENE, vp, rt);
		}

		if (rt)
		{
			rt.unbind;
		}
	}

	auto traceRay(Vector2s pos)
	{
		auto sz = PEwindow._size;
		pos.y = cast(short)(sz.y - pos.y - 1);

		auto v1 = unproject(pos.x, pos.y, -1, _vp, sz);
		auto v2 = unproject(pos.x, pos.y, 1, _vp, sz);

		_ray[0] = v1;
		_ray[1] = (v2 - v1).normalize;
	}

	RC!Program _prog;
	RC!CameraBase _camera;
	RC!Scene _scene;

	Matrix4 _vp;
	FrustumCuller _culler;

	Vector3[2] _ray;
}
