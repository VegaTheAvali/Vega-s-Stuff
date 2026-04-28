#if defined(VERTEX) || __VERSION__ > 100 || defined(GL_FRAGMENT_PRECISION_HIGH)
    #define PRECISION highp
#else
    #define PRECISION mediump
#endif

#define CIRCLE_RADIUS 0.5
#define CIRCLE_SMOOTHNESS 0.4
#define BLOOM_STEPS 10

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
extern PRECISION vec2 singularity;

vec4 dissolve_mask(vec4 final_pixel, vec2 texture_coords, vec2 uv);

vec2 local_uv(vec2 texture_coords)
{
    return (((texture_coords) * image_details) - texture_details.xy * texture_details.zw) / texture_details.zw;
}

vec2 atlas_uv(vec2 uv)
{
    return (texture_details.xy + clamp(uv, vec2(0.002), vec2(0.998))) * texture_details.zw / image_details;
}

float soft_card_bounds(vec2 uv)
{
    float left = smoothstep(-0.01, 0.025, uv.x);
    float right = 1.0 - smoothstep(0.975, 1.01, uv.x);
    float top = smoothstep(-0.01, 0.025, uv.y);
    float bottom = 1.0 - smoothstep(0.975, 1.01, uv.y);
    return left * right * top * bottom;
}

vec3 palette(float t)
{
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.263, 0.416, 0.557);

    return a + b * cos(6.28318 * (c * t + d));
}


vec3 random3(vec3 st)
{
    st = vec3(
        dot(st, vec3(127.1, 311.7, 211.2)),
        dot(st, vec3(269.5, 183.3, 157.1)),
        dot(st, vec3(269.5, 183.3, 17.1))
    );
    return -1.0 + 2.0 * fract(sin(st) * 43758.5453123);
}

float noise(vec3 st)
{
    vec3 i = floor(st);
    vec3 f = fract(st);
    vec3 u = smoothstep(0.0, 1.0, f);

    float value_now_xy01 = mix(
        mix(
            dot(random3(i + vec3(0.0, 0.0, 0.0)), f - vec3(0.0, 0.0, 0.0)),
            dot(random3(i + vec3(1.0, 0.0, 0.0)), f - vec3(1.0, 0.0, 0.0)),
            u.x
        ),
        mix(
            dot(random3(i + vec3(0.0, 1.0, 0.0)), f - vec3(0.0, 1.0, 0.0)),
            dot(random3(i + vec3(1.0, 1.0, 0.0)), f - vec3(1.0, 1.0, 0.0)),
            u.x
        ),
        u.y
    );

    float value_now_xy02 = mix(
        mix(
            dot(random3(i + vec3(0.0, 0.0, 1.0)), f - vec3(0.0, 0.0, 1.0)),
            dot(random3(i + vec3(1.0, 0.0, 1.0)), f - vec3(1.0, 0.0, 1.0)),
            u.x
        ),
        mix(
            dot(random3(i + vec3(0.0, 1.0, 1.0)), f - vec3(0.0, 1.0, 1.0)),
            dot(random3(i + vec3(1.0, 1.0, 1.0)), f - vec3(1.0, 1.0, 1.0)),
            u.x
        ),
        u.y
    );

    return abs(mix(value_now_xy01, value_now_xy02, u.z));
}

float sd_circle(vec2 p, float r, float s)
{
    float c = length(p);
    c = smoothstep(r - s, r, c);
    c = abs(1.0 - c);
    return c;
}

vec2 normalize_length(vec2 noise_uv, vec2 uv, float scale)
{
    float curr_length = max(length(noise_uv), 0.0001);
    vec2 uv_output = vec2(noise_uv.x * 2.0 / curr_length, noise_uv.y * 2.0 / curr_length);

    vec2 scaled_uv = uv * scale;
    float mix_val = clamp(sd_circle(scaled_uv, CIRCLE_RADIUS * scale, CIRCLE_SMOOTHNESS * scale), 0.0, 1.0);
    return mix(uv_output, scaled_uv, mix_val);
}

vec2 rotate_point(vec2 p, float angle)
{
    float s = sin(angle);
    float c = cos(angle);
    return vec2(c * p.x - s * p.y, s * p.x + c * p.y);
}

float lens_amount(vec2 p)
{
    float r = max(length(p), 0.045);
    return clamp(0.070 / (r * r + 0.050), 0.0, 0.24);
}

vec4 effect(vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec2 card_uv = local_uv(texture_coords);
    float card_mask = soft_card_bounds(card_uv);

    float real_time = singularity.y;
    float shader_time = real_time * 1.35 + time * 0.001;
    float aspect = texture_details.z / max(texture_details.w, 1.0);

    vec2 uv = (card_uv * 2.0 - 1.0) * vec2(aspect, 1.0);
    uv = rotate_point(uv, real_time * 0.18 + 0.10 * sin(real_time * 0.47 + singularity.x * 0.10));

    float c = sd_circle(uv, CIRCLE_RADIUS, CIRCLE_SMOOTHNESS);
    float noise_scale = 2.0;
    vec2 noise_uv = normalize_length(uv, uv, noise_scale);
    noise_uv = rotate_point(noise_uv, real_time * 0.32);
    noise_uv += vec2(sin(real_time * 0.72), cos(real_time * 0.53)) * 0.62;
    float noise_tex = noise(vec3(noise_uv, shader_time));
    noise_tex = smoothstep(0.1, 0.8, noise_tex);

    c *= noise_tex;

    for (int idx = 1; idx < BLOOM_STEPS; idx++) {
        float i = float(idx);
        float step_circle = sd_circle(uv, CIRCLE_RADIUS + (1.9 * (i / float(BLOOM_STEPS))), CIRCLE_SMOOTHNESS);
        step_circle *= abs(1.0 - (i / float(BLOOM_STEPS)));
        step_circle *= noise_tex * (0.72 + 0.28 * sin(real_time * 1.7 - i * 0.61));
        c += step_circle;
    }

    float r = max(length(uv), 0.035);
    float angle = atan(uv.y, uv.x);
    float travelling_wave = 0.55 + 0.45 * sin(angle * 8.0 - real_time * 3.2 + noise_tex * 4.0);
    c *= 0.68 + travelling_wave * 0.58;

    float void_core = 1.0 - smoothstep(0.075, 0.235 + 0.018 * sin(real_time * 2.4), r);
    float photon_ring = 1.0 - smoothstep(0.012, 0.050, abs(r - 0.245 - sin(angle * 14.0 - real_time * 3.1) * 0.014));

    vec2 pull = normalize(uv) * lens_amount(uv);
    vec2 swirl = vec2(-uv.y, uv.x) * (0.080 / (r + 0.16));
    vec2 warped_uv = card_uv - pull * 0.115 + swirl * sin(real_time * 0.52 + r * 7.5) * 0.035;

    vec4 base = Texel(texture, atlas_uv(warped_uv)) * colour;
    vec4 base_r = Texel(texture, atlas_uv(warped_uv + pull * 0.030)) * colour;
    vec4 base_b = Texel(texture, atlas_uv(warped_uv - pull * 0.040)) * colour;
    vec4 pixel = vec4(base_r.r, base.g, base_b.b, base.a);

    vec3 singularity_colour = palette(length(noise_uv) + real_time * 0.13) * c;
    singularity_colour += vec3(0.70, 0.88, 1.00) * photon_ring * 0.52;
    singularity_colour += vec3(0.30, 0.60, 1.00) * noise_tex * (1.0 - smoothstep(0.18, 0.78, r)) * 0.35;

    pixel.rgb = mix(pixel.rgb, pixel.rgb * vec3(0.30, 0.42, 0.88), 0.34);
    pixel.rgb += singularity_colour * 0.92;
    pixel.rgb = mix(pixel.rgb, vec3(0.0, 0.0, 0.018), void_core * 0.93);
    pixel.rgb += vec3(0.82, 0.94, 1.00) * photon_ring * 0.18;
    pixel.rgb = clamp(pixel.rgb, vec3(0.0), vec3(1.25));
    pixel.a *= smoothstep(0.02, 0.16, pixel.a) * card_mask;

    return dissolve_mask(pixel, texture_coords, card_uv);
}

vec4 dissolve_mask(vec4 final_pixel, vec2 texture_coords, vec2 uv)
{
    if (dissolve < 0.001) {
        return vec4(shadow ? vec3(0.0) : final_pixel.rgb, shadow ? final_pixel.a * 0.3 : final_pixel.a);
    }

    float adjusted_dissolve = (dissolve * dissolve * (3.0 - 2.0 * dissolve)) * 1.02 - 0.01;
    float t = singularity.y * 10.0 + time * 0.01 + 2003.0;
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

