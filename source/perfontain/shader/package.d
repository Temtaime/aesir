module perfontain.shader;
import bgfx_c, std.file, std.path, std.conv, std.stdio, std.range, std.traits, std.string,
	std.typecons, std.exception, std.algorithm, stb.image, perfontain,
	perfontain.misc, perfontain.shader.lang,
	perfontain.shader.types, perfontain.shader.resource, utile.except;
import cstdio = core.stdc.stdio;

version (Windows)
{
	extern (C) int _close(int);
	extern (C) int _dup(int);
	extern (C) int _dup2(int, int);
}
else
{
	import core.sys.posix.unistd : close, dup, dup2;
}

final class Shader : RCounted
{
	this(string name, string data, ubyte type, bool writeSource)
	{
		_name = name;
		_type = type;

		mkdirRecurse(`bgfx/shaders`);

		auto sourceStem = stripExtension(baseName(name));
		auto binaryStem = format!`%s_%s`(sourceStem, shaderInfo[type].name);
		auto source = `bgfx/shaders/` ~ sourceStem ~ `.sc`;
		auto binary = `bgfx/shaders/` ~ binaryStem ~ `.bin`;
		auto varying = baseName(name).startsWith(`gui`) ? `bgfx/varying_gui.def.sc` : `bgfx/varying.def.sc`;

		if (writeSource)
			std.file.write(source, data);

		auto args = [
			`shaderc`, `-f`, source, `-o`, binary,
			`-i`, `bgfx`,
			`--type`, shaderInfo[type].name,
			`--platform`, `windows`,
			`--profile`, PE.bgfx.shaderProfile,
			`--varyingdef`, varying,
		].map!(a => a.toStringz).array;

		auto output = cstdio.tmpfile;
		output !is null || throwError!`cannot create shaderc output file`();
		auto stdoutFd = cstdio.fileno(cstdio.stdout);
		version (Windows) auto savedStdout = _dup(stdoutFd);
		else auto savedStdout = dup(stdoutFd);
		savedStdout != -1 || throwError!`cannot duplicate stdout`();
		scope (exit)
		{
			cstdio.fflush(cstdio.stdout);
			version (Windows) _dup2(savedStdout, stdoutFd);
			else dup2(savedStdout, stdoutFd);
			version (Windows) _close(savedStdout);
			else close(savedStdout);
			cstdio.fclose(output);
		}

		version (Windows) _dup2(cstdio.fileno(output), stdoutFd) != -1 || throwError!`cannot redirect shaderc output`();
		else dup2(cstdio.fileno(output), stdoutFd) != -1 || throwError!`cannot redirect shaderc output`();
		auto status = shaderc_main(cast(int)args.length, cast(const(char)**)args.ptr);
		cstdio.fflush(cstdio.stdout);
		version (Windows) _dup2(savedStdout, stdoutFd) != -1 || throwError!`cannot restore stdout`();
		else dup2(savedStdout, stdoutFd) != -1 || throwError!`cannot restore stdout`();

		cstdio.fseek(output, 0, cstdio.SEEK_END);
		auto outputLength = cstdio.ftell(output);
		cstdio.fseek(output, 0, cstdio.SEEK_SET);
		char[] outputText;
		outputText.length = cast(size_t)outputLength;
		cstdio.fread(outputText.ptr, 1, outputText.length, output) == outputText.length || throwError!`cannot read shaderc output`();

		status == 0 || throwError!`cannot compile %s:\n%s`(name, outputText);

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
