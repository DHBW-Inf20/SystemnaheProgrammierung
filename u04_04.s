.syntax unified
.cpu cortex-m3
.thumb

.word 0x20000400
.word 0x080000ed
.space 0xe4
.global _start
_start:

ldr r1, =0xZZZZZZZZ		@ ZZZZZZZZ Adresse APB2ENR
ldr r0, [r1]
orr r0, r0, #ZZ			@ ZZ Wert um Port A zu aktivieren
str r0, [r1]			@ Set IOPAEN bit in RCC_APB2ENR to 1 to enable GPIOA

ldr r1, =0xZZZZZZZZ		@ ZZZZZZZZ Adresse Port A CRH
ldr r0, [r1]
and r0, #0xfffffff0
orr r0, #0bZZZZ			@ CNF:MODE Bits für PA8 als Ausgang Push_Pull
str r0, [r1]			@ Set CNF8:MODE8 in GPIOA_CRH

ldr r1, =0xZZZZZZZZ		@ ZZZZZZZZ Adresse BSRR Port A
ldr r0, =0bZZ			@ ZZ Wert um PA8 high zu setzen
str r0, [r1]			@ Set BS8 in GPIOA_BSRR to 1 to set PA8 high

loop:
	b	loop

