#ifndef ELECTRONSANDPROTONS_SHADERS_H
#define ELECTRONSANDPROTONS_SHADERS_H

inline auto vertexShaderSource = "#version 460 core\n"
    "layout (location = 0) in vec2 aPos;\n"
    "layout (location = 1) in vec3 aColor;"
    "\n"
    "out vec3 pixelColor;\n"
    "\n"
    "void main() {\n"
    "   gl_Position = vec4(aPos, 0.0, 1.0);\n"
    "   pixelColor = aColor;\n"
    "}\0";

inline auto fragmentShaderSource = "#version 460 core\n"
    "in vec3 pixelColor;\n"
    "\n"
    "out vec4 FragColor;\n"
    "\n"
    "void main() {\n"
    "   FragColor = vec4(pixelColor, 1.0);\n"
    "}\0";

#endif //ELECTRONSANDPROTONS_SHADERS_H