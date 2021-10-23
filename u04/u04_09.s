/*
 * u04_09.s
 *
 * assemble and link with (might require assembling lib_gpio.s and lib_sys_timer.s first):
 * as -g -o u04_09.o u04_09.s
 * ld -o u04_09.elf u04_09.o ../lib/lib_gpio.o ../lib/lib_sys_timer.o -T ../lib/stm32f1.ld
 *
 * start with:
 * openocd -f interface/stlink-v2-1.cfg -f target/stm32f1x.cfg -c "program u04_09.elf verify reset exit"
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

	mov	r2, #1	@ output

	/* D13 (red) */
	mov	r1, #5	@ pin 5
	bl	gpio_init

	/* D7 (yellow) */
	mov	r1, #8	@ pin 8
	bl	gpio_init

	/* D2 (green) */
	mov	r1, #10	@ pin 10
	bl	gpio_init

	bl	red_off
	bl	yellow_off
	bl	green_off

traffic_light_loop:

	/* red phase */
	bl	red_on
	bl	yellow_off
	bl 	wait_3s

	/* red to green transition */
	bl	yellow_on
	bl	wait_1s

	/* green phase */
	bl	red_off
	bl	yellow_off
	bl	green_on
	bl	wait_3s

	/* green to red transition */
	bl	yellow_on
	bl	green_off
	bl	wait_1s

	b	traffic_light_loop



red_on:
	push	{lr}
	/* D13 */
	mov	r0, #0	@ port A
	mov	r1, #5	@ pin 5
	mov	r2, #1	@ set
	bl	gpio_set
	pop	{pc}

red_off:
	push	{lr}
	/* D13 */
	mov	r0, #0	@ port A
	mov	r1, #5	@ pin 5
	mov	r2, #0	@ reset
	bl	gpio_set
	pop	{pc}

yellow_on:
	push	{lr}
	/* D7 */
	mov	r0, #0	@ port A
	mov	r1, #8	@ pin 8
	mov	r2, #1	@ set
	bl	gpio_set
	pop	{pc}

yellow_off:
	push	{lr}
	/* D7 */
	mov	r0, #0	@ port A
	mov	r1, #8	@ pin 8
	mov	r2, #0	@ reset
	bl	gpio_set
	pop	{pc}

green_on:
	push	{lr}
	/* D2 */
	mov	r0, #0	@ port A
	mov	r1, #10	@ pin 10
	mov	r2, #1	@ set
	bl	gpio_set
	pop	{pc}

green_off:
	push	{lr}
	/* D2 */
	mov	r0, #0	@ port A
	mov	r1, #10	@ pin 10
	mov	r2, #0	@ reset
	bl	gpio_set
	pop	{pc}

wait_3s:
	push	{lr}
	mov	r0, #3
	bl	wait_ca_1s
	pop	{pc}

wait_1s:
	push	{lr}
	mov	r0, #1
	bl	wait_ca_1s
	pop	{pc}
