import
		std.experimental.all;


void main()
{
	auto path = `../../bin/data/gui`.absolutePath;

	auto fs = path
					.dirEntries(`*.png`, SpanMode.depth)
					.map!(a => a
								.relativePath(path)
								.stripExtension
								.replace(dirSeparator, `_`)
								.toUpper)
					.array;

	auto conv = format("enum GUI\n{\n%-(\t%s,\n%)\n}\n", fs);

	std.file.write(`../../source/perfontain/managers/gui/images.d`, "module perfontain.managers.gui.images;\n\n\n" ~ conv);
}
