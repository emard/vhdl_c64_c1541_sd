#!/bin/sh

rm -rf FPGA64_027 rtl_renommes
unzip fpga64_027.zip

mkdir rtl_renommes 

cp FPGA64_027/sources/rtl/fpga64_buslogic_roms.vhd                    rtl_renommes/fpga64_buslogic_roms_mmu.vhd
cp FPGA64_027/sources/rtl/fpga64_cone.vhd                             rtl_renommes/fpga64_sid_iec.vhd  
cp FPGA64_027/sources/rtl/fpga64_keyboard_matrix_mark_mcdougall.vhd   rtl_renommes/fpga64_keyboard_matrix_mark_mcdougall.vhd
cp FPGA64_027/sources/rtl/video_vicII_656x_a.vhd                      rtl_renommes/video_vicII_656x_a.vhd

cd rtl_renommes
cat ../fpga64.patch | tr '\\\\' "/" | patch -p1 --binary
cd ..

cp rtl_renommes/fpga64_buslogic_roms_mmu.vhd              rtl_dar/_fpga64_buslogic_roms_mmu.vhd
cp rtl_renommes/fpga64_sid_iec.vhd                        rtl_dar/_fpga64_buslogic_sid_iec.vhd
cp rtl_renommes/fpga64_keyboard_matrix_mark_mcdougall.vhd rtl_dar/_fpga64_keyboard_matrix_mark_mcdougall.vhd
cp rtl_renommes/video_vicII_656x_a.vhd                    rtl_dar/_video_vicII_656x_a.vhd

rm -rf rtl_renommes
