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
		writer_indicator : IN std_logic;
		address : IN  std_logic_vector(address_width - 1 DOWNTO 0);
		data_in  : IN  std_logic_vector(word_size - 1 DOWNTO 0);
		data_out : OUT std_logic_vector(word_size - 1 DOWNTO 0));
		
END ENTITY RAM;

ARCHITECTURE RAM_arch OF RAM IS
-------------------------------------------------------------------------------------------------------------------
	-- Initialise the RAM from text file 	
	SUBTYPE function_type is bus_array(0 TO RAM_size - 1)(word_size - 1 DOWNTO 0);
  	IMPURE FUNCTION init_RAM RETURN function_type IS
		VARIABLE RAM_content : bus_array(0 TO RAM_size - 1)(word_size - 1 DOWNTO 0);
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
	-- Write the RAM to text file 	
  	IMPURE FUNCTION write_RAM (RAM_content : function_type ) RETURN INTEGER IS 
		VARIABLE DUMMY: INTEGER;
		VARIABLE text_line: LINE;
		CONSTANT Space : String(0 to 3) := "    ";
		CONSTANT Space2 : String(0 to 9) := "          ";
		CONSTANT Hex : String(0 to 2) := "Hex";
		CONSTANT Binary : String(0 to 5) := "Binary";
		CONSTANT Dec : String(0 to 6) := "Decimal";
		CONSTANT Addrs : String(0 to 4) := "Addr.";
		File RAM_file: TEXT open WRITE_MODE is "Ram_output.txt";
	BEGIN
		 DUMMY := 1;
		 WRITE(text_line, Addrs);
		 WRITE(text_line, Space);
		 WRITE(text_line, Binary);
		 WRITE(text_line, Space2);
		 WRITE(text_line, Hex);
		 WRITE(text_line, Space);
		 WRITE(text_line, Dec);
    		 WRITELINE(RAM_file, text_line);
		 FOR i IN 0 TO RAM_size - 1 LOOP
			WRITE(text_line, i);
			WRITE(text_line, Space);
			WRITE(text_line, RAM_content(i));
			WRITE(text_line, Space);
			WRITE(text_line, to_hex_string(RAM_content(i)));
			WRITE(text_line, Space);
			WRITE(text_line, to_integer(unsigned(RAM_content(i))));
    			WRITELINE(RAM_file, text_line);
  		 END LOOP;
		 file_close(RAM_file);
  		 RETURN DUMMY;
	END FUNCTION write_RAM;
-------------------------------------------------------------------------------------------------------------------
SIGNAL RAM_data : bus_array(0 TO RAM_size - 1)(word_size - 1 DOWNTO 0) := init_RAM;
SIGNAL DUMMY: integer := 0;
BEGIN
PROCESS(CLK, writer_indicator) IS
	BEGIN
	IF rising_edge(CLK) THEN  
		IF WR = '1' THEN
			RAM_data(to_integer(unsigned(address))) <= data_in;
		END IF;
	END IF;
	IF writer_indicator = '1' AND DUMMY = 0 THEN
		DUMMY <= write_RAM(RAM_content => RAM_data);
	END IF;
END PROCESS;		
	data_out <= RAM_data(to_integer(unsigned(address)));
END RAM_arch;
