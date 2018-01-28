---------------------------------------------------------------------------------
-- ULX3S Top level for FPGA64_027 by Dar (darfpga@aol.fr)
-- http://github.com/emard
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

library ecp5u;
use ecp5u.components.all;

entity c64_ulx3s is
port(
  clk_25MHz: in std_logic;  -- main clock input from 25MHz clock source

  -- UART0 (FTDI USB slave serial)
  ftdi_rxd: out   std_logic;
  ftdi_txd: in    std_logic;
  -- FTDI additional signaling
  ftdi_ndsr: inout  std_logic;
  ftdi_nrts: inout  std_logic;
  ftdi_txden: inout std_logic;

  -- UART1 (WiFi serial)
  wifi_rxd: out   std_logic;
  wifi_txd: in    std_logic;
  -- WiFi additional signaling
  wifi_en: inout  std_logic := 'Z'; -- '0' will disable wifi by default
  wifi_gpio0, wifi_gpio2, wifi_gpio16, wifi_gpio17: inout std_logic := 'Z';

  -- ADC MAX11123
  adc_csn, adc_sclk, adc_mosi: out std_logic;
  adc_miso: in std_logic;

  -- SDRAM
  sdram_clk: out std_logic;
  sdram_cke: out std_logic;
  sdram_csn: out std_logic;
  sdram_rasn: out std_logic;
  sdram_casn: out std_logic;
  sdram_wen: out std_logic;
  sdram_a: out std_logic_vector (12 downto 0);
  sdram_ba: out std_logic_vector(1 downto 0);
  sdram_dqm: out std_logic_vector(1 downto 0);
  sdram_d: inout std_logic_vector (15 downto 0);

  -- Onboard blinky
  led: out std_logic_vector(7 downto 0);
  btn: in std_logic_vector(6 downto 0);
  sw: in std_logic_vector(3 downto 0);
  oled_csn, oled_clk, oled_mosi, oled_dc, oled_resn: out std_logic;

  -- GPIO
  gp, gn: inout std_logic_vector(27 downto 0);

  -- SHUTDOWN: logic '1' here will shutdown power on PCB >= v1.7.5
  shutdown: out std_logic := '0';

  -- Audio jack 3.5mm
  audio_l, audio_r, audio_v: inout std_logic_vector(3 downto 0) := (others => 'Z');

  -- Onboard antenna 433 MHz
  ant_433mhz: out std_logic;

  -- Digital Video (differential outputs)
  gpdi_dp, gpdi_dn: out std_logic_vector(2 downto 0);
  gpdi_clkp, gpdi_clkn: out std_logic;

  -- i2c shared for digital video and RTC
  gpdi_scl, gpdi_sda: inout std_logic;

  -- US2 port
  usb_fpga_dp, usb_fpga_dn: inout std_logic;

  -- Flash ROM (SPI0)
  -- commented out because it can't be used as GPIO
  -- when bitstream is loaded from config flash
  --flash_miso   : in      std_logic;
  --flash_mosi   : out     std_logic;
  --flash_clk    : out     std_logic;
  --flash_csn    : out     std_logic;

  -- SD card (SPI1)
  sd_dat3_csn, sd_cmd_di, sd_dat0_do, sd_dat1_irq, sd_dat2: inout std_logic;
  sd_clk: out std_logic;
  sd_cdn, sd_wp: in std_logic
	
);
end c64_ulx3s;

architecture struct of c64_ulx3s is

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

	alias ps2_clk : std_logic is usb_fpga_dp;
	alias ps2_dat : std_logic is usb_fpga_dn;

        signal mode_iec: std_logic := '0'; -- to DIP switch

-- DE1/DE2 numbering
	alias ext_iec_atn_i  : std_logic is gp(22);
	alias ext_iec_clk_o  : std_logic is gp(23);
	alias ext_iec_data_o : std_logic is gp(24);
	alias ext_iec_atn_o  : std_logic is gp(25);
	alias ext_iec_data_i : std_logic is gp(2);
	alias ext_iec_clk_i  : std_logic is gp(0);

-- DE0 nano numbering
--	alias iec_atn_i  : std_logic is gpio_0(30);
--	alias iec_clk_o  : std_logic is gpio_0(31);
--	alias iec_data_o : std_logic is gpio_0(32);
--	alias iec_atn_o  : std_logic is gpio_0(33);
--	alias iec_data_i : std_logic is gpio_0_in(1);
--	alias iec_clk_i  : std_logic is gpio_0_in(0);

	signal clk50 : std_logic;
	signal clk32 : std_logic;
	signal clk18 : std_logic;
	alias clk_pixel: std_logic is clk32;
	signal clk_pixel_shift, clkn_pixel_shift : std_logic;

	signal ram_addr : std_logic_vector(15 downto 0);
	signal uram_addr: unsigned(15 downto 0); -- TODO
	signal ram_dq, ram_in, ram_out : std_logic_vector(7 downto 0); -- dq is bidirectional
	signal uram_dq: unsigned(7 downto 0); -- TODO
	signal ram_cen : std_logic;
	signal ram_we, ram_wen : std_logic;
	
	signal r : unsigned(7 downto 0);
	signal g : unsigned(7 downto 0);
	signal b : unsigned(7 downto 0);
	signal hsync : std_logic;
	signal vsync : std_logic;
	signal csync : std_logic;
	signal vga_hs, vga_vs : std_logic;
	signal S_vga_r, S_vga_g, S_vga_b: std_logic_vector(1 downto 0);
	signal S_vga_vsync, S_vga_hsync: std_logic;
	signal S_vga_vblank, S_vga_blank: std_logic;
	signal ddr_d: std_logic_vector(2 downto 0);
	signal ddr_clk: std_logic;
	signal dvid_red, dvid_green, dvid_blue, dvid_clock: std_logic_vector(1 downto 0);

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
	
        signal disk_hi_num: std_logic_vector(1 downto 0) := "00"; -- to DIP switch
	signal disk_num         : std_logic_vector(7 downto 0);
	signal disk_num_full    : std_logic_vector(9 downto 0);
	signal dbg_num          : std_logic_vector(2 downto 0);
	signal led_disk         : std_logic_vector(7 downto 0);

	signal irq_n: std_logic := '1';
	signal nmi_n: std_logic := '1';

begin
	wifi_gpio0 <= '1'; -- setting to 0 will activate ESP32 loader

	tv15Khz_mode <= '0'; -- sw(0);
	ntsc_init_mode <= '1'; -- sw(1);

    clkgen_50: entity work.clk_25M_50M
    port map
    (
      clki => clk_25MHz,         --  25 MHz input from board
      clkop => clk50             --  50 MHz
    );

    clkgen_158_31_18: entity work.clk_25M_158M33_31M66_17M99
    port map
    (
      clki => clk_25MHz,         --  25 MHz input from board
      clkop => clk_pixel_shift,  -- 158.33 MHz
      clkos => clkn_pixel_shift, -- 158.33 MHz inverted
      clkos2 => clk32,           --  31.66 MHz
      clkos3 => clk18            --  17.99 MHz
    );
	
	process(clk32, btn(0))
	begin
		if rising_edge(clk32) then
			reset_n <= '0';
			if btn(0)='0' then
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
		sysclk => clk50,
		clk32 => clk32,
		reset_n => reset_n,
		kbd_clk => ps2_clk,
		kbd_dat => ps2_dat,
		ramAddr => uram_addr,
		ramData => uram_dq,
		ramCE => ram_cen,
		ramWe => ram_wen,
		tv15Khz_mode => tv15Khz_mode,
		ntscInitMode => ntsc_init_mode,
		hsync => hsync,
		vsync => vsync,
		blank => S_vga_blank,
		r => r,
		g => g,
		b => b,
		game => '1',
		exrom => '1',
		irq_n => irq_n,
		nmi_n => nmi_n,
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
	
	ram_addr <= std_logic_vector(uram_addr);
	ram_dq <= std_logic_vector(uram_dq);
	uram_dq <= unsigned(ram_dq);

	-- 
	c64_iec_atn_i  <= not ((not c64_iec_atn_o)  and (not c1541_iec_atn_o) ) or (ext_iec_atn_i  and mode_iec);
  	c64_iec_data_i <= not ((not c64_iec_data_o) and (not c1541_iec_data_o)) or (ext_iec_data_i and mode_iec);
	c64_iec_clk_i  <= not ((not c64_iec_clk_o)  and (not c1541_iec_clk_o) ) or (ext_iec_clk_i  and mode_iec);
	
	c1541_iec_atn_i  <= c64_iec_atn_i;
	c1541_iec_data_i <= c64_iec_data_i;
	c1541_iec_clk_i  <= c64_iec_clk_i;
	
	ext_iec_atn_o  <= c64_iec_atn_o   or c1541_iec_atn_o;
	ext_iec_data_o <= c64_iec_data_o  or c1541_iec_data_o;
	ext_iec_clk_o  <= c64_iec_clk_o   or c1541_iec_clk_o;
	
	disk_num_full <= (disk_hi_num & disk_num);

	c1541_sd : entity work.c1541_sd
	port map
	(
	clk32 => clk32,
	clk18 => clk18,
	reset => not reset_n,
	
	disk_num => disk_num_full,

	iec_atn_i  => c1541_iec_atn_i,
	iec_data_i => c1541_iec_data_i,
	iec_clk_i  => c1541_iec_clk_i,
	
	iec_atn_o  => c1541_iec_atn_o,
	iec_data_o => c1541_iec_data_o,
	iec_clk_o  => c1541_iec_clk_o,

	sd_dat  => sd_dat0_do,
	sd_dat3 => sd_dat3_csn,
	sd_cmd  => sd_cmd_di,
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
	
	--sram addr(17 downto 16) <= (others => '0');
	--sram_ce_n <= ram_ce;
	--sram_we_n <= ram_we;
	--sram_oe_n <= not ram_we;
	--sram_ub_n <= '0';
	--sram_lb_n <= '0';
	
	ram_we <= '1' when ram_cen='0' and ram_wen='0' else '0';
	ram_dq <= ram_out when ram_cen='0' and ram_wen='1' else (others => 'Z');
	I_ram64K: entity work.bram_true2p_1clk
	generic map(
	  dual_port => false,
	  data_width => 8,
	  addr_width => 16
	)
	port map(
	  clk => clk32,
	  addr_a => ram_addr,
	  we_a => ram_we,
	  data_in_a => ram_dq,
	  data_out_a => ram_out
	); 

	--vga_clk <= clk32;
	--vga_sync <=  '0';
	--vga_blank <= '1';

	--vga_r <= std_logic_vector(r(7 downto 0)) & "00";
	--vga_g <= std_logic_vector(g(7 downto 0)) & "00";
	--vga_b <= std_logic_vector(b(7 downto 0)) & "00";

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

	with dbg_num select
	led(7 downto 0) <= disk_num when "000",
					led_disk when "001",
					"00"&dbg_track_dbl(6 downto 1) when "010",
					"000"&dbg_read_sector when "011",
					dbg_sd_state when "100",
					X"AA" when others;
				 

	-- debug de2	
	--gpio_0(15 downto 0) <= dbg_adr_fetch(15 downto 0);
	--gpio_0(16) <= dbg_sync_n;
	--gpio_0(17) <= dbg_byte_n;
	--gpio_0(18) <= not c1541_iec_atn_i;
	--gpio_0(19) <= not c1541_iec_data_i;
	--gpio_0(20) <= not c1541_iec_clk_i;
	--gpio_0(21) <= not c1541_iec_data_o;
	--gpio_0(22) <= not c1541_iec_clk_o;
	--gpio_0(23) <= dbg_sd_busy;
	--gpio_0(24) <= dbg_cpu_irq;
	--gpio_0(32 downto 25) <= dbg_sd_state;
	--gpio_0(29 downto 25) <= dbg_read_sector;


	--h0 : entity work.decodeur_7_segments
	--port map(di=>std_logic_vector(dbg_adr_fetch(3 downto 0)), do=>hex0);
	--h1 : entity work.decodeur_7_segments
	--port map(di=>std_logic_vector(dbg_adr_fetch(7 downto 4)), do=>hex1);

	--h2 : entity work.decodeur_7_segments
	--port map(di=>std_logic_vector(dbg_adr_fetch(11 downto 8)), do=>hex2);
	--h3 : entity work.decodeur_7_segments
	--port map(di=>std_logic_vector(dbg_adr_fetch(15 downto 12)), do=>hex3);

	--h4 : entity work.decodeur_7_segments
	--port map(di=>std_logic_vector(dbg_track_dbl(4 downto 1)), do=>hex4);
	--h5 : entity work.decodeur_7_segments
	--port map(di=>std_logic_vector("00" & dbg_track_dbl(6 downto 5)), do=>hex5);

	--h6 : entity work.decodeur_7_segments
	--port map(di=>std_logic_vector(dbg_read_sector(3 downto 0)), do=>hex6);
	--h7 : entity work.decodeur_7_segments
	--port map(di=>std_logic_vector("000" & dbg_read_sector(4 downto 4)), do=>hex7);

  vga2dvi_converter: entity work.vga2dvid
  generic map
  (
      C_ddr     => true,
      C_depth   => 8 -- 8bpp (8 bit per pixel)
  )
  port map
  (
      clk_pixel => clk_pixel, -- 32 MHz
      clk_shift => clk_pixel_shift, -- 5*32 MHz

      in_red   => std_logic_vector(r),
      in_green => std_logic_vector(g),
      in_blue  => std_logic_vector(b),

      in_hsync => vga_hs,
      in_vsync => vga_vs,
      in_blank => S_vga_blank,

      -- single-ended output ready for differential buffers
      out_red   => dvid_red,
      out_green => dvid_green,
      out_blue  => dvid_blue,
      out_clock => dvid_clock
  );

  -- this module instantiates vendor specific modules ddr_out to
  -- convert SDR 2-bit input to DDR clocked 1-bit output (single-ended)
  G_vgatext_ddrout: entity work.ddr_dvid_out_se
  port map
  (
    clk       => clk_pixel_shift,
    clk_n     => clkn_pixel_shift,
    in_red    => dvid_red,
    in_green  => dvid_green,
    in_blue   => dvid_blue,
    in_clock  => dvid_clock,
    out_red   => ddr_d(2),
    out_green => ddr_d(1),
    out_blue  => ddr_d(0),
    out_clock => ddr_clk
  );

  gpdi_data_channels: for i in 0 to 2 generate
    gpdi_diff_data: OLVDS
    port map(A => ddr_d(i), Z => gpdi_dp(i), ZN => gpdi_dn(i));
  end generate;
  gpdi_diff_clock: OLVDS
  port map(A => ddr_clk, Z => gpdi_clkp, ZN => gpdi_clkn);

end struct;
