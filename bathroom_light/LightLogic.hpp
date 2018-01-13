#ifndef __bathroom_light__light_logic__
#define __bathroom_light__light_logic__

class LightLogic {
public:
    LightLogic();
    
    //you definitely want to configure these before running
    unsigned long (*millis)();
    int (*hallBrightness)();
    int triggerMinutes;
    
    void movementDetected();
    void addMinutes(int minutes);
    void changeBrightness();
    void loop();
    int currentBrightness() const;
    unsigned char timeLeft() const;
    void setState(bool bright, unsigned char minutes);
    
private:
    unsigned char minutesLeft;
    bool isBright;

    unsigned long lastTurnOff;
    unsigned long lastMinuteTick;
    bool wasEverTurnedOff;
};

#endif /* defined(__bathroom_light__light_logic__) */
