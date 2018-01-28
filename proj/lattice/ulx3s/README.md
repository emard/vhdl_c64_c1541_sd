# VHDL C64

Attempt to adapt DarFPGA's C64 FPGA for HDMI on ULX3S board.
Currently it doesn't work (no sync on HDMI monitor).
Thing seems to boot (blue channel appears a second after reset)
but no picture. Hsync, Vsync and blank are connected to onboard
LEDs and they look like OK, but the timing may be probably out
of VGA spec.

