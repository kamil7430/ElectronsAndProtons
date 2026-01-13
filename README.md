# Electrons and Protons

Simple visualization of electrons and protons movement in electrostatic field with additional static electrostatic force sources. Written in C++ and CUDA, consists of two sub-programs: CPU and GPU ones. Allows to compare single-thread CPU implementation to CUDA GPU multi-thread one.

## Building

### Prerequisites

To build the project, you need the **NVIDIA CUDA Toolkit** and **Python** installed and added to your system path. You also need `jinja2` Python library -- it can be installed with command:
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
- `windowSize` is pixel count in both dimensions (width and height -- the window is always square)
- `method` is `gpu` or `cpu`
- `particlesCount` is number of particles to visualize

## Key bindings

- `Esc` -- closes the application
- `Space` -- stops/resumes the simulation
