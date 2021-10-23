/*
 * lib_gpio.s
 *
 * assemble with:
 * as -g -o lib_gpio.o lib_gpio.s
 */

.syntax unified
.cpu cortex-m3
.thumb

/************************************************************************/
/* library:       lib_gpio.s                                            */
/* description:   Provides functions for handling GPIO of NUCLEO-F103RB */
/*                function port_open: enables IO port clock             */
/*                function gpio_init: configures pin                    */
/*                function gpio_set: sets output of pin                 */
/* depends on:    -                                                     */
/************************************************************************/

.global port_open
port_open:
	/**************************************************************/
	/* function:    port_open                                     */
	/* description: enables the clock for the specified IO port   */
	/**************************************************************/
	/* input:  r0: port (A: 0, B: 1, ...), must be >= 0 and <= 4  */
	/*             otherwise this function has no effect          */
	/* output: r0: preserves input                                */
	/**************************************************************/
	/* check parameter */
	push	{lr}
	bl	check_port		@ failed check will return early
	pop	{lr}

	/* begin function */
	push	{r1-r3}

	/*
	 * configure APB2 peripheral clock enable register (RCC_APB2ENR)
	 */

	/*
	 * base reset and clock control RCC address: 0x40021000
	 * RCC_APB2ENR offset: 0x18
	 * -> 0x40021018
	 */
	ldr	r1, =0x40021018		@ RCC_APB2ENR address
	ldr	r2, [r1]		@ load previous register value

	mov	r3, #0b100		@ bitmask, ports start at bit 2
	lsl	r3, r0			@ shift mask by port number
	orr	r2, r3			@ enable clock for port

	str	r2, [r1]		@ store new register value

	/* end function and return */
	pop	{r1-r3}
	bx	lr



.global gpio_init
gpio_init:
	/***************************************************************************/
	/* function:    gpio_init                                                  */
	/* description: configures the specified GPIO pin as an input/output pin   */
	/***************************************************************************/
	/* input:  r0: port the pin belongs to (A: 0, B: 1, ...),                  */
	/*             must be >= 0 and <= 4 otherwise this function has no effect */
	/*         r1: pin, must be >= 0 and <= 15                                 */
	/*             otherwise this function has no effect                       */
	/*         r2: mode, 0 for floating input, anything else for general       */
	/*             purpose output push-pull, max speed 50 MHz                  */
	/* output: r0: preserves input                                             */
	/*         r1: preserves input                                             */
	/*         r2: preserves input                                             */
	/***************************************************************************/
	/* check parameters */
	push	{lr}
	bl	check_port
	bl	check_pin		@ failed check will return early
	pop	{lr}

	/* begin function */
	push	{r0-r5}

	/*
	 * configure port configuration register low/high
	 * (GPIOx_CRL/GPIOx_CRH)
	 */

	/*
	 * base GPIO port A address: 0x40010800
	 * -> add port offset and optional GPIOx_CRH offset (0x04)
	 */
	ldr	r3, =0x40010800		@ base GPIO port A address

	mov	r4, #0x400		@ ports are 0x400 bytes apart
	mul	r4, r0			@ times port number -> offset
	add	r3, r4			@ add port offset to base

	cmp	r1, #8			@ pin >= 8 -> high else low
	it	ge			@ if high
	addge	r3, #0x04		@   add GPIOx_CRH offset to base
	/* final GPIOx_CRL/GPIOx_CRH address is now in r3 */

	/*
	 * we now know whether we have a low or high pin (address in r3)
	 * -> only care about last 3 bits of pin number from here on
	 *    (low and high configuration registers both have
	 *    configurations for 8 = 2^3 pins)
	 * -> multiply by 4 to use as shift distance later
	 *    (each pin has 4 configuration bits)
	 */
	and	r1, #0b111		@ only keep 3 bits
	mov	r0, #4
	mul	r1, r0			@ times 4 for use in shifts

	/* load previous register value */
	ldr	r4, [r3]

	/*
	 * reset previous CNF and MODE for pin by using a bitmask with
	 * 4 unset bits rotated into position using ror with adjusted
	 * shift distance to simulate left rotation
	 * left shift distance is r1
	 */
	mvn	r0, #0b1111		@ all bits set except last 4
	mov	r5, #32
	sub	r5, r1			@ 32 - bits to rotate left
	ror	r0, r5			@ -> left rotation with ror
	and	r4, r0			@ reset CNF and MODE for pin

	/*
	 * set new CNF and MODE for pin based on function parameter r2
	 *                     r2                      | CNF | MODE
	 * input -> floating input                     |  01 |  00
	 * output -> general purpose output push-pull, |  00 |  11
	 *           max speed 50 MHz                  |     |
	 */
	cmp	r2, #0			@ 0 -> input else output
	ite	eq			@ if input
	moveq	r0, #0b0100		@   input configuration
	movne	r0, #0b0011		@ else output configuration
	lsl	r0, r1			@ shift CNF and MODE to position
	orr	r4, r0			@ set new CNF and MODE for pin

	/* store new register value */
	str	r4, [r3]

	/* end function and return */
	pop	{r0-r5}
	bx	lr



.global gpio_set
gpio_set:
	/***************************************************************************/
	/* function:    gpio_set                                                   */
	/* description: sets the output value of the specified GPIO pin            */
	/***************************************************************************/
	/* input:  r0: port the pin belongs to (A: 0, B: 1, ...),                  */
	/*             must be >= 0 and <= 4 otherwise this function has no effect */
	/*         r1: pin, must be >= 0 and <= 15                                 */
	/*             otherwise this function has no effect                       */
	/*         r2: value, 0 to reset, anything else to set                     */
	/* output: r0: preserves input                                             */
	/*         r1: preserves input                                             */
	/*         r2: preserves input                                             */
	/***************************************************************************/
	/* check parameters */
	push	{lr}
	bl	check_port
	bl	check_pin		@ failed check will return early
	pop	{lr}

	/* begin function */
	push	{r0-r2}

	/*
	 * update pin output value using port bit set/reset register
	 * (GPIOx_BSRR)
	 */

	/*
	 * adjust pin number by 16 if pin should be reset
	 * (reset bits in GPIOx_BSRR have an offset of 16)
	 */
	cmp	r2, #0			@ 0 -> reset else set
	it	eq			@ if reset
	addeq	r1, #16			@   add 16 to pin number

	/* port offset */
	mov	r2, #0x400		@ ports are 0x400 bytes apart
	mul	r0, r2			@ times port number -> offset

	/*
	 * base GPIO port A address: 0x40010800
	 * GPIOx_BSRR offset: 0x10
	 * -> 0x40010810
	 * -> add port offset
	 */
	ldr	r2, =0x40010810		@ base adjusted address
	add	r2, r0			@ add port offset to base
	/* final GPIOx_BSRR address is now in r3 */

	/*
	 * write to BSx/BRx, no need to save previous values,
	 * GPIOx_BSRR is a write-only register
	 */
	mov	r0, #1
	lsl	r0, r1			@ shift by adjusted pin number
	str	r0, [r2]		@ set/reset pin

	/* end function and return */
	pop	{r0-r2}
	bx	lr



check_port:
	/* port has to be in range 0-4 (A-E) */

	cmp	r0, #0		@ port less than 0?
	itt	lt		@ |
	poplt	{lr}		@ v
	bxlt	lr		@ return early from caller

	cmp	r0, #4		@ port greater than 4?
	itt	gt		@ |
	popgt	{lr}		@ v
	bxgt	lr		@ return early from caller

	bx	lr		@ ok

check_pin:
	/* pin has to be in range 0-15 */

	cmp	r1, #0		@ pin less than 0?
	itt	lt		@ |
	poplt	{lr}		@ v
	bxlt	lr		@ return early from caller

	cmp	r1, #15		@ pin greater than 15?
	itt	gt		@ |
	popgt	{lr}		@ v
	bxgt	lr		@ return early from caller

	bx	lr		@ ok
