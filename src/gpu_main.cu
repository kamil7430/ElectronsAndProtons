#include "gpu_main.cuh"

#include <random>
#include <thrust/sort.h>

__host__ void gpuFillPixelsArray(const int windowSize, float *xArray, float *yArray) {
    for (int x = 0; x < windowSize; x++) {
        for (int y = 0; y < windowSize; y++) {
            const unsigned int index = y * windowSize + x;
            xArray[index] = indexToFloat(x, windowSize);
            yArray[index] = indexToFloat(y, windowSize);
        }
    }
}

__host__ void gpuFillParticlesArray(const int particlesCount, float *particlesX, float *particlesY, float *particlesV_x,
    float *particlesV_y, int *particlesQ, int *particlesGridIndex, const int windowSize, const int gridCountInOneDimension) {
    std::random_device random_device;
    std::mt19937 gen(random_device());
    std::uniform_real_distribution<float> distrib(-1, 1);

    for (int i = 0; i < particlesCount; i++) {
        particlesX[i] = distrib(gen);
        particlesY[i] = distrib(gen);
        particlesV_x[i] = distrib(gen);
        particlesV_y[i] = distrib(gen);
        particlesQ[i] = distrib(gen) < 0 ? -1 : 1;
        particlesGridIndex[i] = getGridIndex(particlesX[i], particlesY[i], windowSize, gridCountInOneDimension);
    }
}

__host__ void gpuFillStaticSourcesArray(std::vector<float> &staticSourcesX, std::vector<float> &staticSourcesY,
    std::vector<int> &staticSourcesQ, const int windowSize, const int gridCountInOneDimension) {
    constexpr float chargeScale = 30.0f;

    std::random_device random_device;
    std::mt19937 gen(random_device());
    std::uniform_real_distribution<float> distrib(-1, 1);

    for (int i = 0; i < staticSourcesX.size(); i++) {
        staticSourcesX[i] = distrib(gen);
        staticSourcesY[i] = distrib(gen);
        staticSourcesQ[i] = std::round(distrib(gen) * chargeScale);
    }
}

__host__ void gpuSortByGridIndex(thrust::device_ptr<float> device_particlesX, thrust::device_ptr<float> device_particlesY,
    thrust::device_vector<float> &device_particlesV_x, thrust::device_vector<float> &device_particlesV_y,
    thrust::device_vector<int> &device_particlesQ, thrust::device_vector<int> &device_particlesGridIndex,
    const int particlesCount) {
    auto values_begin = thrust::make_zip_iterator(device_particlesX, device_particlesY, device_particlesV_x.begin(),
        device_particlesV_y.begin(), device_particlesQ.begin());
    thrust::sort_by_key(device_particlesGridIndex.begin(), device_particlesGridIndex.end(), values_begin);
}

void kernelFindGridStartIndicesAndComputePotential(int *gridStartIndices, const int gridSize, float *pixelsX,
    float *pixelsY, float *pixelsV, const int pixelsCount, float *particlesX, float *particlesY, float *particlesV_x,
    float *particlesV_y, int *particlesQ, int *particlesGridIndex, const int particlesCount,
    float *device_staticSourcesX, float *device_staticSourcesY, int *device_staticSourcesQ,
    const int staticSourcesCount, const int windowSize, const int gridCountInOneDimension) {
    // Try to find grid start index

}
