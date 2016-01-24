#include <stdlib.h>
#include <stdio.h>
#include <assert.h>

#include "greatest/greatest.h"

#define private public
#include "../bathroom_light/LightLogic.hpp"


/*
 ТЗ:
 можно нажать кнопку и увеличить длительность на 10 минут (хорошо бы дисплей иметь ещё)
 можно нажать кнопку и сменить яркость слабо/сильно
 */
unsigned long millis;
int hallBrightness;

unsigned long returnMillis() {
    return millis;
}

int returnHallBrightness() {
    return hallBrightness;
}

static LightLogic cleanLogic() {
    LightLogic logic;
    logic.millis = returnMillis;
    logic.hallBrightness = returnHallBrightness;
    logic.triggerMinutes = 3;
    return logic;
}

static LightLogic cleanWithState(bool bright, unsigned char minutesLeft) {
    LightLogic logic = cleanLogic();
    logic.state.minutesLeft = minutesLeft;
    logic.state.bright = bright ? 1 : 0;
    return logic;
}

TEST whenDarkInHallShouldTurnOnDark() {
    LightLogic logic = cleanLogic();
    hallBrightness = 0;
    logic.movementDetected();
    ASSERT_EQ_FMT(3, logic.currentBrightness(), "%d");
    PASS();
}

TEST whenBrightInHallShouldTurnOnBright() {
    LightLogic logic = cleanLogic();
    hallBrightness = 1024;
    logic.movementDetected();
    ASSERT_EQ(logic.currentBrightness(), 255);
    PASS();
}

TEST movementShouldNotAffectRunningBulb() {
    LightLogic logic = cleanWithState(true, 5);
    int before = logic.currentBrightness();
    logic.movementDetected();
    ASSERT_EQ_FMT(before, logic.currentBrightness(), "%d");
    PASS();
}

TEST movementTurnsOnFor3Minutes() {
    LightLogic logic = cleanLogic();
    logic.movementDetected();
    millis = (3*60 - 2) * 1000;
    logic.loop();
    ASSERT(logic.currentBrightness() > 0);
    PASS();
}

TEST movementProlongsFor3Minutes() {
    LightLogic logic = cleanWithState(true, 1);
    logic.movementDetected();
    millis = (3*60 - 2) * 1000;
    logic.loop();
    ASSERT(logic.currentBrightness() > 0);
    PASS();
}

TEST turnsOffAfter3Minutes() {
    LightLogic logic = cleanLogic();
    logic.movementDetected();
    millis = (3*60 + 2) * 1000;
    logic.loop();
    ASSERT_EQ_FMT(logic.currentBrightness(), 0, "%d");
    PASS();
}

GREATEST_MAIN_DEFS();

int main(int argc, char **argv) {
    GREATEST_MAIN_BEGIN();
    RUN_TEST(whenDarkInHallShouldTurnOnDark);
    RUN_TEST(whenBrightInHallShouldTurnOnBright);
    RUN_TEST(movementShouldNotAffectRunningBulb);
    RUN_TEST(movementTurnsOnFor3Minutes);
    RUN_TEST(movementProlongsFor3Minutes);
    RUN_TEST(turnsOffAfter3Minutes);
    GREATEST_MAIN_END();
}
