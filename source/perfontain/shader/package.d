module perfontain.shader;
import bgfx_c, std.file, std.path, std.process, std.conv, std.stdio, std.range, std.traits, std.string,
	std.typecons, std.exception, std.algorithm, stb.image, perfontain,
	perfontain.misc, perfontain.shader.lang,
	perfontain.shader.types, utile.except;

final class Shader : RCounted
{
	this(string name, string data, ubyte type)
	{
		_name = name;
		_type = type;

		mkdirRecurse(`bgfx/shaders`);

		auto stem = format!`%s_%s`(stripExtension(baseName(name)), shaderInfo[type].name);
		auto source = `bgfx/shaders/` ~ stem ~ `.sc`;
		auto binary = `bgfx/shaders/` ~ stem ~ `.bin`;
		auto varying = baseName(name).startsWith(`gui_`) ? `bgfx/varying_gui.def.sc` : `bgfx/varying.def.sc`;

		std.file.write(source, data);

		auto result = execute([
			`bgfx/shaderc.exe`, `-f`, source, `-o`, binary,
			`-i`, `bgfx`,
			`--type`, shaderInfo[type].name,
			`--platform`, `windows`,
			`--profile`, PE.bgfx.shaderProfile,
			`--varyingdef`, varying,
		]);

		result.status == 0 || throwError!`cannot compile %s:\n%s`(name, result.output);

		auto bytes = read(binary);
		_handle = bgfx_create_shader(bgfx_copy(bytes.ptr, cast(uint)bytes.length));
	}

	~this()
	{
		if (_owned)
			bgfx_destroy_shader(_handle);
	}

	bgfx_shader_handle_t handle() const => _handle;
	string sourceName() const => _name;
	void relinquish()
	{
		_owned = false;
	}

private:
	bgfx_shader_handle_t _handle;
	ubyte _type;
	string _name;
	bool _owned = true;
}
