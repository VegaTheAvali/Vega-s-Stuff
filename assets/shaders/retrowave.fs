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
extern PRECISION vec2 retrowave;

vec4 dissolve_mask(vec4 final_pixel, vec2 texture_coords, vec2 uv);

float hash21(vec2 p)
{
    p = fract(p * vec2(234.34, 875.13));
    p += dot(p, p + 42.42);
    return fract(p.x * p.y);
}

float line(float x, float width)
{
    return 1.0 - smoothstep(width * 0.35, width, abs(x));
}

float ring(vec2 p, float radius, float width)
{
    return line(length(p) - radius, width);
}

float box(vec2 uv, vec2 center, vec2 size, float softness)
{
    vec2 q = abs(uv - center) - size;
    float d = length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0);
    return 1.0 - smoothstep(0.0, softness, d);
}

vec2 local_uv(vec2 texture_coords)
{
    return (((texture_coords) * image_details) - texture_details.xy * texture_details.zw) / texture_details.zw;
}

vec2 atlas_uv(vec2 uv)
{
    return (texture_details.xy + clamp(uv, vec2(0.003), vec2(0.997))) * texture_details.zw / image_details;
}

vec3 neon_palette(float x)
{
    vec3 magenta = vec3(1.00, 0.06, 0.84);
    vec3 violet = vec3(0.46, 0.10, 1.00);
    vec3 cyan = vec3(0.04, 0.88, 1.00);
    vec3 orange = vec3(1.00, 0.46, 0.12);
    vec3 a = mix(magenta, violet, smoothstep(0.00, 0.35, fract(x)));
    vec3 b = mix(cyan, orange, smoothstep(0.35, 0.88, fract(x)));
    return mix(a, b, smoothstep(0.22, 0.78, fract(x)));
}

float scanlines(vec2 uv, float t)
{
    float px = max(texture_details.w, 1.0);
    float hard = sin((uv.y * px + t * 14.0) * 3.14159);
    float flicker = 0.96 + 0.04 * sin(t * 11.0 + uv.y * 40.0);
    return (0.84 + 0.16 * hard) * flicker;
}

float horizon_grid(vec2 uv, float t)
{
    float horizon = 0.56;
    float below = smoothstep(horizon, 1.04, uv.y);
    float depth = max(uv.y - horizon, 0.001);
    float perspective = 0.44 / depth;
    float drift = t * 4.40;
    float beat = 0.70 + 0.30 * sin(t * 9.5);

    float vertical = 0.0;
    float x = (uv.x - 0.5) * perspective;
    float side_spread = smoothstep(0.00, 0.65, abs(uv.x - 0.5) * (0.55 + perspective * 0.06));
    float lane_sway = sin(t * 4.8 + uv.y * 10.0) * 0.05;
    vertical += line(fract((x + lane_sway) * 0.52 + 0.5) - 0.5, 0.020);
    vertical += line(fract((x - lane_sway) * 1.04 + 0.5) - 0.5, 0.010) * 0.52;
    vertical *= mix(0.70, 1.18, side_spread);

    float y = perspective + drift;
    float sweep = fract(y * 0.18);
    float horizontal = line(sweep - 0.5, 0.030 + 0.012 * smoothstep(0.65, 1.0, uv.y));
    horizontal += line(fract(y * 0.36 + 0.25 * sin(t * 3.0)) - 0.5, 0.014) * 0.48;
    float rush = smoothstep(0.45, 0.98, uv.y) * (0.60 + 0.40 * sin(t * 24.0 + y * 2.4));
    float headlight = smoothstep(0.04, 0.62, abs(uv.x - 0.5)) * smoothstep(0.55, 1.0, uv.y);

    float road = 1.0 - smoothstep(0.26, 0.64, abs(uv.x - 0.5) / max(uv.y - horizon + 0.10, 0.05));
    float fade = (1.0 - smoothstep(0.98, 1.02, uv.y)) * smoothstep(horizon, horizon + 0.05, uv.y);
    fade *= mix(0.52, 1.0, road);
    return clamp((vertical + horizontal * rush + headlight * line(sweep - 0.18, 0.018) * 0.45) * below * fade * beat, 0.0, 1.0);
}

float sunset(vec2 uv, float t)
{
    vec2 p = uv - vec2(0.50, 0.315);
    p.x *= texture_details.z / max(texture_details.w, 0.001);
    float dist = length(p);
    float sun = 1.0 - smoothstep(0.300, 0.335, dist);
    float glow = 1.0 - smoothstep(0.34, 0.48, dist);
    float stripe = fract((uv.y + t * 0.22) * 24.0);
    float bars = smoothstep(0.15, 0.22, stripe) * (1.0 - smoothstep(0.60, 0.72, stripe));
    float stripe_gate = smoothstep(0.30, 0.37, uv.y) * (1.0 - smoothstep(0.56, 0.67, uv.y));
    float lower_cut = 1.0 - smoothstep(0.64, 0.76, uv.y);
    float chip_rings = ring(p, 0.145, 0.010) + ring(p, 0.218, 0.012) + ring(p, 0.292, 0.010);
    float wedges = line(sin(atan(p.y, p.x) * 18.0 + t * 0.75), 0.18) * smoothstep(0.07, 0.25, dist) * (1.0 - smoothstep(0.30, 0.35, dist));
    return (sun * mix(1.0, 0.30, bars * stripe_gate) + glow * 0.38 + chip_rings * 0.35 + wedges * 0.18) * lower_cut;
}

float starfield(vec2 uv, float t)
{
    vec2 cell = floor(uv * texture_details.zw * 0.45);
    float h = hash21(cell);
    float twinkle = 0.45 + 0.55 * sin(t * 4.0 + h * 30.0);
    return clamp(pow(max(0.0, h - 0.90), 5.0) * 150000.0 * twinkle, 0.0, 1.0);
}

float palm_shadow(vec2 uv, float side, float t)
{
    vec2 p = uv - vec2(side > 0.0 ? 0.86 : 0.14, 0.62);
    p.x *= side;
    float trunk = line(p.x + p.y * 0.13, 0.018) * (1.0 - smoothstep(-0.18, 0.42, p.y)) * smoothstep(-0.54, 0.08, p.y);
    float leaves = 0.0;
    leaves += line(p.y + abs(p.x) * 0.42 + 0.08 * sin(t + p.x * 8.0), 0.024) * (1.0 - smoothstep(0.00, 0.36, abs(p.x)));
    leaves += line(p.y + p.x * 0.82 + 0.03, 0.020) * (1.0 - smoothstep(0.00, 0.30, abs(p.x)));
    leaves += line(p.y - p.x * 0.92 + 0.02, 0.020) * (1.0 - smoothstep(0.00, 0.30, abs(p.x)));
    return clamp((trunk + leaves) * smoothstep(0.08, 0.42, uv.y), 0.0, 1.0);
}

float mountain_height(float x, float side, float t)
{
    x += t * 0.22;
    float id = floor(x * 18.0);
    float f = fract(x * 18.0);
    float a = hash21(vec2(id, side * 17.0));
    float b = hash21(vec2(id + 1.0, side * 17.0));
    float peak = mix(a, b, f);
    peak = pow(peak, 1.02);
    float ridge = 0.16 + peak * 0.46;
    ridge += 0.045 * sin(x * 60.0 + side * 3.0 + t * 0.80);
    ridge += 0.018 * sin(x * 119.0 - t * 1.30);
    return ridge;
}

float mountain_fill(vec2 uv, float side, float t)
{
    float edge = side > 0.0 ? uv.x : 1.0 - uv.x;
    float depth = smoothstep(0.42, 1.00, uv.y);
    float forward = t * (0.48 + depth * 1.80);
    float pushed_edge = edge + forward + sin(t * 3.6 + uv.y * 8.0) * 0.018 * depth;
    float perspective_widen = smoothstep(0.40, 1.00, uv.y);
    float side_mask = 1.0 - smoothstep(0.13 + perspective_widen * 0.08, 0.50 + perspective_widen * 0.30, edge);
    float base = 0.64 + 0.035 * sin(t * 4.4 + depth * 4.0);
    float ridge = base - mountain_height(pushed_edge + 0.03 * sin(t * 0.18), side, t) * (0.45 + side_mask * 0.68);
    ridge += (1.0 - depth) * 0.035 * sin(t * 6.0 + edge * 18.0);
    return side_mask * smoothstep(ridge, ridge + 0.018, uv.y) * (1.0 - smoothstep(base + 0.04, base + 0.16, uv.y));
}

float mountain_wire(vec2 uv, float side, float t)
{
    float edge = side > 0.0 ? uv.x : 1.0 - uv.x;
    float fill = mountain_fill(uv, side, t);
    float depth = smoothstep(0.42, 1.00, uv.y);
    float forward = t * (0.48 + depth * 1.80);
    float pushed_edge = edge + forward + sin(t * 3.6 + uv.y * 8.0) * 0.018 * depth;
    float perspective_widen = smoothstep(0.40, 1.00, uv.y);
    float side_mask = 1.0 - smoothstep(0.13 + perspective_widen * 0.08, 0.50 + perspective_widen * 0.30, edge);
    float base = 0.64 + 0.035 * sin(t * 4.4 + depth * 4.0);
    float ridge_y = base - mountain_height(pushed_edge, side, t) * (0.45 + side_mask * 0.68);
    ridge_y += (1.0 - depth) * 0.035 * sin(t * 6.0 + edge * 18.0);
    float ridge = line(uv.y - ridge_y, 0.012);
    float outward = depth * t * 3.40;
    float verticals = line(fract(pushed_edge * 21.0 - outward) - 0.5, 0.014);
    float diagonals = line(fract((pushed_edge * 12.0 + uv.y * 10.0) + t * (1.70 + depth * 2.40)) - 0.5, 0.014);
    diagonals += line(fract((pushed_edge * 13.0 - uv.y * 11.0) - t * (1.55 + depth * 2.10)) - 0.5, 0.013);
    float glow_pulse = 0.60 + 0.40 * sin(t * 13.0 + pushed_edge * 22.0 + depth * 5.0);
    return clamp(fill * (ridge * 2.0 + verticals * 0.46 + diagonals * 0.78) * glow_pulse, 0.0, 1.0);
}

float seven_digit(vec2 uv, vec2 center, float scale)
{
    vec2 p = (uv - center) / scale + 0.5;
    float mask = 0.0;
    mask += box(p, vec2(0.50, 0.18), vec2(0.34, 0.045), 0.014);
    mask += box(p, vec2(0.72, 0.39), vec2(0.055, 0.23), 0.014);
    mask += box(p, vec2(0.56, 0.68), vec2(0.055, 0.24), 0.014);
    return mask * step(0.0, p.x) * step(p.x, 1.0) * step(0.0, p.y) * step(p.y, 1.0);
}

float jackpot_777(vec2 uv, float t)
{
    float pulse = smoothstep(0.70, 1.0, sin(t * 3.7) * 0.5 + 0.5);
    float flicker = step(0.18, fract(t * 5.0));
    float digits = 0.0;
    digits += seven_digit(uv, vec2(0.37, 0.23), 0.18);
    digits += seven_digit(uv, vec2(0.50, 0.225), 0.18);
    digits += seven_digit(uv, vec2(0.63, 0.23), 0.18);
    return digits * pulse * flicker;
}

float casino_signs(vec2 uv, float t)
{
    float left = box(uv, vec2(0.15, 0.43), vec2(0.08, 0.035), 0.010);
    left += box(uv, vec2(0.13, 0.48), vec2(0.018, 0.075), 0.008);
    left += ring((uv - vec2(0.21, 0.39)) * vec2(1.8, 1.0), 0.050, 0.012);

    float right = box(uv, vec2(0.85, 0.43), vec2(0.08, 0.035), 0.010);
    right += box(uv, vec2(0.87, 0.48), vec2(0.018, 0.075), 0.008);
    right += ring((uv - vec2(0.79, 0.39)) * vec2(1.8, 1.0), 0.050, 0.012);

    float blink = 0.65 + 0.35 * sin(t * 9.0);
    return clamp((left + right) * blink, 0.0, 1.0);
}

vec4 effect(vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec2 uv = local_uv(texture_coords);
    float uniform_keepalive = dot(mouse_screen_pos, vec2(0.000000001, 0.000000001)) / max(screen_scale, 0.001);
    float payload = retrowave.x * 0.09 + retrowave.y * 0.071;
    float t = time + payload + dot(screen_coords, vec2(0.00001, 0.00002)) + uniform_keepalive;
    float hover_amt = 0.75 + hovering * 0.25;

    float wave = sin(uv.y * 20.0 + t * 12.0) * 0.006;
    wave += sin(uv.y * 57.0 - t * 13.0) * 0.0024;
    wave += sin(uv.x * 31.0 + t * 8.0) * 0.0014;
    wave += (step(0.985, fract(uv.y * 42.0 + t * 9.0)) - 0.5) * 0.003;
    vec2 warp = vec2(wave * hover_amt, 0.0);

    vec4 base = Texel(texture, atlas_uv(uv + warp)) * colour;
    vec4 red = Texel(texture, atlas_uv(uv + warp + vec2(0.0035, 0.0))) * colour;
    vec4 blue = Texel(texture, atlas_uv(uv + warp - vec2(0.0035, 0.0))) * colour;
    vec4 pixel = vec4(red.r, base.g, blue.b, base.a);
    vec3 original = pixel.rgb;

    float sky = 1.0 - smoothstep(0.04, 0.92, uv.y);
    float cloud = sin(uv.x * 8.0 + t * 0.18) * sin(uv.y * 15.0 - t * 0.12);
    vec3 sky_col = mix(vec3(0.04, 0.00, 0.22), vec3(0.86, 0.00, 0.46), sky);
    sky_col += vec3(0.18, 0.00, 0.18) * cloud * smoothstep(0.05, 0.44, uv.y) * (1.0 - smoothstep(0.48, 0.90, uv.y));
    sky_col = mix(sky_col, vec3(0.22, 0.02, 0.34), smoothstep(0.42, 1.00, uv.y));

    float sun = sunset(uv, t);
    float grid = horizon_grid(uv, t);
    float stars = starfield(uv, t);
    float mountains = mountain_fill(uv, 1.0, t) + mountain_fill(uv, -1.0, t);
    float mountain_lines = mountain_wire(uv, 1.0, t) + mountain_wire(uv, -1.0, t);
    float palms = palm_shadow(uv, 1.0, t) + palm_shadow(uv, -1.0, t);
    float jackpot = jackpot_777(uv, t);
    float signs = casino_signs(uv, t);
    float scan = scanlines(uv, t);
    float vhs_bar = smoothstep(0.0, 0.05, abs(fract(uv.y * 3.0 - t * 2.80) - 0.5));
    float neon_pulse = 0.76 + 0.24 * sin(t * 12.0);

    vec3 neon = vec3(0.0);
    neon += sky_col * 0.88;
    neon += mix(vec3(1.0, 0.17, 0.58), vec3(1.0, 1.00, 0.10), smoothstep(0.0, 0.62, uv.y)) * sun * 1.28;
    neon = mix(neon, vec3(0.006, 0.00, 0.04), clamp(mountains, 0.0, 1.0) * 0.96);
    neon += vec3(0.00, 0.74, 1.00) * mountain_lines * 1.45 * neon_pulse;
    neon += vec3(1.00, 0.04, 0.98) * grid * 1.70 * neon_pulse;
    neon += vec3(0.25, 0.90, 1.00) * smoothstep(0.45, 1.0, mountain_lines) * 0.42;
    neon += vec3(1.00, 0.35, 1.00) * smoothstep(0.45, 1.0, grid) * 0.38;
    neon += vec3(0.30, 0.90, 1.00) * stars * 0.16;
    neon += vec3(1.00, 0.90, 0.18) * jackpot * 0.90;
    neon += vec3(1.00, 0.08, 0.84) * signs * 0.62;
    neon += vec3(0.08, 0.95, 1.00) * signs * 0.35;
    neon -= vec3(0.14, 0.02, 0.18) * palms * 0.32;
    neon += vec3(1.00, 0.08, 0.78) * ring((uv - 0.5) * vec2(texture_details.z / max(texture_details.w, 0.001), 1.0), 0.54, 0.018) * 0.08;

    float scene_strength = clamp(0.42 + grid * 0.08 + sun * 0.06 + mountain_lines * 0.08 + jackpot * 0.08 + signs * 0.05, 0.0, 0.66);
    pixel.rgb = mix(pixel.rgb, neon, scene_strength);
    pixel.rgb += neon_palette(uv.y + t * 0.06) * grid * 0.24;
    pixel.rgb += vec3(1.0, 0.06, 0.92) * grid * 0.20;
    pixel.rgb += vec3(0.0, 0.74, 1.0) * mountain_lines * 0.18;
    pixel.rgb += vec3(1.0, 0.85, 0.10) * jackpot * 0.28;
    pixel.rgb *= scan * mix(0.92, 1.05, vhs_bar);
    pixel.rgb = mix(original, pixel.rgb, 0.66);
    pixel.rgb = clamp(pixel.rgb, vec3(0.0), vec3(1.18));

    return dissolve_mask(pixel, texture_coords, uv + uniform_keepalive);
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
    float pulse = sin(time * 6.0 + mouse_offset.x * 0.12) * hovering * 0.0025;

    return transform_projection * vertex_position + vec4(0.0, 0.0, 0.0, scale + pulse);
}
#endif
