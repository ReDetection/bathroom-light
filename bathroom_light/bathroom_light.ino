#include "Arduino.h"
#include "LightLogic.hpp"
#include "Fader.h"

uint8_t ledsPin = 9;
uint8_t movementPin = 10;
uint8_t durationButton = 11;
uint8_t brightnessButton = 12;
uint8_t hallBrightnessPin = A0;

LightLogic logic;
Fader fader;
//todo: extract buttons to separate lib (or find one)
unsigned long lastDurationAdd;
unsigned long lastBrightnessSwitch;

int readHallBrightness() {
    return analogRead(hallBrightnessPin);
}

void setup() {
    pinMode(ledsPin, OUTPUT);
    pinMode(movementPin, INPUT);
    pinMode(durationButton, INPUT);
    pinMode(brightnessButton, INPUT);
    pinMode(hallBrightnessPin, INPUT);
    
    logic.millis = millis;
    logic.hallBrightness = readHallBrightness;
    logic.triggerMinutes = 3;
}

void loop() {
    unsigned long now = millis();
    
    if (digitalRead(movementPin) == HIGH) {
        logic.movementDetected();
    }
    
    if (digitalRead(durationButton) == HIGH && (now - lastDurationAdd) > 200) {
        logic.addMinutes(10);
        lastDurationAdd = now;
    }
    
    if (digitalRead(brightnessButton) == HIGH && (now - lastBrightnessSwitch) > 200) {
        logic.changeBrightness();
        lastBrightnessSwitch = now;
    }
    
    logic.loop();
    
    fader.targetBrightness = logic.currentBrightness();
    fader.loop();
    
    analogWrite(ledsPin, fader.currentBrightness);
    
    delay(12);
}
