#
#		Build emulator.
#
rm uk101 *.rom
del /Q *.inc
pushd ../processor
sh build.sh
popd
pushd ../roms
python export.py
popd
make -f makefile.linux


