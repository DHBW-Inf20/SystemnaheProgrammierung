/*
 * lib_gpio.s
 *
 * assemble with:
 * as -g -o lib_gpio.o lib_gpio.s
 */

.syntax unified
.cpu cortex-m3
.thumb

.word 0x20000400
.word 0x080000ed
.space 0xe4

/***********************************************************************/
/* library:       lib_gpio.s                                           */
/* description:   TODO Provides mathematical functions                      */
/*                function mult_r0_by_r1: multiplies two numbers       */
/*                function div_r0_by_r1: divides one number by another */
/* depends on:    -                                                    */
/***********************************************************************/

.global port_open
port_open:
	/********************************************************************************/
	/* function:    mult_r0_by_r1                                                   */
	/* description: multiplies the values in r0 and r1 and returns the result in r0 */
	/********************************************************************************/
	/* input:  r0: multiplier (how many times to add)                               */
	/*         r1: multiplicand (what to add)                                       */
	/* output: r0: product of multiplicand and multiplier                           */
	/* helper: r2 (no need to save, is saved on the stack in this function)         */
	/********************************************************************************/
	push	{r1-r3}
	/*
	 * configure APB2 peripheral clock enable register (RCC_APB2ENR)
	 *
	 * base RCC address: 0x40021000
	 * RCC_APB2ENR offset: 0x18
	 * -> 0x40021018
	 */
	ldr	r1, =0x40021018		@ base address
	ldr	r2, [r1]
	mov	r3, #0b100
	lsl	r3, r3, r0
	orr	r2, r2, r3
	str	r2, [r1]

	pop	{r1-r3}
	bx	lr



.global gpio_init
gpio_init:
	push	{r3-r5}

	/* Port offset -> Ports are 0x400 apart */
	mov	r3, #0x400
	mul	r4, r0, r3		@ r0 is Port number (A = 0, ...)
	/*
	 * configure Port configuration register low/high (GPIOx_CRL/GPIOx_CRH)
	 *
	 * base GPIO Port A address: 0x40010800
	 * -> add Port offset in r4 and optional high offset
	 */
	ldr	r3, =0x40010800		@ base address
	add	r3, r3, r4
	/* if Pin number > 8 high else low */
	cmp	r1, #8
	blt	skip_high
	add	r3, r3, #0x04		@ extra high offset
skip_high:
	/* final GPIOx_CRL/GPIOx_CRH address is in r3 */

	/*
	 * low/high is set (stored in r3)
	 * -> only care about last 3 bits of Pin number
	 * -> multiply by 4, use as shift distance
	 */
	and	r1, r1, #0b111
	mov	r5, #4
	mul	r1, r1, r5

	ldr	r4, [r3]		@ load previous register value

	mvn	r0, #0b1111		@ invert mask
	mov	r5, #32
	sub	r5, r5, r1		@ 32 - bits to rotate left
	ror	r0, r0, r5		@ to make left rotate with ror

	and	r4, r4, r0		@ reset CNF and MODE for Pin

	cmp	r2, #0			@ 0 = input, 1 = output
input:
	bne	output
	mov	r0, #0b0100
	b	change_cnf_and_mode
output:
	mov	r0, #0b0001

change_cnf_and_mode:
	lsl	r0, r0, r1		@ shift CNF and MODE to position
	orr	r4, r4, r0

	str	r4, [r3]		@ store new register value

	pop	{r3-r5}
	bx	lr



.global gpio_set
gpio_set:
	push	{r3-r5}

	/* Port offset -> Ports are 0x400 apart */
	mov	r3, #0x400
	mul	r4, r0, r3		@ r0 is Port number (A = 0, ...)
	/*
	 * change Port bit set/reset register (GPIOx_BSRR)
	 *
	 * base GPIO Port A address: 0x40010800
	 * GPIOx_BSRR offset: 0x10
	 * -> 0x40010810
	 * -> add Port offset in r4
	 */
	ldr	r3, =0x40010810		@ base address
	add	r3, r3, r4
	/* final GPIOx_BSRR address is in r3 */

	ldr	r4, [r3]		@ load previous register value

	mvn	r0, 0x10001		@ invert mask
	mov	r5, #32
	sub	r5, r5, r1		@ 32 - bits to rotate left
	ror	r0, r0, r5		@ to make left rotate with ror

	and	r4, r4, r0		@ set and reset bit to 0 for Pin

	mov	r0, #1
	mov	r0, r0, lsl r1		@ shift to Pin number
	cmp	r2, #0			@ 0 = reset, 1 = set
	bne	change_set_or_reset	@ no extra shift for set
	lsl	r0, r0, #16		@ extra 16 bit shift for reset

change_set_or_reset:
	orr	r4, r4, r0

	str	r4, [r3]		@ store new register value

	pop	{r3-r5}
	bx	lr
