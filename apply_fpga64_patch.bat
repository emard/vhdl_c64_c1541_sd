echo off

path "c:\Program Files (x86)\GnuWin32\bin"

mkdir rtl_renommes 

copy FPGA64_027\sources\rtl\fpga64_buslogic_roms.vhd                    rtl_renommes\fpga64_buslogic_roms_mmu.vhd
copy FPGA64_027\sources\rtl\fpga64_cone.vhd                             rtl_renommes\fpga64_sid_iec.vhd  
copy FPGA64_027\sources\rtl\fpga64_keyboard_matrix_mark_mcdougall.vhd   rtl_renommes\fpga64_keyboard_matrix_mark_mcdougall.vhd
copy FPGA64_027\sources\rtl\video_vicII_656x_a.vhd                      rtl_renommes\video_vicII_656x_a.vhd

patch -d rtl_renommes -i ..\fpga64.patch

copy rtl_renommes\fpga64_buslogic_roms_mmu.vhd              rtl_dar\_fpga64_buslogic_roms_mmu.vhd
copy rtl_renommes\fpga64_sid_iec.vhd                        rtl_dar\_fpga64_buslogic_sid_iec.vhd
copy rtl_renommes\fpga64_keyboard_matrix_mark_mcdougall.vhd rtl_dar\_fpga64_keyboard_matrix_mark_mcdougall.vhd
copy rtl_renommes\video_vicII_656x_a.vhd                    rtl_dar\_video_vicII_656x_a.vhd

rmdir /s /q rtl_renommes