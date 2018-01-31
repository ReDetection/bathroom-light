#include "LightLogic.hpp"

LightLogic::LightLogic():
      triggerMinutes(3),
      triggerMinutesAgain(10),
      maximumBrightness(255),
      darkBrightness(3),
      hallBrightnessThreshold(20),
      minutesLeft(0),
      lastMinuteTick(0),
      lastTurnOff(0),
      shouldRememberStartBrightness(true),
      wasEverTurnedOff(false) {
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

void LightLogic::setState(bool bright, unsigned char minutes) {
    isBright = bright;
    minutesLeft = minutes;
    lastMinuteTick = millis();
}

bool LightLogic::hallIsBright() {
    return hallBrightness() >= hallBrightnessThreshold;
}

int LightLogic::currentBrightness() const {
    if (minutesLeft > 0) {
        return isBright ? maximumBrightness : darkBrightness;
    } else {
        return 0;
    }
}

void LightLogic::loop() {
    if (minutesLeft == 0) {
        return;
    }

    unsigned long now = millis();
    if (now - lastMinuteTick >= 60000) {
        minutesLeft -= (now - lastMinuteTick) / 60000;
        lastMinuteTick = now;
        if (minutesLeft == 0) {
            wasEverTurnedOff = true;
            lastTurnOff = now;
            return;
        }
    }
    if (!shouldRememberStartBrightness) {
        isBright = hallIsBright();
    }
}

void LightLogic::movementDetected() {
    unsigned long now = millis();

    if (minutesLeft == 0) {
        if (wasEverTurnedOff && (now - lastTurnOff) < 5000) {
            minutesLeft = triggerMinutesAgain;
            lastMinuteTick = now;
            return;
        } else {
            isBright = hallIsBright();
        }
    }
    if (minutesLeft <= triggerMinutes) {
      minutesLeft = triggerMinutes;
      lastMinuteTick = now;
    }
}
