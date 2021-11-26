/*
 * lib_lcd.s
 *
 * assemble with:
 * as -g -o lib_lcd.o lib_lcd.s
 */

.syntax unified
.cpu cortex-m3
.thumb

/*************************************************************************/
/* library:       lib_lcd.s                                              */
/* description:   Provides functions for using a HD44780U                */
/*                LCD Controller from a NUCLEO-F103RB board              */
/*                HD44780U - NUCLEO-F103RB pin configuration:            */
/*                VSS - GND                                              */
/*                VDD - 5.0V (+ 1kOhm resistor)                          */
/*                VE  - GND                                              */
/*                RS  - PB9                                              */
/*                R/W - GND                                              */
/*                En  - PB8                                              */
/*                DB4 - PB6                                              */
/*                DB5 - PB5                                              */
/*                DB6 - PB11                                             */
/*                DB7 - PB10                                             */
/*                function EnableLCDClockGPIOB: no need to call directly */
/*                function ConfigureLCDPinsPBx: no need to call directly */
/*                function lcd_init: configures HD44780U                 */
/*                function lcd_enable: no need to call directly          */
/*                function lcd_write: turns on write-mode                */
/*                function lcd_command: turns on command-mode            */
/*                function lcd_send_4bit: no need to call directly       */
/*                function lcd_send_4bit_8: sends 8 bits                 */
/*                function lcd_cursor_line_1_position_0: moves cursor    */
/*                function lcd_cursor_line_2_position_0: moves cursor    */
/*                function lcd_reset: clears display                     */
/* depends on:    lib_gpio.s                                             */
/*                lib_times.s                                            */
/*************************************************************************/

.type EnableLCDClockGPIOB, %function
.global EnableLCDClockGPIOB
EnableLCDClockGPIOB:
	/********************************************************************/
	/* function:    EnableLCDClockGPIOB                                 */
	/* description: enables the clock of the GPIO port used by HD44780U */
	/********************************************************************/
	/* input:  -                                                        */
	/* output: -                                                        */
	/********************************************************************/
	/* begin function */
	push	{r0,lr}

	/* init GPIO */
	mov	r0, #1	@ port B
	bl	port_open

	/* end function and return */
	pop	{r0,lr}
	bx	lr



.type ConfigureLCDPinsPBx, %function
.global ConfigureLCDPinsPBx
ConfigureLCDPinsPBx:
	/**********************************************************/
	/* function:    ConfigureLCDPinsPBx                       */
	/* description: configures the GPIO pins used by HD44780U */
	/**********************************************************/
	/* input:  -                                              */
	/* output: -                                              */
	/**********************************************************/
	/* begin function */
	push	{r0-r2,lr}

	/* init Pins */
	mov	r0, #1	@ port B
	mov	r2, #1	@ output

	/* DB5 */
	mov	r1, #5	@ pin 5
	bl	gpio_init

	/* DB4 */
	mov	r1, #6	@ pin 6
	bl	gpio_init

	/* Enable */
	mov	r1, #8	@ pin 8
	bl	gpio_init

	/* Register Select */
	mov	r1, #9	@ pin 9
	bl	gpio_init

	/* DB7 */
	mov	r1, #10	@ pin 10
	bl	gpio_init

	/* DB6 */
	mov	r1, #11	@ pin 11
	bl	gpio_init

	/* end function and return */
	pop	{r0-r2,lr}
	bx	lr



.global lcd_init
lcd_init:
	/*******************************************************/
	/* function:    lcd_init                               */
	/* description: configures the HD44780U LCD Controller */
	/*              and turns on write-mode                */
	/*******************************************************/
	/* input:  -                                           */
	/* output: -                                           */
	/*******************************************************/
	/* begin function */
	push	{r0,lr}

	/* configure GPIO */
	bl	EnableLCDClockGPIOB
	bl	ConfigureLCDPinsPBx

	/* set up command-mode */
	bl	lcd_command

	/* wait 15 ms */
	mov	r0, #15
	bl	delay_ms

	mov	r0, #0b0011
	bl	lcd_send_4bit

	/* wait 5 ms */
	mov	r0, #5
	bl	delay_ms

	mov	r0, #0b0011
	bl	lcd_send_4bit

	/* wait 100 us */
	mov	r0, #20
	bl	delay_times_5us

	mov	r0, #0b0011
	bl	lcd_send_4bit

	mov	r0, #0b0010
	bl	lcd_send_4bit

	/*
	 * function set 001DNF**
	 * D: 0 = 4-bit, 1 = 8-bit
	 * N: 0 = 1 line, 1 = 2 lines
	 * F: 0 = Font 5 x 8 dots, 1 = Font 5 x 10 dots
	 * *: don't care
	 */
	mov	r0, #0b00101000
	bl	lcd_send_4bit_8

	/*
	 * display on 00001DCB
	 * D: 0 = display off, 1 = display on
	 * C: 0 = cursor off, 1 = cursor on
	 * B: 0 = cursor blinking, 1 = no cursor blinking
	 */
	mov	r0, #0b00001100
	bl	lcd_send_4bit_8

	/* clear display 00000001 */
	mov	r0, #0b00000001
	bl	lcd_send_4bit_8

	/*
	 * entry mode set 000001IS
	 * I: 0 = decrement cursor, 1 = increment cursor
	 * S: 0 = no display shift, 1 = display shift
	 */
	mov	r0, #0b00000110
	bl	lcd_send_4bit_8

	/* set up write-mode */
	bl	lcd_write

	/* wait 5 ms */
	mov	r0, #5
	bl	delay_ms

	/* end function and return */
	pop	{r0,lr}
	bx	lr



.global lcd_enable
lcd_enable:
	/*************************************************/
	/* function:    lcd_enable                       */
	/* description: toggles Enable pin to write data */
	/*************************************************/
	/* input:  -                                     */
	/* output: -                                     */
	/*************************************************/
	/* begin function */
	push	{r0-r2,lr}

	/* set Enable to 1 */
	mov	r0, #1	@ port B
	mov	r1, #8	@ pin 8
	mov	r2, #1  @ set
	bl	gpio_set

	/* wait 150us */
	mov	r0, #30
	bl	delay_times_5us

	/* set Enable to 0 */
	mov	r0, #1	@ port B
	mov	r1, #8	@ pin 8
	mov	r2, #0  @ reset
	bl	gpio_set

	/* end function and return */
	pop	{r0-r2,lr}
	bx	lr



.global lcd_write
lcd_write:
	/******************************************/
	/* function:    lcd_write                 */
	/* description: turns on write-mode       */
	/*              (use before writing data) */
	/******************************************/
	/* input:  -                              */
	/* output: -                              */
	/******************************************/
	/* begin function */
	push	{r0-r2,lr}

	/* set Register Select */
	mov	r0, #1	@ port B
	mov	r1, #9	@ pin 9
	mov	r2, #1	@ set
	bl	gpio_set

	/* end function and return */
	pop	{r0-r2,lr}
	bx	lr



.global lcd_command	
lcd_command:
	/*********************************************/
	/* function:    lcd_command                  */
	/* description: turns on command-mode        */
	/*              (use before sending command) */
	/*********************************************/
	/* input:  -                                 */
	/* output: -                                 */
	/*********************************************/
	/* begin function */
	push	{r0-r2,lr}

	/* reset Register Select */
	mov	r0, #1	@ port B
	mov	r1, #9	@ pin 9
	mov	r2, #0	@ reset
	bl	gpio_set

	/* end function and return */
	pop	{r0-r2,lr}
	bx	lr



.global lcd_send_4bit
lcd_send_4bit:
	/*******************************/
	/* function:    lcd_send_4bit  */
	/* description: sends 4 bits   */
	/*******************************/
	/* input:  r0: bits to send    */
	/* output: r0: preserves input */
	/*******************************/
	/* begin function */
	push	{r0-r3,lr}

	mov	r3, r0

	mov	r0, #1	@ port B

	/* set DB4 */
	mov	r1, #6	@ pin 6
	and	r2, r3, #0b0001
	bl	gpio_set

	/* set DB5 */
	mov	r1, #5	@ pin 5
	and	r2, r3, #0b0010
	bl	gpio_set

	/* set DB6 */
	mov	r1, #11	@ pin 11
	and	r2, r3, #0b0100
	bl	gpio_set

	/* set DB7 */
	mov	r1, #10	@ pin 10
	and	r2, r3, #0b1000
	bl	gpio_set

	/* send data */
	bl	lcd_enable

	/* end function and return */
	pop	{r0-r3,lr}
	bx	lr



.global lcd_send_4bit_8
lcd_send_4bit_8:
	/***********************************************************************/
	/* function:    lcd_send_4bit_8                                        */
	/* description: sends 8 bits, use lcd_write/lcd_command to choose mode */
	/***********************************************************************/
	/* input:  r0: bits to send                                            */
	/* output: r0: preserves input                                         */
	/***********************************************************************/
	/* begin function */
	push	{r0-r1,lr}

	mov	r1, r0

	/* send msbs first */
	lsr	r0, #4
	bl	lcd_send_4bit

	/* then send lsbs */
	mov	r0, r1
	bl	lcd_send_4bit

	/* end function and return */
	pop	{r0-r1,lr}
	bx	lr



.global lcd_cursor_line_1_position_0
lcd_cursor_line_1_position_0:
	/*********************************************************/
	/* function:    lcd_cursor_line_1_position_0             */
	/* description: moves cursor to position 0 in first line */
	/*********************************************************/
	/* input:  -                                             */
	/* output: -                                             */
	/*********************************************************/
	/* begin function */
	push	{r0,lr}

	/* move cursor to first line position 0 */
	bl	lcd_command
	mov	r0, #0b10000000
	bl	lcd_send_4bit_8
	bl	lcd_write

	/* end function and return */
	pop	{r0,lr}
	bx	lr



.global lcd_cursor_line_2_position_0
lcd_cursor_line_2_position_0:
	/**********************************************************/
	/* function:    lcd_cursor_line_2_position_0              */
	/* description: moves cursor to position 0 in second line */
	/**********************************************************/
	/* input:  -                                              */
	/* output: -                                              */
	/**********************************************************/

	/* begin function */
	push	{r0,lr}

	/* move cursor to second line position 0 */
	bl	lcd_command
	mov	r0, #0b11000000
	bl	lcd_send_4bit_8
	bl	lcd_write

	/* end function and return */
	pop	{r0,lr}
	bx	lr



.global lcd_reset
lcd_reset:
	/************************************************/
	/* function:    lcd_reset                       */
	/* description: clears display and moves cursor */
	/*              to position 0 in first line     */
	/************************************************/
	/* input:  -                                    */
	/* output: -                                    */
	/************************************************/
	/* begin function */
	push	{r0,lr}

	bl	lcd_command

	/* clear display 00000001 */
	mov	r0, #0b00000001
	bl	lcd_send_4bit_8

	bl	lcd_write

	/* end function and return */
	pop	{r0,lr}
	bx	lr
