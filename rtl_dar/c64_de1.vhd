---------------------------------------------------------------------------------
-- DE1 Top level for FPGA64_027 by Dar (darfpga@aol.fr)
-- http://darfpga.blogspot.fr
--
-- FPGA64 is Copyrighted 2005-2008 by Peter Wendrich (pwsoft@syntiac.com)
-- http://www.syntiac.com/fpga64.html
--
-- Main features
--  15KHz(TV) / 31Khz(VGA) : board switch(9)
--  PAL(50Hz) / NTSC(60Hz) : board switch(6) and F12 key
--  PS2 keyboard input with portA / portB joystick emulation : F11 key
--  wm8731 sound output
--  64Ko of board SRAM used
--  IEC bus available at gpio_1 (for drive 1541 or IEC/SD ...)
--
-- Uses only one pll for 32MHz and 18MHz generation from 50MHz
-- DE2 and DE0 nano Top level also available
--     
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.all;

entity c64_de1 is
port(
	clock_50  : in std_logic;
--	clock_27  : in std_logic_vector(1 downto 0);
--	clock_24  : in std_logic_vector(1 downto 0);
--	ext_clock : in std_logic;
--	ledr       : out std_logic_vector(9 downto 0);
--	ledg       : out std_logic_vector(7 downto 0);
	key       : in std_logic_vector(3 downto 0);
	sw        : in std_logic_vector(9 downto 0);

--	dram_ba_0 : out std_logic;
--	dram_ba_1 : out std_logic;
--	dram_ldqm : out std_logic;
--	dram_udqm : out std_logic;
--	dram_ras_n : out std_logic;
--	dram_cas_n : out std_logic;
--	dram_cke : out std_logic;
--	dram_clk : out std_logic;
--	dram_we_n : out std_logic;
--	dram_cs_n : out std_logic;
--	dram_dq : inout std_logic_vector(15 downto 0);
--	dram_addr : out std_logic_vector(11 downto 0);

--	fl_addr  : out std_logic_vector(21 downto 0);
--	fl_ce_n  : out std_logic;
--	fl_oe_n  : out std_logic;
--	fl_dq    : inout std_logic_vector(7 downto 0);
--	fl_rst_n : out std_logic;
--	fl_we_n  : out std_logic;

--	hex0 : out std_logic_vector(6 downto 0);
--	hex1 : out std_logic_vector(6 downto 0);
--	hex2 : out std_logic_vector(6 downto 0);
--	hex3 : out std_logic_vector(6 downto 0);

	ps2_clk : in std_logic;
	ps2_dat : inout std_logic;

--	uart_txd : out std_logic;
--	uart_rxd : in std_logic;

	sram_addr : out std_logic_vector(17 downto 0);
	sram_dq   : inout std_logic_vector(15 downto 0);
	sram_we_n : out std_logic;
	sram_oe_n : out std_logic;
	sram_ub_n : out std_logic;
	sram_lb_n : out std_logic;
	sram_ce_n : out std_logic;
	
--	tdi : in std_logic;
--	tcs : in std_logic;
--	tck : in std_logic;
--	tdo : out std_logic;
	
	vga_r     : out std_logic_vector(3 downto 0);
	vga_g     : out std_logic_vector(3 downto 0);
	vga_b     : out std_logic_vector(3 downto 0);
	vga_hs    : out std_logic;
	vga_vs    : out std_logic;

	i2c_sclk : out std_logic;
	i2c_sdat : inout std_logic;
	
	aud_adclrck : out std_logic;
	aud_adcdat  : in std_logic;
	aud_daclrck : out std_logic;
	aud_dacdat  : out std_logic;
	aud_xck     : out std_logic;
	aud_bclk    : out std_logic;
	
--	sd_dat : inout std_logic;
--	sd_dat3 : out std_logic;
--	sd_cmd : out std_logic;
--	sd_clk : out std_logic;
	
--	gpio_0    : inout std_logic_vector(35 downto 0);
	gpio_1    : inout std_logic_vector(35 downto 0)
);
end c64_de1;

architecture struct of c64_de1 is

	--alias tv15Khz_mode : std_logic is sw(0);
	signal tv15Khz_mode : std_logic;
	signal ntsc_init_mode : std_logic;

	alias sram_addr_int : unsigned is unsigned(sram_addr);
	alias sram_dq_int   : unsigned is unsigned(sram_dq(7 downto 0));

-- DE1/DE2 numbering
	alias iec_atn_i  : std_logic is gpio_1(32);
	alias iec_clk_o  : std_logic is gpio_1(33);
	alias iec_data_o : std_logic is gpio_1(34);
	alias iec_atn_o  : std_logic is gpio_1(35);
	alias iec_data_i : std_logic is gpio_1(2);
	alias iec_clk_i  : std_logic is gpio_1(0);

-- DE0 nano numbering
--	alias iec_atn_i  : std_logic is gpio_0(30);
--	alias iec_clk_o  : std_logic is gpio_0(31);
--	alias iec_data_o : std_logic is gpio_0(32);
--	alias iec_atn_o  : std_logic is gpio_0(33);
--	alias iec_data_i : std_logic is gpio_0_in(1);
--	alias iec_clk_i  : std_logic is gpio_0_in(0);

	signal clk32 : std_logic;
	signal clk18 : std_logic;

	signal ram_ce : std_logic;
	signal ram_we : std_logic;
	signal r : unsigned(7 downto 0);
	signal g : unsigned(7 downto 0);
	signal b : unsigned(7 downto 0);
	signal hsync : std_logic;
	signal vsync : std_logic;
	signal csync : std_logic;
	signal blank : std_logic;

	signal audio_data : std_logic_vector(17 downto 0);
	signal sound_string : std_logic_vector(31 downto 0 );

begin

	tv15Khz_mode <= sw(9);
	ntsc_init_mode <= sw(6);

	gpio_1(31 downto 3) <= (others => 'Z');
	gpio_1(1) <= 'Z';

	clk_32_18 : entity work.pll50_to_32_and_18
	port map(
		inclk0 => clock_50,
		c0 => clk32,
		c1 => clk18
	);

	fpga64 : entity work.fpga64_sid_iec
	port map(
		sysclk => clock_50,
		clk32 => clk32,
		reset_n => key(0),
		kbd_clk => ps2_clk,
		kbd_dat => ps2_dat,
		ramAddr => sram_addr_int(15 downto 0),
		ramData => sram_dq_int,
		ramCE => ram_ce,
		ramWe => ram_we,
		tv15Khz_mode => tv15Khz_mode,
		ntscInitMode => ntsc_init_mode,
		hsync => hsync,
		vsync => vsync,
		r => r,
		g => g,
		b => b,
		game => '1',
		exrom => '1',
		irq_n => '1',
		nmi_n => '1',
		dma_n => '1',
		ba => open,
		dot_clk => open,
		cpu_clk => open,
		joyA => (others => '0'),
		joyB => (others => '0'),
		serioclk => open,
		ces => open,
		SIDclk => open,
		still => open,
		audio_data => audio_data,
		iec_data_o => iec_data_o,
		iec_atn_o => iec_atn_o,
		iec_clk_o => iec_clk_o,
		iec_data_i => not iec_data_i,
		iec_clk_i => not iec_clk_i,
		iec_atn_i => not iec_atn_i
	);

	sram_addr(17 downto 16) <= (others => '0');
	sram_ce_n <= ram_ce;
	sram_we_n <= ram_we;
	sram_oe_n <= not ram_we;
	sram_ub_n <= '0';
	sram_lb_n <= '0';

	vga_r <= std_logic_vector(r(7 downto 4));
	vga_g <= std_logic_vector(g(7 downto 4));
	vga_b <= std_logic_vector(b(7 downto 4));

	comp_sync : entity work.composite_sync
	port map(
		clk32 => clk32,
		hsync => hsync,
		vsync => vsync,
		csync => csync,
		blank => blank
	);

-- synchro composite/ synchro horizontale
	vga_hs <= csync when tv15Khz_mode = '1' else hsync;
-- commutation rapide / synchro verticale
	vga_vs <= '1'   when tv15Khz_mode = '1' else vsync;

	sound_string <= audio_data(17 downto 2) & audio_data(17 downto 2);

	wm8731_dac : entity work.wm8731_dac
	port map(
		clk18MHz => clk18,
		sampledata => sound_string,
		i2c_sclk => i2c_sclk,
		i2c_sdat => i2c_sdat,
		aud_bclk => aud_bclk,
		aud_daclrck => aud_daclrck,
		aud_dacdat => aud_dacdat,
		aud_xck => aud_xck
	); 

end struct;
