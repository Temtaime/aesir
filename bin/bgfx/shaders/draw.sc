#define LIGHT_DIFFUSE vec3(0.6, 0.4, 0.7)
#define LIGHT_DIR vec3(0.709407, -0.573576, -0.409576)
#define VIEWPORT_SIZE ivec2(3740, 2070)
#define SHADOWS_FLIP_Y
#define LIGHT_AMBIENT vec3(0.245, 0.21, 0.245)
#define LIGHTS_FULL
#define SHADOWS_ENABLED
#if BGFX_SHADER_TYPE_VERTEX

$input a_position, a_normal, a_texcoord0
$output v_texcoord0

#ifdef SHADOWS_ENABLED
$output v_shadowPos
#endif
#ifdef LIGHTS_FULL
$output v_normal, v_worldPos
#endif

#include "bgfx_shader.sh"

#ifdef SHADOWS_ENABLED
uniform mat4 u_shadowMatrix;
uniform mat4 u_shadowModel;
#endif
#ifdef LIGHTS_FULL
uniform mat4 u_lightingModel;
#endif

void main()
{
	v_texcoord0 = a_texcoord0;
#ifdef SHADOWS_ENABLED
	v_shadowPos = mul(u_shadowMatrix, mul(u_shadowModel, vec4(a_position, 1.0)));
#endif
#ifdef LIGHTS_FULL
	v_normal = mul(u_lightingModel, vec4(a_normal, 0.0)).xyz;
	v_worldPos = mul(u_lightingModel, vec4(a_position, 1.0)).xyz;
#endif
	gl_Position = mul(u_modelViewProj, vec4(a_position, 1.0));
}

#else

$input v_texcoord0

#ifdef SHADOWS_ENABLED
$input v_shadowPos
#endif
#ifdef LIGHTS_FULL
$input v_normal, v_worldPos
#endif

#include "bgfx_shader.sh"

SAMPLER2D(s_texMain, 0);
#ifdef SHADOWS_ENABLED
SAMPLER2D(s_shadowMap, 1);
#endif
#ifdef LIGHTS_FULL
USAMPLER2D(s_lightsIndices, 2);
uniform vec4 u_lights[256];
uniform vec4 u_lightsInfo;
#include "lighting.sc"
#endif
uniform vec4 u_color;

void main()
{
	vec4 color = texture2D(s_texMain, v_texcoord0);

	if (color.a < 0.05)
		discard;

#ifdef SHADOWS_ENABLED
	vec3 shadowCoord = v_shadowPos.xyz / v_shadowPos.w;
#ifdef SHADOWS_FLIP_Y
	shadowCoord.y = 1.0 - shadowCoord.y;
#endif
	float shadow = step(shadowCoord.z - 0.001, texture2D(s_shadowMap, shadowCoord.xy).x);
	color.rgb *= 0.5 + shadow * 0.5;
#endif
#ifdef LIGHTS_FULL
	calcLights(color.rgb, normalize(v_normal), v_worldPos, ivec2(gl_FragCoord.xy));
#endif
	gl_FragColor = color * u_color;
}

#endif

