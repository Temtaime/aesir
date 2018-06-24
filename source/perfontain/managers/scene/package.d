module perfontain.managers.scene;

import
		std.math,
		std.stdio,
		std.array,
		std.typecons,
		std.algorithm,

		stb.image,

		perfontain,

		perfontain.math,
		perfontain.misc,
		perfontain.misc.draw,
		perfontain.misc.vmem,

		perfontain.opengl,
		perfontain.math.frustum,

		perfontain.managers.shadow;

public import
				perfontain.render.types,
				perfontain.managers.scene.structs;


final class SceneManager
{
	this()
	{
		PE.onMove.permanent(&traceRay); // TODO: REMOVE

		PE.settings.fogChange.permanent(_ => onUpdate);
		PE.settings.lightsChange.permanent(_ => onUpdate);
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
		CameraBase camera() { return _camera; }

		void camera(CameraBase camera)
		{
			_camera = camera;
			PE.window.cursor = _camera.cursor;
		}

		Scene scene() { return _scene; }

		void scene(Scene sc)
		{
			_prog = null;
			_scene = sc;
		}

		auto ray()
		{
			return Tuple!(Vector3, `pos`, Vector3, `dir`)(_ray.front, _ray.back);
		}

		bool hasLights() { return _scene.lights.length && level == LIGHTS_FULL; }

		ref viewProject() const { return _vp; }
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

				if(PE.settings.shadows)
				{
					creator.define(`SHADOWS_ENABLED`);
				}

				if(s.normals || level)
				{
					creator.define(`LIGHT_DIR`, _scene.lightDir);
				}

				if(s.normals)
				{
					creator.define(`SHADOWS_USE_NORMALS`);
				}
			}

			if(level)
			{
				creator.define(`LIGHTING_ENABLED`);

				creator.define(`LIGHT_AMBIENT`, _scene.ambient);
				creator.define(`LIGHT_DIFFUSE`, _scene.diffuse);

				if(full)
				{
					creator.define(`LIGHTING_FULL`);
				}
			}

			if(PE.settings.fog)
			{
				creator.define(`USE_FOG`);
				creator.define(`FOG_FAR`, _scene.fogFar);
				creator.define(`FOG_NEAR`, _scene.fogNear);
				creator.define(`FOG_COLOR`, _scene.fogColor);
			}

			_prog = creator.create;
		}

		if(full)
		{
			ubyte[] buf;

			foreach(ref r; _scene.lights)
			{
				auto
						v = Vector4(r.pos, r.range),
						u = Vector4(r.color, 0);

				buf ~= v.toByte;
				buf ~= u.toByte;
			}

			_prog.ssbo(`pe_lights`, buf, false);
			_prog.ssbo(`pe_lights_raw`, _scene.lightIndices.map!(a => int(a)).array, false);
		}
	}

package(perfontain):

	//const lightsReallyFull() { return _lights == LIGHTS_FULL && _scene.lights.length; }

	void draw()
	{
		if(_scene)
		{
			if(!_prog) compile;
		}

		draw(_prog, null, _camera.view * proj);
	}

	void draw(Program pg, RenderTarget rt, in Matrix4 vp)
	{
		_vp = vp;
		_culler = FrustumCuller(vp);

		{
			auto flags = GL_DEPTH_BUFFER_BIT;

			if(rt)
			{
				rt.bind;
			}
			else
			{
				flags |= GL_COLOR_BUFFER_BIT;
			}

			PEstate.viewPort = rt ? rt._tex.size : PEwindow._size;
			PEstate.depthMask = true; // enable to clear depth buffer

			glClear(flags);
		}

		if(_scene)
		{
			DrawInfo di;
			_scene.node.draw(&di);

			PE.render.doDraw(pg, RENDER_SCENE, vp, rt);
		}

		if(rt)
		{
			rt.unbind;
		}
	}

	auto traceRay(Vector2s pos)
	{
		auto sz = PEwindow._size;
		pos.y = cast(short)(sz.y - pos.y - 1);

		auto v1 = unproject(pos.x, pos.y, -1, _vp, sz);
		auto v2 = unproject(pos.x, pos.y,  1, _vp, sz);

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
