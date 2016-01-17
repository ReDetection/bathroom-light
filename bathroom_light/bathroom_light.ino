//
// bathroom-light
//
// Automatic bathroom nightlight
// Developed with [embedXcode](http://embedXcode.weebly.com)
//
// Author 		Serg
// 				ReDetection
//
// Date			04/10/15 12:53
// Version		0.1
//
// Copyright	© ReDetection, 2015
// Licence		MIT
//
// See         ReadMe.txt for references
//

#include "Arduino.h"
#include "LightLogic.h"
#include "Fader.h"

uint8_t ledsPin = 9;
uint8_t movementPin = 10;
uint8_t durationButton = 11;
uint8_t brightnessButton = 12;
uint8_t hallBrightnessPin = A0;

LightState state;
Fader fader;
unsigned long lastDurationAdd;
unsigned long lastBrightnessSwitch;
unsigned long lastMinuteTick;
unsigned long lastTurnOff;
bool wasOn;
Bright lastBrightness;


void setup() {
    pinMode(ledsPin, OUTPUT);
    pinMode(movementPin, INPUT);
    pinMode(durationButton, INPUT);
    pinMode(brightnessButton, INPUT);
    pinMode(hallBrightnessPin, INPUT);
}

void loop() {
    unsigned long now = millis();
    
    if (digitalRead(movementPin) == HIGH) {
        Bright hall = hallBrightFromRaw(analogRead(hallBrightnessPin));
        state = movementTriggered(state, hall);
        if ((now - lastTurnOff) < 5000) {
            state.bright = lastBrightness;
        }
        lastBrightness = state.bright;
    }
    
    if (digitalRead(durationButton) == HIGH && (now - lastDurationAdd) > 200) {
        state = addMinutes(state, 10);
        lastDurationAdd = now;
    }
    
    if (digitalRead(brightnessButton) == HIGH && (now - lastBrightnessSwitch) > 200) {
        state = changeBrightness(state);
        lastBrightness = state.bright;
        lastBrightnessSwitch = now;
    }
    
    if (state.minutesLeft > 0 && now - lastMinuteTick >= 60000) {
        state.minutesLeft--;
        lastMinuteTick = now;
        if (state.minutesLeft == 0) {
            lastTurnOff = now;
        }
    }
    
    fader.targetBrightness = ledsBrightnessFromState(state);
    fader.loop();
    
    analogWrite(ledsPin, fader.currentBrightness);
    
    delay(12);
}
