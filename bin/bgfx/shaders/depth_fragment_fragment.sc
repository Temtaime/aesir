$input v_color0
#include "bgfx_shader.sh"
void main()
{
	gl_FragColor = vec4(vec3_splat(gl_FragCoord.z), 1.0);
}
