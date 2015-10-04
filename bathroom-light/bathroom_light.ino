//
// bathroom-light
//
// Automatic bathroom nightlight
// Developed with [embedXcode](http://embedXcode.weebly.com)
//
// Author 		sbuglakov
// 				ReDetection
//
// Date			04/10/15 12:53
// Version		<#version#>
//
// Copyright	© sbuglakov, 2015
// Licence		<#license#>
//
// See         ReadMe.txt for references
//


// Core library for code-sense - IDE-based
#if defined(WIRING) // Wiring specific
#include "Wiring.h"
#elif defined(MAPLE_IDE) // Maple specific
#include "WProgram.h"
#elif defined(MPIDE) // chipKIT specific
#include "WProgram.h"
#elif defined(DIGISPARK) // Digispark specific
#include "Arduino.h"
#elif defined(ENERGIA) // LaunchPad specific
#include "Energia.h"
#elif defined(LITTLEROBOTFRIENDS) // LittleRobotFriends specific
#include "LRF.h"
#elif defined(MICRODUINO) // Microduino specific
#include "Arduino.h"
#elif defined(SPARK) || defined(PARTICLE) // Particle / Spark specific
#include "application.h"
#elif defined(TEENSYDUINO) // Teensy specific
#include "Arduino.h"
#elif defined(REDBEARLAB) // RedBearLab specific
#include "Arduino.h"
#elif defined(ESP8266) // ESP8266 specific
#include "Arduino.h"
#elif defined(ARDUINO) // Arduino 1.0 and 1.5 specific
#include "Arduino.h"
#else // error
#error Platform not defined
#endif // end IDE

// Include application, user and local libraries


// Define variables and constants
//
// Brief	Name of the LED
// Details	Each board has a LED but connected to a different pin
//
uint8_t myLED;


//
// Brief	Setup
// Details	Define the pin the LED is connected to
//
// Add setup code
void setup() {
    // myLED pin number
#if defined(ENERGIA) // All LaunchPads supported by Energia
    myLED = RED_LED;
#elif defined(DIGISPARK) // Digispark specific
    myLED = 1; // assuming model A
#elif defined(MAPLE_IDE) // Maple specific
    myLED = BOARD_LED_PIN;
#elif defined(WIRING) // Wiring specific
    myLED = 15;
#elif defined(LITTLEROBOTFRIENDS) // LittleRobotFriends specific
    myLED = 10;
#elif defined(PANSTAMP_AVR) // panStamp AVR specific
    myLED = 7;
#elif defined(PANSTAMP_NRG) // panStamp NRG specific
    myLED = ONBOARD_LED;
#elif defined(SPARK) || defined(PARTICLE) // Particle / Spark specific
    myLED = D7;
#elif defined(ESP8266) // ESP8266 specific
    myLED = 2;
#else // Arduino, chipKIT, Teensy specific
    myLED = 13;
#endif
    
    pinMode(myLED, OUTPUT);
}

//
// Brief	Loop
// Details	Blink the LED
//
// Add loop code
void loop() {
    digitalWrite(myLED, HIGH);
    delay(500);
    digitalWrite(myLED, LOW);
    delay(500);
}
