#ifndef ELECTRONSANDPROTONS_FILE_HELPER_H
#define ELECTRONSANDPROTONS_FILE_HELPER_H

#include <filesystem>
#include <string>
#include <vector>

#if defined(_WIN32)
    #include <windows.h>
#elif defined(__linux__)
    #include <climits>
    #include <unistd.h>
#elif defined(__APPLE__)
    #include <mach-o/dyld.h>
#endif

inline std::filesystem::path getExecutableDirectory() {
    std::string path;

    #if defined(_WIN32)
        char buffer[MAX_PATH];
        GetModuleFileNameA(NULL, buffer, MAX_PATH);
        path = std::string(buffer);

    #elif defined(__linux__)
        char buffer[PATH_MAX];
        ssize_t count = readlink("/proc/self/exe", buffer, PATH_MAX);
        if (count != -1) {
            path = std::string(buffer, count);
        }

    #elif defined(__APPLE__)
        uint32_t size = 0;
        _NSGetExecutablePath(NULL, &size); // buffer size
        std::vector<char> buffer(size);
        if (_NSGetExecutablePath(buffer.data(), &size) == 0) {
            path = std::string(buffer.data());
        }
    #endif

    return std::filesystem::path(path).parent_path();
}

#endif //ELECTRONSANDPROTONS_FILE_HELPER_H