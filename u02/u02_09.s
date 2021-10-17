/*
 * u02_09.s
 *
 * assemble and link with:
 * as -g -o u02_09.o u02_09.s
 * ld -o u02_09 u02_09.o
 */
 
.global _start
_start:
	/* 1c) */
	mov	r1, #543
	mov	r2, #432
	sub	r0, r1, r2
	/* r0 will be 111 (decimal) here */

	/* 1d) */
	mov	r1, #432
	mov	r2, #543
	sub	r0, r1, r2
	/*
	 * r0 will be 0xffffff91 = 11111111 11111111 11111111 10010001
	 * here, which interpreted as two's complement is -111
	 */

_exit:
	/* syscall exit with status r0 */
	mov	r7, #1
	svc	0
