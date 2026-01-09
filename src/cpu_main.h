#ifndef ELECTRONSANDPROTONS_CPU_MAIN_H
#define ELECTRONSANDPROTONS_CPU_MAIN_H

#include <assert.h>
#include <GLFW/glfw3.h>

#include "common.h"

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

inline float cpuIndexToFloat(const int index, const int windowSize);
inline int cpuFloatToIndex(const float fl, const int windowSize);
void cpuFillPixelStructsArray(const int windowSize, CpuPixel *pixels);
inline int cpuGetGridIndex(const int row, const int col, const int gridCountInOneDimension);
inline int cpuGetGridIndex(const float x, const float y, const int windowSize, const int gridCountInOneDimension);
void cpuFillParticleStructsArray(const int particlesCount, CpuParticle *particles, const int windowSize, const int gridCountInOneDimension);
void cpuSortByGridIndex(CpuParticle *particles, const int particlesCount);

inline void cpuMain(const int windowSize, const int particlesCount, GLFWwindow *window) {
    // Preparing data structures - pixels
    const int pixelsCount = windowSize * windowSize;
    CpuPixel *pixels = new CpuPixel[pixelsCount];
    cpuFillPixelStructsArray(windowSize, pixels);

    // Grid
    assert(windowSize % 100 == 0);
    const int gridCountInOneDimension = windowSize / GRID_SIZE;

    // Particles
    CpuParticle *particles = new CpuParticle[particlesCount];
    cpuFillParticleStructsArray(particlesCount, particles, windowSize, gridCountInOneDimension);
    cpuSortByGridIndex(particles, particlesCount);



    delete[] particles;
    delete[] pixels;
}

#endif //ELECTRONSANDPROTONS_CPU_MAIN_H