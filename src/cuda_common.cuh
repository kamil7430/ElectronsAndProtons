#ifndef ELECTRONSANDPROTONS_CUDA_COMMON_CUH
#define ELECTRONSANDPROTONS_CUDA_COMMON_CUH

#ifndef __CUDACC__
    #define __device__
    #define __host__
    #define __inline__ inline
    #define __forceinline__ inline
#endif

__forceinline__ __device__ __host__ float indexToFloat(const int index, const int windowSize) {
    const float fl = static_cast<float>(index + 1) / static_cast<float>(windowSize) * 2 - 1;
    if (fl < -1.0f)
        return -1.0f;
    if (fl > 1.0f)
        return 1.0f;
    return fl;
}

__forceinline__ __device__ __host__ int floatToIndex(const float fl, const int windowSize) {
    const int ind = static_cast<int>((fl + 1) / 2 * windowSize);
    if (ind < 0)
        return 0;
    if (ind >= windowSize)
        return windowSize - 1;
    return ind;
}

__forceinline__ __device__ __host__ int getGridIndex(const int row, const int col, const int gridCountInOneDimension) {
    return row * gridCountInOneDimension + col;
}

__forceinline__ __device__ __host__ int getGridIndex(const float x, const float y, const int windowSize, const int gridCountInOneDimension) {
    return getGridIndex(floatToIndex(x, windowSize) / GRID_SIZE_IN_PIXELS, floatToIndex(y, windowSize) / GRID_SIZE_IN_PIXELS, gridCountInOneDimension);
}

template <typename lambda>
__forceinline__ __device__ __host__ void doGridWork(const int gridIndex, const int gridSize, const int gridCountInOneDimension, lambda calculate) {
    if (const int lowerLeft = gridIndex - gridCountInOneDimension - 1; lowerLeft >= 0 && gridIndex % gridCountInOneDimension != 0) {
        calculate(lowerLeft);
    }
    if (const int lower = gridIndex - gridCountInOneDimension; lower >= 0) {
        calculate(lower);
    }
    if (const int lowerRight = gridIndex - gridCountInOneDimension + 1; lowerRight >= 0 && (gridIndex + 1) % gridCountInOneDimension != 0) {
        calculate(lowerRight);
    }
    if (const int left = gridIndex - 1; left >= 0 && gridIndex % gridCountInOneDimension != 0) {
        calculate(left);
    }
    calculate(gridIndex); // Center grid
    if (const int right = gridIndex + 1; right < gridSize && (gridIndex + 1) % gridCountInOneDimension != 0) {
        calculate(right);
    }
    if (const int UpperLeft = gridIndex + gridCountInOneDimension - 1; UpperLeft < gridSize && gridIndex % gridCountInOneDimension != 0) {
        calculate(UpperLeft);
    }
    if (const int upper = gridIndex + gridCountInOneDimension; upper < gridSize) {
        calculate(upper);
    }
    if (const int upperRight = gridIndex + gridCountInOneDimension + 1; upperRight < gridSize && (gridIndex + 1) % gridCountInOneDimension != 0) {
        calculate(upperRight);
    }
}

#endif //ELECTRONSANDPROTONS_CUDA_COMMON_CUH