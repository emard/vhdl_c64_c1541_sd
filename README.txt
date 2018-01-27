---------------------------------------------------------------------------------
-- FPGA64_027 and 1541_SD by Dar (darfpga@aol.fr) release 0001- 26/07/2015
--
-- http://darfpga.blogspot.fr
--
-- FPGA64 is Copyrighted 2005-2008 by Peter Wendrich (pwsoft@syntiac.com)
-- http://www.syntiac.com/fpga64.html
--
-- Main features
--  15KHz(TV) / 31Khz(VGA)
--  PAL(50Hz) / NTSC(60Hz)
--  PS2 keyboard input with portA / portB joystick emulation
--  SID sound output
--  64Ko of board SRAM used on DE1 and DE2, external SRAM required for DE0 nano
--
--  External IEC bus available (for drive 1541 or IEC/SD ...)
--    activated external IEC with no external hardware will stuck IEC bus
--    on DE2 switch(5) allow for deactivate external IEC bus
--    on DE0 nano external IEC is always activated as external SRAM/IEC interface
--    is required.
--
--  Internal emulated 1541 on raw SD card (READ ONLY) : D64 images start at 256KB boundaries
--  Use hexadecimal disk editor such as HxD (www.mh-nexus.de) to build SD card.
--  Cut D64 file and paste at 0x00000 (first), 0x40000 (second), 0x80000 (third),
--  0xC0000(fourth), 0x100000(fith), 0x140000 (sixth) and so on.
--  BE CAREFUL NOT WRITING ON YOUR OWN HARDDRIVE
--
--  Use only SIMPLE D64 files : 174 848 octets (without disk error management) 
-- 
-- DE0 nano and DE2 support standalone 1541 to SD card function
-- DE1 has not enough FPGA internal memory to support 1541 ROM and track buffer  
---------------------------------------------------------------------------------
--
-- c1541_sd reads D64 data from raw SD card, produces GCR data, feeds c1541_logic
-- Raw SD data : each D64 image must start on 256KB boundaries
-- disk_num allow to select D64 image
--
-- c1541_logic    from : Mark McDougall
-- spi_controller from : Michel Stempin, Stephen A. Edwards
-- via6522        from : Arnim Laeuger, Mark McDougall, MikeJ
-- T65            from : Daniel Wallner, MikeJ, ehenciak
--
-- c1541_logic    modified for : slow down CPU (EOI ack missed by real c64)
--                             : remove IEC internal OR wired
--                             : synched atn_in (sometime no IRQ to CPU with real c64)
-- spi_controller modified for : sector start and size adapted + busy signal
-- via6522        modified for : no modification
--
---------------------------------------------------------------------------------
-- Known bug :
--   PWM sound converter (DE0 nano only) sometimes makes the screen boucing or 
--   even crash FPGA as soon as sound is produced. It is linked with the PWM clock
--   frequency and with the number of sound data bit used. My conclusion is that
--   when PWM output toggle too often it sink too much current from FPGA. Maybe my 
--   own DE0 nano hardware is the reason (bad external resistor or capacitor design)     
--
---------------------------------------------------------------------------------
How-to build project :
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
First download and install "diffutils" and "patch" from gnuwin at sourceforge.

Then download fpga64_027.zip from http://www.syntiac.com/fpga64.html
and unzip in the vhdl_c64_c1451_sd folder to get FPGA64_027 folder at the same level

Then lauch "apply_fpga64_patch.bat", make sure the four following files appear at within rtl_dar folder:
(You may have to adapt the line path "c:\Program Files (x86)\GnuWin32\bin" to match your configuration.)

 "_fpga64_sid_iec.vhd"
 "_video_vicII_656x_a_dar.vhd"
 "_fpga64_buslogic_roms_mmu.vhd"
 "_fpga64_keyboard_matrix_mark_mcdougall_dar"

If these files doesn't conflict with other existing ones just remove leading underscores of their filenames

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

For Altera/Quartus and de0 nano, de1 or de2 board you should use the following project files (qpf/qsf) that contains the correct file list and pin assignements :

de0_nano/C64_de0_nano.qpf / qsf
de1/C64_de1.qpf / qsf
de2/C64_de2.qpf / qsf

For others software or board the file are listed below :
(do not use extra files from rtl_pace, rtl_edward or fpga64_027 other than the one listed below as they will conflicts with files from rtl_dar)

 ../rtl_dar/wm8731_dac.vhd
 ../rtl_dar/pll50_to_32_and_18.vhd
 ../rtl_dar/c1541_sd
 ../rtl_dar/gcr_floppy
 ../rtl_dar/composite_sync.vhd
 ../rtl_dar/decodeur_7_segments.vhd

 ../rtl_dar/fpga64_sid_iec.vhd                            [modified from fpga64 ]
 ../rtl_dar/video_vicII_656x_a_dar.vhd                    [modified from fpga64 ] 
 ../rtl_dar/fpga64_buslogic_roms_mmu.vhd                  [modified from fpga64 ]
 ../rtl_dar/fpga64_keyboard_matrix_mark_mcdougall_dar.vhd [modified from fpga64 ]
 ../rtl_dar/c1541_logic                                   [modified from pace   ]
 ../rtl_dar/sid6581.vhd                                   [modified from pace   ]
 ../rtl_dar/spi_controller                                [modified from edwards]

 ../rtl_pace/sid_voice.vhd
 ../rtl_pace/m6522
 ../rtl_pace/spram
 ../rtl_pace/sprom

 ../FPGA64_027/sources/roms/rom_c64_chargen.vhd
 ../FPGA64_027/sources/roms/rom_c64_basic.vhd
 ../FPGA64_027/sources/roms/rom_c64_kernal.vhd
 ../FPGA64_027/sources/video_vicII_656x_e.vhd
 ../FPGA64_027/sources/io_ps2_keyboard.vhd
 ../FPGA64_027/sources/gen_rwram.vhd
 ../FPGA64_027/sources/gen_ram.vhd
 ../FPGA64_027/sources/fpga64_rgbcolor.vhd
 ../FPGA64_027/sources/fpga64_hexy_vmode.vhd
 ../FPGA64_027/sources/fpga64_hexy.vhd
 ../FPGA64_027/sources/fpga64_cone_scanconverter.vhd
 ../FPGA64_027/sources/fpga64_bustiming.vhd
 ../FPGA64_027/sources/cpu65xx_fast.vhd
 ../FPGA64_027/sources/cpu65xx_e.vhd
 ../FPGA64_027/sources/cpu_6510.vhd
 ../FPGA64_027/sources/cia6526.vhd

 ../t65/T65_Pack.vhd
 ../t65/T65_MCode.vhd
 ../t65/T65_ALU.vhd
 ../t65/T65.vhd

---------------------------------------------------------------------------------
Top level files are :

c64_de0_nano.vhd or c64_de1.vhd or c64_de2.vhd depending on your board.

de0_nano board required additional hardware (sram, sound, video, kbd).

---------------------------------------------------------------------------------
You can select C64 original kernel or C64 Jiffy kernel  
(Jiffy is not delivered, you will have to build your own vhd file from original Jiffy ROM)

within fpga64_buslogic_roms_mmu.vhd : Keep one line uncommented 

-- kernelrom: entity work.rom_c64_Jiffy_kernel
-- kernelrom: entity work.rom_c64_kernal

---------------------------------------------------------------------------------
You can select C1541 original kernel or C1541 Jiffy kernel  
(Jiffy is not delivered, you will have to build your own hex file from original Jiffy ROM)


within c1541_logic.vhld : : Keep one line uncommented 

-- init_file   => "../roms/JiffyDOS_C1541.hex",               
-- init_file   => "../roms/25196802.hex",             
-- init_file   => "../roms/25196801.hex",             
-- init_file   => "../roms/325302-1_901229-03.hex",   
-- init_file   => "../roms/1541_c000_01_and_e000_06aa.hex",

---------------------------------------------------------------------------------
Keyboard main control keys :

    F4  cycle between 8 possible led displays (DE0 nano/DE2)
          - 0 : disk image number
          - 1 : disk activity
          - 2 : track number
          - 3 : sector number
          - 4 : SD card state machine state
          - 5 : 01010101 
          - 6 : 01010101 
          - 7 : 01010101 

    F8  change selected disk image on internal 1541 SD card
          - F8             next image
          - Left shift F8  previous image

    F11 toggle joystick emulation port A or port B on numeric keypad.
    F12 toggle PAL / NTSC (some VGA monitor doesn't synched at 50Hz )


---------------------------------------------------------------------------------
FPGA64_027 Keyboard specific keys :
    
    Escape : run stop
    [      : @
    ]      : *
    \      : up arrow
    '      : semi colon 
    `      : left arrow
    F9     : £
    F10    : +
    Left Alt : commodore key
    

---------------------------------------------------------------------------------
DE0 Nano switch :

    key0 reset cpu
    gpio_1_in0 toggle PAL / NTSC mode at startup (use F12 after startup)
    gpio_1_in1 toggle15KHz (RBG SCART) / 31KHz (VGA)

---------------------------------------------------------------------------------
DE1 switch :

    key0 reset cpu
    sw6 toggle PAL / NTSC mode at startup (use F12 after startup)
    sw9 toggle 15KHz (RBG SCART) / 31KHz (VGA)  

---------------------------------------------------------------------------------
DE2 switches :

    key0 reset cpu
    sw1 toggle PAL / NTSC mode at startup (use F12 after startup)
    sw0 toggle 15KHz (RBG SCART) / 31KHz (VGA)
    sw5 activate external IEC bus (stuck bus if no external hardware present)
    sw16-17 select image bank 0/1/2/3 (256 disk/bank)   

---------------------------------------------------------------------------------
JiffyDos shortcut with µSDIEC hardware (not internal nor real 1541):

    /FB load file browser from IEC drive
    run 
    @cd< goes out of D64 (< is the left arrow symbol not the 'less than' symbol)
    @cd/ goes up one dir level
    @cd// goes to root dir

---------------------------------------------------------------------------------
END