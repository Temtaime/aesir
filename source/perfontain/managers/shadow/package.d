module perfontain.managers.shadow;

import
		std.algorithm,

		perfontain,
		perfontain.managers.shadow.lispsm;


final class ShadowManager
{
	this()
	{
		PE.onResize.permanent(_ => update);
		PE.settings.shadowsChange.permanent(_ => update);

		_bias = Matrix4.scale(VEC3_2) * Matrix4.translate(VEC3_2);
	}

	void process()
	{
		if(level)
		{
			auto s = PE.scene;

			if(!s.scene)
			{
				return;
			}

			SceneData sd =
			{
				view:				s.camera.view,
				viewProjInversed:	(s.camera.view * s.proj).inverse,
				box:				s.scene.node.bbox,
				cameraPos:			s.camera._pos,
				cameraDir:			s.camera._dir,
				lightDir:			s.scene.lightDir,
			};

			Matrix4
						view = void,
						proj = void;

			//import perfontain.math, std.math, std.stdio;
			//float q = angleTo(sd.cameraDir, sd.lightDir);
			//writeln(q * TO_DEG);

			calculateShadowMatrices(&sd, view.ptr, proj.ptr, lispsm);

			auto vp = view * proj;
			_matrix = vp * _bias;

			_passActive = true;
			s.draw(_depth, _sm, vp);
			_passActive = false;
		}
	}

	const tex()
	{
		return _sm.tex;
	}

	const textured()
	{
		return level >= SHADOWS_MEDIUM;
	}

	const normals()
	{
		return level >= SHADOWS_HIGH;
	}

	bool lispsm = true;
private:
	mixin publicProperty!(Matrix4, `matrix`);
	mixin publicProperty!(bool, `passActive`);

	static level()
	{
		return PE.settings.shadows;
	}

	void update()
	{
		if(level)
		{
			{
				auto k = 2 ^^ (level - 1);
				auto sz = Vector2s(PE.window.size.flat[].reduce!max * k / 4);

				logger.info(`shadow map size: %s`, sz);

				auto tex = new Texture(TEX_SHADOW_MAP, sz);
				tex.bind(1);

				_sm = new RenderTarget(tex);
			}

			{
				auto creator = ProgramCreator(`depth`);

				if(textured)
				{
					creator.define(`TEXTURED_SHADOWS`);
				}

				_depth = creator.create;
			}
		}
		else
		{
			_sm = null;
			_depth = null;
		}

		PE.scene.onUpdate;
	}

	RC!Program _depth;
	RC!RenderTarget _sm;

	immutable Matrix4 _bias;
}
