module perfontain.managers.gui;
import std.utf, std.range, std.stdio, std.ascii, std.array, std.string, std.regex, std.encoding, std.algorithm,
	stb.image, perfontain, perfontain.misc, perfontain.misc.dxt, perfontain.misc.draw, perfontain.opengl, perfontain.signals;

public import nuklear, perfontain.managers.gui.tab, perfontain.managers.gui.text, perfontain.managers.gui.misc,
	perfontain.managers.gui.scroll, perfontain.managers.gui.select, perfontain.managers.gui.tooltip, perfontain.managers.gui.style;

struct PopupText
{
	string msg;
	Vector2s pos;
	bool fill;
}

mixin template Nuklear()
{
	@property nk()
	{
		return PE.gui.ctx;
	}
}

final class GUIManager
{
	this()
	{
		_prog = ProgramCreator(ProgramSource.gui).create;

		bg.r = 0.10f, bg.g = 0.18f, bg.b = 0.24f, bg.a = 1.0f;

		{
			nk_font_atlas_init_default(atlas = new nk_font_atlas);
			nk_font_atlas_begin(atlas);

			auto size = 16;
			auto conf = nk_font_config_(size);

			static const nk_rune[] nk_font_japanese_glyph_ranges = [
				0x0020, 0x00FF, 0x2200, 0x22FF, // Mathematical Operators
				0x3000, 0x303F, // CJK Symbols and Punctuation
				//0x1F600, 0x1F64F, // emoji

				0x0400, 0x052F, // cyrrilic
				0x2DE0, 0x2DFF, 0xA640, 0xA69F, 0
			];

			conf.range = nk_font_cyrillic_glyph_ranges(); // nk_font_japanese_glyph_ranges.ptr;

			//conf.pixel_snap = 1;
			conf.oversample_v = 1;
			conf.oversample_h = 1;

			auto data = PE.fs.get("data/font/notosans-regular.ttf");

			auto font = nk_font_atlas_add_from_memory(atlas, data.ptr, data.length, size, &conf);

			int w, h;
			auto image = nk_font_atlas_bake(atlas, &w, &h, NK_FONT_ATLAS_RGBA32);

			auto td = TextureData(Vector2s(w, h), image[0 .. w * h * 4].toByte);
			auto ti = TextureInfo(TEX_RGBA, td.sliceOne);

			new Image(w, h, td.data).saveToFile(`res.png`);

			ftex = new Texture(ti);
			nk_font_atlas_end(atlas, nk_handle_ptr(cast(void*)ftex), &null_);

			/*if (atlas.default_font)
					nk_style_set_font(_nk, &atlas.default_font.handle);
					else
						nk_style_set_font(_nk, &font.handle);*/

			_ctx = new NuklearContext;
			nk_init_default(_ctx.ctx, &font.handle);

			_ctx.ctx.style.window.min_row_height_padding = 2; // TODO: ???

			nk_buffer_init_default(&cmds);
		}

		PE.onResize.permanent(&onResize);
	}

	nk_font_atlas* atlas;
	nk_colorf bg;
	nk_buffer cmds;

	RC!Texture ftex;

	void draw()
	{
		//alias F = (a, b) => a.flags.topMost < b.flags.topMost;

		//root.childs[].sort!(F, SwapStrategy.stable);
		//root.draw(Vector2s.init);

		//overview(_nk);
		//_windows.each!(a => a.draw);

		if (drawGUI)
			drawGUI();

		nk_buffer vbuf;
		nk_buffer ebuf;

		{
			nk_convert_config config;
			const(nk_draw_vertex_layout_element)[] vertex_layout = [
				{NK_VERTEX_POSITION, NK_FORMAT_FLOAT, 0}, {NK_VERTEX_TEXCOORD, NK_FORMAT_FLOAT, 8},
				{NK_VERTEX_COLOR, NK_FORMAT_R32G32B32A32_FLOAT, 16}, NK_VERTEX_LAYOUT_END
			];
			import core.stdc.string;

			memset(&config, 0, config.sizeof);
			config.vertex_layout = vertex_layout.ptr;
			config.vertex_size = 32;
			config.vertex_alignment = 1;
			config.null_ = null_;
			config.circle_segment_count = 22;
			config.curve_segment_count = 22;
			config.arc_segment_count = 22;
			config.global_alpha = 1.0f;
			config.shape_AA = NK_ANTI_ALIASING_ON;
			config.line_AA = NK_ANTI_ALIASING_ON;

			nk_buffer_init_default(&vbuf);
			nk_buffer_init_default(&ebuf);
			nk_convert(_ctx.ctx, &cmds, &vbuf, &ebuf, &config);
		}

		drawPopups;

		auto elements = nk_buffer_memory(&ebuf)[0 .. ebuf.needed].as!uint;

		if (elements.length)
		{
			auto vertices = nk_buffer_memory(&vbuf)[0 .. vbuf.needed].as!float;
			draw(SubMeshData(elements, vertices.toByte));
		}

		nk_clear(_ctx.ctx);

		nk_buffer_clear(&cmds);
		nk_buffer_free(&vbuf);
		nk_buffer_free(&ebuf);
	}

	void addPopup(PopupText pt)
	{
		_texts ~= pt;
	}

	@property ctx()
	{
		return _ctx;
	}

	void delegate() drawGUI;

	nk_draw_null_texture null_;

	//Signal!(void, GUIElement) onCurrentChanged;

	RC!MeshHolder holder;

	Vector2s[] sizes;
package:
	// void add(GUIWindow w)
	// {
	// 	_windows ~= w;
	// }

	// void remove(GUIWindow w)
	// {
	// 	_windows.remove(w);
	// }

private:
	//RCArray!GUIWindow _windows;

	PopupText[] _texts;

	void draw(SubMeshData data)
	{
		PEstate.culling = false; // TODO: FIX GUI
		scope (exit)
			PEstate.culling = true;

		auto mh = asRC(new MeshHolder(RENDER_GUI, data));
		//mh.texs = (cast(Texture) ftex).sliceOne;

		{
			uint offset;
			short n;

			for (auto cmd = nk__draw_begin(_ctx.ctx, &cmds); (cmd); (cmd) = nk__draw_next(cmd, &cmds, _ctx.ctx))
			{
				if (!cmd.elem_count)
					continue;

				//writefln(`%s`, cmd.elem_count);

				{
					auto tex = cast(Texture)cmd.texture.ptr;
					auto idx = mh.texs[].countUntil!(a => a is tex);

					if (idx < 0)
					{
						mh.texs ~= tex;
						idx = mh.texs[].length - 1;
					}

					mh.meshes ~= HolderMesh([HolderSubMesh(cmd.elem_count, offset, cast(ushort)idx)]);
				}

				DrawInfo d;

				d.mh = mh;

				d.id = n++;
				d.flags = DI_NO_DEPTH;
				d.blendingMode = blendingNormal;
				d.scissor = Vector4s(cmd.clip_rect.x, (PE.window.size.y - (cmd.clip_rect.y + cmd.clip_rect.h)),
						(cmd.clip_rect.w), (cmd.clip_rect.h));

				d.scissor.z += d.scissor.x;
				d.scissor.w += d.scissor.y;

				PE.render.toQueue(d);
				/* glBindTexture(GL_TEXTURE_2D, cast(GLuint)cmd.texture.id);
		glScissor(cast(GLint)(cmd.clip_rect.x * scale.x),
		cast(GLint)((height - cast(GLint)(cmd.clip_rect.y + cmd.clip_rect.h)) * scale.y),
		cast(GLint)(cmd.clip_rect.w * scale.x),
		cast(GLint)(cmd.clip_rect.h * scale.y));
		glDrawElements(GL_TRIANGLES, cast(GLsizei)cmd.elem_count, GL_UNSIGNED_INT, offset);*/
				offset += cmd.elem_count;
			}

		}

		PE.render.doDraw(_prog, RENDER_GUI, _proj, null, false);
	}

	void drawPopups()
	{
		foreach (pt; _texts)
		{
			auto s = pt.msg;
			assert(s.length);

			auto f = ctx.ctx.style.font;
			auto w = f.width(cast()f.userdata, f.height, s.ptr, cast(uint)s.length);

			pt.pos.x -= cast(short)w / 2;
			pt.pos.y -= cast(short)f.height / 2;

			auto lists = &ctx.ctx.draw_list;

			if (pt.fill)
			{
				auto r = nk_rect_(pt.pos.x - 2, pt.pos.y, w + 4, f.height);
				nk_draw_list_fill_rect(lists, r, nk_rgba(0, 0, 0, 128), 0);
			}

			auto c = nk_rgb(255, 255, 255);
			auto r = nk_rect_(pt.pos.x, pt.pos.y, w, f.height);

			foreach (x; -1 .. 2)
				foreach (y; -1 .. 2)
					if (x || y)
						nk_draw_list_add_text(lists, f, nk_rect(r.x + x, r.y + y, r.w, r.h), s.ptr, cast(uint)s.length,
								f.height, nk_rgb(0, 0, 0));

			nk_draw_list_add_text(lists, f, r, s.ptr, cast(uint)s.length, f.height, c);
		}

		_texts = null;
	}

private:
	NuklearContext _ctx;

	void onResize(Vector2s sz)
	{
		//root.size = sz;

		float[4][4] ortho = [
			[2.0f, 0.0f, 0.0f, 0.0f], [0.0f, -2.0f, 0.0f, 0.0f], [0.0f, 0.0f, -1.0f, 0.0f], [-1.0f, 1.0f, 0.0f, 1.0f],
		];
		ortho[0][0] /= sz.x;
		ortho[1][1] /= sz.y;

		_proj.A[] = ortho[];

		// foreach (c; root.childs)
		// {
		// 	if (c.end.x > sz.x || c.end.y > sz.y)
		// 	{
		// 		c.poseDefault;
		// 	}
		// }
	}

	RC!Program _prog;
	RC!TextInput _text;

	Matrix4 _proj;
	Vector2s _moveSub = -1.Vector2s;
}
