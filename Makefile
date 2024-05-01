AS = arm-none-eabi-as
LL = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy
RM = rm -f

LD_SCRIPT = stm32.ld

# Flags
ASFLAGS = -mcpu=cortex-m3
LFLAGS = -v -T$(LD_SCRIPT) -nostartfiles


.PHONY: all flash clean

all: blinky.bin

flash: blinky.bin
	st-flash write blinky.bin 0x08000000

blinky.bin: blinky.elf
	$(OBJCOPY) -O binary blinky.elf blinky.bin

blinky.elf: blinky.o
	$(LL) $(LFLAGS) blinky.o -o blinky.elf

blinky.o: blinky.s
	$(AS) $(ASFLAGS) blinky.s -o blinky.o

clean:
	$(RM) blinky.bin blinky.elf blinky.o

