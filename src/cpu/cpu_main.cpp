#include "cpu_main.h"

#include <random>

void cpuFillPixelStructsArray(const int windowSize, CpuPixel *pixels) {
    for (int x = 0; x < windowSize; x++) {
        for (int y = 0; y < windowSize; y++) {
            const unsigned int index = y * windowSize + x;
            pixels[index].x = static_cast<float>(x + 1) / static_cast<float>(windowSize) * 2 - 1;
            pixels[index].y = static_cast<float>(y + 1) / static_cast<float>(windowSize) * 2 - 1;
        }
    }
}

void cpuFillParticleStructsArray(const int particlesCount, CpuParticle *particles) {
    std::random_device random_device;
    std::mt19937 gen(random_device());
    std::uniform_real_distribution<float> distrib(-1, 1);

    for (int i = 0; i < particlesCount; i++) {
        particles[i].x = distrib(gen);
        particles[i].y = distrib(gen);
        particles[i].v_x = distrib(gen);
        particles[i].v_y = distrib(gen);
    }
}