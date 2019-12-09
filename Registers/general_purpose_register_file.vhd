LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY general_purpose_registers IS
	GENERIC (bus_width : integer := 16;
			 selection_line_width: integer := 3);
	PORT(CLK, RST, SRC_enable, DST_enable : IN std_logic;
		 SRC_selection_line, DST_selection_line: IN std_logic_vector(selection_line_width-1 DOWNTO 0);
		 data_bus: INOUT std_logic_vector(bus_width-1 DOWNTO 0)
	);
END ENTITY general_purpose_registers;

ARCHITECTURE general_purpose_registers OF general_purpose_registers IS
	COMPONENT buffered_reg IS
		GENERIC (size : integer := 16);
		PORT(CLK, RST, in_enable, out_enable : IN std_logic;
			 D : IN std_logic_vector(size-1 DOWNTO 0);
			 Q : OUT std_logic_vector(size-1 DOWNTO 0));
    END COMPONENT;
	
	COMPONENT decoder IS
		GENERIC (selection_line_width : integer := 2);
		PORT(	
			enable           : IN std_logic;
			selection_lines  : IN std_logic_vector(selection_line_width - 1 DOWNTO 0);
			output           : OUT std_logic_vector((2 ** selection_line_width) - 1 DOWNTO 0)
			);
	END COMPONENT;
	
	SIGNAL reg_in_enable, reg_out_enable: std_logic_vector((2 ** selection_line_width) - 1 DOWNTO 0);
BEGIN
	SRC_decoder: decoder GENERIC MAP(selection_line_width => selection_line_width) PORT MAP(SRC_enable, SRC_selection_line, reg_out_enable);
	DST_decoder: decoder GENERIC MAP(selection_line_width => selection_line_width) PORT MAP(DST_enable, DST_selection_line, reg_in_enable);

	registers_loop: FOR i IN (2**selection_line_width) - 1 DOWNTO 0 GENERATE
		rx: buffered_reg GENERIC MAP (size => bus_width) PORT MAP (CLK, RST, reg_in_enable(i), reg_out_enable(i), data_bus, data_bus);
	END GENERATE;
END;