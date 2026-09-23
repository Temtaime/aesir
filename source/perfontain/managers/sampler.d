module perfontain.managers.sampler;

import
		bgfx_c,
		perfontain,
		perfontain.sampler,
		perfontain.misc.rc;


final class SamplerManager
{
	this()
	{
		const clamp = BGFX_SAMPLER_U_CLAMP_ | BGFX_SAMPLER_V_CLAMP_;
		main = new Sampler(clamp | BGFX_SAMPLER_MIN_ANISOTROPIC_);
		noMipMap = new Sampler(clamp);
		shadowMap = new Sampler(clamp | BGFX_SAMPLER_MIN_POINT_ | BGFX_SAMPLER_MAG_POINT_ | BGFX_SAMPLER_MIP_POINT_);
	}

	RC!Sampler
				main,
				noMipMap,
				shadowMap;
}
