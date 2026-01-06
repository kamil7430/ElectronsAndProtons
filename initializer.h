#ifndef ELECTRONSANDPROTONS_INITIALIZER_H
#define ELECTRONSANDPROTONS_INITIALIZER_H

#include <random>

inline float* getInitializedPixelsArray(const int windowWidth, const int windowHeight) {
    constexpr unsigned int parametersPerVertex = 5;
    auto vertices = new float[windowWidth * windowHeight * parametersPerVertex];

    for (int x = 0; x < windowWidth; x++) {
        for (int y = 0; y < windowHeight; y++) {
            const unsigned int index = (y * windowWidth + x) * parametersPerVertex;
            vertices[index] = static_cast<float>(x + 1) / static_cast<float>(windowWidth) * 2 - 1;
            vertices[index + 1] = static_cast<float>(y + 1) / static_cast<float>(windowHeight) * 2 - 1;
            // vertices[index + 2] = 1.0f;
            // vertices[index + 3] = 1.0f;
            // vertices[index + 4] = 1.0f;
        }
    }

    return vertices;
}

inline float* getInitializedParticlesArray(const int particlesCount) {
    constexpr unsigned int parametersPerVertex = 2;
    auto vertices = new float[particlesCount * parametersPerVertex];

    std::random_device random_device;
    std::mt19937 gen(random_device());
    std::uniform_real_distribution<float> distrib(-1, 1);

    for (int i = 0; i < particlesCount * parametersPerVertex; i++) {
        vertices[i] = distrib(gen);
    }

    return vertices;
}

#endif //ELECTRONSANDPROTONS_INITIALIZER_H