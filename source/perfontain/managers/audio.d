module perfontain.managers.audio;
import std.string, derelict.sdl2.sdl, derelict.sdl2.mixer, perfontain, utile.except;

final class AudioManager
{
	this()
	{
		if (Mix_OpenAudio(MIX_DEFAULT_FREQUENCY, MIX_DEFAULT_FORMAT, 2, 1024))
		{
			logMixerError;
			return;
		}

		_ok = true;
		Mix_AllocateChannels(32);
	}

	~this()
	{
		//foreach(ch; _sounds.keys)
		//	removeAudio(ch);
		//Mix_CloseAudio();
	}

	void play(string name, bool loop = false)
	{
		if (!_ok)
		{
			return;
		}

		auto sound = _audios.get(name, null);

		if (!sound)
		{
			const(void)[] data;

			try
			{
				data = PEfs.get(name);
			}
			catch (Exception)
			{
				logger.warning!"can't find `%s' audio"(name);
				return;
			}

			auto mem = SDL_RWFromConstMem(data.ptr, cast(uint)data.length);
			sound = Mix_LoadWAV_RW(mem, true);

			if (!sound)
			{
				logMixerError;
				return;
			}

			_audios[name] = sound;
		}

		int ch = Mix_PlayChannel(-1, sound, loop ? -1 : 0);

		if (ch >= 0)
		{
			_sounds[ch] = sound;
		}
	}

private:
	void stop(int ch)
	{
		if (ch >= 0)
		{
			removeAudio(ch);
		}
	}

	void removeAudio(int ch, bool force = true)
	{
		if (force)
		{
			Mix_HaltChannel(ch);
		}

		Mix_FreeChunk(_sounds[ch]);
		_sounds.remove(ch);
	}

	void logMixerError()
	{
		logger.error!`SDL mixer error: %s`(Mix_GetError().fromStringz);
	}

	bool _ok;

	Mix_Chunk*[int] _sounds;
	Mix_Chunk*[string] _audios;
}

/*struct Cache(K, V)
{

private:
	struct S
	{
		uint _used;
	}
}*/
