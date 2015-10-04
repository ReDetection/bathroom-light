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

uint8_t myLED;


void setup() {
    myLED = 13;
    
    pinMode(myLED, OUTPUT);
}

void loop() {
    digitalWrite(myLED, HIGH);
    delay(500);
    digitalWrite(myLED, LOW);
    delay(500);
}
