module ro.sprite.svg;

// SVG CONVERTER IS BROKEN
version (none)  : import std.stdio, std.base64, std.string, std.algorithm, spr, act, perfontain.misc.binary;

string toSVG(in ActFile a, ubyte aid, in Images images)
{
	// return value
	string ret;

	// array with generated frames
	Frame[] fs;

	foreach (ref f; a.acts[aid].frames)
	{
		// create frame from the image
		auto im = makeImage(images, f);

		// append the frame
		fs ~= im;
	}

	// lets calculate total area size at first
	auto s = calcActionPoses(fs);

	ret = format(`<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<svg width="%upx" height="%upx" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><defs>`,
			s.w, s.h);

	foreach (idx, ref f; fs)
	{
		ret ~= format(`<image id="f_%x" `, idx);

		// calc image's pose
		auto x = s.cx - f.cx, y = s.cy - f.cy;

		if (x)
			ret ~= format(`x="%upx" `, x);
		if (y)
			ret ~= format(`y="%upx" `, y);

		ret ~= format(`width="%upx" height="%upx" xlink:href="data:image/png;base64,%s"/>`, f.im.w, f.im.h,
				Base64.encode(f.im.save(`png`).as!ubyte));
	}

	ret ~= `</defs><use xlink:href="#f_0"><animate attributeName="xlink:href" values="`;
	foreach (idx; 0 .. fs.length)
		ret ~= format(`%s#f_%x`, idx ? `;` : ``, idx);

	ret ~= format(`" dur="%gs" repeatCount="indefinite"/></use></svg>`, a.delays[aid] * fs.length / 1000);
	return ret;
}
