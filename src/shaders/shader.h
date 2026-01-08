#ifndef ELECTRONSANDPROTONS_SHADER_H
#define ELECTRONSANDPROTONS_SHADER_H

class Shader {
private:
    unsigned int shaderProgramId;

public:
    Shader(const char* vertexShaderFilePath, const char* fragmentShaderFilePath);
    void use() const;
    [[nodiscard]] int getUniformLocation(const char* uniformName) const;
    ~Shader();
};

#endif //ELECTRONSANDPROTONS_SHADER_H