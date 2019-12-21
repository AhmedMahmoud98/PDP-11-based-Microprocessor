LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE work.bus_array_pkg.all;

ENTITY special_purpose_registers IS
	GENERIC (bus_width : integer := 16;
			 flags: integer := 5);
	PORT(CLK, RST, MDRin, MDRout, MARin, Rd, PCin, PCout, IRin, IRout : IN std_logic;
		 memory_data_in: IN std_logic_vector(bus_width-1 DOWNTO 0);
		 flag_register_data_in: IN std_logic_vector(flags-1 DOWNTO 0);
		 data_bus: INOUT std_logic_vector(bus_width-1 DOWNTO 0);
		 memory_address_out, memory_data_out, IR_data:  OUT std_logic_vector(bus_width-1 DOWNTO 0);
		 zero_flag, carry_flag: OUT std_logic
	);
END ENTITY special_purpose_registers;

ARCHITECTURE special_purpose_registers_arch OF special_purpose_registers IS
	COMPONENT buffered_reg IS
		GENERIC (size : integer := 16);
		PORT(CLK, RST, in_enable, out_enable : IN std_logic;
			 D : IN std_logic_vector(size-1 DOWNTO 0);
			 Q : OUT std_logic_vector(size-1 DOWNTO 0));
	END COMPONENT;
	
	COMPONENT reg IS
		GENERIC (size : integer := 16);
		PORT(CLK, RST, enable : IN std_logic;
			 D : IN std_logic_vector(size-1 DOWNTO 0);
			 Q : OUT std_logic_vector(size-1 DOWNTO 0));
	END COMPONENT;
	
	COMPONENT mux IS
		GENERIC (selection_line_width : integer := 2;
				 bus_width: integer := 16);
		PORT (enable : IN std_logic;
			  selection_lines : IN std_logic_vector(selection_line_width - 1 DOWNTO 0);
			  input: IN bus_array((2 ** selection_line_width) - 1 DOWNTO 0)(bus_width - 1 DOWNTO 0);
			  output: OUT std_logic_vector(bus_width-1 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT tristate IS
		GENERIC(bus_width: integer := 16);
		PORT(enable: IN std_logic;
			 input: IN std_logic_vector(bus_width-1 DOWNTO 0);
			 output: OUT std_logic_vector(bus_width-1 DOWNTO 0)
		);
	END COMPONENT;

	SIGNAL MDR_data_in: std_logic_vector(bus_width-1 DOWNTO 0);
	SIGNAL MDR_in_enable: std_logic;
	SIGNAL MDR_input_mux_input: bus_array(1 DOWNTO 0)(bus_width-1 DOWNTO 0);
	SIGNAL MDR_input_mux_select: std_logic_vector(0 DOWNTO 0);
	SIGNAL IR_address_out : std_logic_vector(bus_width-1 DOWNTO 0);
	SIGNAL flag_register_data_out : std_logic_vector(flags-1 DOWNTO 0);
BEGIN
	-- Setting up MDR input MUX to choose between data coming from the bus and data coming from memory (or neither)
	MDR_in_enable <= MDRin or Rd;
	MDR_input_mux_input(0) <= memory_data_in;
	MDR_input_mux_input(1) <= data_bus;
	MDR_input_mux_select(0) <= MDRin;
	-- MDR
	MDR_input_MUX: mux GENERIC MAP(selection_line_width => 1, bus_width => bus_width) 
					   PORT MAP (MDR_in_enable, MDR_input_mux_select, MDR_input_mux_input, MDR_data_in); 
	MDR: reg GENERIC MAP (size => bus_width) PORT MAP (CLK, RST, MDR_in_enable, MDR_data_in, memory_data_out);
	MDR_out_buffer: tristate GENERIC MAP (bus_width =>bus_width) PORT MAP (MDRout, memory_data_out, data_bus);
	-- MAR
	MAR: reg GENERIC MAP(size => bus_width) PORT MAP (CLK, RST, MARin, data_bus, memory_address_out);
	-- PC
	PC: buffered_reg GENERIC MAP (size => bus_width) PORT MAP (CLK, RST, PCin, PCout, data_bus, data_bus);
	-- IR 
	IR: reg GENERIC MAP (size => bus_width) PORT MAP (CLK, RST, IRin, data_bus, IR_data);
	-- IR Address Out
	IR_address_out((bus_width/2)-1 DOWNTO 0) <= IR_data((bus_width/2)-1 DOWNTO 0);
	IR_address_out(bus_width-1 DOWNTO bus_width/2) <= (OTHERS => '0');
	IR_address_out_buffer: tristate GENERIC MAP (bus_width => bus_width) PORT MAP (IRout, IR_address_out, data_bus);
	-- Flag Register
	FR: reg GENERIC MAP (size => flags) PORT MAP (CLK, RST, '1', flag_register_data_in, flag_register_data_out); 
	zero_flag <= flag_register_data_out(2);
	carry_flag <= flag_register_data_out(0);
END;