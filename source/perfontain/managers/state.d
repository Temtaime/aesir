module perfontain.managers.state;

import
		std.array,

		core.bitop,

		perfontain,
		perfontain.opengl,
		perfontain.config,
		perfontain.math.matrix,
		perfontain.misc;


final class StateManager
{
	this()
	{
		culling = true;

		if(PE._msaaLevel > 0) msaa = true;
	}

	@property
	{
		void msaa(bool b)
		{
			if(_msaa != b && PE._msaaLevel > 0)
			{
				disableEnable(GL_MULTISAMPLE, _msaa = b);
			}
		}

		void wireframe(bool b)
		{
			if(_wireframe != b)
			{
				glPolygonMode(GL_FRONT_AND_BACK, (_wireframe = b) == true ? GL_LINE : GL_FILL);
			}
		}

		bool msaa() { return _msaa; }
		bool wireframe() { return _wireframe; }
	}

package(perfontain):

	auto queryValue(T = int, uint N = 1)(uint param)
	{
		static if(is(T == int))
		{
			alias F = glGetIntegerv;
		}
		else static if(is(T == float))
		{
			alias F = glGetFloatv;
		}
		else static if(is(T == bool))
		{
			alias F = glGetBooleanv;
		}
		else
		{
			static assert(0);
		}

		static if(N == 1)
		{
			T value;
			F(param, &value);
		}
		else
		{
			T[N] value;
			F(param, value.ptr);
		}

		return value;
	}

	@property
	{
		void viewPort(Vector2s vp)
		{
			if(_viewPort != vp)
			{
				glViewport(0, 0, (_viewPort = vp).x, vp.y);
			}
		}

		void blendingMode(ubyte m)
		{
			blending = m != noBlending;

			if(_blending && _blendingMode != m)
			{
				auto modes = unpackModes(_blendingMode = m);
				glBlendFuncSeparate(modes.front.blendingModeGL, modes.back.blendingModeGL, GL_ONE, GL_ONE);
			}
		}

		void depthMask(bool m)
		{
			if(_depthMask != m)
			{
				glDepthMask(_depthMask = m);
			}
		}
	}

	struct LayerInfo
	{
		uint	tex,
				samp;
	}

	LayerInfo[MAX_LAYERS] _texLayers;
	uint _pipeline, _vao, _prog;
private:
	static disableEnable(uint v, bool b)
	{
		if(b) glEnable(v);
		else glDisable(v);
	}

	void blending(bool b)
	{
		if(_blending != b)
		{
			disableEnable(GL_BLEND, _blending = b);
		}
	}

	void culling(bool b)
	{
		if(_culling != b)
		{
			disableEnable(GL_CULL_FACE, _culling = b);
		}
	}

	Vector2s _viewPort;

	ubyte _blendingMode;

	bool	_depthMask = true,
			_culling,
			_blending,
			_wireframe,
			_msaa;
}
