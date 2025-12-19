#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;
uniform vec3 uColor;
uniform float uIntensity;
uniform vec2 uOrigin;
uniform float uRayLength;
uniform float uDensity;

out vec4 fragColor;

float hash(float n) { return fract(sin(n) * 43758.5453123); }
float noise(vec2 x) {
    vec2 p = floor(x);
    vec2 f = fract(x);
    f = f * f * (3.0 - 2.0 * f);
    float n = p.x + p.y * 57.0;
    return mix(mix(hash(n + 0.0), hash(n + 1.0), f.x),
               mix(hash(n + 57.0), hash(n + 58.0), f.x), f.y);
}
float fbm(vec2 p) {
    float f = 0.0;
    f += 0.50000 * noise(p); p = p * 2.02;
    f += 0.25000 * noise(p); p = p * 2.03;
 
    return f;
}

void main() {
    vec2 uv = FlutterFragCoord().xy / uSize;
    vec2 lightOrigin = uOrigin;
    vec2 toLight = uv - lightOrigin;
    
    float dist = length(toLight); 

if (dist > uRayLength + 0.1) {
        fragColor = vec4(0.0);
        return; 
    }

    float angle = atan(toLight.y, toLight.x);
    
    float rays = fbm(vec2(angle * uDensity + uTime * 0.3, dist * 1.0));
    rays = smoothstep(0.2, 1.0, rays);

    // --- ИСПРАВЛЕНИЕ ТУСКЛОСТИ ---
    
    // ВАРИАНТ 1: "Твердое ядро". 
    // Затухание начинается не сразу, а только после прохождения 50% длины.
    // Если uRayLength = 0.5, то до 0.25 яркость полная, и только потом падает.
    // 1.0 - smoothstep(начало_спада, конец_спада, дистанция)
    float lengthFade = 1.0 - smoothstep(uRayLength * 0.5, uRayLength, dist);

    // ВАРИАНТ 2 (Если Вариант 1 слишком резкий): Экспоненциальное усиление.
    // Раскомментируйте строки ниже, если хотите более мягкий, но яркий свет:
    /*
    float fadeLinear = 1.0 - smoothstep(0.0, uRayLength, dist);
    // Возведение в степень < 1.0 делает график "выпуклым" (дольше остается ярким)
    lengthFade = pow(fadeLinear, 0.5); 
    */

    // Стандартный фейд по Y (можно убрать, если мешает длине)
    float fadeDown = smoothstep(1.2, -0.2, uv.y); 

    // Собираем итоговую альфу
    float alpha = rays * lengthFade * fadeDown * uIntensity;

    fragColor = vec4(uColor * alpha, alpha);
}