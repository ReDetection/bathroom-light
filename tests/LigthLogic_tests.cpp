#include <stdlib.h>
#include <stdio.h>
#include <assert.h>

#include "greatest/greatest.h"

#define private public
#include "../bathroom_light/LightLogic.hpp"


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
    millis = 0;
    return logic;
}

static LightLogic cleanWithState(bool bright, unsigned char minutesLeft) {
    LightLogic logic = cleanLogic();
    logic.minutesLeft = minutesLeft;
    logic.isBright = bright;
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
    ASSERT_EQ_FMT(logic.currentBrightness(), 255, "%d");
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

TEST movementTurnsBackOnQuicklyAfterTurnOff() {
    LightLogic logic = cleanWithState(true, 1);
    millis = (60 + 1) * 1000;
    logic.loop();
    millis = (60 + 2) * 1000;
    hallBrightness = 0;
    logic.movementDetected();
    ASSERT_EQ_FMT(logic.currentBrightness(), 255, "%d");
    PASS();
}

TEST movementTurnsLongerQuicklyAfterTurnOff() {
    LightLogic logic = cleanWithState(true, 1);
    logic.triggerMinutesAgain = 10;
    millis = (60 + 1) * 1000;
    logic.loop();
    millis = (60 + 2) * 1000;
    logic.movementDetected();
    ASSERT_EQ_FMT(logic.timeLeft(), 10, "%d");
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

TEST addMinutesActuallyWorks() {
    LightLogic logic = cleanWithState(true, 1);
    logic.addMinutes(10);
    millis = (11*60 - 2) * 1000;
    logic.loop();
    ASSERT(logic.currentBrightness() > 0);
    PASS();
}

TEST changeBrightnessWorks() {
    LightLogic logic = cleanWithState(false, 1);
    logic.changeBrightness();
    ASSERT_EQ_FMT(255, logic.currentBrightness(), "%d");
    PASS();
}

TEST movementDoesFairTimerReset() {
    LightLogic logic = cleanWithState(false, 1);
    millis = 58 * 1000;
    logic.movementDetected();
    millis = (60*3 + 57) * 1000;
    logic.loop();
    ASSERT(logic.currentBrightness() > 0);
    PASS();
}

GREATEST_MAIN_DEFS();

int main(int argc, char **argv) {
    GREATEST_MAIN_BEGIN();
    RUN_TEST(whenDarkInHallShouldTurnOnDark);
    RUN_TEST(whenBrightInHallShouldTurnOnBright);
    RUN_TEST(movementShouldNotAffectRunningBulb);
    RUN_TEST(movementTurnsOnFor3Minutes);
    RUN_TEST(movementTurnsBackOnQuicklyAfterTurnOff);
    RUN_TEST(movementTurnsLongerQuicklyAfterTurnOff);
    RUN_TEST(movementProlongsFor3Minutes);
    RUN_TEST(movementDoesFairTimerReset);
    RUN_TEST(turnsOffAfter3Minutes);
    RUN_TEST(addMinutesActuallyWorks);
    RUN_TEST(changeBrightnessWorks);
    GREATEST_MAIN_END();
}
