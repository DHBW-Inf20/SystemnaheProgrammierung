/*
 * u03_05.s
 *
 * assemble and link with (might require assembling lib_math.s first):
 * as -g -o u03_05.o u03_05.s
 * ld -o u03_05 u03_05.o lib_math.o
 */

.global _start
_start:
	/* 1e) */
	mov	r0, #73
	mov	r1, #25
	bl	mult_r0_by_r1
	mov	r3, r0
	/* r3 will be 1825 here */

	/* 1h) */
	mov	r0, #857
	mov	r1, #17
	bl	div_r0_by_r1
	mov	r5, r0
	mov	r6, r1
	/* r5 will be 50 and r6 will be 7 here */

_exit:
	/* syscall exit with status r0 */
	mov	r7, #1
	svc	0
