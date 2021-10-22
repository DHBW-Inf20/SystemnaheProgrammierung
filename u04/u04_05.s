/*
 * u04_05.s
 *
 * assemble and link with:
 * as -g -o u04_05.o u04_05.s
 * ld -o u04_05.elf u04_05.o ../lib/lib_gpio.o -T ../lib/stm32f1.ld
 *
 * start with:
 * openocd -f interface/stlink-v2-1.cfg -f target/stm32f1x.cfg -c "program u04_05.elf verify reset exit"
 */

.syntax unified
.cpu cortex-m3
.thumb

.word 0x20000400
.word 0x080000ed
.space 0xe4

.global _start
_start:
	mov	r0, #0	@ Port A
	bl	port_open

	mov	r0, #0	@ Port A
	mov	r1, #8	@ Pin 8
	mov	r2, #1	@ Output
	bl	gpio_init

	mov	r0, #0	@ Port A
	mov	r1, #8	@ Pin 8
	mov	r2, #1	@ set
	bl	gpio_set

loop:
	b	loop
