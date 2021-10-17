/*
 * u03_06.s
 *
 * assemble and link with:
 * gcc -g -o u03_06 u03_06.s lib_math.s
 */

.global main
main:
	/* 1e) */
	mov	r0, #73
	mov	r1, #25
	mov	r3, r0			@ store first input in r3
	mov	r2, r1			@ pass second input in r2

	bl	mult_r0_by_r1

	mov	r1, r3			@ pass first input (r3) in r1
	mov	r3, r0			@ pass result in r3
	ldr	r0, =mult_string	@ pass format in r0

	bl	printf			@ libc call

	/* 1h) */
	ldr	r0, =dividend		@ gcc workaround as it can't
	ldr	r0, [r0]		@ handle big constants (thumb?)
	mov	r1, #17
	mov	r2, r0			@ store first input in r2
	mov	r3, r1			@ store second input in r3

	bl	div_r0_by_r1

	push	{r1}			@ push (more than 4 parameters)
	mov	r1, r2			@ pass first input in r1
	mov	r2, r3			@ pass second input in r2
	mov	r3, r0			@ pass first result in r3
					@ (second result is on stack)
	ldr	r0, =div_string		@ pass format in r0

	bl	printf			@ libc call

main_exit:
	/* syscall exit with status r0 */
	mov	r0, #0
	mov	r7, #1
	svc	0



mult_string:
	.asciz	"%d * %d = %d\n"

dividend:
	.word	857

div_string:
	.asciz	"%d / %d = %d R %d\n"
