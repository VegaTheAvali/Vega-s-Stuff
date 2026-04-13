extern number time;
extern vec2 texture_details;
extern vec2 image_details;

vec4 effect(vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 tex = Texel(texture, texture_coords);


    // Center UV for radial calculations
    vec2 uv = texture_coords - vec2(0.5, 0.5);

    // Brightness masking
    float low = min(tex.r, min(tex.g, tex.b));
    float high = max(tex.r, max(tex.g, tex.b));
    float delta = min(high, max(0.5, 1.0 - low));

    // Time-based animation
    float t = time * 1.5;

    // Radial shimmer math
    float len1 = length(uv * 90.0);
    float len2 = length(uv * 113.1121);

    float wave =
        sin(len1 + t * 2.0 +
        3.0 * (1.0 + 0.8 * cos(len2 - t * 3.121)));

    float shine = clamp(
        2.0 * wave
        - 1.0
        - max(5.0 - len1, 0.0),
        0.0,
        1.0
    );

    // Green foil color (#37d46b)
    vec3 foil_color = vec3(0.216, 0.831, 0.420);

    // Apply foil effect
    tex.rgb += foil_color * shine * delta * 0.6;

    return tex * colour;
}