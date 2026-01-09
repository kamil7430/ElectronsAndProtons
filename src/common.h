#ifndef ELECTRONSANDPROTONS_COMMON_H
#define ELECTRONSANDPROTONS_COMMON_H

inline bool shouldSimulationStop = false;

inline void processInput(GLFWwindow *window) {
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        glfwSetWindowShouldClose(window, true);
    if (glfwGetKey(window, GLFW_KEY_SPACE) == GLFW_PRESS)
        shouldSimulationStop = !shouldSimulationStop;
}

#endif //ELECTRONSANDPROTONS_COMMON_H