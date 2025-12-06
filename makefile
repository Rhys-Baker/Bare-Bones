CC := i686-elf-gcc
CFLAGS := -std=gnu99 -ffreestanding -O2 -Wall -Wextra
# Use the compiler as the linker
LD := i686-elf-gcc
LFLAGS := -ffreestanding -O2 -nostdlib -lgcc

AS := i686-elf-as
AFLAGS :=

OSNAME := myos

all: iso
bin: $(OSNAME).bin
iso: $(OSNAME).iso

clean:
	rm $(OSNAME).iso $(OSNAME).bin
	rm -r iso
	rm *.o

.PHONY: all bin iso clean

boot.o:
	$(AS) $(AFLAGS) boot.s -o boot.o

kernel.o:
	$(CC) $(CFLAGS) -c kernel.c -o kernel.o

$(OSNAME).bin: boot.o kernel.o
	$(LD) $(LFLAGS) -T linker.ld -o myos.bin boot.o kernel.o

# Create the multiboot iso
$(OSNAME).iso: $(OSNAME).bin grub.cfg
	mkdir -p iso/boot/grub
	cp grub.cfg iso/boot/grub/grub.cfg
	cp $(OSNAME).bin iso/boot/$(OSNAME).bin
	grub-mkrescue -o $(OSNAME).iso iso

