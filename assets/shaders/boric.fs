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
extern PRECISION vec2 boric;

vec4 dissolve_mask(vec4 final_pixel, vec2 texture_coords, vec2 uv);

float hash21(vec2 p)
{
    p = fract(p * vec2(123.34, 345.45));
    p += dot(p, p + 34.345);
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
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 4; i++) {
        v += a * noise21(p);
        p = p * 2.02 + vec2(13.1, 7.3);
        a *= 0.5;
    }
    return v;
}

vec4 effect(vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec2 uv = (((texture_coords) * (image_details)) - texture_details.xy * texture_details.zw) / texture_details.zw;
    vec4 pixel = Texel(texture, texture_coords);

    
    float t = boric.y;
    
    float intensity = clamp(1.20 + boric.x * 0.06, 1.0, 1.7);

    
    float y = 1.0 - uv.y;
    vec2 p = vec2((uv.x - 0.5) * 2.0, y);

    
    float edge_noise = fbm(vec2(uv.x * 6.0, 2.0));
    float top_cut = 0.74 + (edge_noise - 0.5) * 0.04;
    float vertical_mask = 1.0 - smoothstep(top_cut, top_cut + 0.10, y);

    
    float wobble = 0.10 * sin(t * 1.8 + y * 8.0) + 0.06 * sin(t * 3.1 - y * 13.0);
    float half_width = mix(1.05, 0.18, smoothstep(0.00, 1.10, y));
    float body_shape = 1.0 - smoothstep(half_width, half_width + 0.09, abs(p.x + wobble));

    
    float tongue_wave = sin((p.x * 7.0 - t * 2.3) + fbm(vec2(p.x * 2.5, y * 3.0 - t * 0.6)) * 2.0) * 0.5 + 0.5;
    float tongue_cut = smoothstep(0.38, 0.88, tongue_wave) * smoothstep(0.22, 0.90, y) * (1.0 - smoothstep(0.90, 1.30, y));

    float flame = clamp(body_shape - tongue_cut * 0.14, 0.0, 1.0) * vertical_mask;
    flame *= mix(0.9, 1.1, (intensity - 1.0) / 0.7);

    
    float band_a = smoothstep(0.20, 0.55, flame);
    float band_b = smoothstep(0.55, 0.82, flame);
    float band_c = smoothstep(0.82, 1.00, flame);

    vec3 fire_outer = vec3(0.08, 0.46, 0.10);
    vec3 fire_mid = vec3(0.16, 0.72, 0.18);
    vec3 fire_inner = vec3(0.42, 0.94, 0.34);
    vec3 fire_core = vec3(0.80, 1.00, 0.62);

    vec3 flame_col = mix(fire_outer, fire_mid, band_a);
    flame_col = mix(flame_col, fire_inner, band_b);
    flame_col = mix(flame_col, fire_core, band_c);

    
    float base_fill = smoothstep(0.04, 0.22, body_shape * vertical_mask);
    pixel.rgb = mix(pixel.rgb, fire_outer, base_fill * 0.45);

    float blend = clamp(flame * 0.54, 0.0, 1.0);
    pixel.rgb = mix(pixel.rgb, flame_col, blend);
    pixel.rgb += fire_core * band_c * 0.06;

    return dissolve_mask(pixel * colour, texture_coords, uv);
}

vec4 dissolve_mask(vec4 final_pixel, vec2 texture_coords, vec2 uv)
{
    if (dissolve < 0.001) {
        return vec4(shadow ? vec3(0.,0.,0.) : final_pixel.xyz, shadow ? final_pixel.a * 0.3 : final_pixel.a);
    }

    float adjusted_dissolve = (dissolve * dissolve * (3. - 2. * dissolve)) * 1.02 - 0.01;

    float t = time * 10.0 + 2003.;
    vec2 floored_uv = (floor((uv * texture_details.ba))) / max(texture_details.b, texture_details.a);
    vec2 uv_scaled_centered = (floored_uv - 0.5) * 2.3 * max(texture_details.b, texture_details.a);

    vec2 field_part1 = uv_scaled_centered + 50. * vec2(sin(-t / 143.6340), cos(-t / 99.4324));
    vec2 field_part2 = uv_scaled_centered + 50. * vec2(cos( t / 53.1532),  cos( t / 61.4532));
    vec2 field_part3 = uv_scaled_centered + 50. * vec2(sin(-t / 87.53218), sin(-t / 49.0000));

    float field = (1. + (
        cos(length(field_part1) / 19.483) + sin(length(field_part2) / 33.155) * cos(field_part2.y / 15.73) +
        cos(length(field_part3) / 27.193) * sin(field_part3.x / 21.92))) / 2.;

    vec2 borders = vec2(0.2, 0.8);
    float res = (.5 + .5 * cos((adjusted_dissolve) / 82.612 + (field + -.5) * 3.14))
    - (floored_uv.x > borders.y ? (floored_uv.x - borders.y) * (5. + 5. * dissolve) : 0.) * dissolve
    - (floored_uv.y > borders.y ? (floored_uv.y - borders.y) * (5. + 5. * dissolve) : 0.) * dissolve
    - (floored_uv.x < borders.x ? (borders.x - floored_uv.x) * (5. + 5. * dissolve) : 0.) * dissolve
    - (floored_uv.y < borders.x ? (borders.x - floored_uv.y) * (5. + 5. * dissolve) : 0.) * dissolve;

    if (final_pixel.a > 0.01 && burn_colour_1.a > 0.01 && !shadow &&
        res < adjusted_dissolve + 0.8 * (0.5 - abs(adjusted_dissolve - 0.5)) && res > adjusted_dissolve) {
        if (res < adjusted_dissolve + 0.5 * (0.5 - abs(adjusted_dissolve - 0.5))) {
            final_pixel.rgba = burn_colour_1.rgba;
        } else if (burn_colour_2.a > 0.01) {
            final_pixel.rgba = burn_colour_2.rgba;
        }
    }

    return vec4(shadow ? vec3(0.,0.,0.) : final_pixel.xyz,
        res > adjusted_dissolve ? (shadow ? final_pixel.a * 0.3 : final_pixel.a) : .0);
}

#ifdef VERTEX
vec4 position(mat4 transform_projection, vec4 vertex_position)
{
    if (hovering <= 0.) {
        return transform_projection * vertex_position;
    }

    float mid_dist = length(vertex_position.xy - 0.5 * love_ScreenSize.xy) / length(love_ScreenSize.xy);
    vec2 mouse_offset = (vertex_position.xy - mouse_screen_pos.xy) / screen_scale;
    float scale = 0.2 * (-0.03 - 0.3 * max(0., 0.3 - mid_dist))
        * hovering * (length(mouse_offset) * length(mouse_offset)) / (2. - mid_dist);

    return transform_projection * vertex_position + vec4(0., 0., 0., scale);
}
#endif

