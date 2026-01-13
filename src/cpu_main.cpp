#include "cpu_main.h"

#include <algorithm>
#include <cmath>
#include <random>

#include "cuda_common.cuh"

static constexpr float k = 1e-3;

void cpuFillPixelStructsArray(const int windowSize, CpuPixel *pixels) {
    for (int x = 0; x < windowSize; x++) {
        for (int y = 0; y < windowSize; y++) {
            const unsigned int index = y * windowSize + x;
            pixels[index].x = indexToFloat(x, windowSize);
            pixels[index].y = indexToFloat(y, windowSize);
        }
    }
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
        particles[i].gridIndex = getGridIndex(particles[i].x, particles[i].y, windowSize, gridCountInOneDimension);
    }
}

void cpuFillStaticSourcesArray(std::vector<CpuParticle> &staticSources, const int windowSize, const int gridCountInOneDimension) {
    constexpr float chargeScale = 30.0f;

    std::random_device random_device;
    std::mt19937 gen(random_device());
    std::uniform_real_distribution<float> distrib(-1, 1);

    for (CpuParticle &source : staticSources) {
        source.x = distrib(gen);
        source.y = distrib(gen);
        // source.v_x = 0.0f;
        // source.v_y = 0.0f;
        source.q = std::round(distrib(gen) * chargeScale);
        // source.gridIndex = getGridIndex(source.x, source.y, windowSize, gridCountInOneDimension);
    }
}

void cpuSortByGridIndex(CpuParticle *particles, const int particlesCount) {
    static auto comparer = [&](const CpuParticle &a, const CpuParticle &b) {
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

void cpuComputePotential(const int *gridStartIndices, const int gridSize, CpuPixel *pixels, const int pixelsCount, const CpuParticle *particles,
    const int particlesCount, const std::vector<CpuParticle> &staticSources, const int windowSize, const int gridCountInOneDimension) {
    for (int pix = 0; pix < pixelsCount; pix++) {
        const float x = pixels[pix].x;
        const float y = pixels[pix].y;

        float V = 0;

        auto calculate = [&](const int gridInd) {
            const int startIndex = gridStartIndices[gridInd];
            if (startIndex < 0)
                return;

            int stopIndex;
            if (gridInd + 1 >= gridSize) {
                stopIndex = particlesCount;
            } else {
                int i = gridInd + 1;
                do {
                    stopIndex = gridStartIndices[i];
                    i++;
                } while (stopIndex < 0 && i < gridSize);
                if (stopIndex < 0) {
                    stopIndex = particlesCount;
                }
            }

            for (int par = startIndex; par < stopIndex; par++) {
                const float vecX = particles[par].x - x;
                const float vecY = particles[par].y - y;

                const float r = std::sqrt(vecX * vecX + vecY * vecY);

                V += k * particles[par].q / r;
            }
        };

        const int gridIndex = getGridIndex(x, y, windowSize, gridCountInOneDimension);

        doGridWork(gridIndex, gridSize, gridCountInOneDimension, calculate);

        for (auto &source : staticSources) {
            const float vecX = source.x - x;
            const float vecY = source.y - y;

            const float r = std::sqrt(vecX * vecX + vecY * vecY);

            V += k * source.q / r;
        }

        pixels[pix].v = V;
    }
}

void cpuComputeParticlesMovement(const int *gridStartIndices, const int gridSize, CpuParticle *particles, const int particlesCount,
    const std::vector<CpuParticle> &staticSources, const int windowSize, const int gridCountInOneDimension, const float timeDelta) {
    for (int par = 0; par < particlesCount; par++) {
        float x = particles[par].x;
        float y = particles[par].y;
        float v_x = particles[par].v_x;
        float v_y = particles[par].v_y;
        int q = particles[par].q;

        // Calculate electrostatic force within grid neighbourhood
        float F_x = 0.0f;
        float F_y = 0.0f;

        auto calculate = [&](const int gridInd) {
            const int startIndex = gridStartIndices[gridInd];
            if (startIndex < 0)
                return;

            int stopIndex;
            if (gridInd + 1 >= gridSize) {
                stopIndex = particlesCount;
            } else {
                int i = gridInd + 1;
                do {
                    stopIndex = gridStartIndices[i];
                    i++;
                } while (stopIndex < 0 && i < gridSize);
                if (stopIndex < 0) {
                    stopIndex = particlesCount;
                }
            }

            for (int p = startIndex; p < stopIndex; p++) {
                if (p == par)
                    continue;

                const float vecX = particles[p].x - x;
                const float vecY = particles[p].y - y;

                const float rSquared = vecX * vecX + vecY * vecY;
                const float r = std::sqrt(rSquared);

                const int sense = q == particles[p].q ? -1 : 1;
                F_x += vecX * k * sense / (r * rSquared);
                F_y += vecY * k * sense / (r * rSquared);
            }
        };

        const int gridIndex = particles[par].gridIndex;
        doGridWork(gridIndex, gridSize, gridCountInOneDimension, calculate);

        // Static sources
        for (auto &source : staticSources) {
            const float vecX = source.x - x;
            const float vecY = source.y - y;

            const float rSquared = vecX * vecX + vecY * vecY;
            const float r = std::sqrt(rSquared);

            const int sense = -q * source.q;
            F_x += vecX * k * sense / (r * rSquared);
            F_y += vecY * k * sense / (r * rSquared);
        }

        // Update velocity (m = 1)
        v_x += F_x * timeDelta;
        v_x *= 0.90f;

        v_y += F_y * timeDelta;
        v_y *= 0.90f;

        // Update position and handle window frame bounces
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
        particles[par].gridIndex = getGridIndex(x, y, windowSize, gridCountInOneDimension);
    }
}