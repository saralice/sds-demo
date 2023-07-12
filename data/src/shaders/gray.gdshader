shader_type canvas_item;

uniform float gray_level = 3.0;

void fragment() {
    COLOR = texture(TEXTURE, UV);
    float avg = (COLOR.r + COLOR.g + COLOR.b) / gray_level;
    COLOR.rgb = vec3(avg);
}