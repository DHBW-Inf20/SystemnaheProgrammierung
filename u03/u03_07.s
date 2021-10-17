/*
 * u03_07.s
 *
 * assemble and link with:
 * gcc -g -o u03_07 u03_07.s lib_math.s
 */

.global main
main:
	ldr	r0, =first_input	@ pass format in r0
	bl	printf			@ libc call

	/*
	 * push/pop use a full ascending stack
	 * -> to let scanf correctly write to stack decrement sp first
	 */
	sub	sp, sp, #4		@ decrement sp for scanf
	ldr	r0, =input_format	@ pass format in r0
	mov	r1, sp			@ pass sp as scan target pointer
	bl	scanf			@ libc call

	ldr	r0, =second_input	@ pass format in r0
	bl	printf			@ libc call

	sub	sp, sp, #4		@ decrement sp for scanf
	ldr	r0, =input_format	@ pass format in r0
	mov	r1, sp			@ pass sp as scan target pointer
	bl	scanf			@ libc call

	/* multiply */
	pop	{r1}			@ pop second input to r1
	pop	{r0}			@ pop first input to r0
	push	{r0, r1}		@ save inputs for later
	mov	r3, r0			@ store first input in r3
	mov	r2, r1			@ pass second input in r2

	bl	mult_r0_by_r1

	mov	r1, r3			@ pass first input (r3) in r1
	mov	r3, r0			@ pass result in r3
	ldr	r0, =mult_string	@ pass format in r0

	bl	printf			@ libc call

	/* divide */
	pop	{r0, r1}		@ restore inputs
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


first_input:
	.asciz	"Enter first number (>= 0): "

second_input:
	.asciz	"Enter second number (> 0): "

input_format:
	.asciz	"%d"

mult_string:
	.asciz	"%d * %d = %d\n"

div_string:
	.asciz	"%d / %d = %d R %d\n"
