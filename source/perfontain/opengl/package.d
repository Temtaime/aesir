module perfontain.opengl;
import std, utile.logger, utile.except;
public import perfontain.opengl.functions;

debug : package:

enum ENABLED_DEBUG = [
		GL_DEBUG_TYPE_ERROR_KHR, GL_DEBUG_TYPE_PORTABILITY_KHR,
		GL_DEBUG_TYPE_UNDEFINED_BEHAVIOR_KHR,
		GL_DEBUG_TYPE_DEPRECATED_BEHAVIOR_KHR
	];

void enableDebug()
{
	glEnable(GL_DEBUG_OUTPUT_SYNCHRONOUS_KHR);
	glDebugMessageControlKHR(GL_DONT_CARE, GL_DONT_CARE, GL_DONT_CARE, 0, null, false);

	foreach (type; ENABLED_DEBUG)
		glDebugMessageControlKHR(GL_DONT_CARE, type, GL_DONT_CARE, 0, null, true);

	glDebugMessageCallbackKHR(&debugCallback, null);
}

string dumpArgs(A...)(A args)
{
	string dump;

	foreach (e; args)
	{
		dump ~= dump ? `, ` : null;

		static if (isPointer!(typeof(e)))
			dump ~= format(`0x%X`, cast(size_t)e);
		else
			dump ~= e.to!string;
	}

	return dump;
}

void traceGL(A...)(string func, string file, uint line, A args)
{
	//logger.info3(`[trace] %s(%s)`, func, dumpArgs(args));
}

void checkError(A...)(string func, string file, uint line, A args)
{
	auto err = glGetError();

	if (err)
		logger.error(`[%s:%u] %s(%s) - ERROR 0x%X`, file, line, func, dumpArgs(args), err);
	// if (error.length)
	// {
	// 	//if (!errors.canFind(error))
	// 	{
	// 		//	errors ~= error;
	// 		logger.warning(`[%s:%u]: %s %s`, file, line, func, error);
	// 	}

	// 	error = null;
	// }
}

private:

extern (System) void debugCallback(uint source, uint type, uint id, uint severity,
		uint length, in char* message, in void* userParam)
{
	auto s = message[0 .. length];
	logger.warning(`[debug] ERROR 0x%X - %s`, id, s);
}
