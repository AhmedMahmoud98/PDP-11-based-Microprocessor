LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY general_purpose_registers IS
	GENERIC (bus_width : integer := 16;
			 selection_line_width: integer := 3);
	PORT(CLK, RST, in_enable, out_enable, PCin, PCout : IN std_logic;
		 out_selection_line, in_selection_line: IN std_logic_vector(selection_line_width-1 DOWNTO 0);
		 data_bus: INOUT std_logic_vector(bus_width-1 DOWNTO 0)
	);
END ENTITY general_purpose_registers;

ARCHITECTURE general_purpose_registers_arch OF general_purpose_registers IS
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
	out_decoder: decoder GENERIC MAP(selection_line_width => selection_line_width) PORT MAP(out_enable, out_selection_line, reg_out_enable);
	in_decoder: decoder GENERIC MAP(selection_line_width => selection_line_width) PORT MAP(in_enable, in_selection_line, reg_in_enable);

	registers_loop: FOR i IN (2**selection_line_width) - 2 DOWNTO 0 GENERATE
		rx: buffered_reg GENERIC MAP (size => bus_width) PORT MAP (CLK, RST, reg_in_enable(i), reg_out_enable(i), data_bus, data_bus);
	END GENERATE;
	r7: buffered_reg GENERIC MAP (size => bus_width) PORT MAP (CLK, RST, reg_in_enable(7) or PCin, reg_out_enable(7) or PCout, data_bus, data_bus);
END;