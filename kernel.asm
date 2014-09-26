;; kernel.asm
;; version 0.0.1

bits 32		;nasm directive
section .text
	;multiboot spec
	align 4
	dd 0x1BADB002			;magic
	dd 0x00				;flags
	dd - (0x1BADB002 + 0x00)	;checksum. m+f+c should be zero

global start
extern k_main	;k_main is defined in the kernel.c file

start:
	cli  ; stop interrupts

	call k_main

	hlt ; halt the CPU
