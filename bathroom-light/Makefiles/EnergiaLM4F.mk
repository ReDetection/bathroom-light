#
# embedXcode
# ----------------------------------
# Embedded Computing on Xcode
#
# Copyright © Rei VILO, 2010-2015
# http://embedxcode.weebly.com
# All rights reserved
#
#
# Last update: Jul 09, 2015 release 299



# Energia LaunchPad Stellaris and Tiva C specifics
# ----------------------------------
#
APPLICATION_PATH := $(ENERGIA_PATH)
ENERGIA_RELEASE  := $(shell tail -c2 $(APPLICATION_PATH)/lib/version.txt)
ARDUINO_RELEASE  := $(shell head -c4 $(APPLICATION_PATH)/lib/version.txt | tail -c3)

ifeq ($(shell if [[ '$(ENERGIA_RELEASE)' -ge '13' ]] ; then echo 1 ; else echo 0 ; fi ),0)
    WARNING_MESSAGE = Energia 13 or later is required.
endif

PLATFORM         := Energia
BUILD_CORE       := tm4c
PLATFORM_TAG      = ENERGIA=$(ENERGIA_RELEASE) ARDUINO=$(ARDUINO_RELEASE) EMBEDXCODE=$(RELEASE_NOW) $(filter __%__ ,$(GCC_PREPROCESSOR_DEFINITIONS))

UPLOADER          = lm4flash
UPLOADER_PATH     = $(APPLICATION_PATH)/hardware/tools
UPLOADER_EXEC     = $(UPLOADER_PATH)/lm4f/bin/lm4flash
UPLOADER_OPTS     =


# StellarPad requires a specific command
#
UPLOADER_COMMAND = prog

APP_TOOLS_PATH   := $(APPLICATION_PATH)/hardware/tools/lm4f/bin
#CORE_LIB_PATH    := $(APPLICATION_PATH)/hardware/lm4f/cores/lm4f
#APP_LIB_PATH     := $(APPLICATION_PATH)/hardware/lm4f/libraries
BOARDS_TXT       := $(APPLICATION_PATH)/hardware/lm4f/boards.txt


# Sketchbook/Libraries path
# wildcard required for ~ management
# ?ibraries required for libraries and Libraries
#
ifeq ($(USER_LIBRARY_DIR)/Energia/preferences.txt,)
    $(error Error: run Energia once and define the sketchbook path)
endif

ifeq ($(wildcard $(SKETCHBOOK_DIR)),)
    SKETCHBOOK_DIR = $(shell grep sketchbook.path $(wildcard ~/Library/Energia/preferences.txt) | cut -d = -f 2)
endif

ifeq ($(wildcard $(SKETCHBOOK_DIR)),)
    $(error Error: sketchbook path not found)
endif

USER_LIB_PATH  = $(wildcard $(SKETCHBOOK_DIR)/?ibraries)

# Rules for making a c++ file from the main sketch (.pde)
#
PDEHEADER      = \\\#include \"Energia.h\"  


# Tool-chain names
#
CC      = $(APP_TOOLS_PATH)/arm-none-eabi-gcc
CXX     = $(APP_TOOLS_PATH)/arm-none-eabi-g++
AR      = $(APP_TOOLS_PATH)/arm-none-eabi-ar
OBJDUMP = $(APP_TOOLS_PATH)/arm-none-eabi-objdump
OBJCOPY = $(APP_TOOLS_PATH)/arm-none-eabi-objcopy
SIZE    = $(APP_TOOLS_PATH)/arm-none-eabi-size
NM      = $(APP_TOOLS_PATH)/arm-none-eabi-nm


# Horrible patch for core libraries
# ----------------------------------
#
# Exclude driverlib/*.c, as already provided by driverlib/libdriverlib.a
#
CORE_LIB_PATH  = $(APPLICATION_PATH)/hardware/lm4f/cores/lm4f

#BUILD_CORE_LIB_PATH = $(filter-out %/driverlib/,$(sort $(dir $(wildcard $(CORE_LIB_PATH)/* $(CORE_LIB_PATH)/*/*)))) # */
#BUILD_CORE_LIB_PATH = $(sort $(dir $(wildcard $(CORE_LIB_PATH)/* $(CORE_LIB_PATH)/*/*))) # */
BUILD_CORE_LIB_PATH = $(filter-out %/driverlib,$(shell find $(CORE_LIB_PATH) -type d))

#BUILD_CORE_LIBS_LIST = $(subst .h,,$(subst $(BUILD_CORE_LIB_PATH)/,,$(wildcard $(BUILD_CORE_LIB_PATH)/*.h))) # */

BUILD_CORE_CPP_SRCS = $(foreach dir,$(BUILD_CORE_LIB_PATH),$(wildcard $(dir)/*.cpp)) # */
BUILD_CORE_C_SRCS   = $(foreach dir,$(BUILD_CORE_LIB_PATH),$(wildcard $(dir)/*.c)) # */

BUILD_CORE_OBJ_FILES  = $(BUILD_CORE_C_SRCS:.c=.c.o) $(BUILD_CORE_CPP_SRCS:.cpp=.cpp.o)
BUILD_CORE_OBJS       = $(patsubst $(CORE_LIB_PATH)/%,$(OBJDIR)/%,$(BUILD_CORE_OBJ_FILES))

CORE_LIBS_LOCK = 1
# ----------------------------------

# Horrible patch for Ethernet library
# ----------------------------------
#
# APPlication Arduino/chipKIT/Digispark/Energia/Maple/Microduino/Teensy/Wiring sources
#
APP_LIB_PATH     := $(APPLICATION_PATH)/hardware/lm4f/libraries

a1000    = $(foreach dir,$(APP_LIB_PATH),$(patsubst %,$(dir)/%,$(APP_LIBS_LIST)))
a1000   += $(foreach dir,$(APP_LIB_PATH),$(patsubst %,$(dir)/%/utility,$(APP_LIBS_LIST)))

APP_LIB_CPP_SRC = $(foreach dir,$(a1000),$(wildcard $(dir)/*.cpp)) # */
APP_LIB_C_SRC   = $(foreach dir,$(a1000),$(wildcard $(dir)/*.c)) # */

APP_LIB_OBJS     = $(patsubst $(APP_LIB_PATH)/%.cpp,$(OBJDIR)/libs/%.cpp.o,$(APP_LIB_CPP_SRC))
APP_LIB_OBJS    += $(patsubst $(APP_LIB_PATH)/%.c,$(OBJDIR)/libs/%.c.o,$(APP_LIB_C_SRC))

BUILD_APP_LIBS_LIST = $(subst $(APP_LIB_PATH)/, ,$(APP_LIB_CPP_SRC))
BUILD_APP_LIB_PATH  = $(a1000) $(foreach dir,$(APP_LIB_PATH),$(patsubst %,$(dir)/%,$(APP_LIBS_LIST)))

APP_LIBS_LOCK = 1
# ----------------------------------


BOARD    = $(call PARSE_BOARD,$(BOARD_TAG),board)
LDSCRIPT = $(call PARSE_BOARD,$(BOARD_TAG),ldscript)
VARIANT  = $(call PARSE_BOARD,$(BOARD_TAG),build.variant)
VARIANT_PATH = $(APPLICATION_PATH)/hardware/lm4f/variants/$(VARIANT)
CORE_A   = $(CORE_LIB_PATH)/driverlib/libdriverlib.a

OPTIMISATION   = -Os

MCU_FLAG_NAME   = mcpu

INCLUDE_PATH     = $(VARIANT_PATH)
INCLUDE_PATH    += $(APPLICATION_PATH)/hardware/tools/lm4f/include
INCLUDE_PATH    += $(CORE_LIB_PATH)
INCLUDE_PATH    += $(CORE_LIB_PATH)/inc
INCLUDE_PATH    += $(APPLICATION_PATH)/hardware/lm4f/cores/lm4f/driverlib
INCLUDE_PATH    += $(BUILD_APP_LIB_PATH)


# Flags for gcc, g++ and linker
# ----------------------------------
#
# Common CPPFLAGS for gcc, g++, assembler and linker
#
CPPFLAGS     = $(OPTIMISATION) $(WARNING_FLAGS)
CPPFLAGS    += -ffunction-sections -fdata-sections -mthumb -MMD
CPPFLAGS    += -$(MCU_FLAG_NAME)=$(MCU) -DF_CPU=$(F_CPU)
CPPFLAGS    += -mfloat-abi=hard -mfpu=fpv4-sp-d16 -fsingle-precision-constant
CPPFLAGS    += $(addprefix -I, $(INCLUDE_PATH))
CPPFLAGS    += $(addprefix -D, $(PLATFORM_TAG))

# Specific CFLAGS for gcc only
# gcc uses CPPFLAGS and CFLAGS
#
CFLAGS       = #

# Specific CXXFLAGS for g++ only
# g++ uses CPPFLAGS and CXXFLAGS
#
CXXFLAGS    = -fno-exceptions -fno-rtti

# Specific ASFLAGS for gcc assembler only
# gcc assembler uses CPPFLAGS and ASFLAGS
#
ASFLAGS      = --asm_extension=S

# Specific LDFLAGS for linker only
# linker uses CPPFLAGS and LDFLAGS
#
LDFLAGS      = $(OPTIMISATION) $(WARNING_FLAGS)
LDFLAGS     += -$(MCU_FLAG_NAME)=$(MCU) -DF_CPU=$(F_CPU)
LDFLAGS     += $(addprefix -I, $(INCLUDE_PATH))
#LDFLAGS     += $(addprefix -D, $(PLATFORM_TAG))
LDFLAGS     += -mfloat-abi=hard -mfpu=fpv4-sp-d16 -fsingle-precision-constant
LDFLAGS     += -Wl,--gc-sections
LDFLAGS     += -T $(CORE_LIB_PATH)/$(LDSCRIPT)
LDFLAGS     += -Wl,--entry=ResetISR -mthumb -nostdlib -nostartfiles

LIB_FLAGS     = -L$(OBJDIR) $(CORE_A) -lm -lc -lgcc

# Specific OBJCOPYFLAGS for objcopy only
# objcopy uses OBJCOPYFLAGS only
#
OBJCOPYFLAGS  = -Obinary # -v

# Target
#
TARGET_HEXBIN = $(TARGET_BIN)


# Commands
# ----------------------------------
#
COMMAND_LINK = $(CXX) $(LDFLAGS) $(OUT_PREPOSITION)$@ $(SYSTEM_OBJS) $(LOCAL_OBJS) $(TARGET_A) $(LIB_FLAGS)


# Specific OBJCOPYFLAGS for objcopy only
# objcopy uses OBJCOPYFLAGS only
#
OBJCOPYFLAGS  = -v -Obinary

# Target
#
TARGET_HEXBIN = $(TARGET_BIN)
