#if defined(VERTEX) || __VERSION__ > 100 || defined(GL_FRAGMENT_PRECISION_HIGH)
    #define PRECISION highp
#else
    #define PRECISION mediump
#endif










#define TAU 6.28318530718
#define MAX_ITER 5

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
extern PRECISION vec2 singularity_aquarium;

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

vec4 effect(vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    float uniform_keepalive = dissolve
        + texture_details.x
        + image_details.x
        + burn_colour_1.x
        + burn_colour_2.x
        + mouse_screen_pos.x
        + screen_scale
        + singularity_aquarium.x
        + singularity_aquarium.y
        + (shadow ? 1.0 : 0.0);
    uniform_keepalive *= 0.000000001;
    float shader_time = singularity_aquarium.y * 0.5 + time * 0.001 + 23.0;
    
    vec2 uv = local_uv(texture_coords);
    vec4 pixel = Texel(texture, texture_coords);

#ifdef SHOW_TILING
    vec2 p = mod(uv * TAU * 2.0, TAU) - 250.0;
#else
    vec2 p = mod(uv * TAU, TAU) - 250.0;
#endif
    vec2 i = vec2(p);
    float c = 1.0;
    float inten = 0.005;

    for (int n = 0; n < MAX_ITER; n++)
    {
        float t = shader_time * (1.0 - (3.5 / float(n + 1)));
        i = p + vec2(cos(t - i.x) + sin(t + i.y), sin(t - i.y) + cos(t + i.x));
        c += 1.0 / length(vec2(p.x / (sin(i.x + t) / inten), p.y / (cos(i.y + t) / inten)));
    }
    c /= float(MAX_ITER);
    c = 1.17 - pow(c, 1.4);
    vec3 shader_colour = vec3(pow(abs(c), 8.0));
    shader_colour = clamp(shader_colour + vec3(0.0, 0.35, 0.5), 0.0, 1.0);

#ifdef SHOW_TILING
    
    vec2 pixel = 2.0 / texture_details.zw;
    uv *= 2.0;
    float f = floor(mod(singularity_aquarium.y * 0.5, 2.0)); 
    vec2 first = step(pixel, uv) * f;             
    uv = step(fract(uv), pixel);                  
    shader_colour = mix(shader_colour, vec3(1.0, 1.0, 0.0), (uv.x + uv.y) * first.x * first.y); 
#endif

    float card_mask = smoothstep(0.02, 0.16, pixel.a) * soft_card_bounds(uv);
    float dissolve_fade = 1.0 - smoothstep(0.0, 1.0, dissolve);
    float alpha = 0.42 * card_mask * dissolve_fade * colour.a;

    if (shadow) {
        return vec4(vec3(uniform_keepalive), alpha * 0.18);
    }

    return vec4((shader_colour + vec3(uniform_keepalive)) * colour.rgb, alpha);
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

