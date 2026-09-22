module perfontain.shader.types;

struct ShaderInfo
{
	string name;
}

static immutable shaderInfo = [
	ShaderInfo(`vertex`),
	ShaderInfo(`fragment`),
	ShaderInfo(`compute`),
];

ubyte shaderType(string name)
{
	foreach (idx, e; shaderInfo)
		if (e.name == name)
			return cast(ubyte)idx;

	assert(false, name);
}
