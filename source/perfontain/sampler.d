module perfontain.sampler;

import bgfx_c, std.stdio, perfontain;

final class Sampler : RCounted
{
	/*
	auto set(T)(uint e, T v)
	{
		switch (e)
		{
			case GL_TEXTURE_MAG_FILTER:
				v == GL_NEAREST && (_flags |= BGFX_SAMPLER_MAG_POINT_);
				break;
			case GL_TEXTURE_MIN_FILTER:
				if (v == GL_NEAREST)
					_flags |= BGFX_SAMPLER_MIN_POINT_ | BGFX_SAMPLER_MIP_POINT_;
				break;
			case GL_TEXTURE_WRAP_S:
				v == GL_CLAMP_TO_EDGE && (_flags |= BGFX_SAMPLER_U_CLAMP_);
				break;
			case GL_TEXTURE_WRAP_T:
				v == GL_CLAMP_TO_EDGE && (_flags |= BGFX_SAMPLER_V_CLAMP_);
				break;
			case GL_TEXTURE_MAX_ANISOTROPY_EXT:
				_flags |= BGFX_SAMPLER_MIN_ANISOTROPIC_;
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
