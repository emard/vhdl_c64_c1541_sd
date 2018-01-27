---------------------------------------------------------------------------------
-- DE0 nano Top level for FPGA64_027 by Dar (darfpga@aol.fr)
-- http://darfpga.blogspot.fr
--
-- FPGA64 is Copyrighted 2005-2008 by Peter Wendrich (pwsoft@syntiac.com)
-- http://www.syntiac.com/fpga64.html
--
-- Main features
--  15KHz(TV) / 31Khz(VGA) : board gpio_1_in(0)
--  PAL(50Hz) / NTSC(60Hz) : board gpio_1_in(1) and F12 key
--  PS2 keyboard input with portA / portB joystick emulation : F11 key
--  pwm sound output : board gpio_1(0 to 1) 
--  video output : board gpio_1(2 to 15) 2 Syncs + 3x4 Colors 
--  64Ko SRAM : board gpio_0(0 to 29)
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
-- DE1 and DE2-35 Top level also available
--     
---------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.all;

entity c64_de0_nano is
port(
	clock_50  : in std_logic;
	led       : out std_logic_vector(7 downto 0);
	key       : in std_logic_vector(1 downto 0);
--	sw        : in std_logic_vector(3 downto 0);

--	dram_ba : out std_logic_vector(1 downto 0);
--	dram_dqm : out std_logic_vector(1 downto 0);
--	dram_ras_n : out std_logic;
--	dram_cas_n : out std_logic;
--	dram_cke : out std_logic;
--	dram_clk : out std_logic;
--	dram_we_n : out std_logic;
--	dram_cs_n : out std_logic;
--	dram_dq : inout std_logic_vector(15 downto 0);
--	dram_addr : out std_logic_vector(12 downto 0);

--	epcs_data0 : inout std_logic_vector;
--	epcs_dclk  : inout std_logic_vector;
--	epcs_ncso  : out std_logic_vector;
--	epcs_asdo  : out std_logic_vector;

--	i2c_sclk : out std_logic;
--	i2c_sdat : inout std_logic;

--	g_sensor_cs_n : out std_logic;
--	g_sensor_int : in std_logic;

--	adc_cs_n : out std_logic;
--	adc_saddr : out std_logic;
--	adc_sclk : out std_logic;
--	adc_sdat : in std_logic;

--	gpio_2    : inout std_logic_vector(12 downto 0);
--	gpio_2_in : in std_logic_vector(2 downto 0);
	gpio_1    : inout std_logic_vector(33 downto 0);
	gpio_1_in : in std_logic_vector(1 downto 0);
	gpio_0    : inout std_logic_vector(33 downto 0);
	gpio_0_in : in std_logic_vector(1 downto 0)
);
end c64_de0_nano;

architecture struct of c64_de0_nano is

-- Previous hardware
--	alias vga_r : std_logic_vector is gpio_1( 7 downto  0);
--	alias vga_g : std_logic_vector is gpio_1(15 downto  8);
--	alias vga_b : std_logic_vector is gpio_1(25 downto 18);
--	alias vga_sync  : std_logic is gpio_1(17);
--	alias vga_blank : std_logic is gpio_1(16);
--	alias vga_clk   : std_logic is gpio_1(26);
--	alias vga_hs    : std_logic is gpio_1(27);
--	alias vga_vs    : std_logic is gpio_1(28);

	alias pwm_audio_out_l : std_logic is gpio_1(0);
	alias pwm_audio_out_r : std_logic is gpio_1(1);

	alias vga_vs : std_logic is gpio_1(2);
	alias vga_hs : std_logic is gpio_1(3);
	
	alias vga_r : std_logic_vector is gpio_1( 7 downto  4);
	alias vga_g : std_logic_vector is gpio_1(11 downto  8);
	alias vga_b : std_logic_vector is gpio_1(15 downto 12);

	--alias tv15Khz_mode : std_logic is gpio_1_in(0);
	signal tv15Khz_mode : std_logic;
	signal ntsc_init_mode : std_logic;
	
	alias ps2_dat : std_logic is gpio_1(32);
	alias ps2_clk : std_logic is gpio_1(33);
	
	alias sram_addr : unsigned is unsigned(gpio_0(18 downto 0));
	alias sram_ce_n : std_logic is gpio_0(19);
	alias sram_we_n : std_logic is gpio_0(20);
	alias sram_oe_n : std_logic is gpio_0(21);
	alias sram_dq   : unsigned is unsigned(gpio_0(29 downto 22));

	alias ext_iec_atn_i  : std_logic is gpio_0(30);
	alias ext_iec_clk_o  : std_logic is gpio_0(31);
	alias ext_iec_data_o : std_logic is gpio_0(32);
	alias ext_iec_atn_o  : std_logic is gpio_0(33);
	alias ext_iec_data_i : std_logic is gpio_0_in(1);
	alias ext_iec_clk_i  : std_logic is gpio_0_in(0);
	
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
	
  alias sd_dat3 : std_logic is gpio_1(16); --sd_dat3, --: out std_logic;     -- MMC chip select
  alias sd_cmd  : std_logic is gpio_1(17); --sd_cmd,  --: out std_logic;     -- Data to card (master out slave in)
  alias sd_dat  : std_logic is gpio_1(19); --sd_dat,  --: in  std_logic;     -- Data from card (master in slave out)
  alias sd_clk  : std_logic is gpio_1(18); --sd_clk,  --: out std_logic;     -- Card clock

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
	signal pwm_accumulator : std_logic_vector(8 downto 0);

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

	tv15Khz_mode <= gpio_1_in(0); --'1';
	ntsc_init_mode <= gpio_1_in(1);

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
		ramAddr => sram_addr(15 downto 0),
		ramData => sram_dq,
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
		iec_atn_o => c64_iec_atn_o,
		iec_clk_o => c64_iec_clk_o,
		iec_data_i => not c64_iec_data_i,
		iec_clk_i => not c64_iec_clk_i,
		iec_atn_i => not c64_iec_atn_i,
		disk_num => disk_num,
	  dbg_num => dbg_num

	);

		-- 
  c64_iec_atn_i  <= not ((not c64_iec_atn_o)  and (not c1541_iec_atn_o) ) or (ext_iec_atn_i  );
  c64_iec_data_i <= not ((not c64_iec_data_o) and (not c1541_iec_data_o)) or (ext_iec_data_i );
	c64_iec_clk_i  <= not ((not c64_iec_clk_o)  and (not c1541_iec_clk_o) ) or (ext_iec_clk_i  );
	
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
	
	disk_num => ("00" & disk_num),

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

	sram_addr(18 downto 16) <= (others => '0');
	sram_ce_n <= ram_ce;
	sram_we_n <= ram_we;
	sram_oe_n <= not ram_we;

	vga_r <= std_logic_vector(r(7 downto 4));-- when blank = '0' else (others => '0');
	vga_g <= std_logic_vector(g(7 downto 4));-- when blank = '0' else (others => '0');
	vga_b <= std_logic_vector(b(7 downto 4));-- when blank = '0' else (others => '0');

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


	process(clk18)
	variable count  : std_logic_vector(4 downto 0) := (others => '0');
	begin
		if rising_edge(clk18) then
			if count = "01000" then
				count := (others => '0');
				pwm_accumulator  <=  std_logic_vector(unsigned("0" & pwm_accumulator(7 downto 0)) + unsigned("00"&audio_data(17 downto 12)));
			else
				count := std_logic_vector(unsigned(count)+1);
			end if;
		end if;
	end process;
	
  pwm_audio_out_l <= pwm_accumulator(8);
  pwm_audio_out_r <= pwm_accumulator(8);

	with dbg_num select
	led <= disk_num when "000",
	       led_disk when "001",
				 "00"&dbg_track_dbl(6 downto 1) when "010",
				 "000"&dbg_read_sector when "011",
				 dbg_sd_state when "100",
				 X"AA" when others;
				 

end struct;
