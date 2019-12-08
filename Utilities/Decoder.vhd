LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.math_real.all;
USE ieee.numeric_std.all;

-- Generic decoder that can be used for any number of selection lines
ENTITY decoder IS
	GENERIC (selection_line_width : integer := 2);

	PORT(	
		enable           : IN std_logic;
	     	selection_lines  : IN std_logic_vector(selection_line_width - 1 DOWNTO 0);
            	output           : OUT std_logic_vector((2 ** selection_line_width) - 1 DOWNTO 0)
	    );

END ENTITY decoder;

ARCHITECTURE decoder_arch of decoder IS
BEGIN
	output <= (to_integer(unsigned(selection_lines))=> '1', others=>'0'); -- The selection lines are the index of the output bit that should be set.

END decoder_arch;
