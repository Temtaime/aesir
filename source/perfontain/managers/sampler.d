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
		const clamp = _BGFX_SAMPLER_U_CLAMP | _BGFX_SAMPLER_V_CLAMP;
		main = new Sampler(clamp | _BGFX_SAMPLER_MIN_ANISOTROPIC);
		noMipMap = new Sampler(clamp);
		shadowMap = new Sampler(clamp | _BGFX_SAMPLER_MIN_POINT | _BGFX_SAMPLER_MAG_POINT | _BGFX_SAMPLER_MIP_POINT);
	}

	RC!Sampler
				main,
				noMipMap,
				shadowMap;
}
