/*
 * u02_08.s
 *
 * assemble and link with:
 * as -g -o u02_08.o u02_08.s
 * ld -o u02_08 u02_08.o
 */

.global _start
_start:
	/* 1a) */
	mov	r1, #432
	mov	r2, #177
	add	r0, r1, r2
	/*
	 * r0 will be 609 here but using `echo $?` gives 97 because
	 * binary representation of 609 is
	 * 00000000 00000000 00000010 01100001
	 *                            01100001
	 * but syscall exit just uses 8 bit (see exit(2))
	 * -> 01100001 -> 97
	 */

_exit:
	/* syscall exit with status r0 */
	mov	r7, #1
	svc	0
