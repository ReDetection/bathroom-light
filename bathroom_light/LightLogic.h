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

class LightLogic {
public:
    //you definitely want to configure these before running
    unsigned long (*millis)();
    int (*hallBrightness)();
    
    void movementDetected();
    void addMinutes(int minutes);
    void changeBrightness();
    void loop();
    int currentBrightness();
    
private:
    LightState state;
    unsigned long lastTurnOff;
    unsigned long lastMinuteTick;
    bool wasOn;
    Bright lastBrightness;
};

#endif /* defined(__bathroom_light__light_logic__) */
