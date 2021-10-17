/*
 * u02_11.s
 *
 * assemble and link with:
 * as -g -o u02_11.o u02_11.s
 * ld -o u02_11 u02_11.o
 */

.global _start
_start:
	mov	r0, #140
	mov	r1, #204
	mov	r2, #251

	/*
	 * default stm stack strategy is ia/ea because
	 * - sp increases -> incrementing/ascending
	 * - ldr r4 [sp] gives garbage -> after/empty
	 */
	stm	sp!, {r0-r2}	@ or stmia/stmea
	ldr	r4, [sp]

_exit:
	/* syscall exit with status r0 */
	mov	r7, #1
	svc	0
