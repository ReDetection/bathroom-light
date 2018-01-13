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
unsigned long lastSerialMovementReport;
bool forceNextMovementReport = true;
unsigned long lastSerialStateReport;
bool forceNextStateReport = true;

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

    Serial.begin(9600);
    Serial.write('I');
}

void reportState() {
    Serial.write('S');
    int brightness = logic.currentBrightness();
    if (brightness == 255) {
      Serial.write('b');
    } else if (brightness == 0) {
      Serial.write('o');
    } else {
      Serial.write('d');
    }
    int minutesLeft = logic.timeLeft();
    Serial.write(minutesLeft / 100 + '0');
    minutesLeft = minutesLeft % 100;
    Serial.write(minutesLeft / 10 + '0');
    minutesLeft = minutesLeft % 10;
    Serial.write(minutesLeft + '0');
    Serial.write(10);
}

void loop() {
    now = millis();

    if (digitalRead(movementPin) == HIGH) {
        logic.movementDetected();
        if (forceNextMovementReport || now - lastSerialMovementReport > 500) {
          forceNextMovementReport = false;
          lastSerialMovementReport = now;
          Serial.write('M');
        }
    }
    
    if (digitalRead(durationButton) == HIGH && (now - lastDurationAdd) > 200) {
        logic.addMinutes(10);
        lastDurationAdd = now;
        Serial.write('A');
        forceNextStateReport = true;
    }
    
    if (digitalRead(brightnessButton) == HIGH && (now - lastBrightnessSwitch) > 200) {
        logic.changeBrightness();
        lastBrightnessSwitch = now;
        Serial.write('B');
        forceNextStateReport = true;
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

    if (forceNextStateReport || now - lastSerialStateReport > 1000) {
      forceNextStateReport = false;
      lastSerialStateReport = now;
      reportState();
    }
}
