/*
 * lib_math.s
 *
 * assemble with:
 * as -g -o lib_math.o lib_math.s
 */

/***********************************************************************/
/* library:       lib_math.s                                           */
/* description:   Provides mathematical functions                      */
/*                function mult_r0_by_r1: multiplies two numbers       */
/*                function div_r0_by_r1: divides one number by another */
/* depends on:    -                                                    */
/***********************************************************************/

.global mult_r0_by_r1
mult_r0_by_r1:
	/********************************************************************************/
	/* function:    mult_r0_by_r1                                                   */
	/* description: multiplies the values in r0 and r1 and returns the result in r0 */
	/********************************************************************************/
	/* input:  r0: multiplier (how many times to add)                               */
	/*         r1: multiplicand (what to add)                                       */
	/* output: r0: product of multiplicand and multiplier                           */
	/* helper: r2 (no need to save, is saved on the stack in this function)         */
	/********************************************************************************/

	/* begin function and init registers */
	push	{r2}		@ save r2 on stack
	mov	r2, r0		@ use r2 for computing
	mov	r0, #0		@ result register

multiply_loop:
	add	r0, r0, r1
	subs	r2, r2, #1
	bne	multiply_loop	@ repeat until eq (r2 reaches 0)

	/* end function and return */
	pop	{r2}		@ restore r2 from stack
	bx	lr		@ similar to `mov pc, lr`



.global div_r0_by_r1
div_r0_by_r1:
	/***********************************************************************************************/
	/* function:    div_r0_by_r1                                                                   */
	/* description: divides the value in r0 by the value in r1 and returns the result in r0 and r1 */
	/***********************************************************************************************/
	/* input:  r0: dividend, must be positive or 0                                                 */
	/*         r1: divisor, must be positive                                                       */
	/* output: r0: integer quotient of dividend and divisor                                        */
	/*         r1: remainder of division                                                           */
	/* helper: r2, r3, r4, r5 (no need to save, are saved on the stack in this function)           */
	/***********************************************************************************************/

	/* begin function and init registers */
	push	{r2-r5}		@ save r2-r5 on stack
	mov	r2, #0		@ offset
	mov	r3, r0		@ partial dividend
	mov	r4, #0		@ quotient
	mov	r5, #0		@ next bit

check_for_dividend_smaller_divisor:
	cmp	r0, r1
	movlt	r0, #0		@ x / y = 0 R y if x < y
	blt	div_r0_by_r1_exit

/*
 * shift dividend in r3 to right until it is smaller than divisor and
 * then undo last shift
 * -> r3 is smallest partial dividend that is still greater than divisor
 *    r2 is how far r3 was shifted right from r0
 */
first_partial_dividend_loop:
	lsr	r3, r0, r2
	cmp	r3, r1
	addge	r2, r2, #1
	bge	first_partial_dividend_loop
	sub	r2, r2, #1
	lsr	r3, r0, r2

divide_loop:
	/* update quotient */
	lsl	r4, r4, #1	@ multiply previous quotient by 2
	cmp	r3, r1		@ if partial dividend >= divisor
	subge	r3, r3, r1	@   partial dividend -= divisor
	addge	r4, r4, #1	@   quotient++

	/* update offset */
	sub	r2, r2, #1	@ offset--
	cmp	r2, #0		@ if offset < 0 go to end
	blt	move_results_before_exit

	/* update partial dividend */
	lsr	r5, r0, r2	@ bit at offset position in dividend:
	and	r5, r5, #1	@ r5 = (dividend >>> offset) & 1
	lsl	r3, r3, #1	@ r3 <<= 1
	add	r3, r3, r5	@ r3 += r5 -> 'take next bit down'
	b	divide_loop

move_results_before_exit:
	mov	r0, r4
	mov	r1, r3

div_r0_by_r1_exit:
	/* end function and return */
	pop	{r2-r5}		@ restore r2-r5 from stack
	bx	lr		@ similar to `mov pc, lr`
