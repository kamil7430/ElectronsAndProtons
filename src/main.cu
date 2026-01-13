#include <format>
#include <iostream>
#include <glad/gl.h>
#include <GLFW/glfw3.h>

#include "cpu_main.h"
#include "gpu_main.cuh"

void usage(const char *errorMessage, const char *programName) {
    std::cerr << "Error: " << errorMessage << std::endl;
    std::cerr << "Usage: " << programName << " size method particles" << std::endl;
}

int main(const int argc, const char **argv) {
    // Arguments parsing
    if (argc != 4) {
        usage("Invalid argument count!", argv[0]);
        return -1;
    }

    const int windowSize = atoi(argv[1]);
    if (windowSize <= 0 || windowSize > 2000 || windowSize % GRID_SIZE_IN_PIXELS != 0) {
        usage(std::format("Invalid window size value (expected 0-2000 and divisible by {})!", GRID_SIZE_IN_PIXELS).c_str(), argv[0]);
        return -1;
    }

    char method;
    if (strcmp(argv[2], "cpu") == 0)
        method = 'c';
    else if (strcmp(argv[2], "gpu") == 0)
        method = 'g';
    else {
        usage(R"(Invalid method (expected 'cpu' or 'gpu')!)", argv[0]);
        return -1;
    }

    const int particlesCount = atoi(argv[3]);
    if (particlesCount <= 0 || particlesCount >= windowSize * windowSize) {
        usage("Particles count should be in range (0, size * size)!", argv[0]);
        return -1;
    }

    // Window initialization
    glfwInit();
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 1);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
    glfwWindowHint(GLFW_RESIZABLE, GLFW_FALSE);

    GLFWwindow *window = glfwCreateWindow(windowSize, windowSize, "Electrons and Protons", nullptr, nullptr);
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

    glViewport(0, 0, windowSize, windowSize);

    switch (method) {
        case 'c':
            cpuMain(windowSize, particlesCount, window);
            break;
        case 'g':
            gpuMain(windowSize, particlesCount, window);
            break;
        default:
            std::cerr << "Invalid method!" << std::endl;
            glfwTerminate();
            return -1;
    }

    glfwTerminate();

    return 0;
}
