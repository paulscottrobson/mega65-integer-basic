#include "fabgl.h"
#include "sys_processor.h"
#include "hardware.h"

// select one color configuration
#define USE_8_COLORS  0
#define USE_64_COLORS 1


// indicate VGA GPIOs to use for selected color configuration
#if USE_8_COLORS
	#define VGA_RED    GPIO_NUM_22
	#define VGA_GREEN  GPIO_NUM_21
	#define VGA_BLUE   GPIO_NUM_19
	#define VGA_HSYNC  GPIO_NUM_18
	#define VGA_VSYNC  GPIO_NUM_5
#elif USE_64_COLORS
	#define VGA_RED1   GPIO_NUM_22
	#define VGA_RED0   GPIO_NUM_21
	#define VGA_GREEN1 GPIO_NUM_19
	#define VGA_GREEN0 GPIO_NUM_18
	#define VGA_BLUE1  GPIO_NUM_5
	#define VGA_BLUE0  GPIO_NUM_4
	#define VGA_HSYNC  GPIO_NUM_23
	#define VGA_VSYNC  GPIO_NUM_15
#endif

#define PS2_PORT0_CLK GPIO_NUM_33
#define PS2_PORT0_DAT GPIO_NUM_32

#include "character_rom.inc"

void HWWriteCharacter(WORD16 x,WORD16 y,BYTE8 ch) {
	RGB rgb,rgbx;
	rgbx.R = 0;rgbx.G = 0;rgbx.B = 0;
	rgb.R = 3;rgb.G = 1;rgb.B = 0;
	int patternBase = (ch & 0xFF) * 8;
	x = x * 8+8;y = y * 16+22;
	Canvas.setBrushColor(rgbx);
	Canvas.fillRectangle(x,y,x+7,y+15);
	for (int y1 = 0;y1 < 8;y1++) {
		int pattern = character_rom[patternBase+y1];
		int x1 = x;
		while (pattern != 0) {
			if (pattern & 0x80) {
				Canvas.setPixel(x1,y+y1*2,rgb);
				Canvas.setPixel(x1,y+y1*2+1,rgb);
			}
			x1++;
			pattern = pattern << 1;
		}
	}
}

int HWGetScanCode(void) {
	return Keyboard.getNextScancode(0);
}

void setup()
{
	#if USE_8_COLORS
	VGAController.begin(VGA_RED, VGA_GREEN, VGA_BLUE, VGA_HSYNC, VGA_VSYNC);
	#elif USE_64_COLORS
	VGAController.begin(VGA_RED1, VGA_RED0, VGA_GREEN1, VGA_GREEN0, VGA_BLUE1, VGA_BLUE0, VGA_HSYNC, VGA_VSYNC);
	#endif

	VGAController.setResolution(VGA_400x300_60Hz, -1, -1);
	VGAController.enableBackgroundPrimitiveExecution(false);
	CPUReset();
	Keyboard.begin(PS2_PORT0_CLK, PS2_PORT0_DAT,false,false);
}


void loop()
{
	while (CPUExecuteInstruction() == 0) {
	}
}
