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
extern PRECISION vec2 event_horizon;

const float PI = 3.14159265359;

vec4 dissolve_mask(vec4 final_pixel, vec2 texture_coords, vec2 uv);

float hash21(vec2 p)
{
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float noise21(vec2 p)
{
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);

    float a = hash21(i);
    float b = hash21(i + vec2(1.0, 0.0));
    float c = hash21(i + vec2(0.0, 1.0));
    float d = hash21(i + vec2(1.0, 1.0));

    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p)
{
    float value = 0.0;
    float amp = 0.5;
    for (int i = 0; i < 5; i++) {
        value += noise21(p) * amp;
        p = mat2(1.61, -1.18, 1.18, 1.61) * p + vec2(7.3, 2.9);
        amp *= 0.52;
    }
    return value;
}

vec2 rotate2(vec2 p, float a)
{
    float s = sin(a);
    float c = cos(a);
    return vec2(c * p.x - s * p.y, s * p.x + c * p.y);
}

vec2 local_uv(vec2 texture_coords)
{
    return (((texture_coords) * image_details) - texture_details.xy * texture_details.zw) / texture_details.zw;
}

vec2 atlas_uv(vec2 uv)
{
    return (texture_details.xy + clamp(uv, vec2(0.003), vec2(0.997))) * texture_details.zw / image_details;
}

float ring(vec2 p, float radius, float width)
{
    return 1.0 - smoothstep(width * 0.35, width, abs(length(p) - radius));
}

float streak(vec2 p, float angle, float width)
{
    vec2 q = rotate2(p, angle);
    float beam = 1.0 - smoothstep(width * 0.35, width, abs(q.y));
    return beam * smoothstep(1.00, 0.06, abs(q.x));
}

vec3 palette(float x)
{
    vec3 a = vec3(0.48, 0.43, 0.58);
    vec3 b = vec3(0.50, 0.46, 0.42);
    vec3 c = vec3(1.00, 0.72, 0.58);
    vec3 d = vec3(0.66, 0.14, 0.92);
    return a + b * cos(6.28318 * (c * x + d));
}

vec4 sample_warped(Image texture, vec2 uv, vec2 pull, float chroma)
{
    vec2 ruv = atlas_uv(uv + pull * (1.00 + chroma));
    vec2 guv = atlas_uv(uv + pull * 0.75);
    vec2 buv = atlas_uv(uv + pull * (1.00 - chroma));

    vec4 r = Texel(texture, ruv);
    vec4 g = Texel(texture, guv);
    vec4 b = Texel(texture, buv);
    return vec4(r.r, g.g, b.b, g.a);
}

vec4 effect(vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec2 uv = local_uv(texture_coords);
    vec2 p = uv - 0.5;
    p.x *= texture_details.z / max(texture_details.w, 0.001);

    float payload = event_horizon.x + event_horizon.y * 0.071;
    float t = time * 0.86 + payload;
    float hover_push = 0.75 + hovering * 0.30;
    float mouse_trace = dot(mouse_screen_pos / max(screen_scale, 0.001), vec2(0.00031, 0.00023));

    float radius = length(p);
    float angle = atan(p.y, p.x);
    float gravity = 1.0 / (0.075 + radius * radius * 6.0);
    vec2 spin = normalize(vec2(-p.y, p.x) + vec2(0.001));
    vec2 inward = -normalize(p + vec2(0.001));

    float turbulent = fbm(uv * 5.0 + vec2(t * 0.33, -t * 0.21));
    float spiral = sin(angle * 5.0 + radius * 28.0 - t * 3.5 + turbulent * 3.0);
    vec2 pull = inward * gravity * 0.018 * hover_push;
    pull += spin * (0.012 * spiral + 0.010 * turbulent) * smoothstep(0.95, 0.08, radius);

    vec4 pixel = sample_warped(texture, uv + pull, pull, 0.0035 + gravity * 0.002) * colour;
    vec3 original = pixel.rgb;

    float disk = ring(p, 0.25 + 0.025 * sin(t * 1.4), 0.060);
    disk += ring(p, 0.38 + 0.018 * cos(t * 1.1), 0.030);
    disk += ring(p, 0.53, 0.018);
    disk *= 0.55 + 0.45 * sin(angle * 7.0 - t * 2.7 + turbulent * 4.0);

    float jet = streak(p, 0.16 + sin(t * 0.3) * 0.10, 0.018);
    jet += streak(p, PI + 0.16 + sin(t * 0.3) * 0.10, 0.018);
    jet *= smoothstep(0.46, 0.10, abs(p.y));

    float core = 1.0 - smoothstep(0.065, 0.155, radius);
    float lens_edge = ring(p, 0.16, 0.020) + ring(p, 0.21, 0.012);
    float star = pow(max(0.0, hash21(floor((uv + mouse_trace) * texture_details.zw * 0.40)) - 0.88), 5.0) * 240000.0;
    star *= 0.35 + 0.65 * sin(t * 4.0 + hash21(floor(uv * 37.0)) * 20.0);

    vec3 accretion = palette(t * 0.04 + angle / 6.28318 + turbulent * 0.5);
    vec3 violet_hot = vec3(0.95, 0.22, 1.00);
    vec3 cyan_hot = vec3(0.12, 0.88, 1.00);
    vec3 gold_hot = vec3(1.00, 0.72, 0.22);
    vec3 glow = mix(violet_hot, cyan_hot, smoothstep(-0.6, 0.8, spiral));
    glow = mix(glow, gold_hot, disk * 0.55);

    pixel.rgb = mix(pixel.rgb, pixel.rgb * vec3(0.34, 0.22, 0.50), core * 0.86);
    pixel.rgb += accretion * clamp(disk, 0.0, 1.0) * 0.34;
    pixel.rgb += glow * clamp(jet, 0.0, 1.0) * 0.22;
    pixel.rgb += vec3(0.88, 0.78, 1.00) * clamp(lens_edge, 0.0, 1.0) * 0.20;
    pixel.rgb += vec3(0.40, 0.75, 1.00) * clamp(star, 0.0, 1.0) * 0.14;
    pixel.rgb = mix(original, pixel.rgb, 0.82);
    pixel.rgb = clamp(pixel.rgb, vec3(0.0), vec3(1.18));

    return dissolve_mask(pixel, texture_coords, uv + screen_coords * 0.0);
}

vec4 dissolve_mask(vec4 final_pixel, vec2 texture_coords, vec2 uv)
{
    if (dissolve < 0.001) {
        return vec4(shadow ? vec3(0.0) : final_pixel.rgb, shadow ? final_pixel.a * 0.3 : final_pixel.a);
    }

    float adjusted_dissolve = (dissolve * dissolve * (3.0 - 2.0 * dissolve)) * 1.02 - 0.01;
    float t = time * 10.0 + 2003.0;
    vec2 floored_uv = floor(uv * texture_details.zw) / max(texture_details.z, texture_details.w);
    vec2 uv_scaled_centered = (floored_uv - 0.5) * 2.3 * max(texture_details.z, texture_details.w);

    vec2 field_part1 = uv_scaled_centered + 50.0 * vec2(sin(-t / 143.6340), cos(-t / 99.4324));
    vec2 field_part2 = uv_scaled_centered + 50.0 * vec2(cos(t / 53.1532), cos(t / 61.4532));
    vec2 field_part3 = uv_scaled_centered + 50.0 * vec2(sin(-t / 87.53218), sin(-t / 49.0000));

    float field = (1.0 + (
        cos(length(field_part1) / 19.483) +
        sin(length(field_part2) / 33.155) * cos(field_part2.y / 15.73) +
        cos(length(field_part3) / 27.193) * sin(field_part3.x / 21.92)
    )) / 2.0;

    vec2 borders = vec2(0.2, 0.8);
    float res = (0.5 + 0.5 * cos(adjusted_dissolve / 82.612 + (field - 0.5) * 3.14))
        - (floored_uv.x > borders.y ? (floored_uv.x - borders.y) * (5.0 + 5.0 * dissolve) : 0.0) * dissolve
        - (floored_uv.y > borders.y ? (floored_uv.y - borders.y) * (5.0 + 5.0 * dissolve) : 0.0) * dissolve
        - (floored_uv.x < borders.x ? (borders.x - floored_uv.x) * (5.0 + 5.0 * dissolve) : 0.0) * dissolve
        - (floored_uv.y < borders.x ? (borders.x - floored_uv.y) * (5.0 + 5.0 * dissolve) : 0.0) * dissolve;

    if (final_pixel.a > 0.01 && burn_colour_1.a > 0.01 && !shadow &&
        res < adjusted_dissolve + 0.8 * (0.5 - abs(adjusted_dissolve - 0.5)) && res > adjusted_dissolve) {
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
    float shimmer = sin(time * 5.0 + mouse_offset.x * 0.20) * cos(time * 3.0 - mouse_offset.y * 0.16);

    return transform_projection * vertex_position + vec4(0.0, 0.0, 0.0, scale + shimmer * hovering * 0.003);
}
#endif
