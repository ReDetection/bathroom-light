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
# Last update: Apr 30, 2015 release 285



# chipKIT MPIDE specifics
# ----------------------------------
# Dirty implementation for MPIDE release 0023-macosx-20130715
# OPT_SYSTEM_INTERNAL is defined in main.cpp but used in wiring.h
#
PLATFORM         := MPIDE
APPLICATION_PATH := $(MPIDE_PATH)

mp001             = $(shell cat $(APPLICATION_PATH)/lib/version.txt | cut -d- -f1 | sed 's/^0*//')
PLATFORM_TAG      = ARDUINO=$(mp001) MPIDE=$(mp001) MPIDEVER=16778000 EMBEDXCODE=$(RELEASE_NOW)

APP_TOOLS_PATH   := $(APPLICATION_PATH)/hardware/pic32/compiler/pic32-tools/bin
CORE_LIB_PATH    := $(APPLICATION_PATH)/hardware/pic32/cores/pic32
APP_LIB_PATH     := $(APPLICATION_PATH)/hardware/pic32/libraries

BOARDS_TXT       := $(APPLICATION_PATH)/hardware/pic32/boards.txt
ifeq ($(call PARSE_FILE,$(BOARD_TAG),name,$(BOARDS_TXT)),)
    BOARDS_TXT   := $(shell grep -rnwls $(MPIDE_PATH)/hardware/pic32/variants -e '$(BOARD_TAG).name')
endif

#BOARDS_TXT       := $(shell grep -rnwls $(MPIDE_PATH)/hardware/pic32/variants -e '$(BOARD_TAG).name')

#BOARDS_TXT       := $(APPLICATION_PATH)/hardware/pic32/boards.txt
#ifeq ($(call PARSE_FILE,$(BOARD_TAG),name,$(BOARDS_TXT)),)
#    BOARDS_TXT   := $(APPLICATION_PATH)/hardware/pic32/variants/picadillo_35t/boards.txt
#endif

# Sketchbook/Libraries path
# wildcard required for ~ management
# ?ibraries required for libraries and Libraries
#
ifeq ($(wildcard $(USER_LIBRARY_DIR)/Mpide/preferences.txt),)
    $(error Error: run Mpide once and define the sketchbook path)
endif

ifeq ($(wildcard $(SKETCHBOOK_DIR)),)
    SKETCHBOOK_DIR = $(shell grep sketchbook.path $(USER_LIBRARY_DIR)/Mpide/preferences.txt | cut -d = -f 2)
endif
ifeq ($(wildcard $(SKETCHBOOK_DIR)),)
    $(error Error: sketchbook path not found)
endif
USER_LIB_PATH  = $(wildcard $(SKETCHBOOK_DIR)/?ibraries)

# USER sources
# wildcard required for ~ management
# ?ibraries required for libraries and Libraries
#
# Network and WiFi libraries need to be compiled on a given order!
#
ifndef USER_LIBS_LIST
    ew001               = $(realpath $(sort $(dir $(wildcard $(USER_LIB_PATH)/*/*.h)))) # */
    USER_LIBS_LIST      = $(subst $(USER_LIB_PATH)/,,$(filter-out $(EXCLUDE_LIST),$(ew001)))
endif
ew002                   = WiFiShieldOrPmodWiFi_G DNETcK DWIFIcK

# Libraries for WiFi
# Success if included in the following order
#
# MPIDE 1.5  = WiFiShieldOrPmodWiFi_G DNETcK DWIFIcK
# MPIDE 0023 = MRF24G DEIPcK DEWFcK HTTPServer

ifneq ($(USER_LIBS_LIST),0)
    ifneq ($(filter $(ew002),$(USER_LIBS_LIST)),)
        ew003           = $(filter-out $(ew002),$(USER_LIBS_LIST))
        ew004           = $(filter $(ew002),$(USER_LIBS_LIST)) $(addsuffix /utility,$(filter $(ew002),$(USER_LIBS_LIST)))
        ew007          += $(addprefix $(USER_LIB_PATH)/,$(ew004))
        USER_LIBS_LOCK  = 1
    else
        ew003           = $(USER_LIBS_LIST)
    endif
    ew005               = $(patsubst %,$(USER_LIB_PATH)/%,$(ew003))

    ew006               = $(foreach dir,$(ew005),$(shell find $(dir) -type d))
    USER_LIBS           = $(ew006) $(ew007)
    USER_LIB_CPP_SRC    = $(wildcard $(patsubst %,%/*.cpp,$(USER_LIBS))) # */
    USER_LIB_C_SRC      = $(wildcard $(patsubst %,%/*.c,$(USER_LIBS))) # */

    USER_OBJS           = $(patsubst $(USER_LIB_PATH)/%.cpp,$(OBJDIR)/libs/%.cpp.o,$(USER_LIB_CPP_SRC))
    USER_OBJS          += $(patsubst $(USER_LIB_PATH)/%.c,$(OBJDIR)/libs/%.c.o,$(USER_LIB_C_SRC))
endif

REMOTE_OBJS = $(sort $(CORE_OBJS) $(BUILD_CORE_OBJS) $(APP_LIB_OBJS) $(BUILD_APP_LIB_OBJS) $(VARIANT_OBJS)) $(USER_OBJS)


# Rules for making a c++ file from the main sketch (.pde)
#
PDEHEADER      = \\\#include \"WProgram.h\"  


# Tool-chain names
#
CC      = $(APP_TOOLS_PATH)/pic32-gcc
CXX     = $(APP_TOOLS_PATH)/pic32-g++
#AS      = $(APP_TOOLS_PATH)/pic32-g++
AR      = $(APP_TOOLS_PATH)/pic32-ar
OBJDUMP = $(APP_TOOLS_PATH)/pic32-objdump
OBJCOPY = $(APP_TOOLS_PATH)/pic32-objcopy
SIZE    = $(APP_TOOLS_PATH)/pic32-size
NM      = $(APP_TOOLS_PATH)/pic32-nm


BOARD    = $(call PARSE_BOARD,$(BOARD_TAG),board)
LDSCRIPT = $(call PARSE_BOARD,$(BOARD_TAG),ldscript)
VARIANT  = $(call PARSE_BOARD,$(BOARD_TAG),build.variant)
VARIANT_PATH = $(APPLICATION_PATH)/hardware/pic32/variants/$(VARIANT)

# Add .S files required by MPIDE release 0023-macosx-20130715
#
CORE_AS_SRCS    = $(wildcard $(CORE_LIB_PATH)/*.S) # */
mp002           = $(patsubst %.S,%.S.o,$(filter %S, $(CORE_AS_SRCS)))
FIRST_O_IN_A    = $(patsubst $(CORE_LIB_PATH)/%,$(OBJDIR)/%,$(mp002))
#FIRST_O_IN_A    = Builds/cpp-startup.S.o Builds/crti.S.o Builds/crtn.S.o Builds/pic32_software_reset.S.o Builds/vector_table.S.o

# Two locations for Arduino libraries
#
VARIANT_C_SRCS    = $(wildcard $(VARIANT_PATH)/*.c) # */
VARIANT_OBJ_FILES = $(VARIANT_C_SRCS:.c=.c.o)
VARIANT_OBJS      = $(patsubst $(VARIANT_PATH)/%,$(OBJDIR)/%,$(VARIANT_OBJ_FILES))

OPTIMISATION      = -O2
MCU_FLAG_NAME     = mprocessor


MCU_FLAG_NAME    = mprocessor
MCU              = $(call PARSE_BOARD,$(BOARD_TAG),build.mcu)

# Flags for gcc, g++ and linker
# ----------------------------------
#
# Common CPPFLAGS for gcc, g++, assembler and linker
#
#CPPFLAGS     = $(OPTIMISATION) -c -mno-smart-io -w
CPPFLAGS     = $(OPTIMISATION)
CPPFLAGS    += -$(MCU_FLAG_NAME)=$(MCU) -DF_CPU=$(F_CPU)
CPPFLAGS    += $(addprefix -D, $(PLATFORM_TAG)) -D$(BOARD)
CPPFLAGS    += -I$(CORE_LIB_PATH) -I$(VARIANT_PATH) -I$(OBJDIR) -I.

# Specific CFLAGS for gcc only
# gcc uses CPPFLAGS and CFLAGS
#
#CFLAGS       = -g -ffunction-sections -fdata-sections -G1024 -mdebugger -Wcast-align -fno-short-double
m101         = $(call PARSE_BOARD,$(BOARD_TAG),compiler.c.flags)
ifeq ($(m101),)
    m101    := -O2::-c::-mno-smart-io::-w::-ffunction-sections::-fdata-sections::-G1024::-g::-mdebugger::-Wcast-align::-fno-short-double
endif
m102         = $(shell echo '$(m101)' | sed 's/::/ /g')
CFLAGS       = $(filter-out -O%,$(m102))

# Specific CXXFLAGS for g++ only
# g++ uses CPPFLAGS and CXXFLAGS
#
#CXXFLAGS     = -g -fno-exceptions -ffunction-sections -fdata-sections -G1024 -mdebugger -Wcast-align -fno-short-double
m201         = $(call PARSE_BOARD,$(BOARD_TAG),compiler.cpp.flags)
ifeq ($(m201),)
    m201    := -O2::-c::-mno-smart-io::-w::-ffunction-sections::-fdata-sections::-G1024::-g::-mdebugger::-Wcast-align::-fno-short-double
endif
m202         = $(shell echo '$(m201)' | sed 's/::/ /g')
CXXFLAGS     = $(filter-out -O%,$(m202))

# Specific ASFLAGS for gcc assembler only
# gcc assembler uses CPPFLAGS and ASFLAGS
#
ASFLAGS      = -g1 -Wa,--gdwarf-2

# Specific LDFLAGS for linker only
# linker uses CPPFLAGS and LDFLAGS
# Thanks to ricklon for spotting the issue on linking!
#
# chipKIT-application-COMMON.ld added by MPIDE release 0023-macosx-20130715
LDFLAGS    = $(OPTIMISATION) -Wl,--gc-sections -$(MCU_FLAG_NAME)=$(MCU) -DF_CPU=$(F_CPU)
ifeq ($(MCU),32MZ2048ECG100)
    LDFLAGS   += -T $(VARIANT_PATH)/$(LDSCRIPT) -T $(CORE_LIB_PATH)/chipKIT-application-COMMON-MZ.ld
else ifeq ($(MCU),32MX695F512L)
    LDFLAGS   += -T $(VARIANT_PATH)/$(LDSCRIPT) -T $(CORE_LIB_PATH)/chipKIT-application-COMMON.ld
else
    LDFLAGS   += -T $(CORE_LIB_PATH)/$(LDSCRIPT) -T $(CORE_LIB_PATH)/chipKIT-application-COMMON.ld
endif
LDFLAGS   += -mdebugger -mno-peripheral-libs -nostartfiles

