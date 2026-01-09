#ifndef ELECTRONSANDPROTONS_CPU_MAIN_H
#define ELECTRONSANDPROTONS_CPU_MAIN_H

#include <assert.h>
#include <cstdio>
#include <glad/gl.h>
#include <GLFW/glfw3.h>

#include "common.h"
#include "shaders/shader.h"

typedef struct {
    float x;
    float y;
    float v;
} CpuPixel;

typedef struct {
    float x;
    float y;
    float v_x;
    float v_y;
    int q;
    int gridIndex;
} CpuParticle;

inline float cpuIndexToFloat(const int index, const int windowSize);
inline int cpuFloatToIndex(const float fl, const int windowSize);
void cpuFillPixelStructsArray(const int windowSize, CpuPixel *pixels);
inline int cpuGetGridIndex(const int row, const int col, const int gridCountInOneDimension);
inline int cpuGetGridIndex(const float x, const float y, const int windowSize, const int gridCountInOneDimension);
void cpuFillParticleStructsArray(const int particlesCount, CpuParticle *particles, const int windowSize, const int gridCountInOneDimension);
void cpuSortByGridIndex(CpuParticle *particles, const int particlesCount);
void cpuFindGridStartIndices(int *gridStartIndices, const int gridSize, const CpuParticle *particles, const int particlesCount);
void cpuComputePotential(int *gridStartIndices, const int gridSize, CpuPixel *pixels, const int pixelsCount, const CpuParticle *particles, const int particlesCount, const int windowSize, const int gridCountInOneDimension);

inline void cpuMain(const int windowSize, const int particlesCount, GLFWwindow *window) {
    // Preparing data structures - pixels
    const int pixelsCount = windowSize * windowSize;
    CpuPixel *pixels = new CpuPixel[pixelsCount];
    cpuFillPixelStructsArray(windowSize, pixels);

    // Grid
    assert(windowSize % GRID_SIZE_IN_PIXELS == 0);
    const int gridCountInOneDimension = windowSize / GRID_SIZE_IN_PIXELS;
    const int gridSize = gridCountInOneDimension * gridCountInOneDimension;

    // Particles
    CpuParticle *particles = new CpuParticle[particlesCount];
    cpuFillParticleStructsArray(particlesCount, particles, windowSize, gridCountInOneDimension);

    // Grid indices array
    int *gridStartIndices = new int[gridSize];

    // OpenGL stuff - pixels buffer
    unsigned int pixelsVao;
    glGenVertexArrays(1, &pixelsVao);
    glBindVertexArray(pixelsVao);

    unsigned int pixelsVbo;
    glGenBuffers(1, &pixelsVbo);

    // OpenGL stuff - particles buffer
    unsigned int particlesVao;
    glGenVertexArrays(1, &particlesVao);
    glBindVertexArray(particlesVao);

    unsigned int particlesVbo;
    glGenBuffers(1, &particlesVbo);

    // OpenGL stuff - Shaders
    const Shader pixelsShader("shaders/vertex/cpu/pixels.vert", "shaders/fragment/pixels.frag");
    const Shader particlesShader("shaders/vertex/cpu/particles.vert", "shaders/fragment/particles.frag");

    // Main loop
    char windowTitle[128];
    int framesCount = 0;
    double lastFpsCalculationTimestamp = glfwGetTime();
    double currentTime = glfwGetTime();
    while (!glfwWindowShouldClose(window)) {
        framesCount++;
        const double previousTime = currentTime;
        currentTime = glfwGetTime();
        if (currentTime - lastFpsCalculationTimestamp >= 0.5) {
            sprintf(windowTitle, "Electrons and Protons (%.1f FPS)", framesCount / (currentTime - lastFpsCalculationTimestamp));
            framesCount = 0;
            lastFpsCalculationTimestamp = currentTime;
            glfwSetWindowTitle(window, windowTitle);
        }

        processInput(window);

        cpuSortByGridIndex(particles, particlesCount);
        cpuFindGridStartIndices(gridStartIndices, gridSize, particles, particlesCount);
        cpuComputePotential(gridStartIndices, gridSize, pixels, pixelsCount, particles, particlesCount, windowSize, gridCountInOneDimension);

        pixelsShader.use();
        glBindVertexArray(pixelsVao);
        glBindBuffer(GL_ARRAY_BUFFER, pixelsVbo);
        glBufferData(GL_ARRAY_BUFFER, pixelsCount * static_cast<int>(sizeof(CpuPixel)), pixels, GL_DYNAMIC_DRAW);
        glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, sizeof(CpuPixel), reinterpret_cast<void*>(0));
        glEnableVertexAttribArray(0);
        glVertexAttribPointer(1, 1, GL_FLOAT, GL_FALSE, sizeof(CpuPixel), reinterpret_cast<void*>(2 * sizeof(float)));
        glEnableVertexAttribArray(1);
        glDrawArrays(GL_POINTS, 0, pixelsCount);

        particlesShader.use();
        glBindVertexArray(particlesVao);
        glBindBuffer(GL_ARRAY_BUFFER, particlesVbo);
        glBufferData(GL_ARRAY_BUFFER, particlesCount * static_cast<int>(sizeof(CpuParticle)), particles, GL_DYNAMIC_DRAW);
        glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, sizeof(CpuParticle), reinterpret_cast<void*>(0));
        glEnableVertexAttribArray(0);
        glDrawArrays(GL_POINTS, 0, particlesCount);

        // const double timeDelta = currentTime - previousTime;

        // if (!shouldSimulationStop) {
        //     switch (method) {
        //         case 'c':
        //             doCpuMovementComputations(pixelsCount, pixelsX, pixelsY, pixelsV,
        //                 particlesCount, particlesX, particlesY, particlesV_x, particlesV_y,
        //                 static_cast<float>(timeDelta), windowWidth, windowHeight);
        //             break;
        //         case 'g':
        //             // TODO
        //             break;
        //     }
        // }

        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    delete[] gridStartIndices;
    delete[] particles;
    delete[] pixels;
}

#endif //ELECTRONSANDPROTONS_CPU_MAIN_H