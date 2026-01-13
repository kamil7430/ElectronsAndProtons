# Electrons and Protons

A simple visualization of electron and proton movement in an electrostatic field with additional static electrostatic force sources. Written in C++ and CUDA, it consists of two sub-programs: CPU and GPU. It allows comparing single-thread CPU implementation to a CUDA GPU multi-thread one.

## Building

### Prerequisites

To build the project, you need the **NVIDIA CUDA Toolkit** and **Python** installed and added to your system path. You also need `jinja2` Python library -- it can be installed with the command:
```bash
pip install jinja2
```
After satisfying the requirements you can build the project using the CMake file provided.

### Linux (GCC/Clang)
```bash
cmake -S . -B build
cmake --build build --config Release
```

### Windows (MSVC)
```bash
cmake -S . -B build -G "Visual Studio 17 2022"
cmake --build build --config Release
```

## Usage

```
./build/ElectronsAndProtons windowSize method particlesCount
```
Where:
- `windowSize` -- window dimensions in pixels (width and height -- the window is always square)
- `method` -- `gpu` or `cpu`
- `particlesCount` -- the number of particles to visualize

## Key bindings

- `Esc` -- closes the application
- `Space` -- stops/resumes the simulation
