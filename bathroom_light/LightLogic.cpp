#include "LightLogic.hpp"

LightLogic::LightLogic() {
    minutesLeft = 0;
    wasEverTurnedOff = false;
}

unsigned char LightLogic::timeLeft() const {
    return minutesLeft;
}

void LightLogic::changeBrightness() {
    isBright = !isBright;
}

void LightLogic::addMinutes(int minutes) {
    minutesLeft += minutes;
    lastMinuteTick = millis();
}

int LightLogic::currentBrightness() const {
    if (minutesLeft > 0) {
        return isBright ? 255 : 3;
    } else {
        return 0;
    }
}

void LightLogic::loop() {
    unsigned long now = millis();
    
    if (minutesLeft > 0 && now - lastMinuteTick >= 60000) {
        minutesLeft -= (now - lastMinuteTick) / 60000;
        lastMinuteTick = now;
        if (minutesLeft == 0) {
            wasEverTurnedOff = true;
            lastTurnOff = now;
        }
    }
}

void LightLogic::movementDetected() {
    unsigned long now = millis();

    if (minutesLeft == 0) {
        if (!wasEverTurnedOff || (now - lastTurnOff) >= 5000) {
            isBright = hallBrightness() > 20;
        }
    }
    if (minutesLeft <= triggerMinutes) {
      minutesLeft = triggerMinutes;
      lastMinuteTick = now;
    }
}
