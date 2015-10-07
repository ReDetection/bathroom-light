//
// Fader.cpp 
// Library C++ code
// ----------------------------------
// Developed with embedXcode 
// http://embedXcode.weebly.com
//
// Project 		bathroom-light
//
// Created by 	sbuglakov, 07/10/15 18:48
// 				ReDetection
//
// Copyright 	© sbuglakov, 2015
// Licence     <#license#>
//
// See 			Fader.h and ReadMe.txt for references
//

#include "Fader.h"

Fader::Fader() {
    currentBrightness = 0;
    targetBrightness = 0;
}

void Fader::loop() {
    if (currentBrightness < targetBrightness) {
        currentBrightness+= 1 + currentBrightness/10;
        currentBrightness = currentBrightness > targetBrightness ? targetBrightness : currentBrightness;
    } else if (currentBrightness > targetBrightness) {
        currentBrightness-= 1 + currentBrightness/10;
        currentBrightness = currentBrightness < targetBrightness ? targetBrightness : currentBrightness;
    }
}
