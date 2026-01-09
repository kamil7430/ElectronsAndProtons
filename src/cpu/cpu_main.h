#ifndef ELECTRONSANDPROTONS_CPU_MAIN_H
#define ELECTRONSANDPROTONS_CPU_MAIN_H

#include <assert.h>
#include <GLFW/glfw3.h>

#include "../common.h"

constexpr int GRID_SIZE = 100;

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
    int gridIndex;
} CpuParticle;

void cpuFillPixelStructsArray(const int windowSize, CpuPixel *pixels);
void cpuFillParticleStructsArray(const int particlesCount, CpuParticle *particles);

inline void cpuMain(const int windowSize, const int particlesCount, GLFWwindow *window) {
    // Preparing data structures - pixels
    const int pixelsCount = windowSize * windowSize;
    CpuPixel *pixels = new CpuPixel[pixelsCount];
    cpuFillPixelStructsArray(windowSize, pixels);

    // Particles
    CpuParticle *particles = new CpuParticle[particlesCount];
    cpuFillParticleStructsArray(particlesCount, particles);

    // Grid
    assert(windowSize % 100 == 0);
    const int gridCountInOneDimension = windowSize / GRID_SIZE;



    delete[] particles;
    delete[] pixels;
}

#endif //ELECTRONSANDPROTONS_CPU_MAIN_H