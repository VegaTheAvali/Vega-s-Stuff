#if defined(VERTEX) || __VERSION__ > 100 || defined(GL_FRAGMENT_PRECISION_HIGH)
    #define PRECISION highp
#else
    #define PRECISION mediump
#endif

#define VIRTUAL_SCREEN_HEIGHT 48.0
#define PIXEL_BORDER 0.22
#define PI 3.14159265359
#define DUST_COUNT 72

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
extern PRECISION vec2 planetarium_deluxe;

vec3 dark_grey = vec3(53.0, 43.0, 49.0) / 255.0;
vec3 dark_blue = vec3(75.0, 109.0, 133.0) / 255.0;
vec3 purple = vec3(157.0, 91.0, 136.0) / 255.0;
vec3 white = vec3(245.0, 245.0, 212.0) / 255.0;
vec3 green = vec3(150.0, 207.0, 133.0) / 255.0;
vec3 light_green = vec3(223.0, 223.0, 170.0) / 255.0;
vec3 light_blue = vec3(191.0, 231.0, 231.0) / 255.0;
vec3 blue = vec3(152.0, 186.0, 210.0) / 255.0;
vec3 grey = vec3(53.0, 53.0, 53.0) / 255.0;
vec3 dark_yellow = vec3(166.0, 166.0, 144.0) / 255.0;

vec4 dissolve_mask(vec4 final_pixel, vec2 texture_coords, vec2 uv);

vec2 local_uv(vec2 texture_coords)
{
    return (((texture_coords) * image_details) - texture_details.xy * texture_details.zw) / texture_details.zw;
}

float soft_card_bounds(vec2 uv)
{
    float left = smoothstep(-0.01, 0.025, uv.x);
    float right = 1.0 - smoothstep(0.975, 1.01, uv.x);
    float top = smoothstep(-0.01, 0.025, uv.y);
    float bottom = 1.0 - smoothstep(0.975, 1.01, uv.y);
    return left * right * top * bottom;
}

vec3 vegas_planet_camera(float fov, vec2 size, vec2 uv)
{
    float z = size.y / tan((fov * PI / 180.0) / 2.0);
    return normalize(vec3(uv, -z));
}

float vegas_planet_intersect_ray_sphere(vec3 origin, vec3 direction, vec3 center, float radius)
{
    vec3 oc = origin - center;
    float a = dot(direction, direction);
    float b = 2.0 * dot(oc, direction);
    float c = dot(oc, oc) - radius * radius;
    float disc = b * b - 4.0 * a * c;
    if (disc < 0.0) {
        return -1.0;
    }
    return (-b - sqrt(disc)) / (2.0 * a);
}

vec3 vegas_planet_rotate_axis(vec3 p, float angle, vec3 axis)
{
    axis = normalize(axis);
    float c = cos(angle);
    float s = sin(angle);
    return p * c + cross(axis, p) * s + axis * dot(axis, p) * (1.0 - c);
}

float vegas_planet_rand(vec2 co)
{
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

float vegas_planet_rand2(vec2 co)
{
    return 8.0 * pow(vegas_planet_rand(co) - 0.5, 3.0);
}

float vegas_planet_noise2(vec2 p)
{
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    float a = vegas_planet_rand(i);
    float b = vegas_planet_rand(i + vec2(1.0, 0.0));
    float c = vegas_planet_rand(i + vec2(0.0, 1.0));
    float d = vegas_planet_rand(i + vec2(1.0, 1.0));
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float vegas_planet_surface_noise(vec2 p)
{
    float n = 0.0;
    float a = 0.55;
    for (int i = 0; i < 4; i++) {
        n += vegas_planet_noise2(p) * a;
        p = mat2(1.57, -1.08, 1.08, 1.57) * p + vec2(4.1, 7.3);
        a *= 0.52;
    }
    return n;
}

float vegas_planet_dither(vec2 uv, float levels, float sharpness, float intensity)
{
    float threshold = vegas_planet_rand(floor(uv) + vec2(17.0, 43.0)) - 0.5;
    float major = floor(levels * intensity);
    float minor = fract(levels * intensity) > 0.5 + sharpness * threshold ? 1.0 : 0.0;
    return (major + minor) / levels;
}

vec3 render_planetarium(vec2 uv, vec2 dims, float t)
{
    vec2 frag_coord = uv * dims;
    vec2 ray_uv = frag_coord - 0.5 * dims;

    vec3 pos = vec3(0.0, 0.0, 12.0);
    vec3 dir = vegas_planet_camera(90.0, vec2(VIRTUAL_SCREEN_HEIGHT), ray_uv);
    vec3 col = dark_grey;
    float depth = 1000.0;

    float star = vegas_planet_rand(floor(ray_uv));
    if (star <= 0.001) {
        col = dark_blue;
    } else if (star <= 0.002) {
        col = purple;
    } else if (star <= 0.003) {
        col = white;
    }

    const float planet_size = 3.0;
    vec3 planet_position = vec3(0.0);

    vec3 sun_position = vegas_planet_rotate_axis(vec3(-900.0, 0.0, 0.0), -35.0 * PI / 180.0 * t, vec3(0.0, 1.0, 0.0));
    vec3 L_sun = normalize(sun_position - planet_position);
    float t_sun = vegas_planet_intersect_ray_sphere(pos, dir, sun_position, 30.0);
    if (t_sun >= 0.0 && t_sun < depth) {
        col = white;
        depth = t_sun;
    }

    float moon_size = 1.0;
    vec3 moon_orbit = vegas_planet_rotate_axis(vec3(cos(2.0 * t), 0.0, sin(2.0 * t)), 30.0 * PI / 180.0, vec3(1.0, 0.0, 1.0));
    vec3 moon_position = planet_position + 7.0 * moon_orbit;
    float t_moon = vegas_planet_intersect_ray_sphere(pos, dir, moon_position, moon_size);
    if (t_moon >= 0.0 && t_moon < depth) {
        vec3 p = pos + dir * t_moon;
        vec3 light_dir = normalize(p - sun_position);
        float t_planet_shadow = vegas_planet_intersect_ray_sphere(sun_position, light_dir, planet_position, planet_size);

        if (t_planet_shadow >= 0.0 && length(sun_position - planet_position) < length(sun_position - p)) {
            col = grey;
        } else {
            vec3 N = normalize(p - moon_position);
            float tex = 1.15 + vegas_planet_surface_noise(3.2 * N.xy + vec2(0.18 * t, 0.0));
            float dot_sun = 0.5 + dot(N, L_sun);
            float shadow_int = vegas_planet_dither(ray_uv, 2.0, 0.8, dot_sun);
            if (shadow_int < 0.5) {
                col = mix(dark_yellow, white, shadow_int);
            } else {
                float intensity = floor(2.0 * max(0.0, tex * dot_sun) + 0.5) / 2.0;
                col = white * (0.70 + 0.20 * intensity);
            }
        }
        depth = t_moon;
    }

    float t_planet = vegas_planet_intersect_ray_sphere(pos, dir, planet_position, planet_size);
    if (t_planet >= 0.0 && t_planet < depth) {
        vec3 p = pos + dir * t_planet;
        vec3 N = normalize(p - planet_position);
        vec2 tex_uv = 2.8 * N.xy + vec2(0.20 * t, 0.0);
        float tex = 0.75 + vegas_planet_surface_noise(tex_uv) * 1.25;
        float land = vegas_planet_surface_noise(tex_uv * 0.78 + vec2(3.0, 9.0));
        float dot_sun = 0.5 + dot(N, L_sun);
        float intensity = floor(2.0 * max(0.0, tex * dot_sun)) / 2.0;
        float shadow_int = vegas_planet_dither(ray_uv, 2.0, 0.8, dot_sun);

        if (shadow_int < 0.5) {
            col = mix(dark_blue, blue, shadow_int);
        } else {
            vec3 light_dir = normalize(p - sun_position);
            float moon_shadow = vegas_planet_intersect_ray_sphere(sun_position, light_dir, moon_position, moon_size);
            if (moon_shadow >= 0.0 && length(sun_position - moon_position) < length(sun_position - planet_position)) {
                col = dark_blue;
            } else {
                vec3 water_col = mix(dark_blue, blue, intensity);
                vec3 land_col = mix(green, light_green, clamp(intensity, 0.0, 1.0));
                col = mix(water_col, land_col, smoothstep(0.58, 0.76, land));
            }
        }
        depth = t_planet;
    }

    vec3 dust_axis = normalize(vec3(1.0, 0.0, 1.0));
    for (int i = 0; i < DUST_COUNT; ++i) {
        float fi = float(i);
        float dust_radius = 4.0 + 2.0 * vegas_planet_rand2(vec2(121.0, fi)) + vegas_planet_rand(vec2(129.0, fi));
        float dust_frequency = 4.0 - 0.5 * dust_radius;
        float dust_phase = 2.0 * PI * vegas_planet_rand(vec2(13.0 + fi, fi));
        float dust_y = 0.05 * vegas_planet_rand2(vec2(137.0, fi));
        float dust_size = 0.09 * (1.0 + vegas_planet_rand2(vec2(93.0, fi)));
        vec3 orbit = vec3(cos(dust_frequency * t + dust_phase), dust_y, sin(dust_frequency * t + dust_phase));
        vec3 dust_position = planet_position + dust_radius * vegas_planet_rotate_axis(orbit, 30.0 * PI / 180.0, dust_axis);
        float t_dust = vegas_planet_intersect_ray_sphere(pos, dir, dust_position, dust_size);

        if (t_dust >= 0.0 && t_dust < depth) {
            vec3 light_dir = normalize(dust_position - sun_position);
            float dust_shadow = vegas_planet_intersect_ray_sphere(sun_position, light_dir, planet_position, planet_size);
            if (dust_shadow >= 0.0 && length(sun_position - planet_position) < length(sun_position - dust_position)) {
                col = grey;
            } else {
                col = mix(purple, light_blue, floor(vegas_planet_rand(vec2(22.0, fi)) + 0.5));
            }
            depth = t_dust;
        }
    }

    return col;
}

vec2 cell_uv(vec2 cell, vec2 dims)
{
    return (clamp(cell, vec2(0.0), dims - vec2(1.0)) + vec2(0.5)) / dims;
}

vec3 pixel_filtered_scene(vec2 uv, float t)
{
    float aspect = texture_details.z / max(texture_details.w, 1.0);
    vec2 dims = vec2(VIRTUAL_SCREEN_HEIGHT * aspect, VIRTUAL_SCREEN_HEIGHT);
    vec2 pixel_pos = uv * dims;
    vec2 cell = floor(pixel_pos);
    vec2 uvf = fract(pixel_pos);

    vec3 col = render_planetarium(cell_uv(cell, dims), dims, t);

    vec3 xcol = col;
    if (uvf.x < PIXEL_BORDER) {
        xcol = mix(render_planetarium(cell_uv(cell + vec2(-1.0, 0.0), dims), dims, t), col, uvf.x / PIXEL_BORDER);
    } else if (1.0 - uvf.x < PIXEL_BORDER) {
        xcol = mix(render_planetarium(cell_uv(cell + vec2(1.0, 0.0), dims), dims, t), col, (1.0 - uvf.x) / PIXEL_BORDER);
    }

    vec3 ycol = col;
    if (uvf.y < PIXEL_BORDER) {
        ycol = mix(render_planetarium(cell_uv(cell + vec2(0.0, -1.0), dims), dims, t), col, uvf.y / PIXEL_BORDER);
    } else if (1.0 - uvf.y < PIXEL_BORDER) {
        ycol = mix(render_planetarium(cell_uv(cell + vec2(0.0, 1.0), dims), dims, t), col, (1.0 - uvf.y) / PIXEL_BORDER);
    }

    return mix(xcol, ycol, 0.5);
}

vec4 effect(vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec2 uv = local_uv(texture_coords);
    vec4 base = Texel(texture, texture_coords) * colour;
    float uniform_keepalive = dot(mouse_screen_pos, vec2(0.000000001)) / max(screen_scale, 0.001) + planetarium_deluxe.x * 0.000000001;
    float t = planetarium_deluxe.y + time * 0.001 + uniform_keepalive;

    vec3 scene = pixel_filtered_scene(uv, t);
    float mask = smoothstep(0.02, 0.16, base.a) * soft_card_bounds(uv);
    float overlay = 0.62 * mask;

    base.rgb = mix(base.rgb * vec3(0.68, 0.74, 0.92), scene, overlay);
    base.rgb = clamp(base.rgb, vec3(0.0), vec3(1.20));
    base.a *= mask;

    return dissolve_mask(base, texture_coords, uv + uniform_keepalive);
}

vec4 dissolve_mask(vec4 final_pixel, vec2 texture_coords, vec2 uv)
{
    if (dissolve < 0.001) {
        return vec4(shadow ? vec3(0.0) : final_pixel.rgb, shadow ? final_pixel.a * 0.3 : final_pixel.a);
    }

    float adjusted_dissolve = (dissolve * dissolve * (3.0 - 2.0 * dissolve)) * 1.02 - 0.01;
    float t = planetarium_deluxe.y * 10.0 + time * 0.01 + 2003.0;
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

