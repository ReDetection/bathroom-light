#include "Fader.h"

Fader::Fader() {
    currentBrightness = 0;
    targetBrightness = 0;
}

void Fader::loop() {
    if (currentBrightness < targetBrightness) {
        currentBrightness+= 1 + currentBrightness/10;
        currentBrightness = currentBrightness > targetBrightness ? targetBrightness : currentBrightness;
    } else if (currentBrightness > targetBrightness) {
        currentBrightness-= 1 + currentBrightness/10;
        currentBrightness = currentBrightness < targetBrightness ? targetBrightness : currentBrightness;
    }
}
