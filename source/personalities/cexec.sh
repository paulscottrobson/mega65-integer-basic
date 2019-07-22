pushd ../../6502system/emulator
sh build.sh
popd
rm rom.bin
64tass -a --m4510 -D TARGET=2 -b ptest.asm  -L rom.lst -o rom.bin
if [ $? -eq 0 ]
then
	../../6502system/emulator/6502mc &
fi
