#include "shader.h"

#include <fstream>
#include <iostream>
#include <sstream>
#include <glad/gl.h>

#include "file_helper.h"

Shader::Shader(const char *vertexShaderFilePath, const char *fragmentShaderFilePath) {
    std::ifstream vertexShaderFile, fragmentShaderFile;
    std::string vertexCode, fragmentCode;

    vertexShaderFile.exceptions(std::ifstream::failbit | std::ifstream::badbit);
    fragmentShaderFile.exceptions(std::ifstream::failbit | std::ifstream::badbit);
    try
    {
        vertexShaderFile.open(getExecutableDirectory() / vertexShaderFilePath);
        fragmentShaderFile.open(getExecutableDirectory() / fragmentShaderFilePath);

        std::stringstream vertexShaderStream, fragmentShaderStream;
        vertexShaderStream << vertexShaderFile.rdbuf();
        fragmentShaderStream << fragmentShaderFile.rdbuf();

        vertexShaderFile.close();
        fragmentShaderFile.close();

        vertexCode = vertexShaderStream.str();
        fragmentCode = fragmentShaderStream.str();
    }
    catch (std::ifstream::failure& e)
    {
        char infoLog[1024];
        sprintf(infoLog, "Shader file reading failure:\n%s", e.what());
        throw std::runtime_error(infoLog);
    }

    const char *vertexShaderCode = vertexCode.c_str();
    const char *fragmentShaderCode = fragmentCode.c_str();

    const unsigned int vertexShader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertexShader, 1, &vertexShaderCode, nullptr);
    glCompileShader(vertexShader);
    int success;
    glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &success);
    if (!success) {
        char infoLog[1024];
        glGetShaderInfoLog(vertexShader, 1024, nullptr, infoLog);
        throw std::runtime_error(std::string("Vertex shader compilation error:\n").append(infoLog));
    }

    const unsigned int fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragmentShader, 1, &fragmentShaderCode, nullptr);
    glCompileShader(fragmentShader);
    glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, &success);
    if (!success) {
        char infoLog[1024];
        glGetShaderInfoLog(fragmentShader, 1024, nullptr, infoLog);
        throw std::runtime_error(std::string("Fragment shader compilation error:\n").append(infoLog));
    }

    shaderProgramId = glCreateProgram();
    glAttachShader(shaderProgramId, vertexShader);
    glAttachShader(shaderProgramId, fragmentShader);
    glLinkProgram(shaderProgramId);
    glGetProgramiv(shaderProgramId, GL_LINK_STATUS, &success);
    if (!success) {
        char infoLog[1024];
        glGetProgramInfoLog(shaderProgramId, 1024, nullptr, infoLog);
        throw std::runtime_error(std::string("Shader program linking error:\n").append(infoLog));
    }

    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
}

void Shader::use() const {
    glUseProgram(shaderProgramId);
}

int Shader::getUniformLocation(const char *uniformName) const {
    return glGetUniformLocation(shaderProgramId, uniformName);
}

Shader::~Shader() {
    glDeleteProgram(shaderProgramId);
}
