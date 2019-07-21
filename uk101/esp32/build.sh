cp ../emulator/*.inc include
cp ../emulator/sys_processor.cpp ../emulator/hardware.cpp src
cp ../emulator/*.h include
cp -R ../emulator/6502 include
pio run -t upload

#
#	pio lib install 6143 	(fabgl)
#