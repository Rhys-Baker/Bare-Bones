CC = i686-elf-gcc
CFLAGS = -std=gnu99 -ffreestanding -O2 -Wall -Wextra
# Get the path to crtbegin.o and crtend.o
CRTBEGIN_OBJ:=$(shell $(CC) $(CFLAGS) -print-file-name=crtbegin.o)
CRTEND_OBJ:=$(shell $(CC) $(CFLAGS) -print-file-name=crtend.o)


# Use the compiler as the linker
LD = i686-elf-gcc
LFLAGS = -ffreestanding -O2 -nostdlib -lgcc

AS = nasm
AFLAGS = -f elf32


INTERNAL_OBJS = boot.o kernel.o
OBJ_LIST = $(CRTBEGIN_OBJ) $(INTERNAL_OBJS) $(CRTEND_OBJ)

OSNAME = myos

all: iso
bin: $(OSNAME).bin
iso: $(OSNAME).iso

clean:
	rm $(OSNAME).iso $(OSNAME).bin
	rm -r iso
	rm *.o

.PHONY: all bin iso clean

# Assemble .asm files
%.o: %.asm
	$(AS) $(AFLAGS) $< -o $@

# Compile .c files
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

$(OSNAME).bin: $(OBJ_LIST)
	$(LD) $(LFLAGS) -T linker.ld -o myos.bin $(OBJ_LIST)

# Create the multiboot iso
$(OSNAME).iso: $(OSNAME).bin grub.cfg
	mkdir -p iso/boot/grub
	cp grub.cfg iso/boot/grub/grub.cfg
	cp $(OSNAME).bin iso/boot/$(OSNAME).bin
	grub-mkrescue -o $(OSNAME).iso iso

