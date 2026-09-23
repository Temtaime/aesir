module perfontain.managers.state;
import std.array, core.bitop, perfontain, perfontain.config, perfontain.math.matrix, perfontain.misc;

final class StateManager
{
	this()
	{
		culling = true;

		if (PE._msaaLevel > 0)
		{
			msaa = true;
		}
	}

	@property
	{
		void msaa(bool b)
		{
			_msaa = b && PE._msaaLevel > 0;
		}

		void wireframe(bool b)
		{
			if (_wireframe != b)
			{
				// FIXME
				//glPolygonMode(GL_FRONT_AND_BACK, (_wireframe = b) == true ? GL_LINE : GL_FILL);
			}
		}

		void culling(bool b)
		{
			_culling = b;
		}

		bool msaa()
		{
			return _msaa;
		}

		bool wireframe()
		{
			return _wireframe;
		}

		bool culling()
		{
			return _culling;
		}
	}

package(perfontain):

	auto queryValue(T = int, uint N = 1)(uint param)
	{
		static if (is(T == int))
		{
			alias F = glGetIntegerv;
		}
		else static if (is(T == float))
		{
			alias F = glGetFloatv;
		}
		else static if (is(T == bool))
		{
			alias F = glGetBooleanv;
		}
		else
		{
			static assert(0);
		}

		static if (N == 1)
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
			_viewPort = vp;
		}

		void blendingMode(ubyte m)
		{
			_blending = m != noBlending;
			_blendingMode = m;
		}

		void depthMask(bool m)
		{
			_depthMask = m;
		}
	}

	uint _pipeline, _vao, _prog;
private:
	/* Legacy GL state mutation retained until it is translated to bgfx submit flags.
	static disableEnable(uint v, bool b)
	{
		if (b)
			glEnable(v);
		else
			glDisable(v);
	}
	*/

	Vector2s _viewPort;

	ubyte _blendingMode;

	bool _depthMask = true, _culling, _blending, _wireframe, _msaa;
}
