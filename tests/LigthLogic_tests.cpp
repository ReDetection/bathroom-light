#include <stdlib.h>
#include <stdio.h>
#include <assert.h>

#include "greatest/greatest.h"

#include "../bathroom_light/LightLogic.hpp"


/*
 ТЗ:
 если в ванной уже горит свет — тогда можно свет не включать
 по умолчанию подсветка включается на 5 минут (любое движение долно означать, что выключится не раньше, чем через 5 минут)
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

GREATEST_MAIN_DEFS();

int main(int argc, char **argv) {
    GREATEST_MAIN_BEGIN();
    RUN_TEST(whenDarkInHallShouldTurnOnDark);
    RUN_TEST(whenBrightInHallShouldTurnOnBright);
    GREATEST_MAIN_END();
}
