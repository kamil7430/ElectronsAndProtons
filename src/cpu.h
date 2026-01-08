#ifndef ELECTRONSANDPROTONS_CPU_H
#define ELECTRONSANDPROTONS_CPU_H

inline void doCpuComputations(const int pixelsCount, const float *pixelsX, const float *pixelsY, float *pixelsV,
    const int particlesCount, float *particlesX, float *particlesY, float *particlesV_x, float *particlesV_y) {
    // Field calculation
    constexpr float k = 1e-2;

    for (int pix = 0; pix < pixelsCount; pix++) {
        const float x = pixelsX[pix];
        const float y = pixelsY[pix];

        float V = 0;
        for (int par = 0; par < particlesCount; par++) {
            // TODO: przemyśleć
            const int particleCharge = par < particlesCount / 2 ? -1 : 1;

            const float vecX = particlesX[par] - x;
            const float vecY = particlesY[par] - y;

            const float r = sqrt(vecX * vecX + vecY * vecY);

            V += k * particleCharge / r;
        }

        pixelsV[pix] = V;
    }

    // Movement calculation
}

#endif //ELECTRONSANDPROTONS_CPU_H