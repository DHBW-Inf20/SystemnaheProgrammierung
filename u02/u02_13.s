/*
 * u02_13.s
 *
 * assemble and link with:
 * as -g -o u02_13.o u02_13.s
 * ld -o u02_13 u02_13.o
 */

.global _start
_start:
	mov	r0, #0		@ result register
	mov	r1, #73
	mov	r2, #25

multiply_loop:
	add	r0, r0, r1
	subs	r2, r2, #1
	bne	multiply_loop	@ repeat until eq (r2 reaches 0)

_exit:
	/* syscall exit with status r0 */
	mov	r7, #1
	svc	0
