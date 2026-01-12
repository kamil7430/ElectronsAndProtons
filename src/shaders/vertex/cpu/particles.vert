#version 410 core

layout (location = 0) in vec2 aParticlePosition;

void main() {
    gl_Position = vec4(aParticlePosition, 0.0f, 1.0f);
}