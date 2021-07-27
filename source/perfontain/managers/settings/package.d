module perfontain.managers.settings;
import std, perfontain, perfontain.opengl, perfontain.managers.shadow, utile.encrypt;

public import perfontain.managers.settings.data;

final class SettingsManager
{
	this()
	{
		auto data = PEfs.get(SETTINGS_FILE);
		rc4.process(data);

		if (data.empty || !data.isValid)
			return;

		try
		{
			auto json = data.assumeUTF.parseJSON;

			static foreach (name; settingNames)
			{
				try
				{
					load(json[name], mixin(name));
				}
				catch (Exception e)
				{
					logger.error!`cannot parse setting %s: %s`(name, e.msg);
				}
			}
		}
		catch (Exception ex)
		{
			logger.error!`cannot parse %s: %s`(SETTINGS_FILE, ex.msg);
		}
	}

	~this()
	{
		JSONValue json;

		static foreach (name; settingNames)
		{
			json[name] = jsonize(mixin(name));
		}

		auto data = json.toJSON.representation.dup;
		rc4.process(data);

		PEfs.put(SETTINGS_FILE, data);
	}

	mixin Setting!(bool, `fog`, true);
	mixin Setting!(bool, `vsync`, true);
	mixin Setting!(bool, `msaa`, false);
	mixin Setting!(bool, `fullscreen`, false);

	mixin Setting!(Lights, `lights`, Lights.global);
	mixin Setting!(Shadows, `shadows`, Shadows.medium);

	Tuple!(string, `user`, string, `pass`)[] accounts;
private:
	static settingNames() // TODO: BUGREPORT
	{
		string[] arr;

		foreach (name; __traits(allMembers, typeof(this)))
			if (is(typeof(mixin(name).offsetof)) && !name.endsWith(`Change`)) // TODO: more elegant way
				arr ~= name;

		return arr;
	}

	static jsonize(T)(T value)
	{
		static if (isDynamicArray!T)
		{
			return value.map!jsonize.array.JSONValue;
		}
		else
		{
			static if (isTuple!T)
			{
				JSONValue[string] aa;

				static foreach (i, name; T.fieldNames)
				{
					aa[name] = value[i].JSONValue;
				}

				return JSONValue(aa);
			}
			else
				return JSONValue(value);
		}
	}

	static load(T)(in JSONValue json, ref T value)
	{
		static if (is(T == string))
		{
			value = json.str;
		}
		else static if (isTuple!T)
		{
			T v;

			static foreach (i, name; T.fieldNames)
			{
				{
					T.Types[i] u;
					load(json[name], u);
					v[i] = u;
				}
			}

			value = v;
		}
		else static if (isDynamicArray!T)
		{
			T arr;

			foreach (j; json.array)
			{
				ElementType!T e;
				load(j, e);
				arr ~= e;
			}

			value = arr;
		}
		else static if (is(T == enum))
		{
			auto k = json.integer;

			if (only(EnumMembers!T).canFind(k))
			{
				value = cast(T)k;
			}
		}
		else static if (isBoolean!T)
		{
			value = json.boolean;
		}
		else
			static assert(false);
	}

	static rc4() => RC4(thisExePath);
}
