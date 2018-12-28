# put your *.o targets here, make should handle the rest!
SRCS = \
	src/tasks.c \
	src/main.c \
	config/system_stm32f4xx.c \
	config/stm32f4xx_it.c 

# project name
PROJ_NAME=project

# Location of the Libraries folder from the STM32F0xx Standard Peripheral Library
STD_PERIPH_LIB=Drivers

# Location of the linker scripts
LDSCRIPT_INC=Device/ldscripts

# location of OpenOCD Board .cfg files (only used with 'make program')
OPENOCD_BOARD_DIR=/usr/share/openocd/scripts/board

# Configuration (cfg) file containing programming directives for OpenOCD
OPENOCD_PROC_FILE=extra/stm32f4-openocd.cfg

# that's it, no need to change anything below this line!

###################################################

CC=arm-none-eabi-gcc
OBJCOPY=arm-none-eabi-objcopy
OBJDUMP=arm-none-eabi-objdump
SIZE=arm-none-eabi-size

#CFLAGS  = -Wall -g -std=c99 -Os  
#CFLAGS += -mlittle-endian -mthumb -mcpu=cortex-m0 -march=armv6s-m
#-mfpu=fpv4-sp-d16 -mfloat-abi=hard
#CFLAGS += -mcpu=cortex-m4 -mthumb -mlittle-endian  -mthumb-interwork
#CFLAGS += -DUSE_STDPERIPH_DRIVER -DSTM32F4XX -DSTM32F401xE


CFLAGS  = -ggdb -O0 -Wall -Wextra -Warray-bounds
CFLAGS += -mcpu=cortex-m4 -mthumb -mlittle-endian -mthumb-interwork
CFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
CFLAGS += -DUSE_STDPERIPH_DRIVER -DSTM32F4XX -DSTM32F401xE
CFLAGS += -ffunction-sections -fdata-sections
CFLAGS += -Wl,--gc-sections -Wl,-Map=$(PROJ_NAME).map

###################################################

vpath %.c src
vpath %.a $(STD_PERIPH_LIB)

ROOT=$(shell pwd)

CFLAGS += -I src -I $(STD_PERIPH_LIB) -I $(STD_PERIPH_LIB)/CMSIS/Device/ST/STM32F4xx/Include
CFLAGS += -I $(STD_PERIPH_LIB)/CMSIS/Include -I $(STD_PERIPH_LIB)/STM32F4xx_HAL_Driver/Inc -I config
CFLAGS += -include $(STD_PERIPH_LIB)/stm32f4xx_hal_conf.h

SRCS += Device/startup_stm32f401xe.s # add startup file to build

# need if you want to build with -DUSE_CMSIS 
#SRCS += stm32f0_discovery.c
#SRCS += stm32f0_discovery.c stm32f0xx_it.c

# FreeRTOS
FREERTOS_BASE = FreeRTOS
SRCS += \
	$(FREERTOS_BASE)/portable/GCC/ARM_CM4F/port.c \
	$(FREERTOS_BASE)/portable/MemMang/heap_4.c \
  $(FREERTOS_BASE)/croutine.c \
	$(FREERTOS_BASE)/event_groups.c \
	$(FREERTOS_BASE)/list.c \
	$(FREERTOS_BASE)/queue.c \
	$(FREERTOS_BASE)/tasks.c \
	$(FREERTOS_BASE)/timers.c \
	$(FREERTOS_BASE)/CMSIS_RTOS/cmsis_os.c
CFLAGS += -I $(FREERTOS_BASE)/include -I $(FREERTOS_BASE)/portable/GCC/ARM_CM4F -I $(FREERTOS_BASE)/CMSIS_RTOS -I .

OBJS = $(SRCS:.c=.o)

###################################################

.PHONY: lib proj

all: lib proj

lib:
	$(MAKE) -C $(STD_PERIPH_LIB)

proj: 	$(PROJ_NAME).elf

$(PROJ_NAME).elf: $(SRCS)
	$(CC) $(CFLAGS) $^ -o $@ -L$(STD_PERIPH_LIB) -lstmf4 -L$(LDSCRIPT_INC) -Tnucleo.ld -g
	$(OBJCOPY) -O ihex $(PROJ_NAME).elf $(PROJ_NAME).hex
	$(OBJCOPY) -O binary $(PROJ_NAME).elf $(PROJ_NAME).bin
	$(OBJDUMP) -St $(PROJ_NAME).elf >$(PROJ_NAME).lst
	$(SIZE) $(PROJ_NAME).elf
	
clean:
	find ./ -name '*~' | xargs rm -f	
	rm -f *.o
	rm -f $(PROJ_NAME).elf
	rm -f $(PROJ_NAME).hex
	rm -f $(PROJ_NAME).bin
	rm -f $(PROJ_NAME).map
	rm -f $(PROJ_NAME).lst

reallyclean: clean
	$(MAKE) -C $(STD_PERIPH_LIB) clean
