import
		std;


void main()
{
	auto path = `../../bin/data/gui`.absolutePath;

	auto arr = path
					.dirEntries(`*.png`, SpanMode.shallow)
					.map!(a => a
								.relativePath(path)
								.stripExtension
								.toUpper)
					.array
					.sort;

	auto conv = format("enum\n{\n%-(\t%s,\n%)\n}\n\n", arr);

	conv ~= format("enum GUI = [ %-(%s, %) ];\n\n", arr);
	conv ~= format("enum GUI_STR = [ %-(`%s`%|, %) ];\n\n", arr);

	arr.each!(a => conv ~= format("@property %1$s_SZ() { return PE.gui.sizes[%1$s]; }\n", a));

	toFile("module perfontain.managers.gui.images;\n\nimport\n\t\tperfontain;\n\n\n" ~ conv, `../../source/perfontain/managers/gui/images.d`);
}
