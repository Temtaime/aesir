module perfontain.managers.texture;

import
		std.algorithm,

		perfontain;

public import
				perfontain.managers.texture.texture;


final class TextureManager
{
	this()
	{
		PE.timers.add(&onUnresident, T, 0);
	}

	void use(const Texture t)
	{
		if(!(t in _aa))
		{
			t.resident = true;
		}

		_aa[t] = PE.tick;
	}

package:
	void remove(Texture t)
	{
		if(t in _aa)
		{
			_aa.remove(t);
			t.resident = false;
		}
	}

private:
	enum T = 500;

	void onUnresident()
	{
		foreach(tex; _aa.keys)
		{
			if(PE.tick - _aa[tex] >= T)
			{
				_aa.remove(tex);
				tex.resident = false;
			}
		}

		//log(`%u textures alive`, _aa.length);
	}

	uint[const(Texture)] _aa;
}
