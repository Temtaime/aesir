module utile.except;
import std.conv, std.format, std.exception;

noreturn throwError(string S, string File = __FILE__, uint Line = __LINE__, A...)(A args)
		if (__traits(compiles, args.format!S))
{
	return throwError(args.format!S, File, Line);
}

noreturn throwError(string S, A...)(string file, uint line, A args) if (__traits(compiles, args.format!S))
{
	return throwError(args.format!S, file, line);
}

noreturn throwError(T)(T value, string file = __FILE__, uint line = __LINE__)
{
	throw new Exception(value.to!string, file, line);
}
