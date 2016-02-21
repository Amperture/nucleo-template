# STM32 Nucleo F401RE Makefile
# ############################
# Written by Amperture Engineering
# http://www.amperture.com
#
# With heavy inspiration and contribution from:
# 	-UCTools Project (http://uctools.github.io)
# 	-Iztok Starc (@iztokstarc)
# ###########################

# ########################
# Toolchain info
# ########################
TOOLPREFIX = arm-none-eabi-
CC = $(TOOLPREFIX)gcc
AS = $(TOOLPREFIX)as
LD = $(TOOLPREFIX)ld -v
CP = $(TOOLPREFIX)objcopy
OD = $(TOOLPREFIX)objdump
SIZE = $(TOOLPREFIX)size
GDB = $(TOOLPREFIX)gdb

# ########################
# Project Info
# ########################

# Project Name
TARGET = main
 
# Architecture/Family used, will usually be something like STM32F4XX
STM32_ARCHITECTURE = STM32F4XX
STM32_FAMILY = STM32F401xx

# OpenOCD script for flashing
OPENOCD_SCRIPT = board/st_nucleo_f4.cfg

# Finding Project Source Files
SOURCE_DIR = src
SOURCES_C = $(shell find -L $(SOURCE_DIR) -name '*.c')
SOURCES_S = $(shell find -L $(SOURCE_DIR) -name '*.s')

# Finding Project Included Headers
INCLUDE_DIR = inc
INC_FILES=$(shell find -L . -name '*.h' -exec dirname {} \; | uniq)
INCLUDES = $(INC_FILES:%=-I%)

# Building Object List
BUILD_DIR = build
OBJECTS = $(SOURCES_S:%.s=%.o)
OBJECTS += $(SOURCES_C:%.c=%.o)

#Output Files
BUILD_ELF = $(TARGET).elf
BUILD_HEX = $(TARGET).hex

# #########################
# Compilation Settings
# #########################
MCU_FLAGS = -mcpu=cortex-m4 -mthumb -mlittle-endian -mfpu=fpv4-sp-d16 \
			-mfloat-abi=hard -mthumb-interwork
DEFS = -DUSE_STDPERIPH_DRIVER -D$(STM32_ARCHITECTURE) -D$(STM32_FAMILY) \
	   -lc -lm -lnosys
CFLAGS = -c $(MCU_FLAGS) $(DEFS) $(INCLUDES)

LD_SCRIPT = ./system/STM32F401CE_FLASH.ld
LDFLAGS = -T $(LD_SCRIPT) --specs=nosys.specs $(MCU_FLAGS)

###
# Optimizations (Taken from @iztokstark)
OPT?='O1 O2 O3 O4 O6 O7' # O5 disabled by default, because it breaks code

ifneq ($(filter O1,$(OPT)),)
CXXFLAGS+=-fno-exceptions # Uncomment to disable exception handling
DEFS+=-DNO_EXCEPTIONS # The source code has to comply with this rule
endif

ifneq ($(filter O2,$(OPT)),)
CFLAGS+=-Os # Optimize for size https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html
CXXFLAGS+=-Os
LDFLAGS+=-Os # Optimize for size https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html
endif

ifneq ($(filter O3,$(OPT)),)
CFLAGS+=-ffunction-sections -fdata-sections # Place each function or data item into its own section in the output file
CXXFLAGS+=-ffunction-sections -fdata-sections # -||-
LDFLAGS+=-Wl,-gc-sections # Remove isolated unused sections
endif

ifneq ($(filter O4,$(OPT)),)
CFLAGS+=-fno-builtin # Disable C++ exception handling
CXXFLAGS+=-fno-builtin # Disable C++ exception handling
endif

ifneq ($(filter O5,$(OPT)),)
CFLAGS+=-flto # Enable link time optimization
CXXFLAGS+=-flto # Enable link time optimization
LDFLAGS+=-flto # Enable link time optimization
endif

ifneq ($(filter O6,$(OPT)),)
CXXFLAGS+=-fno-rtti # Disable type introspection
endif

ifneq ($(findstring O7,$(OPT)),)
LDFLAGS+=--specs=nano.specs # Use size optimized newlib
endif

###

# #########################
# Build Rules
# #########################
.PHONY: all debug clean ocd debug flash

all: $(BUILD_DIR)/$(BUILD_HEX)

$(BUILD_DIR)/$(BUILD_HEX): $(BUILD_DIR)/$(BUILD_ELF)
	@$(CP) -O ihex $< $@
	@echo "Object Copied from ELF to IHEX successfully!\n"
	@$(SIZE) $(BUILD_DIR)/$(BUILD_ELF)

$(BUILD_DIR)/$(BUILD_ELF): $(OBJECTS)
	@$(CC) $(LDFLAGS) $(OBJECTS) -o $@
	@echo "Linking complete!"
	@$(SIZE) $(BUILD_DIR)/$(BUILD_ELF)

%.o: %.c
	@echo "[CC] $(notdir $<)"
	@$(CC) $(CFLAGS) $< -o $@

%.o: %.s
	@echo "[CC] $(notdir $<)"
	@$(CC) $(CFLAGS) $< -o $@

ocd:
	openocd -f $(OPENOCD_SCRIPT) &

debug: $(BUILD_DIR)/$(BUILD_ELF)
	$(GDB) $(BUILD_DIR)/$(BUILD_ELF) -x gdbinit

flash: $(BUILD_DIR)/$(BUILD_ELF)
	openocd -f $(OPENOCD_SCRIPT) -c "program $(BUILD_DIR)/$(BUILD_ELF) verify reset exit"

clean:
	@echo "Cleaning up all compiled files..."
	@rm -f $(OBJECTS) $(BUILD_DIR)/$(BUILD_ELF) $(BUILD_DIR)/$(BUILD_HEX)
	@echo "Done!"
