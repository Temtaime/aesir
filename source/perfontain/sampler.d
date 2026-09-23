module perfontain.sampler;

import bgfx_c, std.stdio, perfontain;

final class Sampler : RCounted
{
	this(uint flags = 0)
	{
		_flags = flags;
	}

	/*
	auto set(T)(uint e, T v)
	{
		switch (e)
		{
			case GL_TEXTURE_MAG_FILTER:
				v == GL_NEAREST && (_flags |= _BGFX_SAMPLER_MAG_POINT);
				break;
			case GL_TEXTURE_MIN_FILTER:
				if (v == GL_NEAREST)
					_flags |= _BGFX_SAMPLER_MIN_POINT | _BGFX_SAMPLER_MIP_POINT;
				break;
			case GL_TEXTURE_WRAP_S:
				v == GL_CLAMP_TO_EDGE && (_flags |= _BGFX_SAMPLER_U_CLAMP);
				break;
			case GL_TEXTURE_WRAP_T:
				v == GL_CLAMP_TO_EDGE && (_flags |= _BGFX_SAMPLER_V_CLAMP);
				break;
			case GL_TEXTURE_MAX_ANISOTROPY_EXT:
				_flags |= _BGFX_SAMPLER_MIN_ANISOTROPIC;
				break;
			default:
				assert(0, `unsupported sampler parameter`);
		}

		return this;
	}
	*/

package:
	uint _flags;
}
