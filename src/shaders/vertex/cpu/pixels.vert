#version 460 core

layout (location = 0) in vec2 aPixelPosition;
layout (location = 1) in float aPixelV;

out vec3 aColor;

void main() {
    if (aPixelV < 0) {
        aColor = vec3(0.0f, 0.0f, -aPixelV);
    } else {
        aColor = vec3(aPixelV, 0.0f, 0.0f);
    }

    gl_Position = vec4(aPixelPosition, 0.0f, 1.0f);
}