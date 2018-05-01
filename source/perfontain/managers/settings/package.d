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
			foreach(idx, w; j[`wins`].object)
			{
				WindowData data;

				data.pos = Vector2s(w[`x`].integer.ifThrown(0),
									w[`y`].integer.ifThrown(0));

				_st.wins[idx] = data;
			}

			foreach(k, arr; j[`hotkeys`].object)
			{
				auto e = arr.array.map!(a => cast(uint)a.integer.ifThrown(0)).array;

				if(k.length && e.all)
				{
					_st.hotkeys[k] = e;
				}
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
