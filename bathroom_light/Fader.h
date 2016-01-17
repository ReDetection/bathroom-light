//
// File			Fader.h
// Library header
//
// Details		<#details#>
//	
// Project	 	bathroom-light
// Developed with [embedXcode](http://embedXcode.weebly.com)
// 
// Author		sbuglakov
// 				ReDetection
//
// Date			07/10/15 18:48
// Version		<#version#>
// 
// Copyright	© sbuglakov, 2015
// Licence     <#license#>
//
// See			ReadMe.txt for references
//

#ifndef Fader_h
#define Fader_h

class Fader {
public:
    int currentBrightness;
    int targetBrightness;
    Fader();
    void loop();
    
};

#endif
