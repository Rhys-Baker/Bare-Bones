#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#if defined(__linux__)
#error "Not cross compiler"
#endif

#if !defined(__i386__)
#error "Not cross compiler"
#endif

typedef enum {
    VGA_COLOR_BLACK         = 0,
    VGA_COLOR_BLUE          = 1,
    VGA_COLOR_GREEN         = 2,
	VGA_COLOR_CYAN          = 3,
	VGA_COLOR_RED           = 4,
	VGA_COLOR_MAGENTA       = 5,
	VGA_COLOR_BROWN         = 6,
	VGA_COLOR_LIGHT_GREY    = 7,
	VGA_COLOR_DARK_GREY     = 8,
	VGA_COLOR_LIGHT_BLUE    = 9,
	VGA_COLOR_LIGHT_GREEN   = 10, // A
	VGA_COLOR_LIGHT_CYAN    = 11, // B
	VGA_COLOR_LIGHT_RED     = 12, // C
	VGA_COLOR_LIGHT_MAGENTA = 13, // D
	VGA_COLOR_LIGHT_BROWN   = 14, // E
	VGA_COLOR_WHITE         = 15  // F
} vga_color;

static inline uint8_t vga_entry_color(vga_color fg, vga_color bg){
    return fg | bg << 4;
}

static inline uint16_t vga_entry(unsigned char uc, uint8_t color){
	return (uint16_t) uc | (uint16_t) color << 8;
}

size_t strlen(const char* str){
	size_t len = 0;
	while (str[len])
		len++;
	return len;
}

#define VGA_WIDTH   80
#define VGA_HEIGHT  25
#define VGA_MEMORY  0xB8000

size_t terminal_row;
size_t terminal_column;
uint8_t terminal_color;
uint16_t* terminal_buffer = (uint16_t*)VGA_MEMORY;

void terminal_initialize(void){
	terminal_row = 0;
	terminal_column = 0;
	terminal_color = vga_entry_color(VGA_COLOR_WHITE, VGA_COLOR_BLACK);
	
	for (size_t y = 0; y < VGA_HEIGHT; y++) {
		for (size_t x = 0; x < VGA_WIDTH; x++) {
			const size_t index = y * VGA_WIDTH + x;
			terminal_buffer[index] = vga_entry(' ', terminal_color);
		}
	}
}

void terminal_setcolor(uint8_t color){
	terminal_color = color;
}

/// @brief Put a character at a given X/Y coordinate on the terminal buffer 
/// @param c Character to write
/// @param color 
/// @param x 
/// @param y 
void terminal_putentryat(char c, vga_color color, size_t x, size_t y){
	const size_t index = y * VGA_WIDTH + x;
	terminal_buffer[index] = vga_entry(c, color);
}

/// @brief Scroll the terminal down by one line. Does not affect cursor position
void terminal_scroll(){
	for(int row=0; row<VGA_HEIGHT-1; row++){
		for(int col=0; col<VGA_WIDTH; col++){
			terminal_buffer[(VGA_WIDTH*row) + col] = terminal_buffer[(VGA_WIDTH*(row+1))+col];
		}
	}
	for(int i=0; i<VGA_WIDTH; i++){
		terminal_buffer[(VGA_WIDTH*(VGA_HEIGHT-1)) + i] = ' ';
	}
}

/// @brief Print a character to the terminal at the current cursor position.
/// @param c Character to print
void terminal_putchar(char c){
	// Newline
	if(c == '\n'){
		if (++terminal_row == VGA_HEIGHT){
			terminal_scroll();
			terminal_row--;
		}
		terminal_column = 0;
		return;
	}

	terminal_putentryat(c, terminal_color, terminal_column, terminal_row);
	if (++terminal_column == VGA_WIDTH) {
		terminal_column = 0;
		if (++terminal_row == VGA_HEIGHT){
			terminal_scroll();
			terminal_row--;
		}
	}
}

void terminal_write(const char* data, size_t size){
	bool escaped = false;
	for (size_t i = 0; i < size; i++){
		if(escaped){
			terminal_color = data[i];
			escaped = false;
			continue;
		}

		if(data[i] == '\x1B'){
			// Escape character for color codes
			escaped=true;
			continue;
		}
		// If character is printable, print it
		terminal_putchar(data[i]);
	}
}

void terminal_writestring(const char* data){
	terminal_write(data, strlen(data));
}


/// @brief Called before kernel_main. Used to initialse heap, log, etc
void kernel_early_main(void){
	// Currently does nothing but return
	
	return;
}

void kernel_main(void){
	// Initialize terminal interface
	terminal_initialize();
	
	// Write some test strings
	terminal_writestring("Hello, kernel World!\n");
	terminal_writestring("This is on the next line.\n");
	terminal_writestring("And \x1B\x0ATHIS\x1B\x0F is a different color.\n");
}