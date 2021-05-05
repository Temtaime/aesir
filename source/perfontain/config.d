module perfontain.config;
import perfontain.vbo, perfontain.misc, perfontain.math.matrix;

enum
{
	// core
	MSAA_LEVEL = 4,

	ANGLE_DIR = `angle`,
	OPENGL_VERSION = 31,

	MAX_LAYERS = 4,

	IDLE_FPS = 20,
	FPS_UPDATE_TIME = 1000,

	// quality
	NORMAL_SMOOTH_ANGLE = 70,

	// performance
	USE_FAST_DXT = true,

	// misc
	LOG_FILE = `perfontain.log`,
	SETTINGS_FILE = `settings.dat`,
}

static immutable
{
	uint[3] triangleOrder = [0, 1, 2], triangleOrderReversed = [2, 1, 0];

	auto noBlending = packModes(2, 1);
	auto blendingNormal = packModes(5, 6);
}
