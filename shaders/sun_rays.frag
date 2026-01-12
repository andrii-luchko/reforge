#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;       // Фізичний розмір
uniform float uTime;
uniform vec3 uColor;
uniform float uIntensity;
uniform vec2 uOrigin;     // 0.0 - 1.0
uniform float uRayLength;
uniform float uDensity;

out vec4 fragColor;

float fastNoise(float angle, float dist) {
    float n = sin(angle * uDensity + uTime * 0.5);
    n += sin(angle * uDensity * 2.1 - uTime * 0.8 + dist * 5.0) * 0.5;
    n += sin(angle * uDensity * 4.3 + uTime * 1.2) * 0.25;
    return max(0.0, n); 
}

void main() {
    // 1. Отримуємо UV (0.0 - 1.0)
    vec2 uv = FlutterFragCoord().xy / uSize;
    
    // 2. Рахуємо вектор від джерела світла до пікселя
    vec2 distVec = uv - uOrigin;
    
    // 3. Коригуємо ТІЛЬКИ вектор відстані на співвідношення сторін
    // Це робить круги круглими, а не овальними, але не зсуває центр
    distVec.x *= uSize.x / uSize.y;
    
    float dist = length(distVec);

    // Early exit
    if (dist > uRayLength + 0.1) {
        fragColor = vec4(0.0);
        return;
    }

    // 4. Кут рахуємо від скоригованого вектора
    float angle = atan(distVec.y, distVec.x);
    
    float rays = fastNoise(angle, dist);
    rays = smoothstep(0.3, 1.0, rays); 

    // Затухання
    float lengthFade = 1.0 - smoothstep(uRayLength * 0.5, uRayLength, dist);
    float alpha = rays * lengthFade * uIntensity;

    fragColor = vec4(uColor * alpha, alpha);
}