/*
 * u02_10.s
 *
 * assemble and link with:
 * as -g -o u02_10.o u02_10.s
 * ld -o u02_10 u02_10.o
 */
 
.global _start
_start:
	mov	r1, #140
	mov	r2, #204
	mov	r3, #251

	push	{r1}
	push	{r2}
	push	{r3}

	pop	{r4}
	pop	{r5}

	ldr	r0, [sp]
	/*
	 * r0 will be 140 here
	 * -> stack strategy 'full' (sp points to top element) but this
	 *    does not tell anything about ascending/descending
	 */

_exit:
	/* syscall exit with status r0 */
	mov	r7, #1
	svc	0
