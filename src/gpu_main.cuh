#ifndef ELECTRONSANDPROTONS_GPU_MAIN_CUH
#define ELECTRONSANDPROTONS_GPU_MAIN_CUH

#include <cassert>
#include <cstdio>
#include <cuda_gl_interop.h>
#include <glad/gl.h>
#include <GLFW/glfw3.h>
#include <thrust/device_vector.h>

#include "common.h"
#include "shaders/shader.h"

__host__ void gpuFillPixelsArray(const int windowSize, float *xArray, float *yArray);
__host__ void gpuFillParticlesArray(const int particlesCount, float *particlesX, float *particlesY, float *particlesV_x, float *particlesV_y, int *particlesQ, int *particlesGridIndex, const int windowSize, const int gridCountInOneDimension);
__host__ void gpuFillStaticSourcesArray(std::vector<float> &staticSourcesX, std::vector<float> &staticSourcesY, std::vector<int> &staticSourcesQ, const int windowSize, const int gridCountInOneDimension);
__host__ void gpuSortByGridIndex(thrust::device_ptr<float> device_particlesX, thrust::device_ptr<float> device_particlesY, thrust::device_vector<float> &device_particlesV_x, thrust::device_vector<float> &device_particlesV_y, thrust::device_vector<int> &device_particlesQ, thrust::device_vector<int> &device_particlesGridIndex, const int particlesCount);
__host__ void kernelFindGridStartIndicesAndComputePotential(int *gridStartIndices, const int gridSize, float *pixelsX, float *pixelsY, float *pixelsV, const int pixelsCount, float *particlesX, float *particlesY, float *particlesV_x, float *particlesV_y, int *particlesQ, int *particlesGridIndex, const int particlesCount, float *device_staticSourcesX, float *device_staticSourcesY, int *device_staticSourcesQ, const int staticSourcesCount, const int windowSize, const int gridCountInOneDimension);

template <typename T>
thrust::device_ptr<T> gpuGetPointer(cudaGraphicsResource *resource) {
    cudaGraphicsMapResources(1, &resource, 0);
    T* raw_ptr;
    size_t num_bytes;
    cudaGraphicsResourceGetMappedPointer(&raw_ptr, &num_bytes, resource);
    thrust::device_ptr<T> thrust_ptr(raw_ptr);
    return thrust_ptr;
}

inline void gpuMain(const int windowSize, const int particlesCount, GLFWwindow *window) {
    // Preparing data structures - pixels
    const int pixelsCount = windowSize * windowSize;
    float *pixelsX = new float[pixelsCount];
    float *pixelsY = new float[pixelsCount];
    float *pixelsV = new float[pixelsCount];
    gpuFillPixelsArray(windowSize, pixelsX, pixelsY);

    unsigned int pixelsVao;
    glGenVertexArrays(1, &pixelsVao);
    glBindVertexArray(pixelsVao);

    unsigned int pixelsXVbo, pixelsYVbo, pixelsVVbo;
    glGenBuffers(1, &pixelsXVbo);
    glGenBuffers(1, &pixelsYVbo);
    glGenBuffers(1, &pixelsVVbo);

    glBindBuffer(GL_ARRAY_BUFFER, pixelsXVbo);
    glBufferData(GL_ARRAY_BUFFER, pixelsCount * static_cast<int>(sizeof(float)), pixelsX, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 1, GL_FLOAT, GL_FALSE, sizeof(float), reinterpret_cast<void*>(0));
    glEnableVertexAttribArray(0);

    glBindBuffer(GL_ARRAY_BUFFER, pixelsYVbo);
    glBufferData(GL_ARRAY_BUFFER, pixelsCount * static_cast<int>(sizeof(float)), pixelsY, GL_STATIC_DRAW);
    glVertexAttribPointer(1, 1, GL_FLOAT, GL_FALSE, sizeof(float), reinterpret_cast<void*>(0));
    glEnableVertexAttribArray(1);

    glBindBuffer(GL_ARRAY_BUFFER, pixelsVVbo);
    glBufferData(GL_ARRAY_BUFFER, pixelsCount * static_cast<int>(sizeof(float)), pixelsV, GL_DYNAMIC_DRAW);
    glVertexAttribPointer(2, 1, GL_FLOAT, GL_FALSE, sizeof(float), reinterpret_cast<void*>(0));
    glEnableVertexAttribArray(2);

    cudaGraphicsResource *pixelsXVboResource, *pixelsYVboResource, *pixelsVVboResource;
    cudaGraphicsGLRegisterBuffer(&pixelsXVboResource, pixelsXVbo, cudaGraphicsMapFlagsNone);
    cudaGraphicsGLRegisterBuffer(&pixelsYVboResource, pixelsYVbo, cudaGraphicsMapFlagsNone);
    cudaGraphicsGLRegisterBuffer(&pixelsVVboResource, pixelsVVbo, cudaGraphicsMapFlagsNone);

    delete[] pixelsX;
    delete[] pixelsY;
    delete[] pixelsV;

    // Grid
    assert(windowSize % GRID_SIZE_IN_PIXELS == 0);
    const int gridCountInOneDimension = windowSize / GRID_SIZE_IN_PIXELS;
    const int gridSize = gridCountInOneDimension * gridCountInOneDimension;

    // Particles
    float *particlesX = new float[particlesCount];
    float *particlesY = new float[particlesCount];
    std::vector<float> particlesV_x(particlesCount);
    std::vector<float> particlesV_y(particlesCount);
    std::vector<int> particlesQ(particlesCount);
    std::vector<int> particlesGridIndex(particlesCount);
    gpuFillParticlesArray(particlesCount, particlesX, particlesY, particlesV_x.data(), particlesV_y.data(),
        particlesQ.data(), particlesGridIndex.data(), windowSize, gridCountInOneDimension);

    unsigned int particlesVao;
    glGenVertexArrays(1, &particlesVao);
    glBindVertexArray(particlesVao);

    unsigned int particlesXVbo, particlesYVbo;
    glGenBuffers(1, &particlesXVbo);
    glGenBuffers(1, &particlesYVbo);

    glBindBuffer(GL_ARRAY_BUFFER, particlesXVbo);
    glBufferData(GL_ARRAY_BUFFER, particlesCount * static_cast<int>(sizeof(float)), particlesX, GL_DYNAMIC_DRAW);
    glVertexAttribPointer(0, 1, GL_FLOAT, GL_FALSE, sizeof(float), reinterpret_cast<void*>(0));
    glEnableVertexAttribArray(0);

    glBindBuffer(GL_ARRAY_BUFFER, particlesYVbo);
    glBufferData(GL_ARRAY_BUFFER, particlesCount * static_cast<int>(sizeof(float)), particlesY, GL_DYNAMIC_DRAW);
    glVertexAttribPointer(1, 1, GL_FLOAT, GL_FALSE, sizeof(float), reinterpret_cast<void*>(0));
    glEnableVertexAttribArray(1);

    cudaGraphicsResource *particlesXVboResource, *particlesYVboResource;
    cudaGraphicsGLRegisterBuffer(&particlesXVboResource, particlesXVbo, cudaGraphicsMapFlagsNone);
    cudaGraphicsGLRegisterBuffer(&particlesYVboResource, particlesYVbo, cudaGraphicsMapFlagsNone);

    thrust::device_vector<float> device_particlesV_x = particlesV_x;
    thrust::device_vector<float> device_particlesV_y = particlesV_y;
    thrust::device_vector<int> device_particlesQ = particlesQ;
    thrust::device_vector<int> device_particlesGridIndex = particlesGridIndex;

    delete[] particlesX;
    delete[] particlesY;

    // Static electrostatic field sources
    const int staticSourcesCount = gridCountInOneDimension;
    std::vector<float> staticSourcesX(staticSourcesCount);
    std::vector<float> staticSourcesY(staticSourcesCount);
    std::vector<int> staticSourcesQ(staticSourcesCount);
    gpuFillStaticSourcesArray(staticSourcesX, staticSourcesY, staticSourcesQ, windowSize, gridCountInOneDimension);

    thrust::device_vector<float> device_staticSourcesX = staticSourcesX;
    thrust::device_vector<float> device_staticSourcesY = staticSourcesY;
    thrust::device_vector<int> device_staticSourcesQ = staticSourcesQ;

    // Grid indices array
    thrust::device_vector<int> device_gridStartIndices(gridSize);

    // Shaders
    const Shader pixelsShader("shaders/vertex/gpu/pixels.vert", "shaders/fragment/pixels.frag");
    const Shader particlesShader("shaders/vertex/gpu/particles.vert", "shaders/fragment/particles.frag");

    // Get device pointers of data managed by OpenGL (before first iteration of main loop)
    glFinish();
    auto device_pixelsX = gpuGetPointer<float>(pixelsXVboResource);
    auto device_pixelsY = gpuGetPointer<float>(pixelsYVboResource);
    auto device_pixelsV = gpuGetPointer<float>(pixelsVVboResource);
    auto device_particlesX = gpuGetPointer<float>(particlesXVboResource);
    auto device_particlesY = gpuGetPointer<float>(particlesYVboResource);

    // Main loop
    char windowTitle[128];
    int framesCount = 0;
    double lastFpsCalculationTimestamp = glfwGetTime();
    double currentTime = glfwGetTime();
    while (!glfwWindowShouldClose(window)) {
        // FPS calculation
        framesCount++;
        const double previousTime = currentTime;
        currentTime = glfwGetTime();
        if (currentTime - lastFpsCalculationTimestamp >= 0.5) {
            sprintf(windowTitle, "Electrons and Protons (%.1f FPS)", framesCount / (currentTime - lastFpsCalculationTimestamp));
            framesCount = 0;
            lastFpsCalculationTimestamp = currentTime;
            glfwSetWindowTitle(window, windowTitle);
        }

        // Potential calculation
        if (!shouldSimulationStop) {
            gpuSortByGridIndex(device_particlesX, device_particlesY, device_particlesV_x, device_particlesV_y,
                device_particlesQ, device_particlesGridIndex, particlesCount);
            thrust::fill(device_gridStartIndices.begin(), device_gridStartIndices.end(), -1);
            kernelFindGridStartIndicesAndComputePotential(thrust::raw_pointer_cast(device_gridStartIndices.data()), gridSize,
                thrust::raw_pointer_cast(device_pixelsX), thrust::raw_pointer_cast(device_pixelsY), thrust::raw_pointer_cast(device_pixelsV),
                pixelsCount, thrust::raw_pointer_cast(device_particlesX), thrust::raw_pointer_cast(device_particlesY),
                thrust::raw_pointer_cast(device_particlesV_x.data()), thrust::raw_pointer_cast(device_particlesV_y.data()),
                thrust::raw_pointer_cast(device_particlesQ.data()), thrust::raw_pointer_cast(device_particlesGridIndex.data()),
                particlesCount, thrust::raw_pointer_cast(device_staticSourcesX.data()),
                thrust::raw_pointer_cast(device_staticSourcesY.data()), thrust::raw_pointer_cast(device_staticSourcesQ.data()),
                staticSourcesCount, windowSize, gridCountInOneDimension);
        }

        // Return the resources to OpenGL
        cudaGraphicsUnmapResources(1, &pixelsXVboResource, 0);
        cudaGraphicsUnmapResources(1, &pixelsYVboResource, 0);
        cudaGraphicsUnmapResources(1, &pixelsVVboResource, 0);
        cudaGraphicsUnmapResources(1, &particlesXVboResource, 0);
        cudaGraphicsUnmapResources(1, &particlesYVboResource, 0);

        pixelsShader.use();
        glBindVertexArray(pixelsVao);
        glDrawArrays(GL_POINTS, 0, pixelsCount);

        particlesShader.use();
        glBindVertexArray(particlesVao);
        glDrawArrays(GL_POINTS, 0, particlesCount);

        // Get device pointers of data managed by OpenGL
        glFinish();
        device_pixelsX = gpuGetPointer<float>(pixelsXVboResource);
        device_pixelsY = gpuGetPointer<float>(pixelsYVboResource);
        device_pixelsV = gpuGetPointer<float>(pixelsVVboResource);
        device_particlesX = gpuGetPointer<float>(particlesXVboResource);
        device_particlesY = gpuGetPointer<float>(particlesYVboResource);

        // // Particles movement calculation
        // if (!shouldSimulationStop)
        //     cpuComputeParticlesMovement(

        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    // Return the resources to OpenGL after last iteration of main loop
    cudaGraphicsUnmapResources(1, &pixelsXVboResource, 0);
    cudaGraphicsUnmapResources(1, &pixelsYVboResource, 0);
    cudaGraphicsUnmapResources(1, &pixelsVVboResource, 0);
    cudaGraphicsUnmapResources(1, &particlesXVboResource, 0);
    cudaGraphicsUnmapResources(1, &particlesYVboResource, 0);
}

#endif //ELECTRONSANDPROTONS_GPU_MAIN_CUH