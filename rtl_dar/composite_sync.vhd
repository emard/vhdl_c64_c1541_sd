---------------------------------------------------------------------------------
-- composite_sync by Dar (darfpga@aol.fr)
-- http://darfpga.blogspot.fr
--
-- Generate composite sync and blank for tv mode from h/v syncs
--
---------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity composite_sync is
port(
	clk32 : in std_logic;
	hsync : in std_logic;
	vsync : in std_logic;
	csync : out std_logic;
	blank : out std_logic
);
end composite_sync ;

architecture struct of composite_sync is

	signal clk_cnt : std_logic_vector(1 downto 0);
	signal dot_clk : std_logic;
	signal vsync_r : std_logic;
	signal hsync_r : std_logic;
	signal hsync_r0 : std_logic;
	signal hsync0 : std_logic;
	signal hsync1 : std_logic;
	signal hsync2 : std_logic;
	signal vblank : std_logic;
	signal hblank : std_logic;

begin

blank <= vblank or hblank;

process(clk32)
	begin
	if rising_edge(clk32) then
		hsync_r0 <= hsync;
		if hsync_r0 = '0' and hsync = '1' then
			clk_cnt <= "00";
		else
			clk_cnt <= clk_cnt + '1';
		end if;
	end if;
end process;

dot_clk <= clk_cnt(1);

process(dot_clk)
	variable dot_count : integer range 0 to 1023 := 0;
	variable line_count : integer range 0 to 511 := 0;
	begin
	if rising_edge(dot_clk) then
		vsync_r <= vsync;
		hsync_r <= hsync;
	
		if vsync_r = '0' and vsync = '1' then
		  line_count := 0;
		end if;
		
		if hsync_r = '0' and hsync = '1' then
			dot_count := 0;
			line_count := line_count + 1;
		else
			dot_count := dot_count + 1;
		end if;

--TEST NTSC (seems to be ok for PAL also)

		if    dot_count = (000)    then hsync0 <= '0';
		elsif dot_count = (000+38) then hsync0 <= '1';
		end if;

		if    dot_count = (000)    then hsync1 <= '0';
		elsif dot_count = (000+18) then hsync1 <= '1';
		elsif dot_count = (256)    then hsync1 <= '0';
		elsif dot_count = (256+18) then hsync1 <= '1';
		end if;
		
		if    dot_count = (000)       then hsync2 <= '0';
		elsif dot_count = (256-38)    then hsync2 <= '1';
		elsif dot_count = (256   )    then hsync2 <= '0';
		elsif dot_count = (512-38)    then hsync2 <= '1';
		end if;

		if     line_count = 001 then csync <= hsync1;
		elsif  line_count = 002 then csync <= hsync1;
		elsif  line_count = 003 then csync <= hsync1;
		elsif  line_count = 004 then csync <= hsync1;
		elsif  line_count = 005 then csync <= hsync2;
		elsif  line_count = 006 then csync <= hsync2;
		elsif  line_count = 007 then csync <= hsync2;
		elsif  line_count = 008 then csync <= hsync1;
		elsif  line_count = 009 then csync <= hsync1;
		elsif  line_count = 010 then csync <= hsync1;
		elsif  line_count = 011 then csync <= hsync0;
		else                         csync <= hsync0;
		end if;

-- PAL (seem not correct for NSTC)
--
--		if    dot_count = (000+ 1) then hsync0 <= '0';
--		elsif dot_count = (000+38) then hsync0 <= '1';
--		end if;
--
--		if    dot_count = (000)        then hsync1 <= '0';
--		elsif dot_count = (000+14)     then hsync1 <= '1';
--		elsif dot_count = (000   +260) then hsync1 <= '0';
--		elsif dot_count = (000+14+260) then hsync1 <= '1';
--		end if;

--		if    dot_count = (503-14)    then hsync2 <= '0';
--		elsif dot_count = (503   )    then hsync2 <= '1';
--		end if;

--		if     line_count = 001 then csync <= hsync1;
--		elsif  line_count = 002 then csync <= hsync1;
--		elsif  line_count = 003 then csync <= hsync1 and hsync2;
--		elsif  line_count = 004 then csync <= not(hsync1);
--		elsif  line_count = 005 then csync <= not(hsync1);
--		elsif  line_count = 006 then csync <= not(hsync1) or not(hsync2);
--		elsif  line_count = 007 then csync <= hsync1;
--		elsif  line_count = 008 then csync <= hsync1;
--		elsif  line_count = 009 then csync <= hsync1;
--		elsif  line_count = 010 then csync <= hsync0;
--		elsif  line_count = 011 then csync <= hsync0;
--		else                         csync <= hsync0;
--		end if;


		if    line_count = 20  then vblank <= '0';
		elsif line_count = 250 then vblank <= '1';
		end if;
		
		if    dot_count = 100  then hblank <= '0';
		elsif dot_count = 500 then hblank <= '1';
		end if;

	end if;
end process;



end architecture;