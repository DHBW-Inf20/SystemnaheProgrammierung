/*
 * u02_12.s
 *
 * assemble and link with:
 * as -g -o u02_12.o u02_12.s
 * ld -o u02_12 u02_12.o
 */

.global _start
_start:
	mov	r0, #140
	mov	r1, #204
	mov	r2, #251

	/*
	 *
	 * default stm stack strategy is ia/ea because
	 * - sp increases
	 *   -> incrementing/ascending
	 * - ldr r4 [sp] gives garbage
	 *   -> after/empty
	 *
	 * default ldm stack strategy is ia/fd because
	 * - sp increases
	 *   -> incrementing/descending ('reverse' store -> descending)
	 * - ```
	 *   mov    r0, #42
	 *   stmia  sp, {r1}   @ do NOT change sp
	 *   ldm    sp!, {r1}
	 *   ```
	 *   gives 42 in r1 at end -> after/full
	 *
	 *
	 * both stm and ldm always (indipendent of stack strategy)
	 * store/load register with lower number to/from lower memory
	 * address and register with higher number to/from higher memory
	 * address
	 *
	 *
	 * here:
	 * default strategy for stm -> increment sp after each store
	 * ea strategy for ldm -> decrement sp before each load
	 * step by step:
	 *  store r0 to address in sp and increment sp
	 *  store r1 to address in sp and increment sp
	 *  store r2 to address in sp and increment sp
	 *  decrement sp and load r3 from address in sp
	 *  decrement sp and load r4 from address in sp
	 *  decrement sp and load r5 from address in sp
	 */
	stm	sp!, {r0-r2}	@ or stmia/stmea
	ldmea	sp!, {r3-r5}	@ or ldmdb

_exit:
	/* syscall exit with status r0 */
	mov	r7, #1
	svc	0
