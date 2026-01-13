#ifndef ELECTRONSANDPROTONS_COMMON_H
#define ELECTRONSANDPROTONS_COMMON_H

#include <GLFW/glfw3.h>

constexpr int GRID_SIZE_IN_PIXELS = 100;

inline bool shouldSimulationStop = false;

static void handleSpacePress() {
    constexpr double timeDelta = 0.5;
    static double lastChangeTimestamp = glfwGetTime();
    const double actualTime = glfwGetTime();
    if (actualTime - lastChangeTimestamp > timeDelta) {
        shouldSimulationStop = !shouldSimulationStop;
        lastChangeTimestamp = actualTime;
    }
}

inline void processInput(GLFWwindow *window) {
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        glfwSetWindowShouldClose(window, true);
    if (glfwGetKey(window, GLFW_KEY_SPACE) == GLFW_PRESS)
        handleSpacePress();
}

inline float indexToFloat(const int index, const int windowSize) {
    const float fl = static_cast<float>(index + 1) / static_cast<float>(windowSize) * 2 - 1;
    if (fl < -1.0f)
        return -1.0f;
    if (fl > 1.0f)
        return 1.0f;
    return fl;
}

inline int floatToIndex(const float fl, const int windowSize) {
    const int ind = static_cast<int>((fl + 1) / 2 * windowSize);
    if (ind < 0)
        return 0;
    if (ind >= windowSize)
        return windowSize - 1;
    return ind;
}

inline int getGridIndex(const int row, const int col, const int gridCountInOneDimension) {
    return row * gridCountInOneDimension + col;
}

inline int getGridIndex(const float x, const float y, const int windowSize, const int gridCountInOneDimension) {
    return getGridIndex(floatToIndex(x, windowSize) / GRID_SIZE_IN_PIXELS, floatToIndex(y, windowSize) / GRID_SIZE_IN_PIXELS, gridCountInOneDimension);
}

#endif //ELECTRONSANDPROTONS_COMMON_H