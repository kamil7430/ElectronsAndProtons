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

#endif //ELECTRONSANDPROTONS_COMMON_H