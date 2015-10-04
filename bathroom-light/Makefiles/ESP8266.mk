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
# Last update: Jun 29, 2015 release 296



# ESP8266 specifics
# ----------------------------------
#
PLATFORM         := esp8266
PLATFORM_TAG      = ARDUINO=10605 ARDUINO_ARCH_ESP8266 EMBEDXCODE=$(RELEASE_NOW) ESP8266
APPLICATION_PATH := $(ESP8266_PATH)

BOARDS_TXT      := $(APPLICATION_PATH)/hardware/esp8266com/esp8266/boards.txt
BUILD_CORE       = $(call PARSE_BOARD,$(BOARD_TAG),build.core)
BUILD_BOARD      = ARDUINO_$(call PARSE_BOARD,$(BOARD_TAG),build.board)

ESP_POST_COMPILE   = $(APPLICATION_PATH)/hardware/esp8266com/esp8266/tools/esptool
BOOTLOADER_ELF     = $(APPLICATION_PATH)/hardware/esp8266com/esp8266/bootloaders/eboot/eboot.elf
BUILD_FLASH_SIZE   = $(call PARSE_BOARD,$(BOARD_TAG),build.flash_size)
BUILD_FLASH_FREQ   = $(call PARSE_BOARD,$(BOARD_TAG),build.flash_freq)


#ifeq ($(UPLOADER),esptool.py)
#    UPLOADER_PATH       = $(APPLICATION_PATH)/hardware/tools/esp8266
#    UPLOADER_EXEC       = $(UPLOADER_PATH)/esptool.py
#    UPLOADER_OPTS       = --baud $(call PARSE_BOARD,$(BOARD_TAG),upload.speed)
#else
    UPLOADER            = esptool
    UPLOADER_PATH       = $(APPLICATION_PATH)/hardware/esp8266com/esp8266/tools
    UPLOADER_EXEC       = $(UPLOADER_PATH)/esptool
    UPLOADER_OPTS       = -vv -cd $(call PARSE_BOARD,$(BOARD_TAG),upload.resetmethod)
    UPLOADER_OPTS      += -cb $(call PARSE_BOARD,$(BOARD_TAG),upload.speed)
#endif

APP_TOOLS_PATH      := $(APPLICATION_PATH)/hardware/esp8266com/esp8266/tools/xtensa-lx106-elf/bin
CORE_LIB_PATH       := $(APPLICATION_PATH)/hardware/esp8266com/esp8266/cores/esp8266

#BUILD_CORE_LIB_PATH  = $(APPLICATION_PATH)/hardware/panstamp/avr/cores/panstamp
#BUILD_CORE_LIBS_LIST = $(subst .h,,$(subst $(BUILD_CORE_LIB_PATH)/,,$(wildcard $(BUILD_CORE_LIB_PATH)/*.h))) # */
#BUILD_CORE_C_SRCS    = $(wildcard $(BUILD_CORE_LIB_PATH)/*.c) # */

#BUILD_CORE_CPP_SRCS  = $(filter-out %program.cpp %main.cpp,$(wildcard $(BUILD_CORE_LIB_PATH)/*.cpp)) # */

#BUILD_CORE_OBJ_FILES = $(BUILD_CORE_C_SRCS:.c=.c.o) $(BUILD_CORE_CPP_SRCS:.cpp=.cpp.o)
#BUILD_CORE_OBJS      = $(patsubst $(BUILD_CORE_LIB_PATH)/%,$(OBJDIR)/%,$(BUILD_CORE_OBJ_FILES))


# Take assembler file as first
#
APP_LIB_PATH        := $(APPLICATION_PATH)/hardware/esp8266com/esp8266/libraries
CORE_AS_SRCS         = $(wildcard $(CORE_LIB_PATH)/*.S) # */
esp001               = $(patsubst %.S,%.S.o,$(filter %S, $(CORE_AS_SRCS)))
FIRST_O_IN_A         = $(patsubst $(CORE_LIB_PATH)/%,$(OBJDIR)/%,$(esp001))


#BUILD_APP_LIB_PATH  := $(APPLICATION_PATH)/hardware/panstamp/avr/libraries

#ifndef APP_LIBS_LIST
#    ps01             = $(realpath $(sort $(dir $(wildcard $(APP_LIB_PATH)/*/*.h $(APP_LIB_PATH)/*/*/*.h $(APP_LIB_PATH)/*/*/*/*.h)))) # */
#    APP_LIBS_LIST    = $(subst $(APP_LIB_PATH)/,,$(filter-out $(EXCLUDE_LIST),$(ps01)))

#    ps02             = $(realpath $(sort $(dir $(wildcard $(BUILD_APP_LIB_PATH)/*/*.h $(BUILD_APP_LIB_PATH)/*/*/*.h $(BUILD_APP_LIB_PATH)/*/*/*/*.h)))) # */
#    BUILD_APP_LIBS_LIST = $(subst $(BUILD_APP_LIB_PATH)/,,$(filter-out $(EXCLUDE_LIST),$(ps02)))
#else
#    ps01              = $(patsubst %,$(BUILD_APP_LIB_PATH)/%,$(APP_LIBS_LIST))
#    ps02             += $(realpath $(sort $(dir $(foreach dir,$(ps01),$(wildcard $(dir)/*.h $(dir)/*/*.h $(dir)/*/*/*.h))))) # */
#    BUILD_APP_LIBS_LIST = $(subst $(BUILD_APP_LIB_PATH)/,,$(filter-out $(EXCLUDE_LIST),$(ps02)))
#endif
#
#ifneq ($(APP_LIBS_LIST),0)
#    ps04              = $(patsubst %,$(APP_LIB_PATH)/%,$(APP_LIBS_LIST))
#    ps04             += $(patsubst %,$(APP_LIB_PATH)/%/$(BUILD_CORE),$(APP_LIBS_LIST))
#    APP_LIBS        = $(realpath $(sort $(dir $(foreach dir,$(ps04),$(wildcard $(dir)/*.h $(dir)/*/*.h $(dir)/*/*/*.h))))) # */

#    APP_LIB_CPP_SRC = $(realpath $(sort $(foreach dir,$(APP_LIBS),$(wildcard $(dir)/*.cpp $(dir)/*/*.cpp $(dir)/*/*/*.cpp))))
#    APP_LIB_C_SRC   = $(realpath $(sort $(foreach dir,$(APP_LIBS),$(wildcard $(dir)/*.c $(dir)/*/*.c $(dir)/*/*/*.c))))

#    APP_LIB_OBJS    = $(patsubst $(APP_LIB_PATH)/%.cpp,$(OBJDIR)/libs/%.cpp.o,$(APP_LIB_CPP_SRC))
#    APP_LIB_OBJS   += $(patsubst $(APP_LIB_PATH)/%.c,$(OBJDIR)/libs/%.c.o,$(APP_LIB_C_SRC))

#    BUILD_APP_LIBS        = $(patsubst %,$(BUILD_APP_LIB_PATH)/%,$(BUILD_APP_LIBS_LIST))

#    BUILD_APP_LIB_CPP_SRC = $(wildcard $(patsubst %,%/*.cpp,$(BUILD_APP_LIBS))) # */
#    BUILD_APP_LIB_C_SRC   = $(wildcard $(patsubst %,%/*.c,$(BUILD_APP_LIBS))) # */

#    BUILD_APP_LIB_OBJS    = $(patsubst $(BUILD_APP_LIB_PATH)/%.cpp,$(OBJDIR)/libs/%.cpp.o,$(BUILD_APP_LIB_CPP_SRC))
#    BUILD_APP_LIB_OBJS   += $(patsubst $(BUILD_APP_LIB_PATH)/%.c,$(OBJDIR)/libs/%.c.o,$(BUILD_APP_LIB_C_SRC))
#endif


# IDE version management, based on the SDK version
#
$(eval SDK_VERSION = $(shell cat $(UPLOADER_PATH)/sdk/version))
#ifeq ($(SDK_VERSION),1.0.0)
#    BOARD_TAG      := generic
    L_FLAGS         = -lm -lgcc -lhal -lphy -lnet80211 -llwip -lwpa -lmain -lpp -lsmartconfig
    ADDRESS_BIN1     = 00000
#    ADDRESS_BIN2    = 40000
#else
# For ESP8266 1.6.1
#    L_FLAGS         = -lm -lc -lgcc -lhal -lphy -lnet80211 -llwip -lwpa -lmain -lpp -lsmartconfig
#    ADDRESS_BIN2    = 10000
#endif


# Sketchbook/Libraries path
# wildcard required for ~ management
# ?ibraries required for libraries and Libraries
#
ifeq ($(USER_LIBRARY_DIR)/Arduino15/preferences.txt,)
    $(error Error: run Arduino or panStamp once and define the sketchbook path)
endif

ifeq ($(wildcard $(SKETCHBOOK_DIR)),)
    SKETCHBOOK_DIR = $(shell grep sketchbook.path $(wildcard ~/Library/Arduino/preferences.txt) | cut -d = -f 2)
endif

ifeq ($(wildcard $(SKETCHBOOK_DIR)),)
    $(error Error: sketchbook path not found)
endif

USER_LIB_PATH  = $(wildcard $(SKETCHBOOK_DIR)/?ibraries)

VARIANT      = $(call PARSE_BOARD,$(BOARD_TAG),build.variant)
VARIANT_PATH = $(APPLICATION_PATH)/hardware/esp8266com/esp8266/variants/$(VARIANT)

VARIANT_CPP_SRCS  = $(wildcard $(VARIANT_PATH)/*.cpp) # */
VARIANT_OBJ_FILES = $(VARIANT_CPP_SRCS:.cpp=.cpp.o)
VARIANT_OBJS      = $(patsubst $(VARIANT_PATH)/%,$(OBJDIR)/%,$(VARIANT_OBJ_FILES))

# Rules for making a c++ file from the main sketch (.pde)
#
PDEHEADER      = \\\#include \"WProgram.h\"  


# Tool-chain names
#
CC      = $(APP_TOOLS_PATH)/xtensa-lx106-elf-gcc
CXX     = $(APP_TOOLS_PATH)/xtensa-lx106-elf-g++
AR      = $(APP_TOOLS_PATH)/xtensa-lx106-elf-ar
OBJDUMP = $(APP_TOOLS_PATH)/xtensa-lx106-elf-objdump
OBJCOPY = $(APP_TOOLS_PATH)/xtensa-lx106-elf-objcopy
SIZE    = $(APP_TOOLS_PATH)/xtensa-lx106-elf-size
NM      = $(APP_TOOLS_PATH)/xtensa-lx106-elf-nm

MCU_FLAG_NAME    = # mmcu
MCU              = $(call PARSE_BOARD,$(BOARD_TAG),build.mcu)
F_CPU            = $(call PARSE_BOARD,$(BOARD_TAG),build.f_cpu)
OPTIMISATION     = -Os

INCLUDE_PATH     = $(APPLICATION_PATH)/hardware/esp8266com/esp8266/tools/sdk/include
INCLUDE_PATH    += $(CORE_LIB_PATH)
INCLUDE_PATH    += $(VARIANT_PATH)


# Flags for gcc, g++ and linker
# ----------------------------------
#
# Common CPPFLAGS for gcc, g++, assembler and linker
#
CPPFLAGS     = -g $(OPTIMISATION) $(WARNING_FLAGS)
CPPFLAGS    += -D__ets__ -DICACHE_FLASH -U__STRICT_ANSI__
CPPFLAGS    += -mlongcalls -mtext-section-literals -falign-functions=4 -MMD
CPPFLAGS    += -DF_CPU=$(F_CPU)
CPPFLAGS    += $(addprefix -D, $(PLATFORM_TAG) $(BUILD_BOARD))
CPPFLAGS    += $(addprefix -I, $(INCLUDE_PATH))



# Specific CFLAGS for gcc only
# gcc uses CPPFLAGS and CFLAGS
#
CFLAGS       = -Wpointer-arith -Wno-implicit-function-declaration -Wl,-EL -fno-inline-functions -nostdlib -std=gnu99
# was -std=c99

# Specific CXXFLAGS for g++ only
# g++ uses CPPFLAGS and CXXFLAGS
#
CXXFLAGS     = -fno-exceptions -fno-rtti -std=c++11

# Specific ASFLAGS for gcc assembler only
# gcc assembler uses CPPFLAGS and ASFLAGS
#
ASFLAGS      = -x assembler-with-cpp

# Specific LDFLAGS for linker only
# linker uses CPPFLAGS and LDFLAGS
#
LDFLAGS      = $(OPTIMISATION) $(WARNING_FLAGS)
#-Wl,--gc-sections
LDFLAGS     += -nostdlib -Wl,--no-check-sections -u call_user_start -Wl,-static
LDFLAGS     += -L$(APPLICATION_PATH)/hardware/esp8266com/esp8266/tools/sdk/lib
LDFLAGS     += -L$(APPLICATION_PATH)/hardware/esp8266com/esp8266/tools/sdk/ld
LDFLAGS     += -T $(call PARSE_BOARD,$(BOARD_TAG),build.flash_ld)
LDFLAGS     += -Wl,-wrap,system_restart_local

# Specific OBJCOPYFLAGS for objcopy only
# objcopy uses OBJCOPYFLAGS only
#
OBJCOPYFLAGS  = $(call PARSE_BOARD,$(BOARD_TAG),build.flash_mode)

# Target
#
TARGET_HEXBIN = $(TARGET_BIN2)

