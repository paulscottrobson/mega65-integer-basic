rom = []
for i in range(0,128*1024,8):
	rom.append(0x4C)
	rom.append(i & 0xFF)
	rom.append((i >> 8) & 0xFF)
	rom.append(((i+0x20000) >> 16) & 0xFF)
	rom.append(0)
	rom.append(0)
	rom.append(0)
	rom.append(0)
rom[0xFFFC] = 0xE0
rom[0xFFFD] = 0xFF
rom[0xFFFE] = 0x02
rom[0xFFFF] = 0x00

open("rom.bin","wb").write(bytes(rom))

