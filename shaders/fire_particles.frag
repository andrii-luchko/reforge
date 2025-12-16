#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;
uniform vec3 uStartColor;
uniform vec3 uEndColor;
uniform float uQuantity;
uniform float uSpeed;
uniform float uSpread;

out vec4 fragColor;

float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

void main() {
    vec2 uv = FlutterFragCoord().xy / uResolution;
    
    vec3 color = vec3(0.0);
    
    // Помірна кількість: quantity * 8 (не quantity²)
    float totalParticles = uQuantity * 8.0;
    
    for(float i = 0.0; i < totalParticles; i += 1.0) {
        float particleID = i / totalParticles;
        
        float seed1 = particleID * 12.9898;
        float seed2 = particleID * 78.233;
        
        float randX = hash(vec2(seed1, 0.5));
        float randSpeed = 0.3 + hash(vec2(seed1, 1.5)) * 0.7;
        float randPhase = hash(vec2(seed2, 2.5)) * 10.0;
        float randSize = hash(vec2(seed1, 3.5));
        float isStreak = step(0.65, hash(vec2(seed2, 4.5)));
        
        float startX = randX;
        float startY = 1.0;
        
        float lifetime = mod(uTime * uSpeed * randSpeed + randPhase, 5.0);
        float progress = lifetime / 5.0;
        
        float x = startX + sin(lifetime * 0.5 + seed1) * uSpread * (randX - 0.5);
        float y = startY - progress * 1.3;
        
        // Early exit: якщо частинка далеко від поточного піксела - скіпаємо
        vec2 particlePos = vec2(x, y);
        vec2 diff = uv - particlePos;
        diff.x *= uResolution.x / uResolution.y;
        
        // Швидка перевірка відстані
        if (length(diff) > 0.05) continue;
        
        float alpha = 1.0 - progress;
        alpha *= smoothstep(0.0, 0.1, progress);
        alpha *= (0.4 + randSize * 0.6);
        
        vec3 particleColor = mix(uStartColor, uEndColor, progress * 0.8);
        
if (isStreak > 0.5) {
    float streakLength = 0.06 + randSize * 0.04;
    
    float distX = abs(diff.x);
    float distY = diff.y;
    
    if (distY > -streakLength && distY < 0.0) {
        // Форма краплі: ширина змінюється по довжині
        float progressAlongStreak = abs(distY) / streakLength;
        
        // Парабола: широке біля основи, вузьке на кінці
        float widthMultiplier = 1.0 - pow(progressAlongStreak, 1.5);
        float streakWidth = (0.001 + randSize * 0.004) * widthMultiplier;
        
        if (distX < streakWidth) {
            float fadeY = 1.0 - progressAlongStreak;
            float fadeX = 1.0 - smoothstep(0.0, streakWidth, distX);
            float intensity = fadeX * fadeY * fadeY * alpha;
            
            color += particleColor * intensity;
        }
    }
}else {
            // DOT
            float dist = length(diff);
            float radius = 0.02 + randSize * 0.007 ;
            
            float intensity = 1.0 - smoothstep(0.0, radius, dist);
            intensity = pow(intensity, 1.5) * alpha;
            
            color += particleColor * intensity * 0.7;
        }
    }
    
    fragColor = vec4(color, length(color));
}