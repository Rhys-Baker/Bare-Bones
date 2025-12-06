/* Declare constants for the multiboot header */
.set ALIGN,    1<<0             # Align loaded modules on page boundaries
.set MEMINFO,  1<<1             # Provide memory map
.set FLAGS,    ALIGN | MEMINFO  # This is the multiboot 'flag' field
.set MAGIC,    0x1BADB002       # Magic number
.set CHECKSUM, -(MAGIC + FLAGS) # Checksum

/* Declare a multiboot header that marks the program as a kernel */
.section .multiboot
.align 4
.long MAGIC
.long FLAGS
.long CHECKSUM

/* 
Multiboot doesn't define the stack pointer, so we need to do that ourself.
Allocate 16 KiB with symbols at the top and bottom. 
*/

.section .bss
.align 16 // Must be 16-bit aligned
stack_bottom:
.skip 16384 # 16 KiB
stack_top:

.section .text
.global _start
.type _start, @function
_start:
    /* 
    At this point, the bootloader has loaded us into 32-bit protected mode.
    Interrupts are disabled, paging is disabled.
    */

    # Set up the stack
    mov $stack_top, %esp

    /* Need to init crucial processor state here. Things like floating-point, GDT, paging. */

    /* Enter the kernel */
    call kernel_main

    /* If we get out of the kernel, we want to just hang forever */
    cli
1:  hlt
    jmp 1b


# Set the size of the start symbol to the current location minus the start
.size _start, . - _start
