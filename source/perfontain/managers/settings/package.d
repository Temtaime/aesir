module perfontain.managers.settings;

import
		std.meta,
		std.range,
		std.traits,
		std.typecons,
		std.algorithm,

		perfontain,
		perfontain.opengl,

		perfontain.managers.shadow;

public import
				perfontain.managers.settings.data;


final class SettingsManager
{
	this()
	{
		try
		{
			_st = PEfs.read!Settings(SETTINGS_FILE);
		}
		catch {}
	}

	~this()
	{
		save;
	}

	void disableUnsupported()
	{
		_st.useBindless &= GL_ARB_bindless_texture;
		save;
	}

	mixin(genSettings);
private:
	const save()
	{
		PEfs.write(SETTINGS_FILE, _st);
	}

	Settings _st;
}
