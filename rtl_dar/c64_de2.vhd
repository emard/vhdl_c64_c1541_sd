---------------------------------------------------------------------------------
-- DE2-35 Top level for FPGA64_027 by Dar (darfpga@aol.fr)
-- http://darfpga.blogspot.fr
--
-- FPGA64 is Copyrighted 2005-2008 by Peter Wendrich (pwsoft@syntiac.com)
-- http://www.syntiac.com/fpga64.html
--
-- Main features
--  15KHz(TV) / 31Khz(VGA) : board switch(0)
--  PAL(50Hz) / NTSC(60Hz) : board switch(1) and F12 key
--  PS2 keyboard input with portA / portB joystick emulation : F11 key
--  wm8731 sound output
--  64Ko of board SRAM used
--  External IEC bus available at gpio_1 (for drive 1541 or IEC/SD ...)
--   activated by switch(5) (activated with no hardware will stuck IEC bus)
--
--  Internal emulated 1541 on raw SD card : D64 images start at 256KB boundaries
--  Use hexidecimal disk editor such as HxD (www.mh-nexus.de) to build SD card.
--  Cut D64 file and paste at 0x00000 (first), 0x40000 (second), 0x80000 (third),
--  0xC0000(fourth), 0x100000(fith), 0x140000 (sixth) and so on.
--  BE CAREFUL NOT WRITING ON YOUR OWN HARDDRIVE
--
-- Uses only one pll for 32MHz and 18MHz generation from 50MHz
-- DE1 and DE0 nano Top level also available
--     
---------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.all;

entity c64_de2 is
port(
	clock_50  : in std_logic;
--	clock_27  : in std_logic;
--	ext_clock : in std_logic;
--	ledr       : out std_logic_vector(17 downto 0);
	ledg       : out std_logic_vector(8 downto 0);
	key       : in std_logic_vector(3 downto 0);
	sw        : in std_logic_vector(17 downto 0);

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
--
--	fl_addr  : out std_logic_vector(21 downto 0);
--	fl_ce_n  : out std_logic;
--	fl_oe_n  : out std_logic;
--	fl_dq    : inout std_logic_vector(7 downto 0);
--	fl_rst_n : out std_logic;
--	fl_we_n  : out std_logic;
--
	hex0 : out std_logic_vector(6 downto 0);
	hex1 : out std_logic_vector(6 downto 0);
	hex2 : out std_logic_vector(6 downto 0);
	hex3 : out std_logic_vector(6 downto 0);
	hex4 : out std_logic_vector(6 downto 0);
	hex5 : out std_logic_vector(6 downto 0);
	hex6 : out std_logic_vector(6 downto 0);
	hex7 : out std_logic_vector(6 downto 0);

	ps2_clk : in std_logic;
	ps2_dat : inout std_logic;

--	uart_txd : out std_logic;
--	uart_rxd : in std_logic;
--
--	lcd_rw   : out std_logic;
--	lcd_en   : out std_logic;
--	lcd_rs   : out std_logic;
--	lcd_data : out std_logic_vector(7 downto 0);
--	lcd_on   : out std_logic;
--	lcd_blon : out std_logic;
	
	sram_addr : out std_logic_vector(17 downto 0);
	sram_dq   : inout std_logic_vector(15 downto 0);
	sram_we_n : out std_logic;
	sram_oe_n : out std_logic;
	sram_ub_n : out std_logic;
	sram_lb_n : out std_logic;
	sram_ce_n : out std_logic;
	
--	otg_addr   : out std_logic_vector(1 downto 0);
--	otg_cs_n   : out std_logic;
--	otg_rd_n   : out std_logic;
--	otg_wr_n   : out std_logic;
--	otg_rst_n  : out std_logic;
--	otg_data   : inout std_logic_vector(15 downto 0);
--	otg_int0   : in std_logic;
--	otg_int1   : in std_logic;
--	otg_dack0_n: out std_logic;
--	otg_dack1_n: out std_logic;
--	otg_dreq0  : in std_logic;
--	otg_dreq1  : in std_logic;
--	otg_fspeed : inout std_logic;
--	otg_lspeed : inout std_logic;
--	
--	tdi : in std_logic;
--	tcs : in std_logic;
--	tck : in std_logic;
--	tdo : out std_logic;
	
	vga_r     : out std_logic_vector(9 downto 0);
	vga_g     : out std_logic_vector(9 downto 0);
	vga_b     : out std_logic_vector(9 downto 0);
	vga_clk   : out std_logic;
	vga_blank : out std_logic;
	vga_hs    : out std_logic;
	vga_vs    : out std_logic;
	vga_sync  : out std_logic;

	i2c_sclk : out std_logic;
	i2c_sdat : inout std_logic;
	
--	td_clk27 : in std_logic;
--	td_reset : out std_logic;
--	td_data : in std_logic_vector(7 downto 0);
--	td_hs : in std_logic;
--	td_vs : in std_logic;

	aud_adclrck : out std_logic;
	aud_adcdat  : in std_logic;
	aud_daclrck : out std_logic;
	aud_dacdat  : out std_logic;
	aud_xck     : out std_logic;
	aud_bclk    : out std_logic;
	
--	enet_data : inout std_logic_vector(15 downto 0);
--	enet_clk : out std_logic;
--	enet_cmd : out std_logic;
--	enet_cs_n : out std_logic;
--	enet_int : in std_logic;
--	enet_rd_n : out std_logic;
--	enet_wr_n : out std_logic;
--	enet_rst_n : out std_logic;
--	
--	irda_txd : out std_logic;
--	irda_rxd : in std_logic;
--	
	sd_dat  : inout std_logic;
	sd_dat3 : out std_logic;
	sd_cmd  : out std_logic;
	sd_clk  : out std_logic;
	

	gpio_0    : inout std_logic_vector(35 downto 0);
	gpio_1    : inout std_logic_vector(35 downto 0)
);
end c64_de2;

architecture struct of c64_de2 is

	signal c64_iec_atn_i  : std_logic;
	signal c64_iec_clk_o  : std_logic;
	signal c64_iec_data_o : std_logic;
	signal c64_iec_atn_o  : std_logic;
	signal c64_iec_data_i : std_logic;
	signal c64_iec_clk_i  : std_logic;

	signal c1541_iec_atn_i  : std_logic;
	signal c1541_iec_clk_o  : std_logic;
	signal c1541_iec_data_o : std_logic;
	signal c1541_iec_atn_o  : std_logic;
	signal c1541_iec_data_i : std_logic;
	signal c1541_iec_clk_i  : std_logic;

	--alias tv15Khz_mode : std_logic is sw(0);
	signal tv15Khz_mode   : std_logic;
	signal ntsc_init_mode : std_logic;

	alias sram_addr_int : unsigned is unsigned(sram_addr);
	alias sram_dq_int   : unsigned is unsigned(sram_dq(7 downto 0));

-- DE1/DE2 numbering
	alias ext_iec_atn_i  : std_logic is gpio_1(32);
	alias ext_iec_clk_o  : std_logic is gpio_1(33);
	alias ext_iec_data_o : std_logic is gpio_1(34);
	alias ext_iec_atn_o  : std_logic is gpio_1(35);
	alias ext_iec_data_i : std_logic is gpio_1(2);
	alias ext_iec_clk_i  : std_logic is gpio_1(0);

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

	signal audio_data : std_logic_vector(17 downto 0);
	signal sound_string : std_logic_vector(31 downto 0 );

	signal dbg_adr_fetch    : std_logic_vector(15 downto 0);
	signal dbg_cpu_irq      : std_logic;
	signal dbg_track_dbl    : std_logic_vector(6 downto 0);
	signal dbg_sync_n       : std_logic;
	signal dbg_byte_n       : std_logic;
	signal dbg_sd_busy      : std_logic;
	signal dbg_sd_state     : std_logic_vector(7 downto 0);
	signal dbg_read_sector  : std_logic_vector(4 downto 0); 
	
	signal reset_counter    : std_logic_vector(7 downto 0);
	signal reset_n          : std_logic;
	
	signal disk_num         : std_logic_vector(7 downto 0);
	signal dbg_num          : std_logic_vector(2 downto 0);
	signal led_disk         : std_logic_vector(7 downto 0);

begin

	tv15Khz_mode <= sw(0);
	ntsc_init_mode <= sw(1);

	gpio_1(31 downto 3) <= (others => 'Z');
	gpio_1(1) <= 'Z';

	clk_32_18 : entity work.pll50_to_32_and_18
	port map(
		inclk0 => clock_50,
		c0 => clk32,
		c1 => clk18
	);
	
	process(clk32, key(0))
	begin
		if rising_edge(clk32) then
			reset_n <= '0';
			if key(0)='0' then
				reset_counter <= (others => '0');
			else
			  if reset_counter = X"FF" then
					reset_n <= '1';
				else
					reset_counter <= std_logic_vector(unsigned(reset_counter)+1);
				end if;
			end if;
		end if;
	end process;

	fpga64 : entity work.fpga64_sid_iec
	port map(
		sysclk => clock_50,
		clk32 => clk32,
		reset_n => reset_n,
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
		iec_data_o => c64_iec_data_o,
		iec_atn_o  => c64_iec_atn_o,
		iec_clk_o  => c64_iec_clk_o,
		iec_data_i => not c64_iec_data_i,
		iec_clk_i  => not c64_iec_clk_i,
		iec_atn_i  => not c64_iec_atn_i,
		disk_num => disk_num,
	  dbg_num => dbg_num

	);

	-- 
  c64_iec_atn_i  <= not ((not c64_iec_atn_o)  and (not c1541_iec_atn_o) ) or (ext_iec_atn_i  and sw(5));
  c64_iec_data_i <= not ((not c64_iec_data_o) and (not c1541_iec_data_o)) or (ext_iec_data_i and sw(5));
	c64_iec_clk_i  <= not ((not c64_iec_clk_o)  and (not c1541_iec_clk_o) ) or (ext_iec_clk_i  and sw(5));
	
	c1541_iec_atn_i  <= c64_iec_atn_i;
	c1541_iec_data_i <= c64_iec_data_i;
	c1541_iec_clk_i  <= c64_iec_clk_i;
	
	ext_iec_atn_o  <= c64_iec_atn_o   or c1541_iec_atn_o;
	ext_iec_data_o <= c64_iec_data_o  or c1541_iec_data_o;
	ext_iec_clk_o  <= c64_iec_clk_o   or c1541_iec_clk_o;
	
	c1541_sd : entity work.c1541_sd
	port map
	(
  clk32 => clk32,
  clk18 => clk18,
	reset => not reset_n,
	
	disk_num => (sw(17 downto 16) & disk_num),

	iec_atn_i  => c1541_iec_atn_i,
	iec_data_i => c1541_iec_data_i,
	iec_clk_i  => c1541_iec_clk_i,
	
	iec_atn_o  => c1541_iec_atn_o,
	iec_data_o => c1541_iec_data_o,
	iec_clk_o  => c1541_iec_clk_o,
	
	sd_dat  => sd_dat,
	sd_dat3 => sd_dat3,
	sd_cmd  => sd_cmd,
	sd_clk  => sd_clk,

  dbg_adr_fetch   => dbg_adr_fetch,
  dbg_cpu_irq     => dbg_cpu_irq,
	dbg_track_dbl   => dbg_track_dbl,
	dbg_sync_n      => dbg_sync_n,
	dbg_byte_n      => dbg_byte_n,
	dbg_sd_busy     => dbg_sd_busy,
	dbg_sd_state    => dbg_sd_state,
  dbg_read_sector => dbg_read_sector, 
	
  led => led_disk
	);
	
	sram_addr(17 downto 16) <= (others => '0');
	sram_ce_n <= ram_ce;
	sram_we_n <= ram_we;
	sram_oe_n <= not ram_we;
	sram_ub_n <= '0';
	sram_lb_n <= '0';

	vga_clk <= clk32;
	vga_sync <=  '0';
	vga_blank <= '1';

	vga_r <= std_logic_vector(r(7 downto 0)) & "00";
	vga_g <= std_logic_vector(g(7 downto 0)) & "00";
	vga_b <= std_logic_vector(b(7 downto 0)) & "00";

	comp_sync : entity work.composite_sync
	port map(
		clk32 => clk32,
		hsync => hsync,
		vsync => vsync,
		csync => csync
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

	with dbg_num select
	ledg(7 downto 0) <= disk_num when "000",
					led_disk when "001",
					"00"&dbg_track_dbl(6 downto 1) when "010",
					"000"&dbg_read_sector when "011",
					dbg_sd_state when "100",
					X"AA" when others;
				 

	-- debug de2	
	gpio_0(15 downto 0) <= dbg_adr_fetch(15 downto 0);
	gpio_0(16) <= dbg_sync_n;
	gpio_0(17) <= dbg_byte_n;
	gpio_0(18) <= not c1541_iec_atn_i;
	gpio_0(19) <= not c1541_iec_data_i;
	gpio_0(20) <= not c1541_iec_clk_i;
	gpio_0(21) <= not c1541_iec_data_o;
	gpio_0(22) <= not c1541_iec_clk_o;
	gpio_0(23) <= dbg_sd_busy;
	gpio_0(24) <= dbg_cpu_irq;
	gpio_0(32 downto 25) <= dbg_sd_state;
	--gpio_0(29 downto 25) <= dbg_read_sector;


	h0 : entity work.decodeur_7_segments
	port map(di=>std_logic_vector(dbg_adr_fetch(3 downto 0)), do=>hex0);
	h1 : entity work.decodeur_7_segments
	port map(di=>std_logic_vector(dbg_adr_fetch(7 downto 4)), do=>hex1);

	h2 : entity work.decodeur_7_segments
	port map(di=>std_logic_vector(dbg_adr_fetch(11 downto 8)), do=>hex2);
	h3 : entity work.decodeur_7_segments
	port map(di=>std_logic_vector(dbg_adr_fetch(15 downto 12)), do=>hex3);

	h4 : entity work.decodeur_7_segments
	port map(di=>std_logic_vector(dbg_track_dbl(4 downto 1)), do=>hex4);
	h5 : entity work.decodeur_7_segments
	port map(di=>std_logic_vector("00" & dbg_track_dbl(6 downto 5)), do=>hex5);

	h6 : entity work.decodeur_7_segments
	port map(di=>std_logic_vector(dbg_read_sector(3 downto 0)), do=>hex6);
	h7 : entity work.decodeur_7_segments
	port map(di=>std_logic_vector("000" & dbg_read_sector(4 downto 4)), do=>hex7);
end struct;
