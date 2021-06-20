module perfontain.sampler;

import std.stdio, std.traits, perfontain, perfontain.opengl;

final class Sampler : RCounted
{
	this()
	{
		glGenSamplers(1, &_id);
	}

	~this()
	{
		// foreach (uint i, ref v; PEstate._texLayers)
		// {
		// 	if (v.samp == _id)
		// 	{
		// 		glBindSampler(i, v.samp = 0);
		// 	}
		// }

		glDeleteSamplers(1, &_id);
	}

	auto set(T)(uint e, T v)
	{
		static if (is(T : const(float)*))
			alias F = glSamplerParameterfv;
		else static if (isFloatingPoint!T)
			alias F = glSamplerParameterf;
		else
			alias F = glSamplerParameteri;

		F(_id, e, v);
		return this;
	}

package:
	uint _id;
}
