library IEEE;
use IEEE.std_logic_1164.all,IEEE.NUMERIC_STD.ALL;


entity decodeur_7_segments is
port(
  di : in std_logic_vector(3 downto 0);
  do : out std_logic_vector(6 downto 0)
);
end decodeur_7_segments;

architecture struct of decodeur_7_segments is

begin

with di select
  do <=
    "1000000" when "0000",
    "1111001" when "0001",
    "0100100" when "0010",
    "0110000" when "0011",
    "0011001" when "0100",
    "0010010" when "0101",
    "0000010" when "0110",
    "1111000" when "0111",
    "0000000" when "1000",
    "0010000" when "1001",
    "0001000" when "1010",
    "0000011" when "1011",
    "1000110" when "1100",
    "0100001" when "1101",
    "0000110" when "1110",
    "0001110" when "1111";

end architecture;