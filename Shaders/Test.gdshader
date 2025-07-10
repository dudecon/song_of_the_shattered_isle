shader_type spatial;
// Prevent the quad from being affected by lighting and fog. This also improves performance.
render_mode unshaded, fog_disabled;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

void fragment() {
    float depth_raw = texture(DEPTH_TEXTURE, SCREEN_UV).x;
	
    ALBEDO.rgb = vec3(depth_raw); // Visualize raw depth texture (0 to 1 range)
	
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth_raw);
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
    view.xyz /= view.w;
    float linear_depth = -view.z;

    // Visualize linear depth
    //ALBEDO.rgb = vec3(fract(linear_depth));
}
