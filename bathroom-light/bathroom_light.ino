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
uint8_t bathBrightnessPin = A1;

LightState state;
Fader fader;
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
    Serial.begin(9600);
}

void loop() {
    
    if (digitalRead(movementPin) == HIGH) {
        
        Serial.println("triggered movement");
        Bright hall = hallBrightFromRaw(analogRead(hallBrightnessPin));
        Bright bath = bathBrightFromRaw(analogRead(bathBrightnessPin));
        state = movementTriggered(state, hall, bath);
        
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
    
    Serial.print("now = " );
    Serial.print(now);
    Serial.print(", minutesLeft = ");
    Serial.print(state.minutesLeft);
    Serial.print(", newB = ");
    Serial.print(newBrightness);
    Serial.print(", currentB = ");
    Serial.println(currentBrightness);
    
    analogWrite(ledsPin, fader.currentBrightness);
    
    delay(12);
}
