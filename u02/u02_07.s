/*
 * u02_07.s
 *
 * assemble and link with:
 * as -g -o u02_07.o u02_07.s
 * ld -o u02_07 u02_07.o
 */

.global _start
_start:
	mov	r1, #32
	mov	r2, #49
	add	r0, r1, r2
	/* r0 will be 81 here */

_exit:
	mov	r7, #1		@ Linux syscall number 1 -> exit

	/*
	 * SuperVisor Call:
	 *
	 * causes exception (processer mode switches to Supervisor (aka
	 * kernel mode))
	 * Linux kernel interprets this as a system call and takes the
	 * system call number from r7
	 *
	 * r0-r6 are used as arguments 1-7 to the system call
	 * -> exit takes 8 least significant bits of r0 (see exit(2))
	 *
	 * see syscall(2)
	 */
	svc	0		@ exactly the same as `swi 0`, svc is the newer mnemonic
