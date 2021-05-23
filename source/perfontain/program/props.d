module perfontain.program.props;
import std;

enum ShaderTexture : ubyte
{
	main,
	depth,
	lights,
	shadows,

	max
}

static immutable string[] SHADER_TEX_NAMES = EnumMembers!ShaderTexture.only.dropBack(1).map!(a => `pe_tex_` ~ a.to!string).array;
