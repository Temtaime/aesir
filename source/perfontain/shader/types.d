module perfontain.shader.types;
import perfontain.opengl;

struct ShaderInfo
{
	uint bit;
	uint type;
	string name;
}

static immutable shaderInfo = [
	ShaderInfo(GL_VERTEX_SHADER_BIT_EXT, GL_VERTEX_SHADER, `vertex`),
	ShaderInfo(GL_FRAGMENT_SHADER_BIT_EXT, GL_FRAGMENT_SHADER, `fragment`),
	ShaderInfo(GL_COMPUTE_SHADER_BIT, GL_COMPUTE_SHADER, `compute`),
];

ubyte shaderType(string name)
{
	foreach (idx, e; shaderInfo)
		if (e.name == name)
			return cast(ubyte)idx;

	assert(false, name);
}
