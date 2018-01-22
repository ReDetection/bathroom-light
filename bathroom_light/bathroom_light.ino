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

typedef enum AdditionalReportModeE {
  None = 0,
  HallBrightness = 'H',
} AdditionalReportMode;

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
AdditionalReportMode reportMode = None;
unsigned long lastReportModeChange;
unsigned long lastAdditionalReport;
unsigned long reportRate = 100;

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

    byte numDigits = 2;   
    byte digitPins[] = {17, 14};
    byte segmentPins[] = {12, 11, 5, 6, 7, 8, 10, 4};
  
    sevseg.begin(COMMON_CATHODE, numDigits, digitPins, segmentPins);
    sevseg.setBrightness(10);

    Serial.begin(9600);
    Serial.write('I');
}

void reportNumber(int number, unsigned char digits) {
  int reverse = 0;
  for (uint8_t i=0; i<digits; i++) {
    reverse = reverse * 10 + number % 10;
    number = number / 10;
  }
  for (uint8_t i=0; i<digits; i++) {
    Serial.write(reverse % 10 + '0');
    reverse = reverse / 10;
  }
}

void reportState() {
    Serial.write('S');
    int brightness = logic.currentBrightness();
    if (brightness == logic.maximumBrightness) {
      Serial.write('b');
    } else if (brightness == 0) {
      Serial.write('o');
    } else {
      Serial.write('d');
    }
    reportNumber(logic.timeLeft(), 3);
    Serial.write(10);
}

int waitForSerial(unsigned long leeway) {
  unsigned long start = millis();
  while (Serial.available() == 0 && millis() - start < leeway);
  return Serial.read();
}

int waitForSerialNumber(uint8_t digits, unsigned long digitLeeway) {
  int result = 0;
  for (uint8_t i = 0; i < digits; i++) {
    int digit = waitForSerial(digitLeeway) - '0';
    if (digit < 0 && digit >= 10) {
      return -1;
    }
    result = result * 10 + digit;
  }
  return result;
}

void reportSettings() {
  Serial.write('e');
  reportNumber(logic.hallBrightnessThreshold, 4);
  Serial.write('b');
  reportNumber(logic.maximumBrightness, 3);
  Serial.write('d');
  reportNumber(logic.darkBrightness, 3);
  Serial.write('m');
  reportNumber(logic.triggerMinutes, 3);
  Serial.write(10);
}

void parseSettings() {
  int number = waitForSerialNumber(4, 50);
  if (number < 0 || number > 1023) return;
  logic.hallBrightnessThreshold = number;
  if (waitForSerial(50) != 'b') return;
  number = waitForSerialNumber(3, 50);
  if (number < 0 || number > 255) return;
  logic.maximumBrightness = number;
  if (waitForSerial(50) != 'd') return;
  number = waitForSerialNumber(3, 50);
  if (number < 0 || number > 255) return;
  logic.darkBrightness = number;
  if (waitForSerial(50) != 'm') return;
  number = waitForSerialNumber(3, 50);
  if (number < 0 || number > 255) return;
  logic.triggerMinutes = number;
  reportSettings();
}

void parseCommand() {
  int command = Serial.read();
  if (command == 'S') {
    int mode = waitForSerial(50);
    if (mode != 'b' && mode != 'd' && mode != 'o') {
      return;
    }
    int minutes = waitForSerialNumber(3, 50);    
    if (minutes < 0) {
      return;
    }
    logic.setState(mode == 'b', mode == 'o' ? 0 : minutes);
    
  } else if (command == 'O') {
    int mode = waitForSerial(50);
    lastReportModeChange = now;
    if (mode == HallBrightness) {
      reportMode = HallBrightness;
      return;
    }
    reportMode = None;
  } else if (command == 'R') {
    reportSettings();

  } else if (command == 'W') {
    parseSettings();
  }
}

void additionalReport() {
  if (reportMode == HallBrightness) {
    Serial.write('H');
    reportNumber(readHallBrightness(), 4);
    Serial.write(10);    
  }
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

    if (Serial.available() > 0) {
      parseCommand();
    }

    if (reportMode != None && now - lastReportModeChange > 1000) {
      reportMode = None;
    } else if (reportMode != None && now - lastAdditionalReport > reportRate) {
      lastAdditionalReport = now;
      additionalReport();
    }
}
