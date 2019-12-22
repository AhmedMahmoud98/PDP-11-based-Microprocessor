LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
USE WORK.bus_array_pkg.all;
use STD.TEXTIO.all;


ENTITY RAM IS
	GENERIC (word_size : integer := 16;
	         address_width: integer := 16;
		 RAM_size: integer := 10);
	PORT(	
		CLK, WR  : IN std_logic;
		address : IN  std_logic_vector(address_width - 1 DOWNTO 0);
		data_in  : IN  std_logic_vector(word_size - 1 DOWNTO 0);
		data_out : OUT std_logic_vector(word_size - 1 DOWNTO 0));
END ENTITY RAM;

ARCHITECTURE RAM_arch OF RAM IS
-------------------------------------------------------------------------------------------------------------------
	-- Initialise the RAM from text file 	
	SUBTYPE function_output is bus_array(RAM_size - 1 DOWNTO 0)(word_size - 1 DOWNTO 0);
  	IMPURE FUNCTION init_RAM RETURN function_output is
		VARIABLE RAM_content : bus_array(RAM_size - 1 DOWNTO 0)(word_size - 1 DOWNTO 0);
		VARIABLE text_line : line;
		VARIABLE count: integer;
		File RAM_file: TEXT open READ_MODE is "Ram.txt";
	BEGIN
		 count := 0;
  		 WHILE not ENDFILE(RAM_file) LOOP
     			readline(RAM_file, text_line);
     			bread(text_line, RAM_content(count));
			count := count + 1;
  		 END LOOP;
		 file_close(RAM_file);
  		 RETURN RAM_content;
	END FUNCTION init_RAM;
-------------------------------------------------------------------------------------------------------------------
SIGNAL RAM_data : bus_array(0 TO RAM_size - 1)(word_size - 1 DOWNTO 0) := init_RAM;
BEGIN
PROCESS(CLK) IS
	BEGIN
	IF rising_edge(CLK) THEN  
		IF WR = '1' THEN
			RAM_data(to_integer(unsigned(address))) <= data_in;
		END IF;
	END IF;
END PROCESS;		
	data_out <= RAM_data(to_integer(unsigned(address)));
END RAM_arch;
