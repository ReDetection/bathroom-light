//
//  light-logic.c
//  bathroom-light
//
//  Created by sbuglakov on 04/10/15.
//  Copyright (c) 2015 ReDetection. All rights reserved.
//

#include "LightLogic.hpp"

void LightLogic::changeBrightness() {
    state.bright = 1 - state.bright;
    lastBrightness = state.bright;
}

void LightLogic::addMinutes(int minutes) {
    state.minutesLeft += minutes;
}

int LightLogic::currentBrightness() {
    if (state.minutesLeft > 0) {
        return state.bright ? 255 : 3;
    } else {
        return 0;
    }
}

void LightLogic::loop() {
    unsigned long now = millis();
    
    if (state.minutesLeft > 0 && now - lastMinuteTick >= 60000) {
        state.minutesLeft--;
        lastMinuteTick = now;
        if (state.minutesLeft == 0) {
            lastTurnOff = now;
        }
    }
}

void LightLogic::movementDetected() {
    if (state.minutesLeft == 0) {
        if ((millis() - lastTurnOff) < 5000) {
            state.bright = lastBrightness;
        } else {
            state.bright = hallBrightness() > 20 ? 1 : 0;
        }
    }
    state.minutesLeft = state.minutesLeft < triggerMinutes ? triggerMinutes : state.minutesLeft;
    lastBrightness = state.bright;
}

