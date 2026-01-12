#version 410 core

layout (location = 0) in float aPixelX;
layout (location = 1) in float aPixelY;
layout (location = 2) in float aPixelV;

out vec3 aColor;

void main() {
    if (aPixelV < 0) {
        aColor = vec3(0.0f, 0.0f, -aPixelV);
    } else {
        aColor = vec3(aPixelV, 0.0f, 0.0f);
    }

    gl_Position = vec4(aPixelX, aPixelY, 0.0f, 1.0f);
}