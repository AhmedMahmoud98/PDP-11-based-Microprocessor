LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

-- Control Store Data
ENTITY ROM IS
	PORT(   
                address : IN  std_logic_vector(4 DOWNTO 0);
		micro_instruction : OUT std_logic_vector(19 DOWNTO 0)
	    );
END ENTITY ROM;

ARCHITECTURE ROM_arch OF ROM IS
TYPE ROM_memory IS ARRAY ( 0 to 2**5 - 1) of std_logic_vector(19 downto 0);
  CONSTANT ROM_data : ROM_memory := (
    		0  => "11000010011010111100",
		1  => "01011110011010000000",
		2  => "01010110011111000111",
		3  => "00110110000010000000",
		4  => "10110110100011111111",
		5  => "00000000011001111111",
		6  => "00111110010110111111",
		7  => "01000110001011111111",
		8  => "01001110100111001011",
		9  => "11000001010010111100",
		10 => "11000001010010011100",
		11 => "11000001010111011111",
		12 => "10010110101111011111",
		13 => "01110110000011111111",
		14 => "01111110110111001011",
		15 => "10010110010110111111",
		16 => "10010110010111011111",
		17 => "10010110010100111101",
		18 => "10011110000010000000",
		19 => "10100110010110111111",
		20 => "00000101001101111111",
		21 => "00000000111111111110",
		22 => "10000100101111001111",
		23 => "00000111111111111111",
		24 => "10110110001011111111",
		25 => "11000011001010111100",
		26 => "10010110101100111101",
		27 => "11010110001010111111",
		28 => "00000000001001111111",
		29 => "00000111111111111111",
		30 => "00000111111111111111",
		31 => "00000111111111111111"
			);

BEGIN
	micro_instruction <= ROM_data(to_integer(unsigned(address)));
END ROM_arch;

