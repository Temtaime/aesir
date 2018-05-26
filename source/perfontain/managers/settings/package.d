module perfontain.managers.settings;

import
		std.experimental.all,

		perfontain,
		perfontain.opengl,

		perfontain.managers.shadow;

public import
				perfontain.managers.settings.data;


final class SettingsManager
{
	this()
	{
		auto j = PEfs.get(SETTINGS_FILE)
										.assumeUTF
										.parseJSON
										.ifThrown(JSONValue.init);

		{
			static foreach(s; [ `lights`, `shadows` ])
			{
				collectException(mixin(`_st.` ~ s) = cast(ubyte)j[s].integer);
			}

			with(_st)
			{
				if(lights > LIGHTS_FULL) lights = 0;
				if(shadows > SHADOWS_ULTRA) shadows = 0;
			}
		}

		static foreach(s; [ `fog`, `vsync`, `msaa`, `fullscreen`, `useBindless` ])
		{
			collectException(mixin(`_st.` ~ s) = j[s].type == JSON_TYPE.TRUE);
		}

		try
		{
			foreach(name, w; j[`wins`].object)
			{
				collectException(_st.wins[name] = WindowData(Vector2s(w[`x`].integer, w[`y`].integer)));
			}

			foreach(name, arr; j[`hotkeys`].object)
			{
				collectException(_st.hotkeys[name] = arr.array.map!(a => cast(SDL_Keycode)a.integer).array);
			}
		}
		catch(Exception)
		{}
	}

	void disableUnsupported()
	{
		_st.useBindless &= GL_ARB_bindless_texture;
		save;
	}

	~this()
	{
		save;
	}

	mixin(genSettings);
private:
	const save()
	{
		JSONValue j;

		static foreach(s; [ `fog`, `vsync`, `msaa`, `fullscreen`, `useBindless`, `lights`, `shadows`, `hotkeys` ])
		{
			j[s] = mixin(`_st.` ~ s);
		}

		{
			JSONValue[string] arr;

			foreach(s, w; _st.wins)
			{
				JSONValue u;

				u[`x`] = w.pos.x;
				u[`y`] = w.pos.y;

				arr[s] = u;
			}

			j[`wins`] = arr;
		}

		PEfs.put(SETTINGS_FILE, j.toJSON);
	}

	Settings _st;
}
