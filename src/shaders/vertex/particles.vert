#version 460 core

layout (location = 0) in float aParticleX;
layout (location = 1) in float aParticleY;

void main() {
    gl_Position = vec4(aParticleX, aParticleY, 0.0f, 1.0f);
}