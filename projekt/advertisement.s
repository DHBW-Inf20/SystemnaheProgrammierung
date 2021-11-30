/*
 * advertisement.s
 *
 * assemble and link with (might require assembling lib_gpio.s, lib_lcd.s and lib_timer.s first):
 * as -g -o advertisement.o advertisement.s
 * ld -o advertisement.elf advertisement.o ../lib/lib_gpio.o ../lib/lib_lcd.o ../lib/lib_timer.o -T stm32f1.ld
 *
 * start with:
 * openocd -f interface/stlink-v2-1.cfg -f target/stm32f1x.cfg -c "program advertisement.elf verify reset exit"
 */

.syntax unified
.cpu cortex-m3
.thumb

.section .VectorTable, "a"
.word _StackEnd
.word Reset_Handler
.space 0x34
.word SysTick_Handler
.space 0xac

.include "../lib/stm32f103.inc"

.text
.type Reset_Handler, %function
.global Reset_Handler
Reset_Handler:
	bl	StartSysTick
	bl	lcd_init

start:
	mov	r0, #1
	bl	delay_s

	ldr	r1, =display_text
	mov	r2, #0
display_text_loop:

	/* load single byte from display_text with offset r2 */
	ldrb	r3, [r1, r2]
	cmp	r3, #0
	beq	display_text_loop_end

	/* line break (before 16th char) */
	cmp	r2, #16
	it	eq
	bleq	lcd_cursor_line_2_position_0

	/*
	 * copy second line to first line and clear second line
	 * (before every 16th char except first)
	 */
	cmp	r2, #16
	ble	skip_copy_second_line_to_first_line_and_clear_second_line
	and	r4, r2, #0b1111
	cmp	r4, #0
	bne	skip_copy_second_line_to_first_line_and_clear_second_line

	mov	r4, r1		@ pass pointer to copy start address
	add	r4, r2		@ start at current offset
	sub	r4, #16		@ and go 16 back to copy those 16 bytes
	bl	copy_second_line_to_first_line_and_clear_second_line

	skip_copy_second_line_to_first_line_and_clear_second_line:

	/* display previously loaded byte and wait slightly */
	mov	r0, r3
	bl	lcd_send_4bit_8
	mov	r0, #80
	bl	delay_ms

	/* increment offset and jump back */
	add	r2, #1
	b	display_text_loop

display_text_loop_end:

	/* wait and reset */
	mov	r0, #3
	bl	delay_s
	bl	lcd_reset

	b	start



/* pointer to second line in r4 */
copy_second_line_to_first_line_and_clear_second_line:
	push	{r0-r1,lr}

	/* move cursor */
	bl	lcd_cursor_line_1_position_0

	/* copy second line to first line */
	mov	r1, #0
copy_second_line_to_first_line_loop:
	/* load and disyplay single byte from r4 with offset r1 */
	ldrb	r0, [r4, r1]
	bl	lcd_send_4bit_8
	add	r1, #1
	cmp	r1, #16
	bne	copy_second_line_to_first_line_loop

	/* move cursor */
	bl	lcd_cursor_line_2_position_0

	/* clear second line */
	mov	r0, #0x20	@ Space
clear_second_line_loop:
	bl	lcd_send_4bit_8
	add	r1, #1
	cmp	r1, #32
	bne	clear_second_line_loop

	/* move cursor */
	bl	lcd_cursor_line_2_position_0

	pop	{r0-r1,lr}
	bx	lr



display_text:
	.asciz	"Hallo DHBW!                     Am Campus Horb studieren rund 1.000 angehende Ingenieur*innen und Informatiker*innen in f\365nf national und international anerkannten Bachelorstudieng\341ngen.                      Direkt am Neckar gelegen bietet der Campus Horb ein ideales Lernumfeld mit modernster technischer Ausstattung und vielen Service- und Beratungsangeboten f\365r einen guten Start in ein erfolgreiches Studium."
