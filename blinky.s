@       lets try to blink an LED on the discovery stm32 L1 board
@       uses LED on PB7 
@ how to compile and flash:
@  arm-none-eabi-as -mcpu=cortex-m3 blinky.s -o blinky.o
@  arm-none-eabi-gcc -v -T stm32l.ld -nostartfiles -o blinky.elf blinky.o 
@  arm-none-eabi-objcopy -O binary blinky.elf blinky.bin
@ then from st-link (https://github.com/texane/stlink)
@  ./st-flash write ../first_arm/blinky.bin 0x08000000
  
        .thumb
        .syntax unified

@       Equates
        .equ STACKINIT,         0x20005000
        .equ RCC_AHBRSTR,       0x40023810      @ reset register
        .equ RCC_AHBENR,        0x4002381C      @ enable clock
        .equ GPIOB_MODER,       0x40020400      @ port B mode
        .equ GPIOB_OTYPER,      0x40020404      @ type push-pull
        .equ GPIOB_OSPEEDR,     0x40020408      @ port pin clock speed
        .equ GPIOB_PUPDR,       0x4002040C      @ pull-up pull-down
        .equ GPIOB_ODR,         0x40020414      @ output data

        .equ LEDDELAY,          800000

.section .text
        .org 0

@ Vectors
vectors:
        .word STACKINIT
        .word _start + 1 
        .word _nmi_handler + 1 
        .word _hard_fault + 1 
        .word _memory_fault + 1 
        .word _bus_fault + 1 
        .word _usage_fault + 1   

_start:
        ldr r6, = RCC_AHBRSTR
        ldr r5, [r6]
        orr r5, r5, 0x02                @ set GPIOB reset bit 
        str r5, [r6]
        ldr r5, [r6]
        and r5, r5, 0xfffffffd          @ clear GPIO reset bit 
        str r5, [r6]
@ next enable clock on GPIO port B
        ldr r6, = RCC_AHBENR
        ldr r5, [r6]
        orr r5, r5, 0x02
        str r5, [r6]
@ now set port B pin 7 to output
        ldr r6, = GPIOB_MODER   
        ldr r5, [r6]
        and r5, r5, 0xffff3fff          @ clear bits 15 14
                orr r5, r5, 0x00004000          @ set bits 15:14 0 1
        str r5, [r6]
@ type = push-pull
        ldr r6, =GPIOB_OTYPER
        ldr r5, [r6]
        and r5, r5, 0xFFFFFF7F
        str r5, [r6]                    @ clear bit 7
@ speed 400kHz
        ldr r6, =GPIOB_OSPEEDR
        ldr r5, [r6]
        and r5, r5, 0xFFFF3FFF
        str r5, [r6]
@ pull up pull down none
        ldr r6, = GPIOB_PUPDR
        ldr r5, [r6]
        and r5, r5, 0xFFFF3FFF
        str r5, [r6]
@ start blinking
        ldr r6, = GPIOB_ODR
loop:
        ldr r5, [r6]
        and r5, r5, 0xFFFFFF7F          @clear bit 7 turns LED on
        str r5, [r6]
        ldr r1, = LEDDELAY
delay1:
        subs r1, 1
        bne delay1
@ turn off led
        ldr r5, [r6]
        orr r5, r5, 0x00000080
        str r5, [r6]
        ldr r1, = LEDDELAY
delay2:
        subs r1, 1
        bne delay2

        b loop

@ if any int gets triggered, just loop
_dummy:
_nmi_handler:
_hard_fault:
_memory_fault:
_bus_fault:
_usage_fault:
        add r0, 1
        add r1, 1
        b _dummy

