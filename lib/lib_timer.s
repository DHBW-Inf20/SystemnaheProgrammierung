/*
 * lib_timer.s
 *
 * assemble with:
 * as -g -o lib_timer.o lib_timer.s
 */

.syntax unified
.cpu cortex-m3
.thumb

.include "stm32f103.inc"

TimerValue=45

.text

/**************************************************************************/
/* library:       lib_timer.s                                             */
/* description:   Provides functions for waiting on a NUCLEO-F103RB       */
/*                board (using r10 for keeping track of time    )         */
/*                function SysTick_Handler: handles timer interrupts      */
/*                function delay_s: delays for n seconds                  */
/*                function delay_ms: delays for n milliseconds            */
/*                function delay_times_5us: delays for n * 5 microseconds */
/*                function delay_5us: delays for 5 microseconds           */
/*                function StartSysTick: configures timer                 */
/* depends on:    -                                                       */
/**************************************************************************/

.type SysTick_Handler, %function
.global SysTick_Handler
SysTick_Handler:
	/******************************************/
	/* function:    SysTick_Handler           */
	/* description: handles timer interrupts  */
	/******************************************/
	/* input:  -                              */
	/* output: r0: used here, will be garbage */
	/******************************************/
	ldr	r0, =SCS
	ldr	r0, [r0, #SCS_SYST_CSR]
	tst	r0, #0x10000
	beq	SysTick_Handler_Exit
	sub	r10, #1
SysTick_Handler_Exit:
	bx	lr



.type delay_s, %function
.global delay_s
delay_s:
	/***********************************************/
	/* function:    delay_s                        */
	/* description: delays execution for n seconds */
	/***********************************************/
	/* input:  r0: n                               */
	/* output: r0: will be garbage                 */
	/***********************************************/
	mov	r10, #1000
	mul	r0, r10
	b	delay_ms



.type delay_ms, %function
.global delay_ms
delay_ms:
	/****************************************************/
	/* function:    delay_ms                            */
	/* description: delays execution for n milliseconds */
	/****************************************************/
	/* input:  r0: n                                    */
	/* output: r0: will be garbage                      */
	/****************************************************/
	mov	r10, #200
	mul	r10, r0
	b	delay_5us



.type delay_times_5us, %function
.global delay_times_5us
delay_times_5us:
	/********************************************************/
	/* function:    delay_times_5us                         */
	/* description: delays execution for n * 5 microseconds */
	/********************************************************/
	/* input:  r0: n                                        */
	/* output: r0: will be garbage                          */
	/********************************************************/
	mov	r10, r0
	b	delay_5us



.type delay_5us, %function
.global delay_5us
delay_5us:
	/****************************************************/
	/* function:    delay_5us                           */
	/* description: delays execution for 5 microseconds */
	/****************************************************/
	/* input:  -                                        */
	/* output: -                                        */
	/****************************************************/
	cmp	r10, #0
	bgt	delay_5us
	bx 	lr



/* r0 = Count-Down value for timer */
.type StartSysTick, %function
.global StartSysTick
StartSysTick:
	/******************************************************/
	/* function:    StartSysTick                          */
	/* description: configures the timer, call before you */
	/*              call other functions of this lib      */
	/******************************************************/
	/* input:  -                                          */
	/* output: r0: used here, will be garbage             */
	/*         r1: used here, will be garbage             */
	/******************************************************/
	ldr	r0, =TimerValue
	ldr	r1, =SCS

	str	r0, [r1, #SCS_SYST_RVR]

	/* ldr r0, =0 */
	str	r0, [r1, #SCS_SYST_CVR]

	ldr	r0, =7
	str	r0, [r1, #SCS_SYST_CSR]

	bx 	lr
