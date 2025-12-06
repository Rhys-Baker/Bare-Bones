; =============================
;   Multiboot Header
; =============================


; Declare a multiboot header that marks the program as a kernel
SECTION .multiboot
align 4

; Declare constants for the multiboot header
%define ALIGN    (1 << 0)
%define MEMINFO  (1 << 1)
%define FLAGS    (ALIGN | MEMINFO)
%define MAGIC    0x1BADB002
%define CHECKSUM -(MAGIC + FLAGS)

; Header
dd MAGIC
dd FLAGS
dd CHECKSUM

; =============================
;   Stack Allocation (16 KiB)
; =============================

SECTION .bss
align 16 ; Must be 16-bit aligned

global stack_bottom
global stack_top

stack_bottom:
    resb 16384 ;Reserve 16 KiB
stack_top:

; =============================
;   Kernel Entry Point
; =============================

SECTION .text
global _start
_start:
    ; Bootloader has placed us in 32-bit mode
    ; Interrupts and paging are disabled
    
    ; Set up stack
    mov esp, stack_top

    ; Call the kernel C entry point
    extern kernel_main
    call kernel_main

    ; If kernel_main returns, halt forever
.hang:
    cli
    hlt
    jmp.hang
    
