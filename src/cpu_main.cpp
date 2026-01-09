#include "cpu_main.h"

#include <algorithm>
#include <random>

inline float cpuIndexToFloat(const int index, const int windowSize) {
    return static_cast<float>(index + 1) / static_cast<float>(windowSize) * 2 - 1;
}

inline int cpuFloatToIndex(const float fl, const int windowSize) {
    return static_cast<int>((fl + 1) / 2 * windowSize);
}

void cpuFillPixelStructsArray(const int windowSize, CpuPixel *pixels) {
    for (int x = 0; x < windowSize; x++) {
        for (int y = 0; y < windowSize; y++) {
            const unsigned int index = y * windowSize + x;
            pixels[index].x = cpuIndexToFloat(x, windowSize);
            pixels[index].y = cpuIndexToFloat(y, windowSize);
        }
    }
}

inline int cpuGetGridIndex(const int row, const int col, const int gridCountInOneDimension) {
    return row * gridCountInOneDimension + col;
}

inline int cpuGetGridIndex(const float x, const float y, const int windowSize, const int gridCountInOneDimension) {
    return cpuGetGridIndex(cpuFloatToIndex(x, windowSize), cpuFloatToIndex(y, windowSize), gridCountInOneDimension);
}

void cpuFillParticleStructsArray(const int particlesCount, CpuParticle *particles, const int windowSize, const int gridCountInOneDimension) {
    std::random_device random_device;
    std::mt19937 gen(random_device());
    std::uniform_real_distribution<float> distrib(-1, 1);

    for (int i = 0; i < particlesCount; i++) {
        particles[i].x = distrib(gen);
        particles[i].y = distrib(gen);
        particles[i].v_x = distrib(gen);
        particles[i].v_y = distrib(gen);
        particles[i].gridIndex = cpuGetGridIndex(particles[i].x, particles[i].y, windowSize, gridCountInOneDimension);
    }
}

void cpuSortByGridIndex(CpuParticle *particles, const int particlesCount) {
    static auto comparer = [](const CpuParticle &a, const CpuParticle &b) {
        return a.gridIndex < b.gridIndex;
    };
    std::sort(particles, particles + particlesCount, comparer);
}