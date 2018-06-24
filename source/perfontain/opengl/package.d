module perfontain.opengl;

import
		std.conv,
		std.algorithm,

		utils.logger;

public import
				perfontain.opengl.functions;


debug:
package:

void enableDebug()
{
	glEnable(GL_DEBUG_OUTPUT_SYNCHRONOUS_ARB);
	glDebugMessageControl(GL_DONT_CARE, GL_DONT_CARE, GL_DONT_CARE, 0, null, false);

	glDebugMessageControl(GL_DONT_CARE, GL_DEBUG_TYPE_ERROR, GL_DONT_CARE, 0, null, true);
	glDebugMessageControl(GL_DONT_CARE, GL_DEBUG_TYPE_PORTABILITY, GL_DONT_CARE, 0, null, true);
	//glDebugMessageControl(GL_DONT_CARE, GL_DEBUG_TYPE_PERFORMANCE, GL_DONT_CARE, 0, null, true);
	glDebugMessageControl(GL_DONT_CARE, GL_DEBUG_TYPE_UNDEFINED_BEHAVIOR, GL_DONT_CARE, 0, null, true);
	glDebugMessageControl(GL_DONT_CARE, GL_DEBUG_TYPE_DEPRECATED_BEHAVIOR, GL_DONT_CARE, 0, null, true);

	glDebugMessageCallback(&debugCallback, null);
}

void checkError(string func, string file, uint line)
{
	if(error.length)
	{
		if(!errors.canFind(error))
		{
			errors ~= error;
			logger.warning(`[%s:%u]: %s - %s`, file, line, func, error);
		}

		error = null;
	}
}

private:

extern(System) void debugCallback(uint source, uint type, uint id, uint severity, uint length, in char *message, in void *userParam) nothrow
{
	error = message.to!string;
}

__gshared
{
	string error;
	string[] errors;
}
