module perfontain.opengl;
import std, utile.logger, utile.except;
public import perfontain.opengl.functions;

uint gen(alias F)()
{
	uint id;
	F(1, &id);
	return id;
}

debug:
package:

string dumpArgs(A...)(A args)
{
	string dump;

	foreach (e; args)
	{
		dump ~= dump ? `, ` : null;

		static if (isPointer!(typeof(e)))
		{
			dump ~= format(`0x%X`, cast(size_t)e);
		}
		else
			dump ~= e.to!string;
	}

	return dump;
}

void traceGL(A...)(string func, string file, uint line, A args)
{
	//logger.info3!`[%s:%u] %s(%s)`(file, line, func, dumpArgs(args));
}

void checkError(A...)(string func, string file, uint line, A args)
{
	auto err = glGetError();

	if (err)
	{
		logger.error!`[%s:%u] %s(%s) - ERROR 0x%X`(file, line, func, dumpArgs(args), err);
	}
}
