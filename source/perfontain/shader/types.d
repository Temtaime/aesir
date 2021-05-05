module perfontain.shader.types;

import perfontain.opengl;

enum
{
	SHADER_VERTEX,
	SHADER_FRAGMENT,
	SHADER_COMPUTE,
	SHADER_MAX
}

package:

static immutable shaderBits = [
	GL_VERTEX_SHADER_BIT_EXT, GL_FRAGMENT_SHADER_BIT_EXT, GL_COMPUTE_SHADER_BIT
];

static immutable shaderTypes = [
	GL_VERTEX_SHADER, GL_FRAGMENT_SHADER, GL_COMPUTE_SHADER
];

static immutable shaderNames = [`vertex`, `fragment`, `compute`];
