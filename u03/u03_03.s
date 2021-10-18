/*
 * u03_03.s
 *
 * assemble and link with:
 * as -g -o u03_03.o u03_03.s
 * ld -o u03_03 u03_03.o
 */

.global _start
_start:
	/* 1h) */
	mov	r0, #857
	mov	r1, #17
	bl	div_r0_by_r1
	/* r0 will be 50 and r1 will be 7 here */

_exit:
	/* syscall exit with status r0 */
	mov	r7, #1
	svc	0



div_r0_by_r1:
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
