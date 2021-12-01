# ATS Is going to use the same tool path as the rest of the stm32
# So some sections from the Common.mk are copied from there here.
# The toolchain path, defaults to using the globally installed toolchain
ifdef TOOLCHAIN_PATH
    TOOLCHAIN_SEPARATOR = /
endif

TOOLCHAIN_PATH      ?= ../../tools/bin/
TOOLCHAIN_SEPARATOR ?=
TOOLCHAIN_PREFIX    ?= arm-none-eabi-

CC      = $(TOOLCHAIN_PATH)$(TOOLCHAIN_SEPARATOR)$(TOOLCHAIN_PREFIX)gcc
CXX     = $(TOOLCHAIN_PATH)$(TOOLCHAIN_SEPARATOR)$(TOOLCHAIN_PREFIX)g++
LD      = $(TOOLCHAIN_PATH)$(TOOLCHAIN_SEPARATOR)$(TOOLCHAIN_PREFIX)ld -v
AR      = $(TOOLCHAIN_PATH)$(TOOLCHAIN_SEPARATOR)$(TOOLCHAIN_PREFIX)ar
AS      = $(TOOLCHAIN_PATH)$(TOOLCHAIN_SEPARATOR)$(TOOLCHAIN_PREFIX)gcc
OBJCOPY = $(TOOLCHAIN_PATH)$(TOOLCHAIN_SEPARATOR)$(TOOLCHAIN_PREFIX)objcopy
OBJDUMP = $(TOOLCHAIN_PATH)$(TOOLCHAIN_SEPARATOR)$(TOOLCHAIN_PREFIX)objdump
SIZE    = $(TOOLCHAIN_PATH)$(TOOLCHAIN_SEPARATOR)$(TOOLCHAIN_PREFIX)size


# ATS Configuration
OBJFOLDER = obj
SATS           = $(wildcard SATS/*.sats)
DATS           = $(wildcard DATS/*.dats)
CATS           = $(wildcard CATS/*.c)
DATSC          = $(patsubst %.dats,%_dats.c,$(DATS))
DATSCFINAL     = $(patsubst DATS/%,$(GENERATEDC_FOLDER)/%, $(DATSC))
DATSOBJ        = $(patsubst %.dats,%_dats.o,$(DATS))
DATSOBJFINAL   = $(patsubst DATS/%,$(OBJFOLDER)/%, $(DATSOBJ))
ATS ?= patsopt


ATSCFLAGS      = -std=c99 -D_XOPEN_SOURCE
ATSCFLAGS      += -D_ATS_CCOMP_EXCEPTION_NONE_ -D_ATS_CCOMP_RUNTIME_NONE_ -D_ATS_CCOMP_PRELUDE_NONE_
ATSCFLAGS      += -Wno-unused-variable -Wno-unused-label -Wno-unused-but-set-variable
ATSCFLAGS      += -I. -I${PATSHOME} -I${PATSHOME}/ccomp/runtime  -I$./_stm32

ATSCCFLAGS= -cc



# CHIP SPECIFIC
DEVICE = STM32F407xG

FLASH  = 0x08000000

USE_ST_CMSIS = true

# Include the main makefile
# Using the enviornment variable method
# To make it more nix compatable
CPPFLAGS += $(ATSCFLAGS)
CPPFLAGS += -g

# Check to make sure that the required variables are set
ifndef DEVICE
    $(error Please set the required DEVICE variable in your makefile.)
endif

ifndef FLASH
    $(error Please set the required FLASH variable in your makefile.)
endif

# Standard values for (linked) STM32-base folders
STM32_BASE_PATH   ?= ./STM32-base
STM32_CUBE_PATH   ?= ./STM32-base-STM32Cube

# STM32-base sub-folders
BASE_LINKER   = $(STM32_BASE_PATH)/linker
BASE_MAKE     = $(STM32_BASE_PATH)/make
BASE_STARTUP  = $(STM32_BASE_PATH)/startup

# Standard values for project folders
BIN_FOLDER ?= ./bin
OBJ_FOLDER ?= ./obj
SRC_FOLDER ?= ./src
INC_FOLDER ?= ./inc
GENERATEDC_FOLDER ?= ./cgen

# Determine the series folder name
include $(BASE_MAKE)/series-folder-name.mk

# Include the series-specific makefile
include $(BASE_MAKE)/$(SERIES_FOLDER)/common.mk
MAPPED_DEVICE ?= $(DEVICE)

# The toolchain path, defaults to using the globally installed toolchain
ifdef TOOLCHAIN_PATH
    TOOLCHAIN_SEPARATOR = /
endif

TOOLCHAIN_PATH      ?= ../../tools/bin/
TOOLCHAIN_SEPARATOR ?=
TOOLCHAIN_PREFIX    ?= arm-none-eabi-

CC      = $(TOOLCHAIN_PATH)$(TOOLCHAIN_SEPARATOR)$(TOOLCHAIN_PREFIX)gcc
CXX     = $(TOOLCHAIN_PATH)$(TOOLCHAIN_SEPARATOR)$(TOOLCHAIN_PREFIX)g++
LD      = $(TOOLCHAIN_PATH)$(TOOLCHAIN_SEPARATOR)$(TOOLCHAIN_PREFIX)ld -v
AR      = $(TOOLCHAIN_PATH)$(TOOLCHAIN_SEPARATOR)$(TOOLCHAIN_PREFIX)ar
AS      = $(TOOLCHAIN_PATH)$(TOOLCHAIN_SEPARATOR)$(TOOLCHAIN_PREFIX)gcc
OBJCOPY = $(TOOLCHAIN_PATH)$(TOOLCHAIN_SEPARATOR)$(TOOLCHAIN_PREFIX)objcopy
OBJDUMP = $(TOOLCHAIN_PATH)$(TOOLCHAIN_SEPARATOR)$(TOOLCHAIN_PREFIX)objdump
SIZE    = $(TOOLCHAIN_PATH)$(TOOLCHAIN_SEPARATOR)$(TOOLCHAIN_PREFIX)size


# Flags - Overall Options
CPPFLAGS += -specs=nosys.specs

# Flags - C Language Options
# CFLAGS += -ffreestanding


# Flags - Warning Options
CPPFLAGS += -Wall
CPPFLAGS += -Wextra

# Flags - Debugging Options
CPPFLAGS += -g

# Flags - Optimization Options
CPPFLAGS += -ffunction-sections
CPPFLAGS += -fdata-sections

# Flags - Preprocessor options
CPPFLAGS += -D $(MAPPED_DEVICE)

# Flags - Assembler Options
ifneq (,$(or USE_ST_CMSIS, USE_ST_HAL))
    CPPFLAGS += -Wa,--defsym,CALL_ARM_SYSTEM_INIT=1
endif

# Flags - Linker Options
# CPPFLAGS += -nostdlib
CPPFLAGS += -Wl,-L$(BASE_LINKER),-T$(BASE_LINKER)/$(SERIES_FOLDER)/$(DEVICE).ld

# Flags - Directory Options
CPPFLAGS += -I$(INC_FOLDER)
CPPFLAGS += -I$(BASE_STARTUP)

# Flags - Machine-dependant options
CPPFLAGS += -mcpu=$(SERIES_CPU)
CPPFLAGS += -march=$(SERIES_ARCH)
CPPFLAGS += -mlittle-endian
CPPFLAGS += -mthumb
CPPFLAGS += -masm-syntax-unified

# Output files
ELF_FILE_NAME ?= stm32_executable.elf
BIN_FILE_NAME ?= stm32_bin_image.bin
OBJ_FILE_NAME ?= startup_$(MAPPED_DEVICE).o

ELF_FILE_PATH = $(BIN_FOLDER)/$(ELF_FILE_NAME)
BIN_FILE_PATH = $(BIN_FOLDER)/$(BIN_FILE_NAME)
OBJ_FILE_PATH = $(OBJ_FOLDER)/$(OBJ_FILE_NAME)

# Input files

SRC ?= $(CATS)
#SRC += $(SRC_FOLDER)/*.c

# Startup file
DEVICE_STARTUP = $(BASE_STARTUP)/$(SERIES_FOLDER)/$(MAPPED_DEVICE).s

# Include the CMSIS files, using the HAL implies using the CMSIS
ifneq (,$(or USE_ST_CMSIS, USE_ST_HAL))
    CPPFLAGS += -I$(STM32_CUBE_PATH)/CMSIS/ARM/inc
    CPPFLAGS += -I$(STM32_CUBE_PATH)/CMSIS/$(SERIES_FOLDER)/inc

    SRC += $(STM32_CUBE_PATH)/CMSIS/$(SERIES_FOLDER)/src/*.c
endif

# Include the HAL files
ifdef USE_ST_HAL
    CPPFLAGS += -D USE_HAL_DRIVER
    CPPFLAGS += -I$(STM32_CUBE_PATH)/HAL/$(SERIES_FOLDER)/inc

    # A simply expanded variable is used here to perform the find command only once.
    HAL_SRC := $(shell find $(STM32_CUBE_PATH)/HAL/$(SERIES_FOLDER)/src/*.c ! -name '*_template.c')
    SRC += $(HAL_SRC)
endif

# Make all
all:$(BIN_FILE_PATH)

$(DATSCFINAL): $(DATS) $(SATS) | $(GENERATEDC_FOLDER)
	$(ATS) -o $@.tmp -d $<
	mv $@.tmp $@


$(BIN_FILE_PATH): $(ELF_FILE_PATH)
	$(OBJCOPY) -O binary $^ $@

$(ELF_FILE_PATH): $(SRC) $(DATSCFINAL) $(OBJ_FILE_PATH) | $(BIN_FOLDER)
	$(CC) $(CPPFLAGS) $(CXXFLAGS) $(SRC) $(DATSCFINAL) $(OBJ_FILE_PATH) -o $@

$(OBJ_FILE_PATH): $(DEVICE_STARTUP) | $(OBJ_FOLDER)
	$(CC) -c $(CPPFLAGS) $(CXXFLAGS) $(DEVICE_STARTUP) -o $@

$(GENERATEDC_FOLDER):
	mkdir $(GENERATEDC_FOLDER)

$(BIN_FOLDER):
	mkdir $(BIN_FOLDER)

$(OBJ_FOLDER):
	mkdir $(OBJ_FOLDER)

# Make clean
clean:
	rm -f $(ELF_FILE_PATH)
	rm -f $(BIN_FILE_PATH)
	rm -f $(OBJ_FILE_PATH)
	rm -f $(DATSCFINAL)
	rm -f $(DATSOBJ)

# Make flash
flash:
	st-flash write $(BIN_FOLDER)/$(BIN_FILE_NAME) $(FLASH)

.PHONY: all clean flash


atsmv: $(echo) $(DATSOBJ)
CFLAGS += -c $(ATSCFLAGS)

