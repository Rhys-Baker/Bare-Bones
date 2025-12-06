ENTRY(_start)
SECTIONS
{
    /* 2M is safer than 1M for complicated reasons */
    . = 2M;

    /* 
    Put the multiboot header first.
    Must be early on or the bootloader won't recognise it.
    */
    .text BLOCK(4K) : ALIGN(4K)
    {
        *(.multiboot)
        *(.text)
    }

    /* Read-Only data */
    .rodata BLOCK(4K) : ALIGN(4K)
    {
        *(.data)
    }

    /* Read-Write data and stack */
    .bss BLOCK(4K) : ALIGN(4K)
    {
        *(COMMON)
        *(.bss)
    }

    /* The compiler may produce other sections. Add more stuff here as needed */

}