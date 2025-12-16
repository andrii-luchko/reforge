#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;   // Розмір екрану (було uSize)
uniform float uTime;
uniform vec3 uColor;
uniform float uQuantity;
uniform float uSpeed;
uniform float uParticleSize; // Розмір частинки (було uSize)
uniform float uAlphaSpeed;

out vec4 fragColor;

float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

void main() {
    vec2 uv = FlutterFragCoord().xy / uResolution;
    uv.x *= uResolution.x / uResolution.y;
    
    vec2 gridUV = uv * uQuantity;
    vec2 gridID = floor(gridUV);
    
    vec3 color = vec3(0.0);
    
    for(int y = -1; y <= 1; y++) {
        for(int x = -1; x <= 1; x++) {
            vec2 offset = vec2(float(x), float(y));
            vec2 neighborID = gridID + offset;
            
            float n = hash(neighborID);
            
            float randomAngle = hash(neighborID + 1.0) * 6.28;
            vec2 direction = vec2(cos(randomAngle), sin(randomAngle));
            
            vec2 moveShift = direction * uTime * uSpeed;
            
            vec2 startPos = vec2(hash(neighborID), hash(neighborID + 2.0));
            vec2 particlePos = fract(startPos + moveShift) + offset;
            
            vec2 localUV = fract(gridUV);
            float dist = length(localUV - particlePos);
            
            float circle = 1.0 - smoothstep(uParticleSize - 0.01, uParticleSize + 0.01, dist);
            
            float fade = sin(uTime * uAlphaSpeed + n * 10.0) * 0.5 + 0.5;
            
            color += circle * fade * uColor;
        }
    }
    
    fragColor = vec4(color, length(color));
}