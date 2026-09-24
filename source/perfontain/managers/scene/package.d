module perfontain.managers.scene;
import std.math, std.stdio, std.array, std.typecons, std.algorithm, stb.image, perfontain, perfontain.math,
	perfontain.misc, perfontain.misc.draw, perfontain.misc.vmem, perfontain.math.frustum,
	perfontain.managers.shadow, perfontain.managers.scene.renderdata;

public import perfontain.render.types, perfontain.managers.scene.structs;

final class SceneManager
{
	this()
	{
		PE.onMove.permanent(&traceRay); // TODO: REMOVE

		PE.onResize.permanent(_ => onUpdate);
		PE.settings.fogChange.permanent(_ => onUpdate);
		PE.settings.lightsChange.permanent(_ => onUpdate);
		PE.settings.shadowsChange.permanent(_ => onUpdate);

		/*
		glClearColor(1, 0, 1, 0);
		*/
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
		CameraBase camera() => _camera;

		void camera(CameraBase camera)
		{
			_camera = camera;
			PE.window.cursor = _camera.cursor;
		}

		Scene scene() => _scene;

		void scene(Scene sc)
		{
			_rd = null;
			_scene = sc;
		}

		auto ray() => Tuple!(Vector3, `pos`, Vector3, `dir`)(_ray.front, _ray.back);

		bool hasLights() => _scene.lights.length && level == Lights.full;

		ref viewProject() const => _vp;
	}

	Matrix4 proj;
private:
	mixin publicProperty!(bool, `shadowPass`);

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
		Program pg;
		Program compute;
		Texture lights;
		_vp = _camera.view * proj;

		if (_scene)
		{
			if (_rd is null)
			{
				_rd = new SceneRenderData(_scene);
			}

			with (_rd)
			{
				if (auto rt = shadowsDepth)
				{
					_shadowPass = true;
					draw(progShadowsDepth, rt, PE.shadows.makeMatrix, 0);
					_shadowPass = false;
				}

				if (auto rt = lightsDepth)
				{
					draw(progLightsDepth, rt, _vp, 1);
					lights = lightsIndices;
					compute = progLightsCompute;
				}

				pg = progDraw;
			}
		}

		draw(pg, null, _vp, 3);

		if (compute)
		{
			computeLights(lights, compute);
		}
	}

	void computeLights(Texture tex, Program compute)
	{
		auto projViewInversed = _vp.inversed;
		compute.dispatch(2, _rd.lightsDepthTexture, tex, projViewInversed);
	}

	void clear(Vector2s size, uint flags)
	{
		// bgfx view clear is configured by BgfxManager.
	}

	void draw(Program pg, RenderTarget rt, Matrix4 vp, ushort view)
	{
		_culler = FrustumCuller(vp);

		if (rt)
		{
			PE.bgfx.setView(view, rt.frameBuffer, rt.size, rt.clearFlags);
			clear(rt.size, rt.clearFlags);
		}
		else
		{
			RenderTarget.unbind;
			clear(PEwindow._size, 0);
		}

		if (_scene)
		{
			DrawInfo di;
			_scene.node.draw(&di);

			PE.render.doDraw(pg, RENDER_SCENE, vp, rt, view);
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
