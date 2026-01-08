#ifndef ELECTRONSANDPROTONS_CPU_H
#define ELECTRONSANDPROTONS_CPU_H

inline void doCpuComputations(const int pixelsCount, const float *pixelsX, const float *pixelsY, float *pixelsE_x, float *pixelsE_y,
    const int particlesCount, float *particlesX, float *particlesY, float *particlesV_x, float *particlesV_y) {
    // Field calculation
    constexpr float k = 1e-2;

    for (int pix = 0; pix < pixelsCount; pix++) {
        const float x = pixelsX[pix];
        const float y = pixelsY[pix];

        float E_x = 0, E_y = 0;
        for (int par = 0; par < particlesCount; par++) {
            // TODO: przemyśleć
            int particleCharge = par < particlesCount / 2 ? -1 : 1;

            // Force vector direction
            float vecX = particlesX[par] - x;
            float vecY = particlesY[par] - y;

            const float rSquared = vecX * vecX + vecY * vecY;
            const float vecLengthBeforeNormalization = sqrt(rSquared);

            // Force vector normalization
            vecX /= vecLengthBeforeNormalization;
            vecY /= vecLengthBeforeNormalization;

            // Force calculation
            vecX *= k * particleCharge / rSquared;
            vecY *= k * particleCharge / rSquared;

            // Update electrostatic field
            E_x += vecX;
            E_y += vecY;
        }

        pixelsE_x[pix] = E_x;
        pixelsE_y[pix] = E_y;
    }

    // Movement calculation
}

#endif //ELECTRONSANDPROTONS_CPU_H