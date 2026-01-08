cmake_minimum_required(VERSION 4.0)
project(ElectronsAndProtons LANGUAGES CUDA C CXX)

set(CMAKE_CUDA_STANDARD 20)

set(CMAKE_CUDA_ARCHITECTURES native)

include(FetchContent)

# GLFW
set(GLFW_BUILD_DOCS OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)

FetchContent_Declare(
        glfw
        GIT_REPOSITORY https://github.com/glfw/glfw.git
        GIT_TAG        3.4
)
FetchContent_MakeAvailable(glfw)

# GLAD (generating with Python)
find_package(Python3 REQUIRED COMPONENTS Interpreter)

execute_process(
        COMMAND ${Python3_EXECUTABLE} -c "import jinja2"
        RESULT_VARIABLE JINJA_FOUND
        OUTPUT_QUIET
        ERROR_QUIET
)

if(NOT JINJA_FOUND EQUAL 0)
    message(FATAL_ERROR "Library 'jinja2' not found. Try to install manually using: pip install jinja2")
endif()

FetchContent_Declare(
        glad_repo
        GIT_REPOSITORY https://github.com/Dav1dde/glad.git
        GIT_TAG        v2.0.8
)
FetchContent_MakeAvailable(glad_repo)

set(GLAD_OUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/glad_auto")
file(MAKE_DIRECTORY ${GLAD_OUT_DIR})

execute_process(
        COMMAND ${Python3_EXECUTABLE} -m glad --api gl:core=4.6 --out-path "${GLAD_OUT_DIR}" c
        WORKING_DIRECTORY "${glad_repo_SOURCE_DIR}"
        RESULT_VARIABLE GLAD_GEN_RESULT
)

if(NOT GLAD_GEN_RESULT EQUAL 0)
    message(FATAL_ERROR "GLAD generation error.")
endif()

add_library(glad STATIC "${GLAD_OUT_DIR}/src/gl.c")
target_include_directories(glad PUBLIC "${GLAD_OUT_DIR}/include")

if (UNIX)
    target_link_libraries(glad PRIVATE dl)
endif()

# APP
add_executable(ElectronsAndProtons src/main.cu
        src/initializer.h)

find_package(OpenGL REQUIRED)

set_target_properties(ElectronsAndProtons PROPERTIES
        CUDA_SEPARABLE_COMPILATION ON)

target_link_libraries(ElectronsAndProtons PRIVATE
        glad
        glfw
        OpenGL::GL
)
