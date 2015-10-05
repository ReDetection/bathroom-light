//
//  light-logic.h
//  bathroom-light
//
//  Created by sbuglakov on 04/10/15.
//  Copyright (c) 2015 ReDetection. All rights reserved.
//

#ifndef __bathroom_light__light_logic__
#define __bathroom_light__light_logic__

typedef unsigned char Bright;

typedef struct LightStateDefinition {
    unsigned char minutesLeft;
    Bright bright: 1; //bool, 0 or 1
    
} LightState;

LightState movementTriggered(LightState state, Bright hallBright, Bright bathBright);
LightState changeBrightness(LightState state);
LightState addMinutes(LightState state, int minutes);
Bright hallBrightFromRaw(int brightness);
Bright bathBrightFromRaw(int brightness);
int ledsBrightnessFromState(LightState state);

#endif /* defined(__bathroom_light__light_logic__) */
