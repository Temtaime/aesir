module perfontain.program.props;
import std;

enum ShaderTexture : ubyte
{
	main,
	lights_depth,
	shadows_depth,

	max
}

enum ShaderBuffer : ubyte
{
	transforms,
	lights,

	max
}

static immutable string[] SHADER_SSBO_NAMES = EnumMembers!ShaderBuffer.only.dropBack(1).map!(a => `pe_` ~ a.to!string).array;
static immutable string[] SHADER_TEX_NAMES = EnumMembers!ShaderTexture.only.dropBack(1).map!(a => `pe_tex_` ~ a.to!string).array;
