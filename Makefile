# STM32 Nucleo F4 Makefile
# ########################
#
# Written by Amperture Engineering
# http://amperture.com
#
# ########################

# ########################
# Toolchain info
# ########################
TOOLPREFIX = arm-none-eabi-
CC = $(TOOLPREFIX)gcc
LD = $(TOOLPREFIX)ld -v
CP = $(TOOLPREFIX)objcopy
OD = $(TOOLPREFIX)objdump
GDB = $(TOOLPREFIX)gdb

# ########################
# Project Info
# ########################
SOURCES =  system.c main.c 
TARGET = main
BUILD_DIR = build
LD_SCRIPT = ./system/STM32F401CE_FLASH.ld

# ########################
# User-Defined Extras
# ########################
USER_DEFS = 
USER_INCLUDES =
USER_CFLAGS = -Wall -g
USER_LDFLAGS = 

# ########################
# Folders to include in project
# ########################
INCLUDE = -I/home/alex/src/CMSIS/Device/ST/STM32F4xx/Include
INCLUDE += -I/home/alex/src/CMSIS/Include
INCLUDE += -I./inc
INCLUDE += -I./src
INCLUDE += -I./system

# ########################
# Core & CPU type for CM4
# ########################
CORE = -mcpu=cortex-m4
CORE += -mlittle-endian
CORE += -mthumb

# ########################
# External DEFINES
# ########################
DEFS = -DSTM32F401xE $(USER_DEFS)
LIBS = -lc -lm -lnosys


# ########################
# Compiler Flags
# ########################
CFLAGS = $(DEFS) $(INCLUDE) $(CORE) $(USER_CFLAGS) $(LIBS)

# ########################
# Compiler Build Rules 
# ########################

# List of user program objects
OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(SOURCES:.c=.o)))

# add an object for startup code
OBJECTS += $(BUILD_DIR)/startup_stm32f401xe.o

all: $(BUILD_DIR)/$(TARGET).elf

$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS)
	$(CC) -o $@ $(CFLAGS) $(OBJECTS) -T$(LD_SCRIPT)
		
	size $@

$(BUILD_DIR)/%.o: src/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c -o $@ $^

$(BUILD_DIR)/%.o: src/%.s | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c -o $@ $^

$(BUILD_DIR):
	mkdir -p $@

clean:
	-rm $(BUILD_DIR)/*.o
	-rm $(BUILD_DIR)/*.elf
