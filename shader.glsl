#version 120  // Specify GLSL version for compatibility

extern float time;

void main() {
    vec2 screen_coords = gl_FragCoord.xy;

    // Create a moving gradient effect based on time
    float r = 0.5 + 0.5 * sin(time + screen_coords.x * 0.1);
    float g = 0.5 + 0.5 * cos(time + screen_coords.y * 0.1);
    float b = 0.5 + 0.5 * sin(time + screen_coords.x * 0.1 + screen_coords.y * 0.1);

    // Set the color of the fragment
    gl_FragColor = vec4(r, g, b, 1.0);
}
