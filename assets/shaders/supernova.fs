#if defined(VERTEX) || __VERSION__ > 100 || defined(GL_FRAGMENT_PRECISION_HIGH)
    #define PRECISION highp
#else
    #define PRECISION mediump
#endif

extern PRECISION number dissolve;
extern PRECISION number time;
extern PRECISION vec4 texture_details;
extern PRECISION vec2 image_details;
extern bool shadow;
extern PRECISION vec4 burn_colour_1;
extern PRECISION vec4 burn_colour_2;
extern PRECISION vec2 mouse_screen_pos;
extern PRECISION float hovering;
extern PRECISION float screen_scale;
extern PRECISION vec2 supernova;

vec4 dissolve_mask(vec4 final_pixel, vec2 texture_coords, vec2 uv);

vec2 local_uv(vec2 texture_coords)
{
    return (((texture_coords) * image_details) - texture_details.xy * texture_details.zw) / texture_details.zw;
}

vec2 atlas_uv(vec2 uv)
{
    return (texture_details.xy + clamp(uv, vec2(0.003), vec2(0.997))) * texture_details.zw / image_details;
}

float soft_card_bounds(vec2 uv)
{
    float left = smoothstep(-0.01, 0.025, uv.x);
    float right = 1.0 - smoothstep(0.975, 1.01, uv.x);
    float top = smoothstep(-0.01, 0.025, uv.y);
    float bottom = 1.0 - smoothstep(0.975, 1.01, uv.y);
    return left * right * top * bottom;
}

vec4 effect(vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec2 card_uv = local_uv(texture_coords);
    vec4 base = Texel(texture, texture_coords) * colour;

    float uniform_keepalive = dot(mouse_screen_pos, vec2(0.000000001)) / max(screen_scale, 0.001)
        + burn_colour_1.x * 0.000000001
        + burn_colour_2.x * 0.000000001
        + supernova.x * 0.000000001
        + (shadow ? 0.000000001 : 0.0);

    vec2 uv = card_uv - vec2(0.5, 0.5);
    uv.x *= texture_details.z / max(texture_details.w, 1.0);

    float t = supernova.y + time * 0.001 + uniform_keepalive;
    float r = length(uv);
    float a = atan(uv.y, uv.x);

    float waves = sin(10.0 * r - t * 2.0 + sin(3.0 * a + t))
        + cos(6.0 * r + t * 1.5 + cos(5.0 * a - t * 0.5));
    float spiral = sin(a * 8.0 + t * 2.0) * 0.2;
    float pattern = sin(20.0 * r + spiral + waves);

    vec3 green_purple = vec3(
        0.75 + 0.5 * sin(t + pattern + 0.0),
        0.50 + 0.5 * sin(t + pattern + 2.0),
        0.75 + 0.5 * sin(t + pattern + 4.0)
    );

    vec3 shader_colour = mix(vec3(0.1, 0.9, 0.2), vec3(0.6, 0.2, 0.7), green_purple);
    float glow = 2.5 / (1.0 + 10.0 * r * r);
    shader_colour *= glow;

    float mask = smoothstep(0.02, 0.16, base.a) * soft_card_bounds(card_uv);
    float overlay = 0.48 * mask;
    base.rgb = mix(base.rgb * vec3(0.74, 0.92, 0.78), shader_colour, overlay);
    base.rgb += shader_colour * 0.06 * mask;
    base.rgb = clamp(base.rgb, vec3(0.0), vec3(1.20));
    base.a *= mask;

    return dissolve_mask(base, texture_coords, card_uv + uniform_keepalive);
}

vec4 dissolve_mask(vec4 final_pixel, vec2 texture_coords, vec2 uv)
{
    if (dissolve < 0.001) {
        return vec4(shadow ? vec3(0.0) : final_pixel.rgb, shadow ? final_pixel.a * 0.3 : final_pixel.a);
    }

    float adjusted_dissolve = (dissolve * dissolve * (3.0 - 2.0 * dissolve)) * 1.02 - 0.01;
    float t = supernova.y * 10.0 + time * 0.01 + 2003.0;
    vec2 floored_uv = floor(uv * texture_details.zw) / max(texture_details.z, texture_details.w);
    vec2 q = (floored_uv - 0.5) * 2.3 * max(texture_details.z, texture_details.w);

    float field = (1.0 + cos(length(q + 50.0 * vec2(sin(-t / 143.6340), cos(-t / 99.4324))) / 19.483)
        + sin(length(q + 50.0 * vec2(cos(t / 53.1532), cos(t / 61.4532))) / 33.155)) / 2.0;
    vec2 borders = vec2(0.2, 0.8);
    float res = (0.5 + 0.5 * cos(adjusted_dissolve / 82.612 + (field - 0.5) * 3.14))
        - (floored_uv.x > borders.y ? (floored_uv.x - borders.y) * (5.0 + 5.0 * dissolve) : 0.0) * dissolve
        - (floored_uv.y > borders.y ? (floored_uv.y - borders.y) * (5.0 + 5.0 * dissolve) : 0.0) * dissolve
        - (floored_uv.x < borders.x ? (borders.x - floored_uv.x) * (5.0 + 5.0 * dissolve) : 0.0) * dissolve
        - (floored_uv.y < borders.x ? (borders.x - floored_uv.y) * (5.0 + 5.0 * dissolve) : 0.0) * dissolve;

    if (final_pixel.a > 0.01 && burn_colour_1.a > 0.01 && !shadow
        && res < adjusted_dissolve + 0.8 * (0.5 - abs(adjusted_dissolve - 0.5))
        && res > adjusted_dissolve) {
        if (res < adjusted_dissolve + 0.5 * (0.5 - abs(adjusted_dissolve - 0.5))) {
            final_pixel.rgba = burn_colour_1.rgba;
        } else if (burn_colour_2.a > 0.01) {
            final_pixel.rgba = burn_colour_2.rgba;
        }
    }

    return vec4(shadow ? vec3(0.0) : final_pixel.rgb,
        res > adjusted_dissolve ? (shadow ? final_pixel.a * 0.3 : final_pixel.a) : 0.0);
}

#ifdef VERTEX
vec4 position(mat4 transform_projection, vec4 vertex_position)
{
    if (hovering <= 0.0) {
        return transform_projection * vertex_position;
    }

    float mid_dist = length(vertex_position.xy - 0.5 * love_ScreenSize.xy) / length(love_ScreenSize.xy);
    vec2 mouse_offset = (vertex_position.xy - mouse_screen_pos.xy) / screen_scale;
    float scale = 0.2 * (-0.03 - 0.3 * max(0.0, 0.3 - mid_dist))
        * hovering * (length(mouse_offset) * length(mouse_offset)) / (2.0 - mid_dist);

    return transform_projection * vertex_position + vec4(0.0, 0.0, 0.0, scale);
}
#endif
