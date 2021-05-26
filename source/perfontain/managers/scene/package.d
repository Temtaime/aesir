module perfontain.managers.scene;
import std.math, std.stdio, std.array, std.typecons, std.algorithm, stb.image, perfontain, perfontain.math,
	perfontain.misc, perfontain.misc.draw, perfontain.misc.vmem, perfontain.opengl, perfontain.math.frustum,
	perfontain.managers.shadow, perfontain.managers.scene.renderdata;

public import perfontain.render.types, perfontain.managers.scene.structs;

final class SceneManager
{
	this()
	{
		PE.onMove.permanent(&traceRay); // TODO: REMOVE

		PE.settings.fogChange.permanent(_ => onUpdate);
		PE.settings.lightsChange.permanent(_ => onUpdate);

		debug
		{
			glClearColor(1, 0, 1, 0);
		}
	}

	~this()
	{
		scene = null;
	}

	void onUpdate()
	{
		_rd = null;
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
			_rd = null;
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

	/*void compile()
	{
		auto full = hasLights;

		version (none)
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
	}*/

package(perfontain):

	//const lightsReallyFull() { return _lights == LIGHTS_FULL && _scene.lights.length; }

	void draw()
	{
		//glDisable(GL_BLEND);
		//glEnable(GL_DEPTH_TEST);

		Program pg;
		_culler = FrustumCuller(_vp = _camera.view * proj);

		if (_scene)
		{
			if (_rd is null)
			{
				_rd = new SceneRenderData(_scene);
			}

			with (_rd)
			{
				if (auto rt = lightsDepth)
				{
					draw(progLightsDepth, rt);
					computeLights(lightsIndices, progLightsCompute, computeBlock);

					pg = progDraw;
				}
			}
		}

		draw(pg, null);
	}

	void computeLights(Texture tex, Program compute, ushort bs)
	{
		tex.imageBind(0, GL_WRITE_ONLY);

		compute.send(`proj_view_inversed`, _vp.inversed);
		compute.bind;

		{
			Vector2s sz = tex.size;

			sz += bs;
			sz -= 1;
			sz /= bs;

			glDispatchCompute(sz.x, sz.y, 1);
		}

		glMemoryBarrier(GL_TEXTURE_FETCH_BARRIER_BIT);
	}

	void clear(Vector2s size, bool color)
	{
		auto flags = GL_DEPTH_BUFFER_BIT;

		if (color)
			flags |= GL_COLOR_BUFFER_BIT;

		PEstate.viewPort = size;
		PEstate.depthMask = true; // otherwise depth clear won't work

		glClear(flags);
	}

	void draw(Program pg, RenderTarget rt)
	{
		if (rt)
			clear(rt.attachments[0].size, false); // rt.size, rt.hasColor
		else
			clear(PEwindow._size, true);

		if (_scene)
		{
			DrawInfo di;
			_scene.node.draw(&di);

			PE.render.doDraw(pg, RENDER_SCENE, _vp, rt);
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

	RC!Scene _scene;
	RC!CameraBase _camera;
	RC!SceneRenderData _rd;

	Matrix4 _vp;
	FrustumCuller _culler;

	Vector3[2] _ray;
}
