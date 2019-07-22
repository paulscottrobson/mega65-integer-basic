rm rom.bin
64tass -a --m4510 -b ptest.asm  -L rom.lst -o rom.bin
if [ $? -eq 0 ]
then
../../../xemu/build/bin/xmega65.native 1>/dev/null
fi
