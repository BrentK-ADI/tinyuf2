UF2_FAMILY_ID = 0x91d3fd18
CROSS_COMPILE = arm-none-eabi-

JLINK_DEVICE = MAX78002

# Important locations in the hw support for MCU
MAX32_CMSIS = lib/mcu/analog/max32/Libraries/CMSIS
MAX32_PERIPH = lib/mcu/analog/max32/Libraries/PeriphDrivers
PERIPH_SRC = $(MAX32_PERIPH)/Source

FLASH_BOOT_SIZE := 0x8000 #32K

# Port Compiler Flags
CFLAGS += \
	-mthumb \
	-mabi=aapcs \
	-mcpu=cortex-m4 \

# Flags for TUSB features
CFLAGS += \
	-DCFG_TUSB_MCU=OPT_MCU_MAX78002 \
	-DBOARD_TUD_MAX_SPEED=OPT_MODE_HIGH_SPEED

# Flags for the MAX78002 SDK
CFLAGS += \
	-DTARGET=MAX78002 \
	-DTARGET_REV=0x4131 \
	-DMXC_ASSERT_ENABLE \
	-DMAX78002 \
	-DIAR_PRAGMAS=0 \
	-DFLASH_BOOT_SIZE=$(FLASH_BOOT_SIZE) \


# mcu driver cause following warnings
CFLAGS += \
	-Wno-error=redundant-decls \
	-Wno-error=strict-prototypes \
	-Wno-error=unused-parameter \
	-Wno-error=enum-conversion \
	-Wno-error=sign-compare \
	-Wno-error=cast-qual \


# default linker file
ifdef BUILD_APPLICATION
LD_FILES ?= \
	$(PORT_DIR)/linker/max78002_app.ld \
	$(PORT_DIR)/linker/max78002_common.ld
else
LD_FILES ?= \
	$(PORT_DIR)/linker/max78002_boot.ld \
	$(PORT_DIR)/linker/max78002_common.ld
endif

LDFLAGS += -nostartfiles -Wl,--defsym=__FLASH_BOOT_SIZE=${FLASH_BOOT_SIZE} \

# Port source
SRC_C += \
	$(PORT_DIR)/boards.c \
	$(PORT_DIR)/board_flash.c \
	$(MAX32_CMSIS)/Device/Maxim/MAX78002/Source/heap.c \
	$(MAX32_CMSIS)/Device/Maxim/MAX78002/Source/system_max78002.c \
	$(PERIPH_SRC)/SYS/mxc_assert.c \
	$(PERIPH_SRC)/SYS/mxc_delay.c \
	$(PERIPH_SRC)/SYS/mxc_lock.c \
	$(PERIPH_SRC)/SYS/nvic_table.c \
	$(PERIPH_SRC)/SYS/pins_ai87.c \
	$(PERIPH_SRC)/SYS/sys_ai87.c \
	$(PERIPH_SRC)/AES/aes_ai87.c \
	$(PERIPH_SRC)/AES/aes_revb.c \
	$(PERIPH_SRC)/FLC/flc_common.c \
	$(PERIPH_SRC)/FLC/flc_ai87.c \
	$(PERIPH_SRC)/FLC/flc_reva.c \
	$(PERIPH_SRC)/GPIO/gpio_common.c \
	$(PERIPH_SRC)/GPIO/gpio_ai87.c \
	$(PERIPH_SRC)/GPIO/gpio_reva.c \
	$(PERIPH_SRC)/ICC/icc_ai87.c \
	$(PERIPH_SRC)/ICC/icc_reva.c \
	$(PERIPH_SRC)/TRNG/trng_ai87.c \
	$(PERIPH_SRC)/TRNG/trng_revb.c \
	$(PERIPH_SRC)/UART/uart_common.c \
	$(PERIPH_SRC)/UART/uart_ai87.c \
	$(PERIPH_SRC)/UART/uart_revb.c \

ifndef BUILD_NO_TINYUSB
SRC_C += lib/tinyusb/src/portable/mentor/musb/dcd_musb.c
endif

SRC_S += $(MAX32_CMSIS)/Device/Maxim/MAX78002/Source/GCC/startup_max78002.S

# Port include
INC += \
	$(TOP)/lib/CMSIS_5/CMSIS/Core/Include \
	$(TOP)/$(MAX32_CMSIS)/Device/Maxim/MAX78002/Include \
	$(TOP)/$(MAX32_PERIPH)/Include/MAX78002 \
	$(TOP)/$(PERIPH_SRC)/SYS \
	$(TOP)/$(PERIPH_SRC)/GPIO \
	$(TOP)/$(PERIPH_SRC)/AES \
	$(TOP)/$(PERIPH_SRC)/ICC \
	$(TOP)/$(PERIPH_SRC)/FLC \
	$(TOP)/$(PERIPH_SRC)/TRNG \
	$(TOP)/$(PERIPH_SRC)/UART

# By default use JLink to the flash the devices since OpenOCD requires ADI's
# OpenOCD fork until the part support can get mainlined. See flash-msdk below
# to use OpenOCD from ADI
flash: flash-jlink
erase: erase-jlink

# Optional flash option when running within an installed MSDK to use OpenOCD
# Mainline OpenOCD does not yet have the MAX32's flash algorithm integrated.
# If the MSDK is installed, flash-msdk can be run to utilize the the modified
# openocd with the algorithms

# Set default if MAXIM_PATH is unset or empty
ifndef MAXIM_PATH
    MAXIM_PATH := C:\MaximSDK
endif

MAXIM_PATH := $(subst \,/,$(MAXIM_PATH))
flash-msdk: $(BUILD)/$(OUTNAME).elf
	$(MAXIM_PATH)/Tools/OpenOCD/openocd -s $(MAXIM_PATH)/Tools/OpenOCD/scripts \
		-f interface/cmsis-dap.cfg -f target/max78002.cfg \
		-c "program $(BUILD)/$(OUTNAME).elf verify; init; reset; exit"
