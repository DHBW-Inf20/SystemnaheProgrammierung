/*
 * u03_01.s
 *
 * assemble and link with:
 * as -g -o u03_01.o u03_01.s
 * ld -o u03_01 u03_01.o
 */

.global _start
_start:
	/* 1e) */
	mov	r0, #73
	mov	r1, #25
	bl	mult_r0_by_r1
	mov	r5, r0
	/* r5 will be 1825 here */

	/* 1f) */
	mov	r0, #127
	mov	r1, #7
	bl	mult_r0_by_r1
	mov	r6, r0
	/* r6 will be 889 here */

_exit:
	/* syscall exit with status r0 */
	mov	r7, #1
	svc	0



mult_r0_by_r1:
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
