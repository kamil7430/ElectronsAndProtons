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
            break;
    }

    glfwTerminate();

    return 0;
}

// ======================================
//
// // Preparing data structures - pixels
// const int pixelsCount = windowWidth * windowHeight;
// float *pixelsX = new float[pixelsCount];
// float *pixelsY = new float[pixelsCount];
// float *pixelsV = new float[pixelsCount];
// fillPixelsArray(windowWidth, windowHeight, pixelsX, pixelsY);
//
// unsigned int pixelsVao;
// glGenVertexArrays(1, &pixelsVao);
// glBindVertexArray(pixelsVao);
//
// unsigned int pixelsXVbo, pixelsYVbo, pixelsVVbo;
// glGenBuffers(1, &pixelsXVbo);
// glGenBuffers(1, &pixelsYVbo);
// glGenBuffers(1, &pixelsVVbo);
//
// glBindBuffer(GL_ARRAY_BUFFER, pixelsXVbo);
// glBufferData(GL_ARRAY_BUFFER, pixelsCount * static_cast<int>(sizeof(float)), pixelsX, GL_STATIC_DRAW);
// glVertexAttribPointer(0, 1, GL_FLOAT, GL_FALSE, sizeof(float), reinterpret_cast<void*>(0));
// glEnableVertexAttribArray(0);
//
// glBindBuffer(GL_ARRAY_BUFFER, pixelsYVbo);
// glBufferData(GL_ARRAY_BUFFER, pixelsCount * static_cast<int>(sizeof(float)), pixelsY, GL_STATIC_DRAW);
// glVertexAttribPointer(1, 1, GL_FLOAT, GL_FALSE, sizeof(float), reinterpret_cast<void*>(0));
// glEnableVertexAttribArray(1);
//
// // Particles
// float *particlesX = new float[particlesCount];
// float *particlesY = new float[particlesCount];
// float *particlesV_x = new float[particlesCount];
// float *particlesV_y = new float[particlesCount];
// fillParticlesArray(particlesCount, particlesX, particlesY, particlesV_x, particlesV_y);
//
// unsigned int particlesVao;
// glGenVertexArrays(1, &particlesVao);
// glBindVertexArray(particlesVao);
//
// unsigned int particlesXVbo, particlesYVbo, particlesV_xVbo, particlesV_yVbo;
// glGenBuffers(1, &particlesXVbo);
// glGenBuffers(1, &particlesYVbo);
// glGenBuffers(1, &particlesV_xVbo);
// glGenBuffers(1, &particlesV_yVbo);
//
// // Shaders
// const Shader pixelsShader("shaders/vertex/pixels.vert", "shaders/fragment/pixels.frag");
// const Shader particlesShader("shaders/vertex/particles.vert", "shaders/fragment/particles.frag");
//
// // Main loop
// char windowTitle[128];
// int framesCount = 0;
// double lastFpsCalculationTimestamp = glfwGetTime();
// double currentTime = glfwGetTime();
// while (!glfwWindowShouldClose(window)) {
//     framesCount++;
//     const double previousTime = currentTime;
//     currentTime = glfwGetTime();
//     if (currentTime - lastFpsCalculationTimestamp >= 0.5) {
//         sprintf(windowTitle, "Electrons and Protons (%.1f FPS)", framesCount / (currentTime - lastFpsCalculationTimestamp));
//         framesCount = 0;
//         lastFpsCalculationTimestamp = currentTime;
//         glfwSetWindowTitle(window, windowTitle);
//     }
//
//     processInput(window);
//
//     const double timeDelta = currentTime - previousTime;
//     switch (method) {
//         case 'c':
//             doCpuFieldComputations(pixelsCount, pixelsX, pixelsY, pixelsV,
//                 particlesCount, particlesX, particlesY, particlesV_x, particlesV_y,
//                 timeDelta);
//             break;
//         case 'g':
//             // TODO
//             break;
//     }
//
//     pixelsShader.use();
//     glBindVertexArray(pixelsVao);
//     glDrawArrays(GL_POINTS, 0, pixelsCount);
//
//     glBindBuffer(GL_ARRAY_BUFFER, pixelsVVbo);
//     glBufferData(GL_ARRAY_BUFFER, pixelsCount * static_cast<int>(sizeof(float)), pixelsV, GL_DYNAMIC_DRAW);
//     glVertexAttribPointer(2, 1, GL_FLOAT, GL_FALSE, sizeof(float), reinterpret_cast<void*>(0));
//     glEnableVertexAttribArray(2);
//
//     particlesShader.use();
//     glBindVertexArray(particlesVao);
//     glDrawArrays(GL_POINTS, 0, particlesCount);
//
//     glBindBuffer(GL_ARRAY_BUFFER, particlesXVbo);
//     glBufferData(GL_ARRAY_BUFFER, particlesCount * static_cast<int>(sizeof(float)), particlesX, GL_DYNAMIC_DRAW);
//     glVertexAttribPointer(0, 1, GL_FLOAT, GL_FALSE, sizeof(float), reinterpret_cast<void*>(0));
//     glEnableVertexAttribArray(0);
//
//     glBindBuffer(GL_ARRAY_BUFFER, particlesYVbo);
//     glBufferData(GL_ARRAY_BUFFER, particlesCount * static_cast<int>(sizeof(float)), particlesY, GL_DYNAMIC_DRAW);
//     glVertexAttribPointer(1, 1, GL_FLOAT, GL_FALSE, sizeof(float), reinterpret_cast<void*>(0));
//     glEnableVertexAttribArray(1);
//
//     // glBindBuffer(GL_ARRAY_BUFFER, particlesV_xVbo);
//     // glBufferData(GL_ARRAY_BUFFER, particlesCount * static_cast<int>(sizeof(float)), particlesV_x, GL_DYNAMIC_DRAW);
//     // glVertexAttribPointer(2, 1, GL_FLOAT, GL_FALSE, sizeof(float), reinterpret_cast<void*>(0));
//     // glEnableVertexAttribArray(2);
//     //
//     // glBindBuffer(GL_ARRAY_BUFFER, particlesV_yVbo);
//     // glBufferData(GL_ARRAY_BUFFER, particlesCount * static_cast<int>(sizeof(float)), particlesV_y, GL_DYNAMIC_DRAW);
//     // glVertexAttribPointer(3, 1, GL_FLOAT, GL_FALSE, sizeof(float), reinterpret_cast<void*>(0));
//     // glEnableVertexAttribArray(3);
//
//     if (!shouldSimulationStop) {
//         switch (method) {
//             case 'c':
//                 doCpuMovementComputations(pixelsCount, pixelsX, pixelsY, pixelsV,
//                     particlesCount, particlesX, particlesY, particlesV_x, particlesV_y,
//                     static_cast<float>(timeDelta), windowWidth, windowHeight);
//                 break;
//             case 'g':
//                 // TODO
//                 break;
//         }
//     }
//
//     glfwSwapBuffers(window);
//     glfwPollEvents();
// }
//
// // Clean up
// delete[] pixelsX;
// delete[] pixelsY;
// delete[] pixelsV;
// delete[] particlesX;
// delete[] particlesY;
// delete[] particlesV_x;
// delete[] particlesV_y;
