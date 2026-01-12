#version 410 core

layout (location = 0) in vec2 aPixelPosition;
layout (location = 1) in float aPixelPotential;

out vec3 aColor;

void main() {
    if (aPixelPotential < 0) {
        aColor = vec3(0.0f, 0.0f, -aPixelPotential);
    } else {
        aColor = vec3(aPixelPotential, 0.0f, 0.0f);
    }

    gl_Position = vec4(aPixelPosition, 0.0f, 1.0f);
}