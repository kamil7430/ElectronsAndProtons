#include "cpu_main.h"

#include <algorithm>
#include <random>

inline float cpuIndexToFloat(const int index, const int windowSize) {
    const float fl = static_cast<float>(index + 1) / static_cast<float>(windowSize) * 2 - 1;
    if (fl < -1.0f)
        return -1.0f;
    if (fl > 1.0f)
        return 1.0f;
    return fl;
}

inline int cpuFloatToIndex(const float fl, const int windowSize) {
    const int ind = static_cast<int>((fl + 1) / 2 * windowSize);
    if (ind < 0)
        return 0;
    if (ind >= windowSize)
        return windowSize - 1;
    return ind;
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
    return cpuGetGridIndex(cpuFloatToIndex(x, windowSize) / GRID_SIZE_IN_PIXELS, cpuFloatToIndex(y, windowSize) / GRID_SIZE_IN_PIXELS, gridCountInOneDimension);
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
        particles[i].q = distrib(gen) < 0 ? -1 : 1;
        particles[i].gridIndex = cpuGetGridIndex(particles[i].x, particles[i].y, windowSize, gridCountInOneDimension);
    }
}

void cpuSortByGridIndex(CpuParticle *particles, const int particlesCount) {
    static auto comparer = [](const CpuParticle &a, const CpuParticle &b) {
        return a.gridIndex < b.gridIndex;
    };
    std::sort(particles, particles + particlesCount, comparer);
}

void cpuFindGridStartIndices(int *gridStartIndices, const int gridSize, const CpuParticle *particles, const int particlesCount) {
    for (int i = 0; i < gridSize; i++)
        gridStartIndices[i] = -1;

    int g = particles[0].gridIndex;
    gridStartIndices[g] = 0;

    for (int i = 1; i < particlesCount; i++) {
        if (particles[i - 1].gridIndex == particles[i].gridIndex)
            continue;

        g += particles[i].gridIndex - particles[i - 1].gridIndex;
        assert(g < gridSize);
        gridStartIndices[g] = i;
    }
}

void cpuComputePotential(int *gridStartIndices, const int gridSize, CpuPixel *pixels, const int pixelsCount,
    const CpuParticle *particles, const int particlesCount, const int windowSize, const int gridCountInOneDimension) {
    for (int pix = 0; pix < pixelsCount; pix++) {
        const float x = pixels[pix].x;
        const float y = pixels[pix].y;

        const int gridIndex = cpuGetGridIndex(x, y, windowSize, gridCountInOneDimension);

        float V = 0;
        for (int par = 0; par < particlesCount; par++) {
            constexpr float k = 1e-2;

            const float vecX = particles[par].x - x;
            const float vecY = particles[par].y - y;

            const float r = sqrt(vecX * vecX + vecY * vecY);

            V += k * particles[par].q / r;
        }

        pixels[pix].v = V;
    }
}

void cpuComputeParticlesMovement(int *gridStartIndices, const int gridSize, CpuParticle *particles,
    const int particlesCount, const int windowSize, const int gridCountInOneDimension, const float timeDelta) {
    // TODO

    for (int par = 0; par < particlesCount; par++) {
        float x = particles[par].x;
        float y = particles[par].y;
        float v_x = particles[par].v_x;
        float v_y = particles[par].v_y;

        // Update positions and handle window frame bounces
        x += v_x * timeDelta;
        if (x < -1.0f || x > 1.0f) {
            v_x *= -1;
            x += v_x * timeDelta;
        }

        y += v_y * timeDelta;
        if (y < -1.0f || y > 1.0f) {
            v_y *= -1;
            y += v_y * timeDelta;
        }

        // Save new values
        particles[par].x = x;
        particles[par].y = y;
        particles[par].v_x = v_x;
        particles[par].v_y = v_y;
    }
}