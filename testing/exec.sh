rm rom.bin
64tass -a --m4510 -b test.asm  -L rom.lst -o rom.bin
if [ -e rom.bin ]
then
../../xemu/build/bin/xmega65.native &
fi
