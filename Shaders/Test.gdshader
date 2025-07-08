shader_type spatial;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

void fragment() {
    float depth_raw = texture(DEPTH_TEXTURE, SCREEN_UV).r;
    ALBEDO = vec3(depth_raw); // Visualize raw depth texture (0 to 1 range)
}
