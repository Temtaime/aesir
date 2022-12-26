module utile.logger;
import std.conv, std.range, std.string, std.algorithm, core.stdc.stdio, utile.console;

abstract class Logger
{
	final
	{
		void info(T)(T value) => log(CC_FG_GREEN, value.to!string);
		void info(string F, A...)(A args) => log(CC_FG_GREEN, format!F(args));

		void info2(T)(T value) => log(CC_FG_MAGENTA, value.to!string);
		void info2(string F, A...)(A args) => log(CC_FG_MAGENTA, format!F(args));

		void info3(T)(T value) => log(CC_FG_WHITE, value.to!string);
		void info3(string F, A...)(A args) => log(CC_FG_WHITE, format!F(args));

		void error(T)(T value) => log(CC_FG_RED, value.to!string);
		void error(string F, A...)(A args) => log(CC_FG_RED, format!F(args));

		void warning(T)(T value) => log(CC_FG_YELLOW, value.to!string);
		void warning(string F, A...)(A args) => log(CC_FG_YELLOW, format!F(args));

		void msg(T)(T value) => log(CC_FG_CYAN, value.to!string);
		void msg(string F, A...)(A args) => log(CC_FG_CYAN, format!F(args));
	}

	ubyte ident;
protected:
	final void log(int c, string s)
	{
		ident.iota.each!(a => write(c, "\t"));

		write(c, s);
		write(c, "\n");
	}

	void write(int color, string s);
}

final class ConsoleLogger : Logger
{
protected:
	override void write(int color, string s)
	{
		cc_fprintf(color, stdout, "%.*s", s.length, s.ptr);
	}
}

__gshared Logger logger = new ConsoleLogger;

unittest
{
	logger.msg(`hello, world`);
	logger.msg!`%s, %s`(`hello`, `world`);
}
