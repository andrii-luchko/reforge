#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;
uniform vec3 uColor;
uniform float uQuantity;
uniform float uSpeed;
uniform float uParticleSize;
uniform float uAlphaSpeed;

out vec4 fragColor;

float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

vec2 hash2(vec2 p) {
    float x = hash(p);
    float y = hash(p + vec2(12.34, 56.78));
    return vec2(x, y) * 2.0 - 1.0;
}

void main() {
    vec2 uv = FlutterFragCoord().xy / uResolution;
    uv.x *= uResolution.x / uResolution.y;
    
    vec2 gridUV = uv * uQuantity;
    vec2 gridID = floor(gridUV);
    vec2 localUV = fract(gridUV);
    
    vec3 color = vec3(0.0);
    
 
    float absoluteSize = uParticleSize;
    
    for(int y = -1; y <= 1; y++) {
        for(int x = -1; x <= 1; x++) {
            vec2 offset = vec2(float(x), float(y));
            vec2 neighborID = gridID + offset;
            
            vec2 direction = hash2(neighborID + 1.0); 
            vec2 moveShift = direction * uTime * uSpeed;
            vec2 startPos = vec2(hash(neighborID), hash(neighborID + 2.0));
            vec2 particlePos = fract(startPos + moveShift) + offset;
            
            float dist = length(localUV - particlePos);
            
            float circle = 1.0 - smoothstep(absoluteSize, absoluteSize + (0.005 * uQuantity), dist);
            
            if (circle > 0.0) {
                 float n = hash(neighborID);
                 float fade = sin(uTime * uAlphaSpeed + n * 10.0) * 0.5 + 0.5;
                 color += circle * fade * uColor;
            }
        }
    }
    
    fragColor = vec4(color, length(color));
}