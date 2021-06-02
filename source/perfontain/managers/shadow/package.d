module perfontain.managers.shadow;

import std.algorithm, perfontain, perfontain.managers.shadow.lispsm;

final class ShadowManager
{
	this()
	{
		_bias = Matrix4.scale(VEC3_2) * Matrix4.translate(VEC3_2);
	}

	auto makeMatrix()
	{
		auto s = PE.scene;

		SceneData sd = {
			view: s.camera.view, viewProjInversed: (s.camera.view * s.proj).inverse, box: s.scene.node.bbox, cameraPos: s.camera._pos,
			cameraDir: s.camera._dir, lightDir: s.scene.lightDir,
		};

		Matrix4 view = void, proj = void;

		calculateShadowMatrices(&sd, view.ptr, proj.ptr, lispsm);

		auto vp = view * proj;
		_matrix = vp * _bias;

		return vp;
	}

	const textured()
	{
		return level >= Shadows.medium;
	}

	const normals()
	{
		return level >= Shadows.high;
	}

	const texSize()
	{
		auto k = 2 ^^ (level - 1);
		auto sz = Vector2s(PE.window.size.flat[].reduce!max * k / 4);

		logger.info!`shadow map size: %s`(sz);
		return sz;
	}

	bool lispsm = true;
private:
	mixin publicProperty!(Matrix4, `matrix`);
	mixin publicProperty!(Vector2s, `texSize`);

	static level() => PE.settings.shadows;

	immutable Matrix4 _bias;
}
