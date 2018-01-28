-- VHDL netlist generated by SCUBA Diamond (64-bit) 3.7.0.96.1
-- Module  Version: 5.7
--/mt/lattice/diamond/3.7_x64/ispfpga/bin/lin64/scuba -w -n clk_25M_250M_50M -lang vhdl -synth synplify -bus_exp 7 -bb -arch sa5p00 -type pll -fin 25.00 -fclkop 250.00 -fclkop_tol 0.0 -fclkos 250.00 -fclkos_tol 0.0 -phases 180 -fclkos2 50.00 -fclkos2_tol 0.0 -phases2 0 -phase_cntl STATIC -fb_mode 1 -fdc /home/guest/src/fpga/c64/vhdl_c64_c1541_sd/proj/lattice/ulx3s/clk1/clk_25M_250M_50M/clk_25M_250M_50M.fdc 

-- Sun Jan 28 02:06:47 2018

library IEEE;
use IEEE.std_logic_1164.all;
library ECP5U;
use ECP5U.components.all;

entity clk_25M_250M_50M is
    port (
        CLKI: in  std_logic; 
        CLKOP: out  std_logic; 
        CLKOS: out  std_logic; 
        CLKOS2: out  std_logic);
end clk_25M_250M_50M;

architecture Structure of clk_25M_250M_50M is

    -- internal signal declarations
    signal REFCLK: std_logic;
    signal LOCK: std_logic;
    signal CLKOS2_t: std_logic;
    signal CLKOS_t: std_logic;
    signal CLKOP_t: std_logic;
    signal scuba_vhi: std_logic;
    signal scuba_vlo: std_logic;

    attribute FREQUENCY_PIN_CLKOS2 : string; 
    attribute FREQUENCY_PIN_CLKOS : string; 
    attribute FREQUENCY_PIN_CLKOP : string; 
    attribute FREQUENCY_PIN_CLKI : string; 
    attribute ICP_CURRENT : string; 
    attribute LPF_RESISTOR : string; 
    attribute FREQUENCY_PIN_CLKOS2 of PLLInst_0 : label is "50.000000";
    attribute FREQUENCY_PIN_CLKOS of PLLInst_0 : label is "250.000000";
    attribute FREQUENCY_PIN_CLKOP of PLLInst_0 : label is "250.000000";
    attribute FREQUENCY_PIN_CLKI of PLLInst_0 : label is "25.000000";
    attribute ICP_CURRENT of PLLInst_0 : label is "9";
    attribute LPF_RESISTOR of PLLInst_0 : label is "8";
    attribute syn_keep : boolean;
    attribute NGD_DRC_MASK : integer;
    attribute NGD_DRC_MASK of Structure : architecture is 1;

begin
    -- component instantiation statements
    scuba_vhi_inst: VHI
        port map (Z=>scuba_vhi);

    scuba_vlo_inst: VLO
        port map (Z=>scuba_vlo);

    PLLInst_0: EHXPLLL
        generic map (PLLRST_ENA=> "DISABLED", INTFB_WAKE=> "DISABLED", 
        STDBY_ENABLE=> "DISABLED", DPHASE_SOURCE=> "DISABLED", 
        CLKOS3_FPHASE=>  0, CLKOS3_CPHASE=>  0, CLKOS2_FPHASE=>  0, 
        CLKOS2_CPHASE=>  9, CLKOS_FPHASE=>  0, CLKOS_CPHASE=>  2, 
        CLKOP_FPHASE=>  0, CLKOP_CPHASE=>  1, PLL_LOCK_MODE=>  0, 
        CLKOS_TRIM_DELAY=>  0, CLKOS_TRIM_POL=> "FALLING", 
        CLKOP_TRIM_DELAY=>  0, CLKOP_TRIM_POL=> "FALLING", 
        OUTDIVIDER_MUXD=> "DIVD", CLKOS3_ENABLE=> "DISABLED", 
        OUTDIVIDER_MUXC=> "DIVC", CLKOS2_ENABLE=> "ENABLED", 
        OUTDIVIDER_MUXB=> "DIVB", CLKOS_ENABLE=> "ENABLED", 
        OUTDIVIDER_MUXA=> "DIVA", CLKOP_ENABLE=> "ENABLED", CLKOS3_DIV=>  1, 
        CLKOS2_DIV=>  10, CLKOS_DIV=>  2, CLKOP_DIV=>  2, CLKFB_DIV=>  10, 
        CLKI_DIV=>  1, FEEDBK_PATH=> "CLKOP")
        port map (CLKI=>CLKI, CLKFB=>CLKOP_t, PHASESEL1=>scuba_vlo, 
            PHASESEL0=>scuba_vlo, PHASEDIR=>scuba_vlo, 
            PHASESTEP=>scuba_vlo, PHASELOADREG=>scuba_vlo, 
            STDBY=>scuba_vlo, PLLWAKESYNC=>scuba_vlo, RST=>scuba_vlo, 
            ENCLKOP=>scuba_vlo, ENCLKOS=>scuba_vlo, ENCLKOS2=>scuba_vlo, 
            ENCLKOS3=>scuba_vlo, CLKOP=>CLKOP_t, CLKOS=>CLKOS_t, 
            CLKOS2=>CLKOS2_t, CLKOS3=>open, LOCK=>LOCK, INTLOCK=>open, 
            REFCLK=>REFCLK, CLKINTFB=>open);

    CLKOS2 <= CLKOS2_t;
    CLKOS <= CLKOS_t;
    CLKOP <= CLKOP_t;
end Structure;
