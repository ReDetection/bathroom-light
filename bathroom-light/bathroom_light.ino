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
#include "SevSeg.h"

uint8_t ledsPin = 9;
uint8_t movementPin = 10;
uint8_t durationButton = 11;
uint8_t brightnessButton = 12;
uint8_t hallBrightnessPin = A0;
uint8_t bathBrightnessPin = A1;

LightState state;
Fader fader;
SevSeg display;
SevSeg leftDisplay;
unsigned char movementsCount;
unsigned long lastDurationAdd;
unsigned long lastBrightnessSwitch;
unsigned long lastMinuteTick;

void setup() {
    pinMode(ledsPin, OUTPUT);
    pinMode(movementPin, INPUT);
    pinMode(durationButton, INPUT);
    pinMode(brightnessButton, INPUT);
    pinMode(hallBrightnessPin, INPUT);
    pinMode(bathBrightnessPin, INPUT);

    {
        byte digitPins[] = {A5, A4, A3};
        byte segmentPins[] = {2,3,4,5,6,7,8,13};
        display.begin(COMMON_CATHODE, 3, digitPins, segmentPins);
        display.setBrightness(10);
    }
    {
        byte digitPins[] = {A1, A2};
        byte segmentPins[] = {2,3,4,5,6,7,8,13};
        leftDisplay.begin(COMMON_CATHODE, 2, digitPins, segmentPins);
        leftDisplay.setBrightness(10);
    }
    
}

void loop() {
    
    if (digitalRead(movementPin) == HIGH) {
        Bright hall = hallBrightFromRaw(analogRead(hallBrightnessPin));
        Bright bath = bathBrightFromRaw(analogRead(bathBrightnessPin));
        state = movementTriggered(state, hall, bath);
        movementsCount++;
    }
    
    unsigned long now = millis();
    
    if (digitalRead(durationButton) == HIGH && (now - lastDurationAdd) > 200) {
        state = addMinutes(state, 10);
        lastDurationAdd = now;
    }
    
    if (digitalRead(brightnessButton) == HIGH && (now - lastBrightnessSwitch) > 200) {
        state = changeBrightness(state);
        lastBrightnessSwitch = now;
    }
    
    if (state.minutesLeft > 0 && now - lastMinuteTick >= 60000) {
        state.minutesLeft--;
        lastMinuteTick = now;
    }
    
    fader.targetBrightness = ledsBrightnessFromState(state);
    fader.loop();
    
    display.setNumber(state.minutesLeft > 999 ? 999 : state.minutesLeft, 0);
    display.refreshDisplay();
    leftDisplay.setNumber(movementsCount % 100, 0);
    leftDisplay.refreshDisplay();
    
    analogWrite(ledsPin, fader.currentBrightness);
    
    delay(12);
}
