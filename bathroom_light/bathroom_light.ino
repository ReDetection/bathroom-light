#include "Arduino.h"
#include "LightLogic.hpp"
#include "Fader.h"
#include <SevSeg.h>

uint8_t ledsPin = 9;
uint8_t movementPin = 15;
uint8_t durationButton = 3;
uint8_t brightnessButton = 2;
uint8_t hallBrightnessPin = A2;
unsigned long now;


SevSeg sevseg;
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

    byte numDigits = 2;   
    byte digitPins[] = {17, 14};
    byte segmentPins[] = {12, 11, 5, 6, 7, 8, 10, 4};
  
    sevseg.begin(COMMON_CATHODE, numDigits, digitPins, segmentPins);
    sevseg.setBrightness(10);
}

void loop() {
    now = millis();

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

    unsigned char minutesLeft = logic.timeLeft();
    minutesLeft = minutesLeft > 99 ? 99 : minutesLeft;
    sevseg.setNumber(minutesLeft, 0);
    while(millis() - now < 12) {
      sevseg.refreshDisplay();
    }
    digitalWrite(4, (now / 1000) % 2 == 0 ? HIGH : LOW);
}
