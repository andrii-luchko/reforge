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

float hash(float n) {

    return fract(sin(n) * 43758.5453);

}

float noise(float angle) {



    float i = floor(angle);

    float f = fract(angle);

    

    float n = mix(hash(i), hash(i + 1.0), smoothstep(0.0, 1.0, f));

    return n;

}



void main() {

    vec2 uv = FlutterFragCoord().xy / uSize;

    



    vec2 distVec = uv - uOrigin;

    

    

    distVec.x *= (uSize.x / uSize.y);

    

    

    // distSquared = x*x + y*y

    float distSquared = dot(distVec, distVec);

    float maxLenSq = (uRayLength + 0.1) * (uRayLength + 0.1);

    if (distSquared > maxLenSq) {

        fragColor = vec4(0.0);

        return;

    }

    float dist = sqrt(distSquared);

    float angle = atan(distVec.y, distVec.x);

    // Нормализуем угол от -PI..PI к 0..1 для удобства

    float normalizedAngle = angle / 3.14159 + 1.0; 

    

    float movingAngle = normalizedAngle * uDensity + uTime * 0.001;



    // Генерируем лучи

    // Вместо сложения синусов используем "рваный" шум

    float rays = noise(movingAngle * 10.0);       // Основа

    rays += noise(movingAngle * 20.0 + uTime) * 0.5; // Детали

    

    // Усиливаем контраст лучей (делаем их тоньше и ярче)

    rays = pow(rays, 3.0); 



    // Затухание

    float lengthFade = 1.0 - smoothstep(0.0, uRayLength, dist);

    

    // Доп. фишка: центр ярче ("корона" солнца)

    float coreGlow = 1.0 / (dist * 10.0 + 0.5); 

    

    float alpha = (rays * uIntensity + coreGlow * 0.5) * lengthFade;

    

    // Применяем цвет

    fragColor = vec4(uColor * alpha, alpha);

}
