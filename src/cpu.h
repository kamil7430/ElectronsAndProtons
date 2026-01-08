#ifndef ELECTRONSANDPROTONS_CPU_H
#define ELECTRONSANDPROTONS_CPU_H

inline void doCpuFieldComputations(const int pixelsCount, const float *pixelsX, const float *pixelsY, float *pixelsV,
    const int particlesCount, float *particlesX, float *particlesY, float *particlesV_x, float *particlesV_y,
    const double timeDelta) {
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

            if (r > 1e-2)
                V += k * particleCharge / r;
        }

        pixelsV[pix] = V;
    }
}

inline void doCpuMovementComputations(const int pixelsCount, const float *pixelsX, const float *pixelsY, float *pixelsV,
    const int particlesCount, float *particlesX, float *particlesY, float *particlesV_x, float *particlesV_y,
    const double timeDelta, const int windowWidth, const int windowHeight) {
    for (int par = 0; par < particlesCount; par++) {
        float x = particlesX[par];
        float y = particlesY[par];
        float v_x = particlesV_x[par];
        float v_y = particlesV_y[par];
        int particleCharge = par < particlesCount / 2 ? -1 : 1; // TODO

        // Calculate index in pixels array
        int xIndex = static_cast<int>((x + 1) / 2 * windowWidth);
        int yIndex = static_cast<int>((y + 1) / 2 * windowHeight);

        if (xIndex < 1) xIndex = 1;
        if (xIndex >= windowWidth - 1) xIndex = windowWidth - 2;
        if (yIndex < 1) yIndex = 1;
        if (yIndex >= windowHeight - 1) yIndex = windowHeight - 2;

        const int index = yIndex * windowWidth + xIndex;

        // Calculate electrostatic force in particle position
        // E(x, y) ~ -(V(x + 1, y) - V(x - 1, y)) / (2 * delta)
        float E_x = -(pixelsV[index + 1] - pixelsV[index - 1]) /
            (pixelsX[index + 1] - pixelsX[index - 1]);
        float E_y = -(pixelsV[index + windowWidth] - pixelsV[index - windowWidth]) /
            (pixelsY[index + windowWidth] - pixelsY[index - windowWidth]);

        if (E_x > 10.0f) E_x = 10.0f;
        if (E_x < -10.0f) E_x = -10.0f;
        if (E_y > 10.0f) E_y = 10.0f;
        if (E_y < -10.0f) E_y = -10.0f;

        // Calculate new velocity
        v_x += particleCharge * E_x * timeDelta;
        v_x *= 0.90f;
        // if (v_x > 1.0f) {
        //     v_x = 1.0f;
        // }
        // if (v_x < -1.0f) {
        //     v_x = -1.0f;
        // }

        v_y += particleCharge * E_y * timeDelta;
        v_y *= 0.90f;
        // if (v_y > 1.0f) {
        //     v_y = 1.0f;
        // }
        // if (v_y < -1.0f) {
        //     v_y = -1.0f;
        // }

        // Update positions and handle window frame bounces
        x += v_x * timeDelta;
        if (x < -1.0f || x > 1.0f) {
            v_x *= -1;
            x += v_x * timeDelta;
        }

        y += v_y * timeDelta;
        if (y < -1.0f || y > 1.0f) {
            v_y *= -1;
            y += v_y * timeDelta;
        }

        // Save new values
        particlesX[par] = x;
        particlesY[par] = y;
        particlesV_x[par] = v_x;
        particlesV_y[par] = v_y;
    }
}

#endif //ELECTRONSANDPROTONS_CPU_H