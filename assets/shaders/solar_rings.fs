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
extern PRECISION vec2 solar_rings;

const float PI = 3.14159265359;

float hash21(vec2 p)
{
    p = fract(p * vec2(127.1, 311.7));
    p += dot(p, p + 74.7);
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
        p = p * 2.04 + vec2(9.7, 4.3);
        a *= 0.5;
    }
    return v;
}

vec2 rotate_point(vec2 p, float angle)
{
    float s = sin(angle);
    float c = cos(angle);
    return vec2(c * p.x - s * p.y, s * p.x + c * p.y);
}

float soft_bounds(vec2 uv)
{
    float left = smoothstep(-0.08, 0.05, uv.x);
    float right = 1.0 - smoothstep(0.95, 1.08, uv.x);
    float top = smoothstep(-0.08, 0.05, uv.y);
    float bottom = 1.0 - smoothstep(0.95, 1.08, uv.y);
    return left * right * top * bottom;
}

float ellipse_dist(vec2 p, float squash)
{
    return length(vec2(p.x, p.y * squash));
}

float ring_band(vec2 p, float radius, float width, float squash)
{
    float dist = abs(ellipse_dist(p, squash) - radius);
    return 1.0 - smoothstep(width, width + 0.012, dist);
}

float ring_glow(vec2 p, float radius, float width, float squash)
{
    float dist = abs(ellipse_dist(p, squash) - radius);
    return 1.0 - smoothstep(width, width + 0.070, dist);
}

float braided_ring(vec2 p, float radius, float width, float squash, float teeth, float speed, float t)
{
    vec2 q = vec2(p.x, p.y * squash);
    float angle = atan(q.y, q.x);
    float braid = sin(angle * teeth + t * speed) * 0.014;
    braid += sin(angle * (teeth * 0.5) - t * (speed * 1.31)) * 0.009;
    float dist = abs(length(q) - radius - braid);
    return 1.0 - smoothstep(width, width + 0.011, dist);
}

float orbit_shine(vec2 p, float squash, float count, float speed, float t)
{
    float angle = atan(p.y * squash, p.x);
    float wave = 0.60 + 0.40 * sin(angle * count + t * speed);
    float sweep = pow(max(0.0, 0.5 + 0.5 * sin(angle * 2.0 - t * speed * 0.40)), 4.0);
    return clamp(wave + sweep * 0.46, 0.0, 1.32);
}

float orbit_spark(vec2 p, float radius, float squash, float t, float salt)
{
    float angle = atan(p.y * squash, p.x);
    float dist = abs(ellipse_dist(p, squash) - radius);
    float lane = 1.0 - smoothstep(0.008, 0.030, dist);
    float cell = floor((angle + PI + t * 0.30 + salt) * 8.0);
    float gate = step(0.73, hash21(vec2(cell, salt)));
    float pulse = pow(max(0.0, sin(t * 3.2 + cell * 1.41 + salt)), 9.0);
    return lane * gate * pulse;
}

float contained_arc(vec2 p, float angle, float width, float inner, float outer)
{
    float a = atan(p.y, p.x);
    float angle_dist = abs(atan(sin(a - angle), cos(a - angle)));
    float radial = length(p);
    float angular = 1.0 - smoothstep(width, width + 0.16, angle_dist);
    float radial_mask = smoothstep(inner, inner + 0.08, radial) * (1.0 - smoothstep(outer, outer + 0.14, radial));
    return angular * radial_mask;
}

vec4 effect(vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec2 uv = (((texture_coords) * image_details) - texture_details.xy * texture_details.zw) / texture_details.zw;
    vec4 pixel = Texel(texture, texture_coords);

    float t = solar_rings.y + time * 0.018;
    float tilt = solar_rings.x * 0.11;
    vec2 p = (uv - vec2(0.5, 0.515)) * vec2(1.50, 1.98);
    vec2 core_p = p * vec2(0.94, 1.08);

    vec2 orbit_back = rotate_point(p, -0.30 + tilt + 0.020 * sin(t * 0.52));
    vec2 orbit_main = rotate_point(p, 0.12 + tilt * 0.56 + 0.018 * cos(t * 0.44));
    vec2 orbit_inner = rotate_point(p, -0.04 + tilt * 0.28 + 0.016 * sin(t * 0.74));
    vec2 orbit_crown = rotate_point(p, 0.27 - tilt * 0.30);

    float front = smoothstep(-0.08, 0.15, p.y);
    float back = 1.0 - front;
    float depth = mix(0.32, 1.0, front);

    float back_ring = braided_ring(orbit_back, 0.95, 0.017, 2.90, 10.0, -1.16, t) * orbit_shine(orbit_back, 2.90, 5.0, -1.12, t);
    float main_ring = braided_ring(orbit_main, 0.76, 0.021, 2.52, 12.0, 1.28, t) * orbit_shine(orbit_main, 2.52, 5.0, 1.20, t);
    float inner_ring = ring_band(orbit_inner, 0.51, 0.016, 2.12) * orbit_shine(orbit_inner, 2.12, 7.0, -1.02, t);
    float crown_ring = ring_band(orbit_crown, 1.08, 0.010, 3.22) * 0.60;

    float rings = (main_ring + inner_ring + crown_ring * 0.82) * depth + back_ring * (0.42 + back * 0.25);
    float glow = ring_glow(orbit_back, 0.95, 0.072, 2.90) * 0.30;
    glow += ring_glow(orbit_main, 0.76, 0.070, 2.52) * 0.50;
    glow += ring_glow(orbit_inner, 0.51, 0.050, 2.12) * 0.36;
    glow += ring_glow(orbit_crown, 1.08, 0.040, 3.22) * 0.15;

    float radial = length(core_p);
    float plasma = fbm(core_p * 5.2 + vec2(t * 0.42, -t * 0.22));
    float core = (1.0 - smoothstep(0.05, 0.46, radial)) * (0.50 + 0.18 * sin(t * 2.4));
    core += (1.0 - smoothstep(0.12, 0.72, radial)) * plasma * 0.28;

    float corona = (1.0 - smoothstep(0.32, 1.12, radial)) * 0.34;
    corona *= 0.78 + 0.22 * sin(t * 1.7 + radial * 18.0);

    float ray_angle = atan(p.y, p.x);
    float rays = pow(max(0.0, 0.5 + 0.5 * sin(ray_angle * 12.0 - t * 0.88)), 2.8);
    rays += pow(max(0.0, 0.5 + 0.5 * sin(ray_angle * 20.0 + t * 0.62)), 5.0) * 0.42;
    rays *= (1.0 - smoothstep(0.22, 1.02, radial)) * 0.20;

    float arc_a = contained_arc(p, t * 0.34, 0.10, 0.34, 1.10);
    float arc_b = contained_arc(p, -t * 0.28 + 2.20, 0.09, 0.44, 1.22) * 0.72;
    float arcs = arc_a + arc_b;

    float spark = orbit_spark(orbit_back, 0.95, 2.90, t, 1.0);
    spark += orbit_spark(orbit_main, 0.76, 2.52, t, 8.0) * 1.05;
    spark += orbit_spark(orbit_inner, 0.51, 2.12, t, 13.0) * 0.70;

    float edge = soft_bounds(uv);
    float dissolve_fade = 1.0 - smoothstep(0.0, 1.0, dissolve);
    float art_alpha = max(smoothstep(0.02, 0.18, pixel.a), 0.24);
    float alpha = rings * 0.78 + glow * 0.62 + core + corona + rays + arcs * 0.45 + spark * 0.96;
    alpha = clamp(alpha * edge * dissolve_fade * art_alpha, 0.0, 0.96);

    vec3 deep_orange = vec3(1.00, 0.26, 0.03);
    vec3 orange = vec3(1.00, 0.52, 0.08);
    vec3 gold = vec3(1.00, 0.78, 0.20);
    vec3 white_hot = vec3(1.00, 0.96, 0.62);

    vec3 ring_colour = mix(deep_orange, gold, clamp(glow + rings * 0.38 + corona * 0.35, 0.0, 1.0));
    ring_colour = mix(ring_colour, white_hot, clamp(core * 0.45 + spark + rings * 0.18, 0.0, 0.62));
    ring_colour = mix(ring_colour, orange, clamp(arcs * 0.45 + rays * 0.35, 0.0, 0.28));
    ring_colour += white_hot * spark * 0.18;

    vec3 burn_tint = mix(burn_colour_1.rgb, burn_colour_2.rgb, 0.5);
    ring_colour = mix(ring_colour, burn_tint, clamp(dissolve * 0.08, 0.0, 0.08));

    if (shadow) {
        return vec4(0.0, 0.0, 0.0, alpha * 0.20 * colour.a);
    }
    return vec4(ring_colour * colour.rgb, alpha * colour.a);
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
