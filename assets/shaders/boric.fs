#if defined(VERTEX) || __VERSION__ > 100 || defined(GL_FRAGMENT_PRECISION_HIGH)
	#define MY_HIGHP_OR_MEDIUMP highp
#else
	#define MY_HIGHP_OR_MEDIUMP mediump
#endif

extern MY_HIGHP_OR_MEDIUMP vec2 boric;
extern MY_HIGHP_OR_MEDIUMP number dissolve;
extern MY_HIGHP_OR_MEDIUMP number time;
extern MY_HIGHP_OR_MEDIUMP vec4 texture_details;
extern MY_HIGHP_OR_MEDIUMP vec2 image_details;
extern bool shadow;
extern MY_HIGHP_OR_MEDIUMP vec4 burn_colour_1;
extern MY_HIGHP_OR_MEDIUMP vec4 burn_colour_2;

vec4 dissolve_mask(vec4 tex, vec2 texture_coords, vec2 uv)
{
    if (dissolve < 0.001) {
        return vec4(shadow ? vec3(0.,0.,0.) : tex.xyz, shadow ? tex.a*0.3: tex.a);
    }

    float adjusted_dissolve = (dissolve*dissolve*(3.-2.*dissolve))*1.02 - 0.01; //Adjusting 0.0-1.0 to fall to -0.1 - 1.1 scale so the mask does not pause at extreme values

	float t = time * 10.0 + 2003.;
	vec2 floored_uv = (floor((uv*texture_details.ba)))/max(texture_details.b, texture_details.a);
    vec2 uv_scaled_centered = (floored_uv - 0.5) * 2.3 * max(texture_details.b, texture_details.a);
	
	vec2 field_part1 = uv_scaled_centered + 50.*vec2(sin(-t / 143.6340), cos(-t / 99.4324));
	vec2 field_part2 = uv_scaled_centered + 50.*vec2(cos( t / 53.1532),  cos( t / 61.4532));
	vec2 field_part3 = uv_scaled_centered + 50.*vec2(sin(-t / 87.53218), sin(-t / 49.0000));

    float field = (1.+ (
        cos(length(field_part1) / 19.483) + sin(length(field_part2) / 33.155) * cos(field_part2.y / 15.73) +
        cos(length(field_part3) / 27.193) * sin(field_part3.x / 21.92) ))/2.;
    vec2 borders = vec2(0.2, 0.8);

    float res = (.5 + .5* cos( (adjusted_dissolve) / 82.612 + ( field + -.5 ) *3.14))
    - (floored_uv.x > borders.y ? (floored_uv.x - borders.y)*(5. + 5.*dissolve) : 0.)*(dissolve)
    - (floored_uv.y > borders.y ? (floored_uv.y - borders.y)*(5. + 5.*dissolve) : 0.)*(dissolve)
    - (floored_uv.x < borders.x ? (borders.x - floored_uv.x)*(5. + 5.*dissolve) : 0.)*(dissolve)
    - (floored_uv.y < borders.x ? (borders.x - floored_uv.y)*(5. + 5.*dissolve) : 0.)*(dissolve);

    if (tex.a > 0.01 && burn_colour_1.a > 0.01 && !shadow && res < adjusted_dissolve + 0.8*(0.5-abs(adjusted_dissolve-0.5)) && res > adjusted_dissolve) {
        if (!shadow && res < adjusted_dissolve + 0.5*(0.5-abs(adjusted_dissolve-0.5)) && res > adjusted_dissolve) {
            tex.rgba = burn_colour_1.rgba;
        } else if (burn_colour_2.a > 0.01) {
            tex.rgba = burn_colour_2.rgba;
        }
    }

    return vec4(shadow ? vec3(0.,0.,0.) : tex.xyz, res > adjusted_dissolve ? (shadow ? tex.a*0.3: tex.a) : .0);
}

number hue(number s, number t, number h)
{
	number hs = mod(h, 1.)*6.;
	if (hs < 1.) return (t-s) * hs + s;
	if (hs < 3.) return t;
	if (hs < 4.) return (t-s) * (4.-hs) + s;
	return s;
}

vec4 RGB(vec4 c)
{
	if (c.y < 0.0001)
		return vec4(vec3(c.z), c.a);

	number t = (c.z < .5) ? c.y*c.z + c.z : -c.y*c.z + (c.y+c.z);
	number s = 2.0 * c.z - t;
	return vec4(hue(s,t,c.x + 1./3.), hue(s,t,c.x), hue(s,t,c.x - 1./3.), c.w);
}

vec4 HSL(vec4 c)
{
	number low = min(c.r, min(c.g, c.b));
	number high = max(c.r, max(c.g, c.b));
	number delta = high - low;
	number sum = high+low;

	vec4 hsl = vec4(.0, .0, .5 * sum, c.a);
	if (delta == .0)
		return hsl;

	hsl.y = (hsl.z < .5) ? delta / sum : delta / (2.0 - sum);

	if (high == c.r)
		hsl.x = (c.g - c.b) / delta;
	else if (high == c.g)
		hsl.x = (c.b - c.r) / delta + 2.0;
	else
		hsl.x = (c.r - c.g) / delta + 4.0;

	hsl.x = mod(hsl.x / 6., 1.);
	return hsl;
}

vec4 effect( vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords )
{
    vec4 tex = Texel(texture, texture_coords);
	vec2 uv = (((texture_coords)*(image_details)) - texture_details.xy*texture_details.ba)/texture_details.ba;
    vec4 hsl = HSL(0.5*tex + 0.5*vec4(0.,0.,1.,tex.a));

	float t = boric.y*7.221 + time;
	vec2 floored_uv = (floor((uv*texture_details.ba)))/texture_details.ba;
    vec2 uv_scaled_centered = (floored_uv - 0.5) * 250.;
	
	vec2 field_part1 = uv_scaled_centered + 50.*vec2(sin(-t / 143.6340), cos(-t / 99.4324));
	vec2 field_part2 = uv_scaled_centered + 50.*vec2(cos( t / 53.1532),  cos( t / 61.4532));
	vec2 field_part3 = uv_scaled_centered + 50.*vec2(sin(-t / 87.53218), sin(-t / 49.0000));

    float field = (1.+ (
        cos(length(field_part1) / 19.483) + sin(length(field_part2) / 33.155) * cos(field_part2.y / 15.73) +
        cos(length(field_part3) / 27.193) * sin(field_part3.x / 21.92) ))/2.;
	
vec2 nearest_cell = vec2(0.0);

    vec2 grid_point = uv * texture_details.ba;
    float hex_radius = 9.0;
    float hex_row_step = 1.5 * hex_radius;
    float hex_col_step = 1.7320508 * hex_radius;
    float row_base = floor(grid_point.y / hex_row_step);
    float nearest_d2 = 1e20;
    vec2 nearest_local = vec2(0.0);

    for (int row_offset = -1; row_offset <= 1; row_offset++) {
        float row = row_base + float(row_offset);
        float row_shift = mod(abs(row), 2.0) * 0.5 * hex_col_step;
        float col_base = floor((grid_point.x - row_shift) / hex_col_step);

        for (int col_offset = -1; col_offset <= 1; col_offset++) {
            float col = col_base + float(col_offset);
            vec2 center = vec2(col * hex_col_step + row_shift, row * hex_row_step);
            vec2 local = grid_point - center;
            float distance_squared = dot(local, local);

            if (distance_squared < nearest_d2) {
                nearest_d2 = distance_squared;
                nearest_local = local;
                nearest_cell = vec2(col, row);
            }
        }
    }

float cell_seed = dot(nearest_cell, vec2(127.1, 311.7));
float cell_phase = fract(sin(cell_seed) * 43758.5453) * 6.2831853;
float panel_res = 0.5 + 0.5 * cos(
    boric.x * 2.612 + (field - 0.5) * 3.14 + cell_phase
);

    vec2 hex_abs = abs(nearest_local);
float hex_metric = max(
    hex_abs.y,
    dot(hex_abs, vec2(0.8660254, 0.5))
);
float edge_glow = smoothstep(hex_radius - 1.4, hex_radius, hex_metric);

    float shine = max(smoothstep(0.68, 0.92, panel_res), edge_glow * 0.8);

vec3 green_rgb = vec3(100.0, 198.0, 14.0) / 255.0;

vec3 yellow_rgb = vec3(255.0, 230.0, 141.0) / 255.0; // rgb(255, 230, 141)
vec3 gold_rgb = vec3(162.0, 241.0, 72.0) / 255.0;   // rgb(162, 241, 72)

float yellow_mix = smoothstep(0.50, 0.75, shine);
float gold_mix = smoothstep(0.85, 0.98, shine);

vec3 holo_rgb = mix(green_rgb, yellow_rgb, yellow_mix);
holo_rgb = mix(holo_rgb, gold_rgb, gold_mix);

vec4 rainbow_hsl = hsl;
rainbow_hsl.x += panel_res + edge_glow;
rainbow_hsl.y = min(rainbow_hsl.y * 1.3, 1.0);
rainbow_hsl.z = rainbow_hsl.z * 0.6 + 0.4;

vec3 rainbow_rgb = RGB(rainbow_hsl).rgb;
float gray = dot(rainbow_rgb, vec3(0.299, 0.587, 0.114));
float mono_strength = smoothstep(0.68, 0.92, panel_res) * 0.30;

holo_rgb = mix(holo_rgb, vec3(gray), mono_strength);

    tex.rgb = mix(tex.rgb, holo_rgb, 0.5);
	
	if (tex[3] < 0.7)
		tex[3] = tex[3]/3.;
	return dissolve_mask(tex*colour, texture_coords, uv);
}

extern MY_HIGHP_OR_MEDIUMP vec2 mouse_screen_pos;
extern MY_HIGHP_OR_MEDIUMP float hovering;
extern MY_HIGHP_OR_MEDIUMP float screen_scale;

#ifdef VERTEX
vec4 position( mat4 transform_projection, vec4 vertex_position )
{
    if (hovering <= 0.){
        return transform_projection * vertex_position;
    }
    float mid_dist = length(vertex_position.xy - 0.5*love_ScreenSize.xy)/length(love_ScreenSize.xy);
    vec2 mouse_offset = (vertex_position.xy - mouse_screen_pos.xy)/screen_scale;
    float scale = 0.2*(-0.03 - 0.3*max(0., 0.3-mid_dist))
                *hovering*(length(mouse_offset)*length(mouse_offset))/(2. -mid_dist);

    return transform_projection * vertex_position + vec4(0,0,0,scale);
}
#endif
