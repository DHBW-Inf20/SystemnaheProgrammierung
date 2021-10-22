/*
 * u04_04.s
 *
 * assemble and link with:
 * as -g -o led_d7_an.o u04_04.s
 * ld -o led_d7_an.elf led_d7_an.o -T ../lib/stm32f1.ld
 *
 * start with:
 * openocd -f interface/stlink-v2-1.cfg -f target/stm32f1x.cfg -c "program led_d7_an.elf verify reset exit"
 */

.syntax unified
.cpu cortex-m3
.thumb

.word 0x20000400
.word 0x080000ed
.space 0xe4

.global _start
_start:
	/*
	 * configure APB2 peripheral clock enable register (RCC_APB2ENR)
	 *
	 * base RCC address: 0x40021000
	 * RCC_APB2ENR offset: 0x18
	 * -> 0x40021018
	 */
	ldr	r1, =0x40021018		@ load address
	ldr	r0, [r1]
	orr	r0, r0, #0b100		@ bit 2: enable GPIO Port A (IOPAEN)
	str	r0, [r1]		@ -> GPIOA enabled

	/*
	 * configure Port configuration register high (GPIOx_CRH)
	 *
	 * base GPIO Port A address: 0x40010800
	 * GPIOx_CRH offset: 0x04
	 * -> 0x40010804
	 */
	ldr	r1, =0x40010804		@ load address
	ldr	r0, [r1]
	and	r0, #0xfffffff0		@ reset CNF8 and MODE8
	orr	r0, #0b0001		@ set CNF8 to 00 and MODE8 to 01
	str	r0, [r1]		@ -> Port 8 push-pull general purpose output, max speed 10 MHz

	/*
	 * change Port bit set/reset register (GPIOx_BSRR)
	 *
	 * base GPIO Port A address: 0x40010800
	 * GPIOx_BSRR offset: 0x10
	 * -> 0x40010810
	 */
	ldr	r1, =0x40010810		@ load address
	mov	r2, #1
	mov	r0, r2, lsl #8		@ set bit 8 (BS8) to 1
	str	r0, [r1]		@ -> Port 8 set

loop:
	b	loop
