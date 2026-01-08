#include <iostream>
#include <glad/gl.h>
#include <GLFW/glfw3.h>

#include "initializer.h"

auto vertexShaderSource = "#version 460 core\n"
    "layout (location = 0) in vec2 aPos;\n"
    "layout (location = 1) in vec3 aColor;"
    "\n"
    "out vec3 pixelColor;\n"
    "\n"
    "void main() {\n"
    "   gl_Position = vec4(aPos, 0.0, 1.0);\n"
    "   pixelColor = aColor;\n"
    "}\0";

auto fragmentShaderSource = "#version 460 core\n"
    "in vec3 pixelColor;\n"
    "\n"
    "out vec4 FragColor;\n"
    "\n"
    "void main() {\n"
    "   FragColor = vec4(pixelColor, 1.0);\n"
    "}\0";

int windowWidth, windowHeight;

void processInput(GLFWwindow *window) {
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        glfwSetWindowShouldClose(window, true);
}

void usage(const char *errorMessage, const char *programName) {
    std::cerr << "Error: " << errorMessage << std::endl;
    std::cerr << "Usage: " << programName << " width height method particles" << std::endl;
}

int main(const int argc, const char **argv) {
    // Arguments parsing
    if (argc != 5) {
        usage("Invalid argument count!", argv[0]);
        return -1;
    }

    windowWidth = atoi(argv[1]);
    if (windowWidth <= 0 || windowWidth > 2000) {
        usage("Invalid width value (expected 0-2000)!", argv[0]);
        return -1;
    }

    windowHeight = atoi(argv[2]);
    if (windowHeight <= 0 || windowHeight > 2000) {
        usage("Invalid height value (expected 0-2000)!", argv[0]);
        return -1;
    }

    char method;
    if (strcmp(argv[3], "cpu") == 0)
        method = 'c';
    else if (strcmp(argv[3], "gpu") == 0)
        method = 'g';
    else {
        usage(R"(Invalid method (expected 'cpu' or 'gpu')!)", argv[0]);
        return -1;
    }

    const int particlesCount = atoi(argv[4]);
    if (particlesCount <= 0 || particlesCount >= windowWidth * windowHeight) {
        usage("Particles count should be in range (0, width * height)!", argv[0]);
        return -1;
    }

    // Window initialization
    glfwInit();
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 4);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
    glfwWindowHint(GLFW_RESIZABLE, GLFW_FALSE);

    GLFWwindow *window = glfwCreateWindow(windowWidth, windowHeight, "Electrons and Protons", nullptr, nullptr);
    if (window == nullptr) {
        std::cerr << "Failed to create GLFW window!" << std::endl;
        glfwTerminate();
        return -1;
    }
    glfwMakeContextCurrent(window);

    if (gladLoadGL(glfwGetProcAddress) == 0) {
        std::cerr << "Failed to initialize GLAD!" << std::endl;
        glfwTerminate();
        return -1;
    }

    glViewport(0, 0, windowWidth, windowHeight);

    // Preparing data structures - pixels
    const int pixelsCount = windowWidth * windowHeight;
    float *pixelsColor = new float[pixelsCount];
    float *pixelsX = new float[pixelsCount];
    float *pixelsY = new float[pixelsCount];
    fillPixelsArray(windowWidth, windowHeight, pixelsX, pixelsY);

    unsigned int pixelsVao;
    glGenVertexArrays(1, &pixelsVao);
    glBindVertexArray(pixelsVao);

    unsigned int pixelsXVbo, pixelsYVbo, pixelsColorVbo;
    glGenBuffers(1, &pixelsXVbo);
    glGenBuffers(1, &pixelsYVbo);
    glGenBuffers(1, &pixelsColorVbo);

    glBindBuffer(GL_ARRAY_BUFFER, pixelsXVbo);
    glBufferData(GL_ARRAY_BUFFER, pixelsCount * static_cast<int>(sizeof(float)), pixelsX, GL_DYNAMIC_DRAW);
    glVertexAttribPointer(0, 1, GL_FLOAT, GL_FALSE, sizeof(float), reinterpret_cast<void*>(0));
    glEnableVertexAttribArray(0);

    glBindBuffer(GL_ARRAY_BUFFER, pixelsYVbo);
    glBufferData(GL_ARRAY_BUFFER, pixelsCount * static_cast<int>(sizeof(float)), pixelsY, GL_DYNAMIC_DRAW);
    glVertexAttribPointer(1, 1, GL_FLOAT, GL_FALSE, sizeof(float), reinterpret_cast<void*>(0));
    glEnableVertexAttribArray(1);

    glBindBuffer(GL_ARRAY_BUFFER, pixelsColorVbo);
    glBufferData(GL_ARRAY_BUFFER, pixelsCount * static_cast<int>(sizeof(float)), pixelsColor, GL_DYNAMIC_DRAW);
    glVertexAttribPointer(2, 1, GL_FLOAT, GL_FALSE, sizeof(float), reinterpret_cast<void*>(0));
    glEnableVertexAttribArray(2);

    // Particles
    // float *particles = getInitializedParticlesArray(particlesCount);
    // const int particlesSize = particlesCount * 2;

    const unsigned int vertexShader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertexShader, 1, &vertexShaderSource, nullptr);
    glCompileShader(vertexShader);
    int success;
    glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &success);
    if (!success) {
        char infoLog[512];
        glGetShaderInfoLog(vertexShader, 512, nullptr, infoLog);
        std::cerr << "ERROR::SHADER::VERTEX::COMPILATION_FAILED\n" << infoLog << std::endl;
        return -1;
    }

    const unsigned int fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragmentShader, 1, &fragmentShaderSource, nullptr);
    glCompileShader(fragmentShader);
    glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, &success);
    if (!success) {
        char infoLog[512];
        glGetShaderInfoLog(fragmentShader, 512, nullptr, infoLog);
        std::cerr << "ERROR::SHADER::VERTEX::COMPILATION_FAILED\n" << infoLog << std::endl;
        return -1;
    }

    const unsigned int shaderProgram = glCreateProgram();
    glAttachShader(shaderProgram, vertexShader);
    glAttachShader(shaderProgram, fragmentShader);
    glLinkProgram(shaderProgram);
    glGetProgramiv(shaderProgram, GL_LINK_STATUS, &success);
    if (!success) {
        char infoLog[512];
        glGetProgramInfoLog(shaderProgram, 512, nullptr, infoLog);
        std::cerr << "ERROR::SHADER::PROGRAM::LINKING_FAILED\n" << infoLog << std::endl;
        return -1;
    }
    glUseProgram(shaderProgram);
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);

    char windowTitle[128];
    int framesCount = 0;
    double lastTimestamp = glfwGetTime();
    while (!glfwWindowShouldClose(window)) {
        framesCount++;
        const double currentTime = glfwGetTime();
        if (currentTime - lastTimestamp >= 0.5) {
            sprintf(windowTitle, "Electrons and Protons (%.1f FPS)", framesCount / (currentTime - lastTimestamp));
            framesCount = 0;
            lastTimestamp = currentTime;
            glfwSetWindowTitle(window, windowTitle);
        }

        processInput(window);

        // glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
        // glClear(GL_COLOR_BUFFER_BIT);

        glBindVertexArray(pixelsVao);
        glDrawArrays(GL_POINTS, 0, pixelsSize);

        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    glfwTerminate();
    // delete[] pixels;
    // delete[] particles;

    return 0;
}