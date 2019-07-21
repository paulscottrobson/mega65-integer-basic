// *******************************************************************************************************************************
// *******************************************************************************************************************************
//
//		Name:		hardware.h
//		Purpose:	Hardware Emulation Header
//		Created:	15th July 2019
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// *******************************************************************************************************************************
// *******************************************************************************************************************************

#ifndef _HARDWARE_H
#define _HARDWARE_H

void HWReset(void);
void HWSync(void);
BYTE8 HWWriteKeyboard(BYTE8 pattern);
void HWWriteDisplay(WORD16 address,BYTE8 data);
int HWGetScanCode(void);
void HWWriteCharacter(WORD16 x,WORD16 y,BYTE8 ch);
#endif