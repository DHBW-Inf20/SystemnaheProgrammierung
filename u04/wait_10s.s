/*
 * wait_10s.s
 *
 * assemble and link with (might require assembling lib_gpio.s and lib_sys_timer.s first):
 * as -g -o wait_10s.o wait_10s.s
 * ld -o wait_10s.elf wait_10s.o ../lib/lib_gpio.o ../lib/lib_sys_timer.o -T ../lib/stm32f1.ld
 *
 * start with:
 * openocd -f interface/stlink-v2-1.cfg -f target/stm32f1x.cfg -c "program wait_10s.elf verify reset exit"
 */

.syntax unified
.cpu cortex-m3
.thumb

.word 0x20000400
.word 0x080000ed
.space 0xe4

.global _start
_start:
	/* D7 */
	mov	r0, #0	@ port A
	mov	r1, #8	@ pin 8

	bl	port_open

	mov	r2, #1	@ output
	bl	gpio_init

	/* LED on */
	mov	r2, #1	@ set
	bl	gpio_set

	/* wait 10 seconds */
	push	{r0}
	mov	r0, #10
	bl	wait_ca_1s
	pop	{r0}

	/* LED off */
	mov	r2, #0	@ reset
	bl	gpio_set

loop:
	b	loop
