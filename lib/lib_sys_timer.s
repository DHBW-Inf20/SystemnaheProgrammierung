/*
 * lib_sys_timer.s
 *
 * assemble with:
 * as -g -o lib_sys_timer.o lib_sys_timer.s
 */

.syntax unified
.cpu cortex-m3
.thumb

/******************************************************************/
/* library:       lib_sys_timer.s                                 */
/* description:   Provides functions for waiting on NUCLEO-F103RB */
/*                function wait_ca_1us: waits ca. 1 microsecond   */
/*                function wait_ca_1ms: waits ca. n milliseconds  */
/*                function wait_ca_1s: waits ca. n seconds        */
/* depends on:    -                                               */
/******************************************************************/

.global wait_ca_1us
wait_ca_1us:
	/*************************************************************/
	/* function:    wait_ca_1us                                  */
	/* description: waits for ca. 1 microsecond before returning */
	/*************************************************************/
	/* input:  -                                                 */
	/* output: -                                                 */
	/*************************************************************/
	/* no loop needed, this takes ca. 1 microsecond on our NUCLEO */
	bx	lr



.global wait_ca_1ms
wait_ca_1ms:
	/**************************************************************/
	/* function:    wait_ca_1ms                                   */
	/* description: waits for ca. n milliseconds before returning */
	/**************************************************************/
	/* input:  r0: n (milliseconds to wait)                       */
	/* output: r0: preserves input                                */
	/**************************************************************/
	push	{r0,r1,lr}

outer_ms_loop:
	mov	r1, #1135

inner_ms_loop:
	bl	wait_ca_1us
	subs	r1, #1
	bne	inner_ms_loop

	subs	r0, #1
	bne	outer_ms_loop

	pop	{r0,r1,lr}
	bx	lr



.global wait_ca_1s
wait_ca_1s:
	/*********************************************************/
	/* function:    wait_ca_1s                               */
	/* description: waits for ca. n seconds before returning */
	/*********************************************************/
	/* input:  r0: n (seconds to wait)                       */
	/* output: r0: preserves input                           */
	/*********************************************************/
	push	{r0,r1,lr}

	mov	r1, #1000
	mul	r0, r1
	bl	wait_ca_1ms

	pop	{r0,r1,lr}
	bx	lr
