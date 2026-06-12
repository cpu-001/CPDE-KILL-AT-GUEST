shader_type canvas_item;

uniform vec4 color_azul : source_color = vec4(0.1, 0.4, 1.0, 1.0);

void fragment() {
    float t = UV.y;

    vec4 inicio = color_azul;               // Azul opaco
    vec4 fin = vec4(color_azul.rgb, 0.0);   // Azul transparente

    COLOR = mix(inicio, fin, t);
}