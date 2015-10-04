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
# Last update: Jul 17, 2015 release 299



# Energia MSP432 specifics
# ----------------------------------
#
APPLICATION_PATH := $(ENERGIA_PATH)
ENERGIA_RELEASE  := $(shell tail -c2 $(APPLICATION_PATH)/lib/version.txt)
ARDUINO_RELEASE  := $(shell head -c4 $(APPLICATION_PATH)/lib/version.txt | tail -c3)

ifeq ($(shell if [[ '$(ENERGIA_RELEASE)' -ge '16' ]] ; then echo 1 ; else echo 0 ; fi ),0)
    WARNING_MESSAGE = Energia 16 or later is required.
endif

PLATFORM         := Energia
BUILD_CORE       := msp432
PLATFORM_TAG      = ENERGIA=$(ENERGIA_RELEASE) ARDUINO=$(ARDUINO_RELEASE) EMBEDXCODE=$(RELEASE_NOW) $(filter __%__ ,$(GCC_PREPROCESSOR_DEFINITIONS)) ENERGIA_MT
MULTI_INO         := 1

UPLOADER          = DSLite
UPLOADER_PATH     = $(APPLICATION_PATH)/tools/common/DSLite
UPLOADER_EXEC     = $(UPLOADER_PATH)/DebugServer/bin/DSLite
UPLOADER_OPTS     = -c $(UPLOADER_PATH)/MSP432P401R.ccxml


# StellarPad requires a specific command
#
UPLOADER_COMMAND = prog

APP_TOOLS_PATH  := $(APPLICATION_PATH)/hardware/tools/lm4f/bin
#CORE_LIB_PATH    := $(APPLICATION_PATH)/hardware/msp432/cores/msp432
CORES_PATH      := $(APPLICATION_PATH)/hardware/msp432/cores/msp432
APP_LIB_PATH    := $(APPLICATION_PATH)/hardware/msp432/libraries
BOARDS_TXT      := $(APPLICATION_PATH)/hardware/msp432/boards.txt

#CORE_LIBS_LIST   := #
#BUILD_CORE_LIBS_LIST := #

#BUILD_CORE_LIB_PATH  = $(APPLICATION_PATH)/hardware/msp432/cores/msp432/driverlib
#BUILD_CORE_LIBS_LIST = $(subst .h,,$(subst $(BUILD_CORE_LIB_PATH)/,,$(wildcard $(BUILD_CORE_LIB_PATH)/*.h))) # */

#BUILD_CORE_C_SRCS    = $(wildcard $(BUILD_CORE_LIB_PATH)/*.c) # */

#BUILD_CORE_CPP_SRCS = $(filter-out %program.cpp %main.cpp,$(wildcard $(BUILD_CORE_LIB_PATH)/*.cpp)) # */

#BUILD_CORE_OBJ_FILES  = $(BUILD_CORE_C_SRCS:.c=.c.o) $(BUILD_CORE_CPP_SRCS:.cpp=.cpp.o)
#BUILD_CORE_OBJS       = $(patsubst $(BUILD_CORE_LIB_PATH)/%,$(OBJDIR)/%,$(BUILD_CORE_OBJ_FILES))


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


BOARD            = $(call PARSE_BOARD,$(BOARD_TAG),board)
VARIANT          = $(call PARSE_BOARD,$(BOARD_TAG),build.variant)
VARIANT_PATH     = $(APPLICATION_PATH)/hardware/msp432/variants/$(VARIANT)
CORE_A           = $(CORES_PATH)/driverlib/libdriverlib.a
LDSCRIPT         = $(VARIANT_PATH)/linker.cmd


OPTIMISATION   = -Os


MCU_FLAG_NAME    = mcpu
MCU              = $(call PARSE_BOARD,$(BOARD_TAG),build.mcu)
F_CPU            = $(call PARSE_BOARD,$(BOARD_TAG),build.f_cpu)

SUB_PATH         = $(sort $(dir $(wildcard $(1)/*/))) # */

INCLUDE_PATH     = $(call SUB_PATH,$(CORES_PATH))
INCLUDE_PATH    += $(call SUB_PATH,$(VARIANT_PATH))
INCLUDE_PATH    += $(call SUB_PATH,$(APPLICATION_PATH)/hardware/common)
INCLUDE_PATH    += $(APPLICATION_PATH)/hardware/tools/lm4f/include
INCLUDE_PATH    += $(APPLICATION_PATH)/hardware/msp432/cores/msp432/inc/CMSIS
INCLUDE_PATH    += $(APPLICATION_PATH)/hardware/msp432/variants/$(call PARSE_BOARD,$(BOARD_TAG),build.hardware)

INCLUDE_LIBS     = $(APPLICATION_PATH)/hardware/common
INCLUDE_LIBS    += $(APPLICATION_PATH)/hardware/tools/lm4f/lib
INCLUDE_LIBS    += $(APPLICATION_PATH)/hardware/msp432/variants/$(call PARSE_BOARD,$(BOARD_TAG),build.hardware)
INCLUDE_LIBS    += $(APPLICATION_PATH)/hardware/common/libs


# Flags for gcc, g++ and linker
# ----------------------------------
#
# Common CPPFLAGS for gcc, g++, assembler and linker
#
CPPFLAGS     = $(OPTIMISATION) $(WARNING_FLAGS)
#CPPFLAGS    += @$(APPLICATION_PATH)/hardware/msp432/targets/MSP_EXP432P401R/compiler.opt
CPPFLAGS    += @$(VARIANT_PATH)/compiler.opt
CPPFLAGS    += $(addprefix -I, $(INCLUDE_PATH))
CPPFLAGS    += $(addprefix -D, $(PLATFORM_TAG))
CPPFLAGS    += -DF_CPU=$(F_CPU) -D$(call PARSE_BOARD,$(BOARD_TAG),build.hardware)
CPPFLAGS    += -DBOARD_$(call PARSE_BOARD,$(BOARD_TAG),build.hardware)
CPPFLAGS    += $(addprefix -D, TARGET_IS_MSP432P4XX xdc__nolocalstring=1)
CPPFLAGS    += -ffunction-sections -fdata-sections -mfloat-abi=hard -mfpu=fpv4-sp-d16 -fsingle-precision-constant

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
LDFLAGS      = -Wl,-T$(LDSCRIPT) $(CORE_A) $(addprefix -L, $(INCLUDE_LIBS))
LDFLAGS     += $(OPTIMISATION) $(WARNING_FLAGS) $(addprefix -D, $(PLATFORM_TAG))
LDFLAGS     += @$(APPLICATION_PATH)/hardware/msp432/variants/MSP_EXP432P401R/compiler.opt
LDFLAGS     += -nostartfiles -Wl,--no-wchar-size-warning -Wl,-static -Wl,--gc-sections
LDFLAGS     += $(CORES_PATH)/driverlib/libdriverlib.a
LDFLAGS     += -lstdc++ -lgcc -lc -lm -lnosys

# Specific OBJCOPYFLAGS for objcopy only
# objcopy uses OBJCOPYFLAGS only
#
OBJCOPYFLAGS  = -v -Obinary

# Target
#
TARGET_HEXBIN = $(TARGET_ELF)


# Commands
# ----------------------------------
#
COMMAND_LINK = $(CC) $(OUT_PREPOSITION)$@ $(LOCAL_OBJS) $(TARGET_A) $(LDFLAGS)
