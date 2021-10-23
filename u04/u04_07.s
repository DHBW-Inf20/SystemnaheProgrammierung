/*
 * u04_07.s
 *
 * assemble and link with (might require assembling lib_gpio.s first):
 * as -g -o led_d2_d7_d13_an.o u04_07.s
 * ld -o led_d2_d7_d13_an.elf led_d2_d7_d13_an.o ../lib/lib_gpio.o -T ../lib/stm32f1.ld
 *
 * start with:
 * openocd -f interface/stlink-v2-1.cfg -f target/stm32f1x.cfg -c "program led_d2_d7_d13_an.elf verify reset exit"
 */

.syntax unified
.cpu cortex-m3
.thumb

.word 0x20000400
.word 0x080000ed
.space 0xe4

.global _start
_start:
	mov	r0, #0	@ port A

	bl	port_open


	/* D13 */
	mov	r1, #5	@ pin 5

	mov	r2, #1	@ output
	bl	gpio_init

	mov	r2, #1	@ set
	bl	gpio_set


	/* D7 */
	mov	r1, #8	@ pin 8

	mov	r2, #1	@ output
	bl	gpio_init

	mov	r2, #1	@ set
	bl	gpio_set


	/* D2 */
	mov	r1, #10	@ pin 10

	mov	r2, #1	@ output
	bl	gpio_init

	mov	r2, #1	@ set
	bl	gpio_set

loop:
	b	loop
