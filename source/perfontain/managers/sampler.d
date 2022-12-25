module perfontain.managers.sampler;

import
		perfontain,
		perfontain.opengl,
		perfontain.sampler,
		perfontain.misc.rc,
		perfontain.opengl.functions;

final class SamplerManager
{
	this()
	{
		// used for bindless textures
		main = new Sampler;

		main.set(GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		main.set(GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);

		//s.set(GL_TEXTURE_WRAP_S, GL_REPEAT);
		//s.set(GL_TEXTURE_WRAP_T, GL_REPEAT);

		main.set(GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE); // TODO: use repeat here
		main.set(GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

		if(PE._aaLevel)
		{
			main.set(GL_TEXTURE_MAX_ANISOTROPY_EXT, PE._aaLevel);
		}

		// used for texture atlases
		noMipMap = new Sampler;

		noMipMap.set(GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		noMipMap.set(GL_TEXTURE_MIN_FILTER, GL_LINEAR);

		// used for shadow maps
		shadowMap = new Sampler;

		shadowMap.set(GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		shadowMap.set(GL_TEXTURE_MAG_FILTER, GL_NEAREST);

		shadowMap.set(GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		shadowMap.set(GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	}

	RC!Sampler
				main,
				noMipMap,
				shadowMap;
}
