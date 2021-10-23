/*
 * u04_04_aus.s
 *
 * assemble and link with:
 * as -g -o led_d7_aus.o u04_04_aus.s
 * ld -o led_d7_aus.elf led_d7_aus.o -T ../lib/stm32f1.ld
 *
 * start with:
 * openocd -f interface/stlink-v2-1.cfg -f target/stm32f1x.cfg -c "program led_d7_aus.elf verify reset exit"
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
	 * base reset and clock control RCC address: 0x40021000
	 * RCC_APB2ENR offset: 0x18
	 * -> 0x40021018
	 */
	ldr	r1, =0x40021018		@ RCC_APB2ENR address
	ldr	r0, [r1]		@ load previous register value
	orr	r0, #0b100		@ enable GPIO port A (IOPAEN)
	str	r0, [r1]		@ store new register value

	/*
	 * configure port configuration register high (GPIOx_CRH)
	 *
	 * base GPIO port A address: 0x40010800
	 * GPIOx_CRH offset: 0x04
	 * -> 0x40010804
	 */
	ldr	r1, =0x40010804		@ GPIOx_CRH address
	ldr	r0, [r1]		@ load previous register value
	and	r0, #0xfffffff0		@ reset CNF8 and MODE8
	orr	r0, #0b0011		@ set CNF8 to 00 and MODE8 to 11
	str	r0, [r1]		@ -> pin 8 general purpose output push-pull, max speed 50 MHz

	/*
	 * update pin output value using port bit set/reset register
	 * (GPIOx_BSRR)
	 *
	 * base GPIO port A address: 0x40010800
	 * GPIOx_BSRR offset: 0x10
	 * -> 0x40010810
	 */
	ldr	r1, =0x40010810		@ GPIOx_BSRR address
	mov	r0, #1
	lsl	r0, #24
	str	r0, [r1]		@ write 1 to BR8 -> pin 8 reset

loop:
	b	loop
