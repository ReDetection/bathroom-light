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
