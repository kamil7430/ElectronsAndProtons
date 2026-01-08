#version 460 core

layout (location = 0) in float aPixelX;
layout (location = 1) in float aPixelY;
layout (location = 2) in float aPixelE_x;
layout (location = 3) in float aPixelE_y;

out vec3 aColor;

void main() {
    float potential = aPixelE_x + aPixelE_y;

    if (potential > 0) {
        aColor = vec3(1.0f, 1.0f, 1.0f - potential);
    } else {
        aColor = vec3(1.0f - potential, 1.0f, 1.0f);
    }

    gl_Position = vec4(aPixelX, aPixelY, 0.0f, 1.0f);
}