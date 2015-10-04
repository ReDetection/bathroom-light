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



# Energia LaunchPad CC3200 specifics
# ----------------------------------
#
APPLICATION_PATH := $(ENERGIA_PATH)
ENERGIA_RELEASE  := $(shell tail -c2 $(APPLICATION_PATH)/lib/version.txt)
ARDUINO_RELEASE  := $(shell head -c4 $(APPLICATION_PATH)/lib/version.txt | tail -c3)

ifeq ($(shell if [[ '$(ENERGIA_RELEASE)' -ge '14' ]] ; then echo 1 ; else echo 0 ; fi ),0)
    WARNING_MESSAGE = Energia 14 or later is required.
endif

PLATFORM         := Energia
BUILD_CORE       := cc3200
PLATFORM_TAG      = ENERGIA=$(ENERGIA_RELEASE) ARDUINO=$(ARDUINO_RELEASE) EMBEDXCODE=$(RELEASE_NOW) $(filter __%__ ,$(GCC_PREPROCESSOR_DEFINITIONS))

UPLOADER          = cc3200serial
UPLOADER_PATH = $(APPLICATION_PATH)/hardware/tools
ifneq ($(wildcard $(UPLOADER_PATH)/lm4f/bin/serial),)
    UPLOADER_EXEC      = $(UPLOADER_PATH)/lm4f/bin/serial
else
    UPLOADER_EXEC      = $(UPLOADER_PATH)/lm4f/bin/cc3200prog
endif
UPLOADER_OPTS =

# StellarPad requires a specific command
#
UPLOADER_COMMAND = prog

APP_TOOLS_PATH  := $(APPLICATION_PATH)/hardware/tools/lm4f/bin
CORE_LIB_PATH   := $(APPLICATION_PATH)/hardware/cc3200/cores/cc3200
APP_LIB_PATH    := $(APPLICATION_PATH)/hardware/cc3200/libraries
BOARDS_TXT      := $(APPLICATION_PATH)/hardware/cc3200/boards.txt

# Not so clean Energia implementation for CC3200 non-EMT
# Take cores/cc3200 but not the sub-folders...
#
CORE_LIBS_LIST   = $(subst .h,,$(subst $(CORE_LIB_PATH)/,,$(wildcard $(CORE_LIB_PATH)/*.h))) # */
CORE_C_SRCS      = $(wildcard $(CORE_LIB_PATH)/*.c) # */
CORE_CPP_SRCS    = $(filter-out %/$(EXCLUDE_LIST),$(wildcard $(CORE_LIB_PATH)/*.cpp)) # */
CORE_OBJ_FILES   = $(CORE_C_SRCS:.c=.c.o) $(CORE_CPP_SRCS:.cpp=.cpp.o)
CORE_OBJS        = $(patsubst $(CORE_LIB_PATH)/%,$(OBJDIR)/%,$(CORE_OBJ_FILES))

# ...except cores/cc3200/avr
#
BUILD_CORE_LIB_PATH  = $(CORE_LIB_PATH)/avr
BUILD_CORE_LIBS_LIST = $(subst .h,,$(subst $(BUILD_CORE_LIB_PATH)/,,$(wildcard $(BUILD_CORE_LIB_PATH)/*.h))) # */
BUILD_CORE_C_SRCS    = $(wildcard $(BUILD_CORE_LIB_PATH)/*.c) # */
BUILD_CORE_CPP_SRCS = $(filter-out %program.cpp %main.cpp,$(wildcard $(BUILD_CORE_LIB_PATH)/*.cpp)) # */
BUILD_CORE_OBJ_FILES  = $(BUILD_CORE_C_SRCS:.c=.c.o) $(BUILD_CORE_CPP_SRCS:.cpp=.cpp.o)
BUILD_CORE_OBJS       = $(patsubst $(BUILD_CORE_LIB_PATH)/%,$(OBJDIR)/%,$(BUILD_CORE_OBJ_FILES))

CORE_LIBS_LOCK = 1

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


BOARD    = $(call PARSE_BOARD,$(BOARD_TAG),board)
LDSCRIPT = $(call PARSE_BOARD,$(BOARD_TAG),ldscript)
VARIANT  = $(call PARSE_BOARD,$(BOARD_TAG),build.variant)
VARIANT_PATH = $(APPLICATION_PATH)/hardware/cc3200/variants/$(VARIANT)
CORE_A   = $(CORE_LIB_PATH)/driverlib/libdriverlib.a

OPTIMISATION   = -Os

MCU_FLAG_NAME   = mcpu

INCLUDE_PATH     = $(VARIANT_PATH)
INCLUDE_PATH    += $(APPLICATION_PATH)/hardware/tools/cc3200/include
INCLUDE_PATH    += $(CORE_LIB_PATH)
INCLUDE_PATH    += $(CORE_LIB_PATH)/inc


# Flags for gcc, g++ and linker
# ----------------------------------
#
# Common CPPFLAGS for gcc, g++, assembler and linker
#
CPPFLAGS     = $(OPTIMISATION) $(WARNING_FLAGS)
CPPFLAGS    += -ffunction-sections -fdata-sections -mthumb -MMD
CPPFLAGS    += -$(MCU_FLAG_NAME)=$(MCU) -DF_CPU=$(F_CPU)
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
LDFLAGS     += -nostartfiles -nostdlib -Wl,--gc-sections
LDFLAGS     += -$(MCU_FLAG_NAME)=$(MCU) -DF_CPU=$(F_CPU)
LDFLAGS     += -T $(CORE_LIB_PATH)/$(LDSCRIPT)
LDFLAGS     += -Wl,--entry=ResetISR -mthumb
LDFLAGS     += $(addprefix -I, $(INCLUDE_PATH))
LDFLAGS     += $(CORE_A) -lm -lc -lgcc -lm

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
COMMAND_LINK = $(CXX) $(OUT_PREPOSITION)$@ $(SYSTEM_OBJS) $(LOCAL_OBJS) $(TARGET_A) $(LDFLAGS)

