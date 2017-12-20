module perfontain.shader.types;

import
		perfontain.opengl;

enum
{
	SHADER_VERTEX,
	SHADER_GEOMETRY,
	SHADER_FRAGMENT,
	SHADER_TESS_CONTROL,
	SHADER_TESS_EVALUATION,
	SHADER_COMPUTE,
	SHADER_MAX
}

package:

static immutable shaderBits =
[
	GL_VERTEX_SHADER_BIT,
	GL_FRAGMENT_SHADER_BIT,
	GL_GEOMETRY_SHADER_BIT,
	GL_TESS_CONTROL_SHADER_BIT,
	GL_TESS_EVALUATION_SHADER_BIT,
	GL_COMPUTE_SHADER_BIT
];

static immutable shaderTypes =
[
	GL_VERTEX_SHADER,
	GL_GEOMETRY_SHADER,
	GL_FRAGMENT_SHADER,
	GL_TESS_CONTROL_SHADER,
	GL_TESS_EVALUATION_SHADER,
	GL_COMPUTE_SHADER,
];

static immutable shaderNames =
[
	`vertex`,
	`geometry`,
	`fragment`,
	`tess_control`,
	`tess_eval`,
	`compute`,
];
