//
//  light-logic.c
//  bathroom-light
//
//  Created by sbuglakov on 04/10/15.
//  Copyright (c) 2015 ReDetection. All rights reserved.
//

#include "LightLogic.h"


/*
 ТЗ:
 когда чувак заходит, а в коридоре очень темно — включать слабую подсветку
 когда чувак заходит, а в коридоре слабо темно или ярче — включать яркую подсветку
 если в ванной уже горит свет — тогда можно свет не включать
 по умолчанию подсветка включается на 5 минут (любое движение долно означать, что выключится не раньше, чем через 5 минут)
 можно нажать кнопку и увеличить длительность на 10 минут (хорошо бы дисплей иметь ещё)
 можно нажать кнопку и сменить яркость слабо/сильно
 
 
 */

#define trigger_minutes 3

LightState movementTriggered(LightState state, Bright hallBright) {
    state.bright = state.minutesLeft > 0 ? state.bright : hallBright;
    state.minutesLeft = state.minutesLeft < trigger_minutes ? trigger_minutes : state.minutesLeft;
    return state;
}

LightState changeBrightness(LightState state) {
    state.bright = 1 - state.bright;
    return state;
}

LightState addMinutes(LightState state, int minutes) {
    state.minutesLeft += minutes;
    return state;
}

Bright hallBrightFromRaw(int brightness) {
    return brightness > 20 ? 1 : 0;
}

int ledsBrightnessFromState(LightState state) {
    if (state.minutesLeft > 0) {
        return state.bright ? 255 : 3;
    } else {
        return 0;
    }
}

